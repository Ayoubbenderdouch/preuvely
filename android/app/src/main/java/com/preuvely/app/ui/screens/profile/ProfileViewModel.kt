package com.preuvely.app.ui.screens.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.Claim
import com.preuvely.app.data.models.Review
import com.preuvely.app.data.models.User
import com.preuvely.app.data.repository.AuthRepository
import com.preuvely.app.data.repository.ReviewRepository
import com.preuvely.app.data.repository.UserRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class ProfileUiState(
    val user: User? = null,
    val isAuthenticated: Boolean = false,
    val reviews: List<Review> = emptyList(),
    val claims: List<Claim> = emptyList(),
    val isLoading: Boolean = false,
    val isLoadingReviews: Boolean = false,
    val isLoadingClaims: Boolean = false,
    val error: String? = null,
    val isResendingEmail: Boolean = false,
    val emailResent: Boolean = false,
    val showEmailVerificationSheet: Boolean = false,
    val emailVerificationState: EmailVerificationUiState = EmailVerificationUiState()
)

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val authRepository: AuthRepository,
    private val reviewRepository: ReviewRepository,
    private val userRepository: UserRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(ProfileUiState())
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    private var cooldownJob: Job? = null

    init {
        observeUser()
    }

    private fun observeUser() {
        viewModelScope.launch {
            authRepository.currentUser.collect { user ->
                _uiState.value = _uiState.value.copy(
                    user = user,
                    isAuthenticated = user != null
                )
                if (user != null) {
                    loadUserData()
                }
            }
        }
    }

    fun loadUserData() {
        loadReviews()
        loadClaims()
    }

    private fun loadReviews() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingReviews = true)

            when (val result = reviewRepository.getMyReviews()) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        reviews = result.data.data.take(3),
                        isLoadingReviews = false
                    )
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(isLoadingReviews = false)
                }
                else -> {}
            }
        }
    }

    private fun loadClaims() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingClaims = true)

            when (val result = userRepository.getMyClaims()) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        claims = result.data.take(3),
                        isLoadingClaims = false
                    )
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(isLoadingClaims = false)
                }
                else -> {}
            }
        }
    }

    fun resendVerificationEmail() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isResendingEmail = true)

            when (authRepository.resendVerificationEmail()) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isResendingEmail = false,
                        emailResent = true
                    )
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(isResendingEmail = false)
                }
                else -> {}
            }
        }
    }

    fun logout(onComplete: () -> Unit) {
        viewModelScope.launch {
            // Clear local state first to prevent any further API calls
            _uiState.value = ProfileUiState(
                user = null,
                isAuthenticated = false,
                reviews = emptyList(),
                claims = emptyList(),
                isLoading = false,
                isLoadingReviews = false,
                isLoadingClaims = false,
                error = null,
                isResendingEmail = false,
                emailResent = false
            )

            try {
                authRepository.logout()
            } catch (e: Exception) {
                // Ignore logout errors - user is already logged out locally
                android.util.Log.d("ProfileViewModel", "[Logout] Server logout failed: ${e.message}")
            }

            onComplete()
        }
    }

    fun refreshUser() {
        viewModelScope.launch {
            authRepository.getCurrentUser()
        }
    }

    // Email Verification Sheet methods

    fun showEmailVerificationSheet() {
        _uiState.value = _uiState.value.copy(
            showEmailVerificationSheet = true,
            emailVerificationState = EmailVerificationUiState()
        )
    }

    fun hideEmailVerificationSheet() {
        cooldownJob?.cancel()
        _uiState.value = _uiState.value.copy(
            showEmailVerificationSheet = false,
            emailVerificationState = EmailVerificationUiState()
        )
    }

    fun updateVerificationDigits(digits: List<String>) {
        _uiState.value = _uiState.value.copy(
            emailVerificationState = _uiState.value.emailVerificationState.copy(
                digits = digits,
                errorMessage = null // Clear error when user starts typing
            )
        )
    }

    fun verifyEmailCode(code: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                emailVerificationState = _uiState.value.emailVerificationState.copy(
                    isLoading = true,
                    errorMessage = null
                )
            )

            when (val result = authRepository.verifyEmailWithCode(code)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        emailVerificationState = _uiState.value.emailVerificationState.copy(
                            isLoading = false,
                            isVerified = true
                        ),
                        showEmailVerificationSheet = false
                    )
                    // Refresh user data to update email verified status
                    refreshUser()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        emailVerificationState = _uiState.value.emailVerificationState.copy(
                            isLoading = false,
                            errorMessage = result.message,
                            digits = List(6) { "" } // Clear digits on error
                        )
                    )
                }
                else -> {}
            }
        }
    }

    fun resendVerificationCode() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                emailVerificationState = _uiState.value.emailVerificationState.copy(
                    isResending = true,
                    errorMessage = null
                )
            )

            when (authRepository.resendVerificationEmail()) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        emailVerificationState = _uiState.value.emailVerificationState.copy(
                            isResending = false
                        )
                    )
                    startResendCooldown()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        emailVerificationState = _uiState.value.emailVerificationState.copy(
                            isResending = false,
                            errorMessage = "Failed to resend code. Please try again."
                        )
                    )
                }
                else -> {}
            }
        }
    }

    private fun startResendCooldown() {
        cooldownJob?.cancel()
        cooldownJob = viewModelScope.launch {
            for (i in 60 downTo 0) {
                _uiState.value = _uiState.value.copy(
                    emailVerificationState = _uiState.value.emailVerificationState.copy(
                        resendCooldown = i
                    )
                )
                delay(1000)
            }
        }
    }
}
