package com.preuvely.app.data.repository

import com.preuvely.app.data.api.ApiService
import com.preuvely.app.data.models.*
import com.preuvely.app.utils.Result
import com.preuvely.app.utils.safeApiCall
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.File
import javax.inject.Inject

interface StoreRepository {
    suspend fun searchStores(
        query: String? = null,
        category: String? = null,
        verified: Boolean? = null,
        sort: String? = null,
        page: Int = 1,
        perPage: Int = 15
    ): Result<StoreListResponse>

    suspend fun getTrendingStores(): Result<List<Store>>
    suspend fun getTopRatedStores(): Result<List<Store>>
    suspend fun getStore(slug: String): Result<Store>
    suspend fun getStoreSummary(slug: String): Result<StoreSummary>
    suspend fun createStore(request: CreateStoreRequest, logoFile: File?): Result<Store>
    suspend fun getMyStores(): Result<List<OwnedStore>>
    suspend fun updateStore(storeId: Int, request: UpdateStoreRequest): Result<OwnedStore>
    suspend fun uploadStoreLogo(storeId: Int, file: File): Result<String>
    suspend fun getStoreLinks(storeId: Int): Result<List<StoreLink>>
    suspend fun updateStoreLinks(storeId: Int, links: List<StoreLinkInput>): Result<List<StoreLink>>
}

class StoreRepositoryImpl @Inject constructor(
    private val apiService: ApiService
) : StoreRepository {

    override suspend fun searchStores(
        query: String?,
        category: String?,
        verified: Boolean?,
        sort: String?,
        page: Int,
        perPage: Int
    ): Result<StoreListResponse> {
        return safeApiCall {
            apiService.searchStores(
                query = query,
                category = category,
                verified = verified,
                sort = sort,
                page = page,
                perPage = perPage
            )
        }
    }

    override suspend fun getTrendingStores(): Result<List<Store>> {
        val result = safeApiCall { apiService.getTrendingStores() }
        return result.map { it.data }
    }

    override suspend fun getTopRatedStores(): Result<List<Store>> {
        val result = safeApiCall { apiService.getTopRatedStores() }
        return result.map { it.data }
    }

    override suspend fun getStore(slug: String): Result<Store> {
        val result = safeApiCall { apiService.getStore(slug) }
        return result.map { it.data }
    }

    override suspend fun getStoreSummary(slug: String): Result<StoreSummary> {
        val result = safeApiCall { apiService.getStoreSummary(slug) }
        return result.map { it.data }
    }

    override suspend fun createStore(request: CreateStoreRequest, logoFile: File?): Result<Store> {
        // If no logo, use JSON request
        if (logoFile == null) {
            val result = safeApiCall { apiService.createStoreJson(request) }
            return result.map { it.data }
        }

        // With logo, use multipart
        val nameBody = request.name.toRequestBody("text/plain".toMediaTypeOrNull())
        val descriptionBody = request.description?.toRequestBody("text/plain".toMediaTypeOrNull())
        val cityBody = request.city?.toRequestBody("text/plain".toMediaTypeOrNull())
        val categoryIdBodies = request.categoryIds.map {
            it.toString().toRequestBody("text/plain".toMediaTypeOrNull())
        }

        val logoRequestFile = logoFile.asRequestBody("image/*".toMediaTypeOrNull())
        val logoPart = MultipartBody.Part.createFormData("logo", logoFile.name, logoRequestFile)

        val linksJson = request.links?.let {
            com.google.gson.Gson().toJson(it).toRequestBody("application/json".toMediaTypeOrNull())
        }
        val contactsJson = request.contacts?.let {
            com.google.gson.Gson().toJson(it).toRequestBody("application/json".toMediaTypeOrNull())
        }

        val result = safeApiCall {
            apiService.createStore(
                name = nameBody,
                description = descriptionBody,
                city = cityBody,
                categoryIds = categoryIdBodies,
                logo = logoPart,
                links = linksJson,
                contacts = contactsJson
            )
        }
        return result.map { it.data }
    }

    override suspend fun getMyStores(): Result<List<OwnedStore>> {
        val result = safeApiCall { apiService.getMyStores() }
        return result.map { it.data }
    }

    override suspend fun updateStore(storeId: Int, request: UpdateStoreRequest): Result<OwnedStore> {
        val result = safeApiCall { apiService.updateStore(storeId, request) }
        return result.map { it.data }
    }

    override suspend fun uploadStoreLogo(storeId: Int, file: File): Result<String> {
        val requestFile = file.asRequestBody("image/*".toMediaTypeOrNull())
        val body = MultipartBody.Part.createFormData("logo", file.name, requestFile)

        val result = safeApiCall { apiService.uploadStoreLogo(storeId, body) }
        return result.map { it.data.logo }
    }

    override suspend fun getStoreLinks(storeId: Int): Result<List<StoreLink>> {
        val result = safeApiCall { apiService.getStoreLinks(storeId) }
        return result.map { it.data }
    }

    override suspend fun updateStoreLinks(storeId: Int, links: List<StoreLinkInput>): Result<List<StoreLink>> {
        val result = safeApiCall {
            apiService.updateStoreLinks(storeId, UpdateStoreLinksRequest(links))
        }
        return result.map { it.data }
    }
}
