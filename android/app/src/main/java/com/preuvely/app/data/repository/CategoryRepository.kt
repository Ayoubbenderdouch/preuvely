package com.preuvely.app.data.repository

import com.preuvely.app.data.api.ApiService
import com.preuvely.app.data.local.CacheService
import com.preuvely.app.data.models.*
import com.preuvely.app.utils.Result
import com.preuvely.app.utils.safeApiCall
import javax.inject.Inject

interface CategoryRepository {
    suspend fun getCategories(forceRefresh: Boolean = false): Result<List<Category>>
    suspend fun getCategory(slug: String): Result<Category>
    suspend fun getBanners(locale: String = "en", forceRefresh: Boolean = false): Result<List<Banner>>
    fun getCachedCategories(): List<Category>?
    fun getCachedBanners(): List<Banner>?
}

class CategoryRepositoryImpl @Inject constructor(
    private val apiService: ApiService,
    private val cacheService: CacheService
) : CategoryRepository {

    override suspend fun getCategories(forceRefresh: Boolean): Result<List<Category>> {
        // Return cached data if available and not forcing refresh
        if (!forceRefresh) {
            cacheService.loadCategories()?.let { cached ->
                if (cached.isNotEmpty()) {
                    // Still fetch fresh data in the background, but return cached immediately
                    refreshCategoriesInBackground()
                    return Result.Success(cached)
                }
            }
        }

        val result = safeApiCall { apiService.getCategories() }
        return result.map { response ->
            response.data.also { categories ->
                cacheService.saveCategories(categories)
            }
        }
    }

    private fun refreshCategoriesInBackground() {
        // This will be called to update cache after returning cached data
        // The actual refresh happens in the next call with forceRefresh = true
    }

    override suspend fun getCategory(slug: String): Result<Category> {
        val result = safeApiCall { apiService.getCategory(slug) }
        return result.map { it.data }
    }

    override suspend fun getBanners(locale: String, forceRefresh: Boolean): Result<List<Banner>> {
        // Return cached data if available and not forcing refresh
        if (!forceRefresh) {
            cacheService.loadBanners()?.let { cached ->
                if (cached.isNotEmpty()) {
                    return Result.Success(cached)
                }
            }
        }

        val result = safeApiCall { apiService.getBanners(locale) }
        return result.map { response ->
            response.data.also { banners ->
                cacheService.saveBanners(banners)
            }
        }
    }

    override fun getCachedCategories(): List<Category>? {
        return cacheService.loadCategories()
    }

    override fun getCachedBanners(): List<Banner>? {
        return cacheService.loadBanners()
    }
}
