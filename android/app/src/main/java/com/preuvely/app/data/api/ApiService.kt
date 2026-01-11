package com.preuvely.app.data.api

import com.preuvely.app.data.models.*
import okhttp3.MultipartBody
import retrofit2.Response
import retrofit2.http.*

interface ApiService {

    // ==================== AUTH ====================

    @POST("auth/register")
    suspend fun register(@Body request: RegisterRequest): Response<AuthResponse>

    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): Response<AuthResponse>

    @POST("auth/logout")
    suspend fun logout(): Response<MessageResponse>

    @GET("auth/me")
    suspend fun getCurrentUser(): Response<UserResponse>

    @PUT("auth/profile")
    suspend fun updateProfile(@Body request: UpdateProfileRequest): Response<UserResponse>

    @Multipart
    @POST("auth/avatar")
    suspend fun uploadAvatar(@Part avatar: MultipartBody.Part): Response<UserResponse>

    @POST("auth/email/resend")
    suspend fun resendVerificationEmail(): Response<MessageResponse>

    @POST("auth/email/verify-code")
    suspend fun verifyEmailWithCode(@Body request: VerifyEmailRequest): Response<UserResponse>

    @POST("auth/social/{provider}/callback")
    suspend fun socialAuth(
        @Path("provider") provider: String,
        @Body request: SocialAuthRequest
    ): Response<AuthResponse>

    // ==================== CATEGORIES ====================

    @GET("categories")
    suspend fun getCategories(): Response<CategoryListResponse>

    @GET("categories/{slug}")
    suspend fun getCategory(@Path("slug") slug: String): Response<CategoryResponse>

    // ==================== BANNERS ====================

    @GET("banners")
    suspend fun getBanners(@Query("locale") locale: String = "en"): Response<BannerListResponse>

    // ==================== STORES ====================

    @GET("stores/search")
    suspend fun searchStores(
        @Query("q") query: String? = null,
        @Query("category") category: String? = null,
        @Query("city") city: String? = null,
        @Query("verified") verified: Boolean? = null,
        @Query("sort") sort: String? = null,
        @Query("per_page") perPage: Int = 15,
        @Query("page") page: Int = 1
    ): Response<StoreListResponse>

    @GET("stores/trending")
    suspend fun getTrendingStores(): Response<StoreListResponse>

    @GET("stores/top-rated")
    suspend fun getTopRatedStores(): Response<StoreListResponse>

    @GET("stores/{slug}")
    suspend fun getStore(@Path("slug") slug: String): Response<StoreResponse>

    @GET("stores/{slug}/summary")
    suspend fun getStoreSummary(@Path("slug") slug: String): Response<StoreSummaryResponse>

    @Multipart
    @POST("stores")
    suspend fun createStore(
        @Part("name") name: okhttp3.RequestBody,
        @Part("description") description: okhttp3.RequestBody?,
        @Part("city") city: okhttp3.RequestBody?,
        @Part categoryIds: List<MultipartBody.Part>,
        @Part logo: MultipartBody.Part?,
        @Part("links") links: okhttp3.RequestBody?,
        @Part("contacts") contacts: okhttp3.RequestBody?
    ): Response<CreateStoreResponse>

    @POST("stores")
    suspend fun createStoreJson(@Body request: CreateStoreRequest): Response<CreateStoreResponse>

    // ==================== MY STORES (Owner) ====================

    @GET("my-stores")
    suspend fun getMyStores(): Response<OwnedStoreListResponse>

    @PUT("my-stores/{storeId}")
    suspend fun updateStore(
        @Path("storeId") storeId: Int,
        @Body request: UpdateStoreRequest
    ): Response<UpdateStoreResponse>

    @Multipart
    @POST("my-stores/{storeId}/logo")
    suspend fun uploadStoreLogo(
        @Path("storeId") storeId: Int,
        @Part logo: MultipartBody.Part
    ): Response<LogoUploadResponse>

    @GET("my-stores/{storeId}/links")
    suspend fun getStoreLinks(@Path("storeId") storeId: Int): Response<StoreLinkListResponse>

    @PUT("my-stores/{storeId}/links")
    suspend fun updateStoreLinks(
        @Path("storeId") storeId: Int,
        @Body request: UpdateStoreLinksRequest
    ): Response<StoreLinkListResponse>

    // ==================== REVIEWS ====================

    @GET("stores/{storeId}/reviews")
    suspend fun getStoreReviews(
        @Path("storeId") storeId: Int,
        @Query("per_page") perPage: Int = 15,
        @Query("page") page: Int = 1
    ): Response<ReviewListResponse>

    @POST("stores/{storeId}/reviews")
    suspend fun createReview(
        @Path("storeId") storeId: Int,
        @Body request: CreateReviewRequest
    ): Response<ReviewResponse>

    @PUT("reviews/{reviewId}")
    suspend fun updateReview(
        @Path("reviewId") reviewId: Int,
        @Body request: CreateReviewRequest
    ): Response<ReviewResponse>

    @GET("stores/{storeId}/my-review")
    suspend fun getUserReview(@Path("storeId") storeId: Int): Response<UserReviewResponse>

    @GET("reviews/my")
    suspend fun getMyReviews(
        @Query("per_page") perPage: Int = 15,
        @Query("page") page: Int = 1
    ): Response<ReviewListResponse>

    @Multipart
    @POST("reviews/{reviewId}/proof")
    suspend fun uploadProof(
        @Path("reviewId") reviewId: Int,
        @Part proof: MultipartBody.Part
    ): Response<ProofUploadResponse>

    @POST("reviews/{reviewId}/reply")
    suspend fun createReply(
        @Path("reviewId") reviewId: Int,
        @Body request: CreateReplyRequest
    ): Response<ReplyResponse>

    // ==================== CLAIMS ====================

    @POST("stores/{storeId}/claim")
    suspend fun createClaim(
        @Path("storeId") storeId: Int,
        @Body request: CreateClaimRequest
    ): Response<ClaimResponse>

    @GET("claims")
    suspend fun getMyClaims(): Response<ClaimListResponse>

    // ==================== REPORTS ====================

    @POST("reports")
    suspend fun createReport(@Body request: CreateReportRequest): Response<ReportResponse>

    @GET("reports")
    suspend fun getMyReports(): Response<ReportListResponse>

    // ==================== NOTIFICATIONS ====================

    @GET("notifications")
    suspend fun getNotifications(
        @Query("per_page") perPage: Int = 15,
        @Query("page") page: Int = 1
    ): Response<NotificationListResponse>

    @GET("notifications/unread-count")
    suspend fun getUnreadCount(): Response<UnreadCountResponse>

    @POST("notifications/{id}/read")
    suspend fun markAsRead(@Path("id") id: Int): Response<MarkReadResponse>

    @POST("notifications/mark-all-read")
    suspend fun markAllAsRead(): Response<MarkAllReadResponse>

    @DELETE("notifications/{id}")
    suspend fun deleteNotification(@Path("id") id: Int): Response<MessageResponse>

    // ==================== USER PROFILES ====================

    @GET("users/{id}/profile")
    suspend fun getUserProfile(@Path("id") userId: Int): Response<UserProfileResponse>

    @GET("users/{id}/profile/stores")
    suspend fun getUserStores(
        @Path("id") userId: Int,
        @Query("per_page") perPage: Int = 10,
        @Query("page") page: Int = 1
    ): Response<StoreListResponse>

    @GET("users/{id}/profile/reviews")
    suspend fun getUserReviews(
        @Path("id") userId: Int,
        @Query("per_page") perPage: Int = 10,
        @Query("page") page: Int = 1
    ): Response<ReviewListResponse>
}
