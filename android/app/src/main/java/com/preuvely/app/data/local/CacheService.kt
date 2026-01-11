package com.preuvely.app.data.local

import android.content.Context
import android.util.Log
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.preuvely.app.BuildConfig
import com.preuvely.app.data.models.Banner
import com.preuvely.app.data.models.Category
import com.preuvely.app.data.models.Store
import dagger.hilt.android.qualifiers.ApplicationContext
import java.io.File
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Service for caching API responses locally for offline support and instant app launch.
 * Similar to iOS CacheService implementation.
 */
@Singleton
class CacheService @Inject constructor(
    @ApplicationContext private val context: Context,
    private val gson: Gson
) {
    companion object {
        private const val TAG = "CacheService"
        private const val CACHE_DIR_NAME = "PreuvelyCache"
    }

    // Cache keys
    enum class CacheKey(val fileName: String) {
        CATEGORIES("cached_categories.json"),
        BANNERS("cached_banners.json"),
        TRENDING_STORES("cached_trending_stores.json"),
        TOP_RATED_STORES("cached_top_rated_stores.json")
    }

    private val cacheDirectory: File by lazy {
        File(context.cacheDir, CACHE_DIR_NAME).also { dir ->
            if (!dir.exists()) {
                dir.mkdirs()
            }
        }
    }

    // MARK: - Generic Save/Load

    /**
     * Save data to cache
     */
    inline fun <reified T> save(data: T, key: CacheKey) {
        try {
            val json = gson.toJson(data)
            val file = File(cacheDirectory, key.fileName)
            file.writeText(json)

            if (BuildConfig.DEBUG) {
                Log.d(TAG, "Saved ${key.name}")
            }
        } catch (e: Exception) {
            if (BuildConfig.DEBUG) {
                Log.e(TAG, "Failed to save ${key.name}: ${e.message}")
            }
        }
    }

    /**
     * Load data from cache
     */
    inline fun <reified T> load(key: CacheKey): T? {
        val file = File(cacheDirectory, key.fileName)

        if (!file.exists()) {
            return null
        }

        return try {
            val json = file.readText()
            val type = object : TypeToken<T>() {}.type
            val result: T = gson.fromJson(json, type)

            if (BuildConfig.DEBUG) {
                Log.d(TAG, "Loaded ${key.name}")
            }

            result
        } catch (e: Exception) {
            if (BuildConfig.DEBUG) {
                Log.e(TAG, "Failed to load ${key.name}: ${e.message}")
            }
            null
        }
    }

    /**
     * Check if cache exists for key
     */
    fun hasCache(key: CacheKey): Boolean {
        return File(cacheDirectory, key.fileName).exists()
    }

    /**
     * Clear specific cache
     */
    fun clear(key: CacheKey) {
        try {
            File(cacheDirectory, key.fileName).delete()
        } catch (e: Exception) {
            if (BuildConfig.DEBUG) {
                Log.e(TAG, "Failed to clear ${key.name}: ${e.message}")
            }
        }
    }

    /**
     * Clear all cache
     */
    fun clearAll() {
        try {
            cacheDirectory.deleteRecursively()
            cacheDirectory.mkdirs()
        } catch (e: Exception) {
            if (BuildConfig.DEBUG) {
                Log.e(TAG, "Failed to clear all cache: ${e.message}")
            }
        }
    }

    // MARK: - Convenience Methods

    // Categories
    fun saveCategories(categories: List<Category>) {
        save(categories, CacheKey.CATEGORIES)
    }

    fun loadCategories(): List<Category>? {
        return load<List<Category>>(CacheKey.CATEGORIES)
    }

    // Banners
    fun saveBanners(banners: List<Banner>) {
        save(banners, CacheKey.BANNERS)
    }

    fun loadBanners(): List<Banner>? {
        return load<List<Banner>>(CacheKey.BANNERS)
    }

    // Trending Stores
    fun saveTrendingStores(stores: List<Store>) {
        save(stores, CacheKey.TRENDING_STORES)
    }

    fun loadTrendingStores(): List<Store>? {
        return load<List<Store>>(CacheKey.TRENDING_STORES)
    }

    // Top Rated Stores
    fun saveTopRatedStores(stores: List<Store>) {
        save(stores, CacheKey.TOP_RATED_STORES)
    }

    fun loadTopRatedStores(): List<Store>? {
        return load<List<Store>>(CacheKey.TOP_RATED_STORES)
    }
}
