package com.preuvely.app.ui.screens.category

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.Category
import com.preuvely.app.data.models.Store
import com.preuvely.app.data.repository.CategoryRepository
import com.preuvely.app.data.repository.StoreRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class CategoryStoresUiState(
    val category: Category? = null,
    val stores: List<Store> = emptyList(),
    val isLoading: Boolean = false,
    val isLoadingMore: Boolean = false,
    val hasMorePages: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class CategoryStoresViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val storeRepository: StoreRepository,
    private val categoryRepository: CategoryRepository
) : ViewModel() {

    private val categoryId: Int = savedStateHandle.get<Int>("categoryId") ?: 0
    private val categorySlug: String = savedStateHandle.get<String>("categorySlug") ?: ""

    private val _uiState = MutableStateFlow(CategoryStoresUiState())
    val uiState: StateFlow<CategoryStoresUiState> = _uiState.asStateFlow()

    private var currentPage = 1
    private val perPage = 20

    init {
        loadCategory()
        loadStores()
    }

    private fun loadCategory() {
        viewModelScope.launch {
            when (val result = categoryRepository.getCategories()) {
                is Result.Success -> {
                    val category = result.data.find { it.id == categoryId }
                    _uiState.value = _uiState.value.copy(category = category)
                }
                else -> {}
            }
        }
    }

    private fun loadStores() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            currentPage = 1

            when (val result = storeRepository.searchStores(
                query = null,
                category = categorySlug,
                page = currentPage,
                perPage = perPage
            )) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        stores = result.data.data,
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

    fun loadMoreStores() {
        if (_uiState.value.isLoadingMore || !_uiState.value.hasMorePages) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingMore = true)
            currentPage++

            when (val result = storeRepository.searchStores(
                query = null,
                category = categorySlug,
                page = currentPage,
                perPage = perPage
            )) {
                is Result.Success -> {
                    _uiState.value = _uiState.value.copy(
                        stores = _uiState.value.stores + result.data.data,
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

    fun refresh() {
        loadStores()
    }
}
