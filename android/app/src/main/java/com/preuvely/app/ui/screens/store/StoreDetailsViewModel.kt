package com.preuvely.app.ui.screens.store

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.*
import com.preuvely.app.data.repository.ReviewRepository
import com.preuvely.app.data.repository.StoreRepository
import com.preuvely.app.data.repository.UserRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class StoreDetailsUiState(
    val store: Store? = null,
    val summary: StoreSummary? = null,
    val reviews: List<Review> = emptyList(),
    val userReview: Review? = null,
    val isLoading: Boolean = false,
    val isLoadingReviews: Boolean = false,
    val isLoadingMore: Boolean = false,
    val isSubmittingReview: Boolean = false,
    val isSubmittingClaim: Boolean = false,
    val isSubmittingReport: Boolean = false,
    val isSubmittingReply: Boolean = false,
    val isUpdatingStore: Boolean = false,
    val hasMoreReviews: Boolean = false,
    val error: String? = null,
    val reviewSubmitted: Boolean = false
)

@HiltViewModel
class StoreDetailsViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val storeRepository: StoreRepository,
    private val reviewRepository: ReviewRepository,
    private val userRepository: UserRepository
) : ViewModel() {

    private val slug: String = savedStateHandle.get<String>("slug") ?: ""

    private val _uiState = MutableStateFlow(StoreDetailsUiState())
    val uiState: StateFlow<StoreDetailsUiState> = _uiState.asStateFlow()

    private var currentPage = 1
    private val perPage = 15

    init {
        loadData()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)

            // Load store first
            when (val storeResult = storeRepository.getStore(slug)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(store = storeResult.data)

                    // Then load summary, reviews, and user review in parallel
                    val summaryDeferred = async { storeRepository.getStoreSummary(slug) }
                    val reviewsDeferred = async {
                        reviewRepository.getStoreReviews(storeResult.data.id, 1, perPage)
                    }
                    val userReviewDeferred = async {
                        reviewRepository.getUserReview(storeResult.data.id)
                    }

                    val summaryResult = summaryDeferred.await()
                    val reviewsResult = reviewsDeferred.await()
                    val userReviewResult = userReviewDeferred.await()

                    _uiState.value = _uiState.value.copy(
                        summary = (summaryResult as? Result.Success)?.data,
                        reviews = (reviewsResult as? Result.Success)?.data?.data ?: emptyList(),
                        hasMoreReviews = (reviewsResult as? Result.Success)?.data?.meta?.hasNextPage ?: false,
                        userReview = (userReviewResult as? Result.Success)?.data?.data,
                        isLoading = false
                    )
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        error = storeResult.message,
                        isLoading = false
                    )
                }
                else -> {}
            }
        }
    }

    fun loadMoreReviews() {
        val store = _uiState.value.store ?: return
        if (_uiState.value.isLoadingMore || !_uiState.value.hasMoreReviews) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingMore = true)
            currentPage++

            when (val result = reviewRepository.getStoreReviews(store.id, currentPage, perPage)) {
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

    fun refreshReviews() {
        val store = _uiState.value.store ?: return
        currentPage = 1

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingReviews = true)

            val summaryDeferred = async { storeRepository.getStoreSummary(slug) }
            val reviewsDeferred = async { reviewRepository.getStoreReviews(store.id, 1, perPage) }
            val userReviewDeferred = async { reviewRepository.getUserReview(store.id) }

            val summaryResult = summaryDeferred.await()
            val reviewsResult = reviewsDeferred.await()
            val userReviewResult = userReviewDeferred.await()

            _uiState.value = _uiState.value.copy(
                summary = (summaryResult as? Result.Success)?.data ?: _uiState.value.summary,
                reviews = (reviewsResult as? Result.Success)?.data?.data ?: _uiState.value.reviews,
                hasMoreReviews = (reviewsResult as? Result.Success)?.data?.meta?.hasNextPage ?: false,
                userReview = (userReviewResult as? Result.Success)?.data?.data,
                isLoadingReviews = false
            )
        }
    }

    fun createReview(stars: Int, comment: String, onSuccess: () -> Unit, onError: (String) -> Unit) {
        val store = _uiState.value.store ?: return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSubmittingReview = true)

            when (val result = reviewRepository.createReview(store.id, stars, comment)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSubmittingReview = false,
                        reviewSubmitted = true
                    )
                    refreshReviews()
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReview = false)
                    onError(result.message)
                }
                else -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReview = false)
                }
            }
        }
    }

    fun resetReviewSubmitted() {
        _uiState.value = _uiState.value.copy(reviewSubmitted = false)
    }

    fun updateReview(reviewId: Int, stars: Int, comment: String, onSuccess: () -> Unit, onError: (String) -> Unit) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSubmittingReview = true)

            when (val result = reviewRepository.updateReview(reviewId, stars, comment)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSubmittingReview = false,
                        reviewSubmitted = true
                    )
                    refreshReviews()
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReview = false)
                    onError(result.message)
                }
                else -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReview = false)
                }
            }
        }
    }

    fun createClaim(
        requesterName: String,
        requesterPhone: String,
        note: String?,
        onSuccess: () -> Unit,
        onError: (String) -> Unit
    ) {
        val store = _uiState.value.store ?: return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSubmittingClaim = true)

            when (val result = userRepository.createClaim(store.id, requesterName, requesterPhone, note)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(isSubmittingClaim = false)
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(isSubmittingClaim = false)
                    onError(result.message)
                }
                else -> {
                    _uiState.value = _uiState.value.copy(isSubmittingClaim = false)
                }
            }
        }
    }

    fun createReport(
        reason: String,
        note: String?,
        onSuccess: () -> Unit,
        onError: (String) -> Unit
    ) {
        val store = _uiState.value.store ?: return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSubmittingReport = true)

            when (val result = userRepository.createReport("store", store.id, reason, note)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReport = false)
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReport = false)
                    onError(result.message)
                }
                else -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReport = false)
                }
            }
        }
    }

    fun createReply(
        reviewId: Int,
        replyText: String,
        onSuccess: () -> Unit,
        onError: (String) -> Unit
    ) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSubmittingReply = true)

            when (val result = reviewRepository.createReply(reviewId, replyText)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReply = false)
                    refreshReviews()
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReply = false)
                    onError(result.message)
                }
                else -> {
                    _uiState.value = _uiState.value.copy(isSubmittingReply = false)
                }
            }
        }
    }

    fun updateStore(
        description: String?,
        whatsapp: String?,
        phone: String?,
        onSuccess: () -> Unit,
        onError: (String) -> Unit
    ) {
        val store = _uiState.value.store ?: return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isUpdatingStore = true)

            val contacts = if (whatsapp != null || phone != null) {
                StoreContactInput(whatsapp = whatsapp, phone = phone)
            } else null

            val request = UpdateStoreRequest(
                description = description,
                contacts = contacts
            )

            when (val result = storeRepository.updateStore(store.id, request)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isUpdatingStore = false,
                        store = result.data.toStore()
                    )
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(isUpdatingStore = false)
                    onError(result.message)
                }
                else -> {
                    _uiState.value = _uiState.value.copy(isUpdatingStore = false)
                }
            }
        }
    }

}
