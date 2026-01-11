package com.preuvely.app.ui.screens.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.preuvely.app.data.models.Banner
import com.preuvely.app.data.models.Category
import com.preuvely.app.data.models.Store
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

data class HomeUiState(
    val banners: List<Banner> = emptyList(),
    val categories: List<Category> = emptyList(),
    val trendingStores: List<Store> = emptyList(),
    val topRatedStores: List<Store> = emptyList(),
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val error: String? = null,
    val hasCachedData: Boolean = false
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val categoryRepository: CategoryRepository,
    private val storeRepository: StoreRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        // Load cached data immediately for instant display
        loadCachedData()
        // Then fetch fresh data from API (always force refresh to get latest data)
        loadData(forceRefresh = true)
    }

    /**
     * Load cached data immediately for instant app launch experience
     */
    private fun loadCachedData() {
        val cachedBanners = categoryRepository.getCachedBanners() ?: emptyList()
        val cachedCategories = categoryRepository.getCachedCategories()?.filter { it.shouldShowOnHome } ?: emptyList()
        val cachedTrending = storeRepository.getCachedTrendingStores() ?: emptyList()
        val cachedTopRated = storeRepository.getCachedTopRatedStores()?.sortedByDescending { it.reviewsCount } ?: emptyList()

        val hasCachedData = cachedBanners.isNotEmpty() || cachedCategories.isNotEmpty() ||
                cachedTrending.isNotEmpty() || cachedTopRated.isNotEmpty()

        if (hasCachedData) {
            _uiState.value = _uiState.value.copy(
                banners = cachedBanners,
                categories = cachedCategories,
                trendingStores = cachedTrending,
                topRatedStores = cachedTopRated,
                hasCachedData = true
            )
        }
    }

    /**
     * Load data from API
     * @param forceRefresh If true, bypasses cache and fetches fresh data
     */
    fun loadData(forceRefresh: Boolean = false) {
        viewModelScope.launch {
            // Only show loading indicator if we don't have cached data
            val showLoading = !_uiState.value.hasCachedData && _uiState.value.banners.isEmpty()
            _uiState.value = _uiState.value.copy(
                isLoading = showLoading,
                error = null
            )

            val bannersDeferred = async { categoryRepository.getBanners(forceRefresh = forceRefresh) }
            val categoriesDeferred = async { categoryRepository.getCategories(forceRefresh = forceRefresh) }
            val trendingDeferred = async { storeRepository.getTrendingStores(forceRefresh = forceRefresh) }
            val topRatedDeferred = async { storeRepository.getTopRatedStores(forceRefresh = forceRefresh) }

            val bannersResult = bannersDeferred.await()
            val categoriesResult = categoriesDeferred.await()
            val trendingResult = trendingDeferred.await()
            val topRatedResult = topRatedDeferred.await()

            _uiState.value = _uiState.value.copy(
                banners = (bannersResult as? Result.Success)?.data ?: _uiState.value.banners,
                categories = (categoriesResult as? Result.Success)?.data?.filter { it.shouldShowOnHome } ?: _uiState.value.categories,
                trendingStores = (trendingResult as? Result.Success)?.data ?: _uiState.value.trendingStores,
                topRatedStores = (topRatedResult as? Result.Success)?.data?.sortedByDescending { it.reviewsCount } ?: _uiState.value.topRatedStores,
                isLoading = false,
                isRefreshing = false,
                hasCachedData = true
            )
        }
    }

    /**
     * Manual refresh - forces cache bypass to get fresh data
     */
    fun refresh() {
        if (_uiState.value.isRefreshing) return
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isRefreshing = true)
            loadData(forceRefresh = true)
        }
    }
}
