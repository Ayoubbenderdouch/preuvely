package com.preuvely.app.ui.screens.user

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.Review
import com.preuvely.app.data.models.UserProfile
import com.preuvely.app.data.repository.UserRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class UserProfileUiState(
    val user: UserProfile? = null,
    val reviews: List<Review> = emptyList(),
    val isLoading: Boolean = false,
    val isLoadingMore: Boolean = false,
    val hasMoreReviews: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class UserProfileViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val userRepository: UserRepository
) : ViewModel() {

    private val userId: Int = savedStateHandle.get<Int>("userId") ?: 0

    private val _uiState = MutableStateFlow(UserProfileUiState())
    val uiState: StateFlow<UserProfileUiState> = _uiState.asStateFlow()

    private var currentPage = 1
    private val perPage = 15

    init {
        loadUserProfile()
    }

    private fun loadUserProfile() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)

            val userDeferred = async { userRepository.getUserProfile(userId) }
            val reviewsDeferred = async { userRepository.getUserReviews(userId, 1, perPage) }

            val userResult = userDeferred.await()
            val reviewsResult = reviewsDeferred.await()

            when (userResult) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        user = userResult.data,
                        reviews = (reviewsResult as? Result.Success)?.data?.data ?: emptyList(),
                        hasMoreReviews = (reviewsResult as? Result.Success)?.data?.meta?.hasNextPage ?: false,
                        isLoading = false
                    )
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        error = userResult.message,
                        isLoading = false
                    )
                }
                else -> {}
            }
        }
    }

    fun loadMoreReviews() {
        if (_uiState.value.isLoadingMore || !_uiState.value.hasMoreReviews) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingMore = true)
            currentPage++

            when (val result = userRepository.getUserReviews(userId, currentPage, perPage)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        reviews = _uiState.value.reviews + result.data.data,
                        hasMoreReviews = result.data.meta?.hasNextPage ?: false,
                        isLoadingMore = false
                    )
                }
                is Result.Error -> {
                    currentPage--
                    _uiState.value = _uiState.value.copy(isLoadingMore = false)
                }
                else -> {}
            }
        }
    }

    fun refresh() {
        currentPage = 1
        loadUserProfile()
    }
}
