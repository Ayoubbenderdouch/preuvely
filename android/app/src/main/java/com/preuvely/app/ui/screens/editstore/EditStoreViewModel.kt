package com.preuvely.app.ui.screens.editstore

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.*
import com.preuvely.app.data.repository.CategoryRepository
import com.preuvely.app.data.repository.StoreRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class EditStoreUiState(
    val store: Store? = null,
    val categories: List<Category> = emptyList(),
    val name: String = "",
    val description: String = "",
    val city: String = "",
    val selectedCategories: Set<Int> = emptySet(),
    val platformLinks: Map<Platform, String> = emptyMap(),
    val whatsapp: String = "",
    val phone: String = "",
    val isLoading: Boolean = false,
    val isSaving: Boolean = false,
    val error: String? = null,
    val saveSuccess: Boolean = false
)

@HiltViewModel
class EditStoreViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val storeRepository: StoreRepository,
    private val categoryRepository: CategoryRepository
) : ViewModel() {

    private val storeId: Int = savedStateHandle.get<Int>("storeId") ?: 0

    private val _uiState = MutableStateFlow(EditStoreUiState())
    val uiState: StateFlow<EditStoreUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    private fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)

            // Load categories
            when (val categoriesResult = categoryRepository.getCategories()) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        categories = categoriesResult.data,
                        isLoading = false
                    )
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        error = categoriesResult.message,
                        isLoading = false
                    )
                }
                else -> {}
            }
        }
    }

    fun setName(name: String) {
        _uiState.value = _uiState.value.copy(name = name, error = null)
    }

    fun setDescription(description: String) {
        _uiState.value = _uiState.value.copy(description = description, error = null)
    }

    fun setCity(city: String) {
        _uiState.value = _uiState.value.copy(city = city, error = null)
    }

    fun setPlatformLink(platform: Platform, link: String) {
        val links = _uiState.value.platformLinks.toMutableMap()
        links[platform] = link
        _uiState.value = _uiState.value.copy(platformLinks = links, error = null)
    }

    fun setWhatsapp(whatsapp: String) {
        _uiState.value = _uiState.value.copy(whatsapp = whatsapp)
    }

    fun setPhone(phone: String) {
        _uiState.value = _uiState.value.copy(phone = phone)
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

    fun saveStore(onSuccess: () -> Unit) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isSaving = true, error = null)

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
            val contacts = if (_uiState.value.whatsapp.isNotBlank() || _uiState.value.phone.isNotBlank()) {
                StoreContactInput(
                    whatsapp = _uiState.value.whatsapp.ifBlank { null },
                    phone = _uiState.value.phone.ifBlank { null }
                )
            } else null

            val request = UpdateStoreRequest(
                name = _uiState.value.name,
                description = _uiState.value.description.ifBlank { null },
                city = _uiState.value.city.ifBlank { null }
            )

            when (val result = storeRepository.updateStore(storeId, request)) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        isSaving = false,
                        saveSuccess = true
                    )
                    onSuccess()
                }
                is Result.Error -> {
                    _uiState.value = _uiState.value.copy(
                        isSaving = false,
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
