package com.preuvely.app.data.repository

import com.preuvely.app.data.api.ApiService
import com.preuvely.app.data.models.*
import com.preuvely.app.utils.Result
import com.preuvely.app.utils.safeApiCall
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File
import javax.inject.Inject

interface ReviewRepository {
    suspend fun getStoreReviews(storeId: Int, page: Int = 1, perPage: Int = 15): Result<ReviewListResponse>
    suspend fun createReview(storeId: Int, stars: Int, comment: String): Result<ReviewResponse>
    suspend fun updateReview(reviewId: Int, stars: Int, comment: String): Result<ReviewResponse>
    suspend fun getUserReview(storeId: Int): Result<UserReviewResponse>
    suspend fun getMyReviews(page: Int = 1, perPage: Int = 15): Result<ReviewListResponse>
    suspend fun uploadProof(reviewId: Int, file: File): Result<Proof>
    suspend fun createReply(reviewId: Int, replyText: String): Result<StoreReply>
}

class ReviewRepositoryImpl @Inject constructor(
    private val apiService: ApiService
) : ReviewRepository {

    override suspend fun getStoreReviews(storeId: Int, page: Int, perPage: Int): Result<ReviewListResponse> {
        return safeApiCall {
            apiService.getStoreReviews(storeId, perPage, page)
        }
    }

    override suspend fun createReview(storeId: Int, stars: Int, comment: String): Result<ReviewResponse> {
        return safeApiCall {
            apiService.createReview(storeId, CreateReviewRequest(stars, comment))
        }
    }

    override suspend fun updateReview(reviewId: Int, stars: Int, comment: String): Result<ReviewResponse> {
        return safeApiCall {
            apiService.updateReview(reviewId, CreateReviewRequest(stars, comment))
        }
    }

    override suspend fun getUserReview(storeId: Int): Result<UserReviewResponse> {
        return safeApiCall {
            apiService.getUserReview(storeId)
        }
    }

    override suspend fun getMyReviews(page: Int, perPage: Int): Result<ReviewListResponse> {
        return safeApiCall {
            apiService.getMyReviews(perPage, page)
        }
    }

    override suspend fun uploadProof(reviewId: Int, file: File): Result<Proof> {
        val requestFile = file.asRequestBody("image/*".toMediaTypeOrNull())
        val body = MultipartBody.Part.createFormData("proof", file.name, requestFile)

        val result = safeApiCall { apiService.uploadProof(reviewId, body) }
        return result.map { it.data }
    }

    override suspend fun createReply(reviewId: Int, replyText: String): Result<StoreReply> {
        val result = safeApiCall {
            apiService.createReply(reviewId, CreateReplyRequest(replyText))
        }
        return result.map { it.data }
    }
}
