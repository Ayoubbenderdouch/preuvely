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
    val error: String? = null
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val categoryRepository: CategoryRepository,
    private val storeRepository: StoreRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    fun loadData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)

            val bannersDeferred = async { categoryRepository.getBanners() }
            val categoriesDeferred = async { categoryRepository.getCategories() }
            val trendingDeferred = async { storeRepository.getTrendingStores() }
            val topRatedDeferred = async { storeRepository.getTopRatedStores() }

            val bannersResult = bannersDeferred.await()
            val categoriesResult = categoriesDeferred.await()
            val trendingResult = trendingDeferred.await()
            val topRatedResult = topRatedDeferred.await()

            _uiState.value = _uiState.value.copy(
                banners = (bannersResult as? Result.Success)?.data ?: emptyList(),
                categories = (categoriesResult as? Result.Success)?.data?.filter { it.shouldShowOnHome } ?: emptyList(),
                trendingStores = (trendingResult as? Result.Success)?.data ?: emptyList(),
                topRatedStores = (topRatedResult as? Result.Success)?.data?.sortedByDescending { it.reviewsCount } ?: emptyList(),
                isLoading = false,
                isRefreshing = false
            )
        }
    }

    fun refresh() {
        if (_uiState.value.isRefreshing) return
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isRefreshing = true)
            loadData()
        }
    }
}
