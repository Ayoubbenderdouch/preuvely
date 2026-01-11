package com.preuvely.app.ui.screens.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.repository.AuthRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

enum class AuthMode {
    LOGIN, REGISTER
}

data class AuthUiState(
    val mode: AuthMode = AuthMode.LOGIN,
    val email: String = "",
    val password: String = "",
    val confirmPassword: String = "",
    val name: String = "",
    val phone: String = "",
    val isLoading: Boolean = false,
    val error: String? = null,
    val passwordsMatch: Boolean = true
)

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    fun setMode(mode: AuthMode) {
        _uiState.value = _uiState.value.copy(mode = mode, error = null)
    }

    fun setEmail(email: String) {
        _uiState.value = _uiState.value.copy(email = email, error = null)
    }

    fun setPassword(password: String) {
        _uiState.value = _uiState.value.copy(password = password, error = null)
        validatePasswords()
    }

    fun setConfirmPassword(confirmPassword: String) {
        _uiState.value = _uiState.value.copy(confirmPassword = confirmPassword, error = null)
        validatePasswords()
    }

    fun setName(name: String) {
        _uiState.value = _uiState.value.copy(name = name, error = null)
    }

    fun setPhone(phone: String) {
        _uiState.value = _uiState.value.copy(phone = phone, error = null)
    }

    fun setError(error: String?) {
        _uiState.value = _uiState.value.copy(error = error)
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(error = null)
    }

    private fun validatePasswords() {
        if (_uiState.value.mode == AuthMode.REGISTER) {
            val match = _uiState.value.password == _uiState.value.confirmPassword ||
                    _uiState.value.confirmPassword.isEmpty()
            _uiState.value = _uiState.value.copy(passwordsMatch = match)
        }
    }

    fun login(onSuccess: () -> Unit) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)

            val result = authRepository.login(
                email = _uiState.value.email.takeIf { it.isNotBlank() },
                phone = null,
                password = _uiState.value.password
            )

            when (result) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(isLoading = false)
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = result.message
                    )
                }
                else -> {}
            }
        }
    }

    fun register(onSuccess: () -> Unit) {
        if (!_uiState.value.passwordsMatch) {
            _uiState.value = _uiState.value.copy(error = "Passwords do not match")
            return
        }

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)

            val result = authRepository.register(
                name = _uiState.value.name,
                email = _uiState.value.email.takeIf { it.isNotBlank() },
                phone = _uiState.value.phone.takeIf { it.isNotBlank() },
                password = _uiState.value.password
            )

            when (result) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(isLoading = false)
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = result.message
                    )
                }
                else -> {}
            }
        }
    }

    fun socialAuth(provider: String, idToken: String, onSuccess: () -> Unit) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)

            val result = authRepository.socialAuth(provider, idToken)

            when (result) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(isLoading = false)
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        error = result.message
                    )
                }
                else -> {}
            }
        }
    }

    val isLoginFormValid: Boolean
        get() = _uiState.value.email.isNotBlank() && _uiState.value.password.length >= 6

    val isRegisterFormValid: Boolean
        get() = _uiState.value.name.isNotBlank() &&
                _uiState.value.email.isNotBlank() &&
                _uiState.value.password.length >= 8 &&
                _uiState.value.passwordsMatch
}
