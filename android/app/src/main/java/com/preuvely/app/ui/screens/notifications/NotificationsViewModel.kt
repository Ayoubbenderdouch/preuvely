package com.preuvely.app.ui.screens.notifications

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.AppNotification
import com.preuvely.app.data.repository.NotificationRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class NotificationsUiState(
    val notifications: List<AppNotification> = emptyList(),
    val isLoading: Boolean = false,
    val isLoadingMore: Boolean = false,
    val hasMorePages: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class NotificationsViewModel @Inject constructor(
    private val notificationRepository: NotificationRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(NotificationsUiState())
    val uiState: StateFlow<NotificationsUiState> = _uiState.asStateFlow()

    private var currentPage = 1
    private val perPage = 20

    init {
        loadNotifications()
    }

    fun loadNotifications() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            currentPage = 1

            when (val result = notificationRepository.getNotifications(currentPage, perPage)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        notifications = result.data.data,
                        hasMorePages = result.data.meta?.hasNextPage ?: false,
                        isLoading = false
                    )
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        error = result.message,
                        isLoading = false
                    )
                }
                else -> {}
            }
        }
    }

    fun loadMoreNotifications() {
        if (_uiState.value.isLoadingMore || !_uiState.value.hasMorePages) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingMore = true)
            currentPage++

            when (val result = notificationRepository.getNotifications(currentPage, perPage)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        notifications = _uiState.value.notifications + result.data.data,
                        hasMorePages = result.data.meta?.hasNextPage ?: false,
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

    fun markAsRead(notificationId: Int) {
        viewModelScope.launch {
            when (notificationRepository.markAsRead(notificationId)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        notifications = _uiState.value.notifications.map {
                            if (it.id == notificationId) it.copy(isRead = true) else it
                        }
                    )
                }
                else -> {}
            }
        }
    }

    fun markAllAsRead() {
        viewModelScope.launch {
            when (notificationRepository.markAllAsRead()) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        notifications = _uiState.value.notifications.map {
                            it.copy(isRead = true)
                        }
                    )
                }
                else -> {}
            }
        }
    }
}
