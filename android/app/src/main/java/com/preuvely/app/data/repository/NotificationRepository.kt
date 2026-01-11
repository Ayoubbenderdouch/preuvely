package com.preuvely.app.data.repository

import com.preuvely.app.data.api.ApiService
import com.preuvely.app.data.models.*
import com.preuvely.app.utils.Result
import com.preuvely.app.utils.safeApiCall
import javax.inject.Inject

interface NotificationRepository {
    suspend fun getNotifications(page: Int = 1, perPage: Int = 15): Result<NotificationListResponse>
    suspend fun getUnreadCount(): Result<Int>
    suspend fun markAsRead(id: Int): Result<String>
    suspend fun markAllAsRead(): Result<Int>
    suspend fun deleteNotification(id: Int): Result<String>
}

class NotificationRepositoryImpl @Inject constructor(
    private val apiService: ApiService
) : NotificationRepository {

    override suspend fun getNotifications(page: Int, perPage: Int): Result<NotificationListResponse> {
        return safeApiCall {
            apiService.getNotifications(perPage, page)
        }
    }

    override suspend fun getUnreadCount(): Result<Int> {
        val result = safeApiCall { apiService.getUnreadCount() }
        return result.map { it.unreadCount }
    }

    override suspend fun markAsRead(id: Int): Result<String> {
        val result = safeApiCall { apiService.markAsRead(id) }
        return result.map { it.message }
    }

    override suspend fun markAllAsRead(): Result<Int> {
        val result = safeApiCall { apiService.markAllAsRead() }
        return result.map { it.count }
    }

    override suspend fun deleteNotification(id: Int): Result<String> {
        val result = safeApiCall { apiService.deleteNotification(id) }
        return result.map { it.message }
    }
}
