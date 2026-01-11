package com.preuvely.app.data.repository

import com.preuvely.app.data.api.ApiService
import com.preuvely.app.data.models.*
import com.preuvely.app.utils.Result
import com.preuvely.app.utils.safeApiCall
import javax.inject.Inject

interface CategoryRepository {
    suspend fun getCategories(): Result<List<Category>>
    suspend fun getCategory(slug: String): Result<Category>
    suspend fun getBanners(locale: String = "en"): Result<List<Banner>>
}

class CategoryRepositoryImpl @Inject constructor(
    private val apiService: ApiService
) : CategoryRepository {

    override suspend fun getCategories(): Result<List<Category>> {
        val result = safeApiCall { apiService.getCategories() }
        return result.map { it.data }
    }

    override suspend fun getCategory(slug: String): Result<Category> {
        val result = safeApiCall { apiService.getCategory(slug) }
        return result.map { it.data }
    }

    override suspend fun getBanners(locale: String): Result<List<Banner>> {
        val result = safeApiCall { apiService.getBanners(locale) }
        return result.map { it.data }
    }
}
