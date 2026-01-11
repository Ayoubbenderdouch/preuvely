package com.preuvely.app.data.api

import com.preuvely.app.utils.SessionManager
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import okhttp3.Interceptor
import okhttp3.Response
import java.util.Locale
import javax.inject.Inject

class AuthInterceptor @Inject constructor(
    private val sessionManager: SessionManager
) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val originalRequest = chain.request()

        val token = runBlocking {
            sessionManager.authToken.first()
        }

        val language = Locale.getDefault().language.let {
            when (it) {
                "ar" -> "ar"
                "fr" -> "fr"
                else -> "en"
            }
        }

        val requestBuilder = originalRequest.newBuilder()
            .addHeader("Accept", "application/json")
            .addHeader("Content-Type", "application/json")
            .addHeader("Accept-Language", language)

        if (!token.isNullOrBlank()) {
            requestBuilder.addHeader("Authorization", "Bearer $token")
        }

        val request = requestBuilder.build()
        val response = chain.proceed(request)

        // Handle 401 Unauthorized - clear token
        if (response.code == 401) {
            runBlocking {
                sessionManager.clearSession()
            }
        }

        return response
    }
}
