package com.preuvely.app.ui.screens.addstore

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.*
import com.preuvely.app.data.repository.AuthRepository
import com.preuvely.app.data.repository.CategoryRepository
import com.preuvely.app.data.repository.StoreRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AddStoreUiState(
    val name: String = "",
    val categories: List<Category> = emptyList(),
    val selectedCategories: Set<Int> = emptySet(),
    val selectedPlatform: Platform? = null,
    val platformLinks: Map<Platform, String> = emptyMap(),
    val whatsapp: String = "",
    val isSubmitting: Boolean = false,
    val error: String? = null,
    val hasAttemptedSubmit: Boolean = false,
    val duplicateStore: Store? = null
)

@HiltViewModel
class AddStoreViewModel @Inject constructor(
    private val storeRepository: StoreRepository,
    private val categoryRepository: CategoryRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(AddStoreUiState())
    val uiState: StateFlow<AddStoreUiState> = _uiState.asStateFlow()

    init {
        loadCategories()
    }

    private fun loadCategories() {
        viewModelScope.launch {
            when (val result = categoryRepository.getCategories()) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(categories = result.data)
                }
                else -> {}
            }
        }
    }

    fun setName(name: String) {
        _uiState.value = _uiState.value.copy(name = name, error = null)
    }

    fun setSelectedPlatform(platform: Platform) {
        _uiState.value = _uiState.value.copy(selectedPlatform = platform)
    }

    fun setPlatformLink(platform: Platform, link: String) {
        val links = _uiState.value.platformLinks.toMutableMap()
        links[platform] = link
        _uiState.value = _uiState.value.copy(platformLinks = links, error = null)
    }

    fun setWhatsapp(whatsapp: String) {
        _uiState.value = _uiState.value.copy(whatsapp = whatsapp)
    }

    fun toggleCategory(categoryId: Int) {
        val selected = _uiState.value.selectedCategories.toMutableSet()
        if (selected.contains(categoryId)) {
            selected.remove(categoryId)
        } else {
            selected.add(categoryId)
        }
        _uiState.value = _uiState.value.copy(selectedCategories = selected, error = null)
    }

    val isFormValid: Boolean
        get() {
            val state = _uiState.value
            return state.name.isNotBlank() &&
                    state.selectedCategories.isNotEmpty() &&
                    state.platformLinks.values.any { it.isNotBlank() }
        }

    fun submitStore(
        onSuccess: (String) -> Unit,
        onAuthRequired: () -> Unit
    ) {
        viewModelScope.launch {
            // Check if authenticated
            val isAuthenticated = authRepository.isAuthenticated.first()
            if (!isAuthenticated) {
                onAuthRequired()
                return@launch
            }

            _uiState.value = _uiState.value.copy(
                isSubmitting = true,
                error = null,
                hasAttemptedSubmit = true
            )

            // Build links
            val links = _uiState.value.platformLinks
                .filter { it.value.isNotBlank() }
                .map { (platform, url) ->
                    StoreLinkInput(
                        platform = platform.value,
                        url = url,
                        handle = extractHandle(platform, url)
                    )
                }

            // Build contacts
            val contacts = if (_uiState.value.whatsapp.isNotBlank()) {
                StoreContactInput(
                    whatsapp = _uiState.value.whatsapp,
                    phone = null
                )
            } else null

            val request = CreateStoreRequest(
                name = _uiState.value.name,
                description = null,
                city = null,
                categoryIds = _uiState.value.selectedCategories.toList(),
                links = links,
                contacts = contacts
            )

            when (val result = storeRepository.createStore(request, null)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(isSubmitting = false)
                    onSuccess(result.data.slug)
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

    private fun extractHandle(platform: Platform, url: String): String? {
        return when (platform) {
            Platform.INSTAGRAM -> {
                val regex = Regex("instagram\\.com/([^/?]+)")
                regex.find(url)?.groupValues?.getOrNull(1)
            }
            Platform.TIKTOK -> {
                val regex = Regex("tiktok\\.com/@?([^/?]+)")
                regex.find(url)?.groupValues?.getOrNull(1)
            }
            Platform.FACEBOOK -> {
                val regex = Regex("facebook\\.com/([^/?]+)")
                regex.find(url)?.groupValues?.getOrNull(1)
            }
            else -> null
        }
    }
}
