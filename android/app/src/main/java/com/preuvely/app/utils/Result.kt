package com.preuvely.app.utils

sealed class Result<out T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error(val message: String, val code: Int? = null) : Result<Nothing>()
    object Loading : Result<Nothing>()

    val isSuccess: Boolean get() = this is Success
    val isError: Boolean get() = this is Error
    val isLoading: Boolean get() = this is Loading

    fun getOrNull(): T? = when (this) {
        is Success -> data
        else -> null
    }

    fun getOrDefault(default: @UnsafeVariance T): T = when (this) {
        is Success -> data
        else -> default
    }

    fun <R> map(transform: (T) -> R): Result<R> = when (this) {
        is Success -> Success(transform(data))
        is Error -> Error(message, code)
        is Loading -> Loading
    }

    companion object {
        fun <T> success(data: T): Result<T> = Success(data)
        fun error(message: String, code: Int? = null): Result<Nothing> = Error(message, code)
        fun loading(): Result<Nothing> = Loading
    }
}

// Extension function to handle API responses
suspend fun <T> safeApiCall(
    apiCall: suspend () -> retrofit2.Response<T>
): Result<T> {
    return try {
        val response = apiCall()
        if (response.isSuccessful) {
            response.body()?.let {
                Result.Success(it)
            } ?: Result.Error("Empty response body")
        } else {
            val errorBody = response.errorBody()?.string()
            val errorMessage = try {
                val gson = com.google.gson.Gson()
                val errorResponse = gson.fromJson(errorBody, com.preuvely.app.data.models.ErrorResponse::class.java)
                errorResponse.firstError
            } catch (e: Exception) {
                errorBody ?: "Unknown error occurred"
            }
            Result.Error(errorMessage, response.code())
        }
    } catch (e: java.io.IOException) {
        Result.Error("Network error. Please check your connection.")
    } catch (e: Exception) {
        Result.Error(e.message ?: "Unknown error occurred")
    }
}
