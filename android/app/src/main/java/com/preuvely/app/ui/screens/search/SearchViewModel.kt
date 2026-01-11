package com.preuvely.app.ui.screens.search

import android.content.Context
import android.content.SharedPreferences
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.Category
import com.preuvely.app.data.models.Store
import com.preuvely.app.data.models.StoreSortOption
import com.preuvely.app.data.repository.CategoryRepository
import com.preuvely.app.data.repository.StoreRepository
import com.preuvely.app.utils.Result
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SearchUiState(
    val query: String = "",
    val stores: List<Store> = emptyList(),
    val categories: List<Category> = emptyList(),
    val selectedCategory: Category? = null,
    val verifiedOnly: Boolean = false,
    val sortOption: StoreSortOption = StoreSortOption.BEST_RATED,
    val isLoading: Boolean = false,
    val isLoadingMore: Boolean = false,
    val hasMorePages: Boolean = false,
    val error: String? = null,
    val hasSearched: Boolean = false,
    val recentSearches: List<String> = emptyList(),
    val isSearchFocused: Boolean = false
) {
    val hasActiveFilters: Boolean
        get() = selectedCategory != null || verifiedOnly || sortOption != StoreSortOption.BEST_RATED
}

@HiltViewModel
class SearchViewModel @Inject constructor(
    private val storeRepository: StoreRepository,
    private val categoryRepository: CategoryRepository,
    @ApplicationContext private val context: Context
) : ViewModel() {

    private val _uiState = MutableStateFlow(SearchUiState())
    val uiState: StateFlow<SearchUiState> = _uiState.asStateFlow()

    private var searchJob: Job? = null
    private var currentPage = 1

    private val prefs: SharedPreferences by lazy {
        context.getSharedPreferences("search_prefs", Context.MODE_PRIVATE)
    }

    companion object {
        private const val RECENT_SEARCHES_KEY = "recent_searches"
        private const val MAX_RECENT_SEARCHES = 8
    }

    init {
        loadCategories()
        loadRecentSearches()
    }

    private fun loadRecentSearches() {
        val searches = prefs.getStringSet(RECENT_SEARCHES_KEY, emptySet())?.toList() ?: emptyList()
        _uiState.value = _uiState.value.copy(recentSearches = searches.take(MAX_RECENT_SEARCHES))
    }

    private fun saveRecentSearch(query: String) {
        if (query.isBlank() || query.length < 2) return

        val currentSearches = _uiState.value.recentSearches.toMutableList()
        currentSearches.remove(query)
        currentSearches.add(0, query)

        val trimmedSearches = currentSearches.take(MAX_RECENT_SEARCHES)
        _uiState.value = _uiState.value.copy(recentSearches = trimmedSearches)

        prefs.edit().putStringSet(RECENT_SEARCHES_KEY, trimmedSearches.toSet()).apply()
    }

    fun removeRecentSearch(query: String) {
        val currentSearches = _uiState.value.recentSearches.toMutableList()
        currentSearches.remove(query)
        _uiState.value = _uiState.value.copy(recentSearches = currentSearches)
        prefs.edit().putStringSet(RECENT_SEARCHES_KEY, currentSearches.toSet()).apply()
    }

    fun clearRecentSearches() {
        _uiState.value = _uiState.value.copy(recentSearches = emptyList())
        prefs.edit().remove(RECENT_SEARCHES_KEY).apply()
    }

    fun setSearchFocused(focused: Boolean) {
        _uiState.value = _uiState.value.copy(isSearchFocused = focused)
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

    fun onQueryChange(query: String) {
        _uiState.value = _uiState.value.copy(query = query)

        searchJob?.cancel()
        searchJob = viewModelScope.launch {
            delay(300) // Debounce
            if (query.isNotBlank()) {
                search()
            } else {
                _uiState.value = _uiState.value.copy(
                    stores = emptyList(),
                    hasSearched = false
                )
            }
        }
    }

    fun selectRecentSearch(query: String) {
        _uiState.value = _uiState.value.copy(query = query)
        search()
    }

    fun setCategory(category: Category?) {
        _uiState.value = _uiState.value.copy(selectedCategory = category)
    }

    fun setVerifiedOnly(verified: Boolean) {
        _uiState.value = _uiState.value.copy(verifiedOnly = verified)
    }

    fun setSortOption(option: StoreSortOption) {
        _uiState.value = _uiState.value.copy(sortOption = option)
    }

    fun applyFilters() {
        currentPage = 1
        search()
    }

    fun resetFilters() {
        _uiState.value = _uiState.value.copy(
            selectedCategory = null,
            verifiedOnly = false,
            sortOption = StoreSortOption.BEST_RATED
        )
    }

    fun search() {
        searchJob?.cancel()
        currentPage = 1

        // Save to recent searches
        if (_uiState.value.query.isNotBlank()) {
            saveRecentSearch(_uiState.value.query)
        }

        searchJob = viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null, hasSearched = true)

            val result = storeRepository.searchStores(
                query = _uiState.value.query.takeIf { it.isNotBlank() },
                category = _uiState.value.selectedCategory?.slug,
                verified = if (_uiState.value.verifiedOnly) true else null,
                sort = _uiState.value.sortOption.value,
                page = currentPage
            )

            when (result) {
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

    fun loadMore() {
        if (_uiState.value.isLoadingMore || !_uiState.value.hasMorePages) return

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoadingMore = true)
            currentPage++

            val result = storeRepository.searchStores(
                query = _uiState.value.query.takeIf { it.isNotBlank() },
                category = _uiState.value.selectedCategory?.slug,
                verified = if (_uiState.value.verifiedOnly) true else null,
                sort = _uiState.value.sortOption.value,
                page = currentPage
            )

            when (result) {
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
}
