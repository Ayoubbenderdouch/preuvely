package com.preuvely.app.di

import android.content.Context
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.preuvely.app.BuildConfig
import com.preuvely.app.data.api.ApiService
import com.preuvely.app.data.api.AuthInterceptor
import com.preuvely.app.data.local.CacheService
import com.preuvely.app.data.repository.*
import com.preuvely.app.utils.SessionManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideGson(): Gson {
        return GsonBuilder()
            .setDateFormat("yyyy-MM-dd'T'HH:mm:ss")
            .create()
    }

    @Provides
    @Singleton
    fun provideSessionManager(
        @ApplicationContext context: Context,
        gson: Gson
    ): SessionManager {
        return SessionManager(context, gson)
    }

    @Provides
    @Singleton
    fun provideAuthInterceptor(sessionManager: SessionManager): AuthInterceptor {
        return AuthInterceptor(sessionManager)
    }

    @Provides
    @Singleton
    fun provideOkHttpClient(authInterceptor: AuthInterceptor): OkHttpClient {
        val loggingInterceptor = HttpLoggingInterceptor().apply {
            level = if (BuildConfig.DEBUG) {
                HttpLoggingInterceptor.Level.BODY
            } else {
                HttpLoggingInterceptor.Level.NONE
            }
        }

        return OkHttpClient.Builder()
            .addInterceptor(authInterceptor)
            .addInterceptor(loggingInterceptor)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient, gson: Gson): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create(gson))
            .build()
    }

    @Provides
    @Singleton
    fun provideApiService(retrofit: Retrofit): ApiService {
        return retrofit.create(ApiService::class.java)
    }

    @Provides
    @Singleton
    fun provideCacheService(
        @ApplicationContext context: Context,
        gson: Gson
    ): CacheService {
        return CacheService(context, gson)
    }

    // Repositories
    @Provides
    @Singleton
    fun provideAuthRepository(
        apiService: ApiService,
        sessionManager: SessionManager
    ): AuthRepository {
        return AuthRepositoryImpl(apiService, sessionManager)
    }

    @Provides
    @Singleton
    fun provideStoreRepository(
        apiService: ApiService,
        cacheService: CacheService
    ): StoreRepository {
        return StoreRepositoryImpl(apiService, cacheService)
    }

    @Provides
    @Singleton
    fun provideReviewRepository(apiService: ApiService): ReviewRepository {
        return ReviewRepositoryImpl(apiService)
    }

    @Provides
    @Singleton
    fun provideCategoryRepository(
        apiService: ApiService,
        cacheService: CacheService
    ): CategoryRepository {
        return CategoryRepositoryImpl(apiService, cacheService)
    }

    @Provides
    @Singleton
    fun provideNotificationRepository(apiService: ApiService): NotificationRepository {
        return NotificationRepositoryImpl(apiService)
    }

    @Provides
    @Singleton
    fun provideUserRepository(apiService: ApiService): UserRepository {
        return UserRepositoryImpl(apiService)
    }
}
