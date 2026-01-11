package com.preuvely.app.data.repository

import com.preuvely.app.data.api.ApiService
import com.preuvely.app.data.models.*
import com.preuvely.app.utils.Result
import com.preuvely.app.utils.SessionManager
import com.preuvely.app.utils.safeApiCall
import kotlinx.coroutines.flow.Flow
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import java.io.File
import javax.inject.Inject

interface AuthRepository {
    val isAuthenticated: Flow<Boolean>
    val currentUser: Flow<User?>

    suspend fun login(email: String?, phone: String?, password: String): Result<User>
    suspend fun register(name: String, email: String?, phone: String?, password: String): Result<User>
    suspend fun logout(): Result<Unit>
    suspend fun getCurrentUser(): Result<User>
    suspend fun updateProfile(name: String?, phone: String?): Result<User>
    suspend fun uploadAvatar(file: File): Result<User>
    suspend fun resendVerificationEmail(): Result<String>
    suspend fun verifyEmailWithCode(code: String): Result<User>
    suspend fun socialAuth(provider: String, idToken: String): Result<User>
}

class AuthRepositoryImpl @Inject constructor(
    private val apiService: ApiService,
    private val sessionManager: SessionManager
) : AuthRepository {

    override val isAuthenticated: Flow<Boolean> = sessionManager.isAuthenticated
    override val currentUser: Flow<User?> = sessionManager.user

    override suspend fun login(email: String?, phone: String?, password: String): Result<User> {
        val result = safeApiCall {
            apiService.login(LoginRequest(email = email, phone = phone, password = password))
        }

        return when (result) {
            is Result.Success -> {
                sessionManager.saveSession(result.data.token, result.data.user)
                Result.Success(result.data.user)
            }
            is Result.Error -> Result.Error(result.message, result.code)
            is Result.Loading -> Result.Loading
        }
    }

    override suspend fun register(name: String, email: String?, phone: String?, password: String): Result<User> {
        val result = safeApiCall {
            apiService.register(
                RegisterRequest(
                    name = name,
                    email = email,
                    phone = phone,
                    password = password,
                    passwordConfirmation = password
                )
            )
        }

        return when (result) {
            is Result.Success -> {
                sessionManager.saveSession(result.data.token, result.data.user)
                Result.Success(result.data.user)
            }
            is Result.Error -> Result.Error(result.message, result.code)
            is Result.Loading -> Result.Loading
        }
    }

    override suspend fun logout(): Result<Unit> {
        val result = safeApiCall { apiService.logout() }
        sessionManager.clearSession()
        return when (result) {
            is Result.Success -> Result.Success(Unit)
            is Result.Error -> Result.Success(Unit) // Clear session even if API fails
            is Result.Loading -> Result.Loading
        }
    }

    override suspend fun getCurrentUser(): Result<User> {
        val result = safeApiCall { apiService.getCurrentUser() }
        return when (result) {
            is Result.Success -> {
                sessionManager.saveUser(result.data.user)
                Result.Success(result.data.user)
            }
            is Result.Error -> Result.Error(result.message, result.code)
            is Result.Loading -> Result.Loading
        }
    }

    override suspend fun updateProfile(name: String?, phone: String?): Result<User> {
        val result = safeApiCall {
            apiService.updateProfile(UpdateProfileRequest(name = name, phone = phone))
        }
        return when (result) {
            is Result.Success -> {
                sessionManager.saveUser(result.data.user)
                Result.Success(result.data.user)
            }
            is Result.Error -> Result.Error(result.message, result.code)
            is Result.Loading -> Result.Loading
        }
    }

    override suspend fun uploadAvatar(file: File): Result<User> {
        val requestFile = file.asRequestBody("image/*".toMediaTypeOrNull())
        val body = MultipartBody.Part.createFormData("avatar", file.name, requestFile)

        val result = safeApiCall { apiService.uploadAvatar(body) }
        return when (result) {
            is Result.Success -> {
                sessionManager.saveUser(result.data.user)
                Result.Success(result.data.user)
            }
            is Result.Error -> Result.Error(result.message, result.code)
            is Result.Loading -> Result.Loading
        }
    }

    override suspend fun resendVerificationEmail(): Result<String> {
        val result = safeApiCall { apiService.resendVerificationEmail() }
        return when (result) {
            is Result.Success -> Result.Success(result.data.message)
            is Result.Error -> Result.Error(result.message, result.code)
            is Result.Loading -> Result.Loading
        }
    }

    override suspend fun verifyEmailWithCode(code: String): Result<User> {
        val result = safeApiCall { apiService.verifyEmailWithCode(VerifyEmailRequest(code)) }
        return when (result) {
            is Result.Success -> {
                sessionManager.saveUser(result.data.user)
                Result.Success(result.data.user)
            }
            is Result.Error -> Result.Error(result.message, result.code)
            is Result.Loading -> Result.Loading
        }
    }

    override suspend fun socialAuth(provider: String, idToken: String): Result<User> {
        val result = safeApiCall {
            apiService.socialAuth(provider, SocialAuthRequest(idToken = idToken))
        }
        return when (result) {
            is Result.Success -> {
                sessionManager.saveSession(result.data.token, result.data.user)
                Result.Success(result.data.user)
            }
            is Result.Error -> Result.Error(result.message, result.code)
            is Result.Loading -> Result.Loading
        }
    }
}
