package com.preuvely.app.ui.screens.review

import android.net.Uri
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.CreateReviewRequest
import com.preuvely.app.data.repository.ReviewRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class WriteReviewUiState(
    val storeId: Int = 0,
    val storeName: String = "",
    val rating: Int = 0,
    val content: String = "",
    val proofImages: List<Uri> = emptyList(),
    val isSubmitting: Boolean = false,
    val error: String? = null,
    val hasAttemptedSubmit: Boolean = false,
    val submitSuccess: Boolean = false
)

@HiltViewModel
class WriteReviewViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val reviewRepository: ReviewRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(WriteReviewUiState())
    val uiState: StateFlow<WriteReviewUiState> = _uiState.asStateFlow()

    fun setStoreInfo(storeId: Int, storeName: String) {
        _uiState.value = _uiState.value.copy(storeId = storeId, storeName = storeName)
    }

    fun setRating(rating: Int) {
        _uiState.value = _uiState.value.copy(rating = rating, error = null)
    }

    fun setContent(content: String) {
        _uiState.value = _uiState.value.copy(content = content, error = null)
    }

    fun addProofImage(uri: Uri) {
        if (_uiState.value.proofImages.size < 5) {
            _uiState.value = _uiState.value.copy(
                proofImages = _uiState.value.proofImages + uri
            )
        }
    }

    fun removeProofImage(index: Int) {
        val images = _uiState.value.proofImages.toMutableList()
        if (index in images.indices) {
            images.removeAt(index)
            _uiState.value = _uiState.value.copy(proofImages = images)
        }
    }

    val isFormValid: Boolean
        get() = _uiState.value.rating > 0

    fun submitReview(onSuccess: () -> Unit) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                isSubmitting = true,
                error = null,
                hasAttemptedSubmit = true
            )

            // For now, submit without images (would need multipart handling)
            when (val result = reviewRepository.createReview(
                storeId = _uiState.value.storeId,
                stars = _uiState.value.rating,
                comment = _uiState.value.content.ifBlank { "" }
            )) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        submitSuccess = true
                    )
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isSubmitting = false,
                        error = result.message
                    )
                }
                else -> {}
            }
        }
    }

    fun reset() {
        _uiState.value = WriteReviewUiState()
    }
}
