package com.preuvely.app.data.repository

import com.preuvely.app.data.api.ApiService
import com.preuvely.app.data.models.*
import com.preuvely.app.utils.Result
import com.preuvely.app.utils.safeApiCall
import javax.inject.Inject

interface UserRepository {
    suspend fun getUserProfile(userId: Int): Result<UserProfile>
    suspend fun getUserStores(userId: Int, page: Int = 1, perPage: Int = 10): Result<StoreListResponse>
    suspend fun getUserReviews(userId: Int, page: Int = 1, perPage: Int = 10): Result<ReviewListResponse>
    suspend fun getMyClaims(): Result<List<Claim>>
    suspend fun createClaim(storeId: Int, requesterName: String, requesterPhone: String, note: String?): Result<Claim>
    suspend fun createReport(reportableType: String, reportableId: Int, reason: String, note: String?): Result<Report>
    suspend fun getMyReports(): Result<List<Report>>
}

class UserRepositoryImpl @Inject constructor(
    private val apiService: ApiService
) : UserRepository {

    override suspend fun getUserProfile(userId: Int): Result<UserProfile> {
        val result = safeApiCall { apiService.getUserProfile(userId) }
        return result.map { it.data }
    }

    override suspend fun getUserStores(userId: Int, page: Int, perPage: Int): Result<StoreListResponse> {
        return safeApiCall {
            apiService.getUserStores(userId, perPage, page)
        }
    }

    override suspend fun getUserReviews(userId: Int, page: Int, perPage: Int): Result<ReviewListResponse> {
        return safeApiCall {
            apiService.getUserReviews(userId, perPage, page)
        }
    }

    override suspend fun getMyClaims(): Result<List<Claim>> {
        val result = safeApiCall { apiService.getMyClaims() }
        return result.map { it.data }
    }

    override suspend fun createClaim(
        storeId: Int,
        requesterName: String,
        requesterPhone: String,
        note: String?
    ): Result<Claim> {
        val result = safeApiCall {
            apiService.createClaim(storeId, CreateClaimRequest(requesterName, requesterPhone, note))
        }
        return result.map { it.data }
    }

    override suspend fun createReport(
        reportableType: String,
        reportableId: Int,
        reason: String,
        note: String?
    ): Result<Report> {
        val result = safeApiCall {
            apiService.createReport(CreateReportRequest(reportableType, reportableId, reason, note))
        }
        return result.map { it.data }
    }

    override suspend fun getMyReports(): Result<List<Report>> {
        val result = safeApiCall { apiService.getMyReports() }
        return result.map { it.data }
    }
}
