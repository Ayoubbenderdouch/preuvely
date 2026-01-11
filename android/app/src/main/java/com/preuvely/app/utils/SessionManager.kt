package com.preuvely.app.utils

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.google.gson.Gson
import com.preuvely.app.data.models.User
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.launch
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "preuvely_prefs")

@Singleton
class SessionManager @Inject constructor(
    @ApplicationContext private val context: Context,
    private val gson: Gson
) {
    private val dataStore = context.dataStore

    companion object {
        private val AUTH_TOKEN = stringPreferencesKey("auth_token")
        private val USER_DATA = stringPreferencesKey("user_data")
        private val HAS_COMPLETED_ONBOARDING = booleanPreferencesKey("has_completed_onboarding")
        private val SELECTED_LANGUAGE = stringPreferencesKey("selected_language")
    }

    // Auth Token
    val authToken: Flow<String?> = dataStore.data.map { preferences ->
        preferences[AUTH_TOKEN]
    }

    suspend fun saveAuthToken(token: String) {
        dataStore.edit { preferences ->
            preferences[AUTH_TOKEN] = token
        }
    }

    // User Data
    val user: Flow<User?> = dataStore.data.map { preferences ->
        preferences[USER_DATA]?.let { json ->
            try {
                gson.fromJson(json, User::class.java)
            } catch (e: Exception) {
                null
            }
        }
    }

    suspend fun saveUser(user: User) {
        dataStore.edit { preferences ->
            preferences[USER_DATA] = gson.toJson(user)
        }
    }

    // Check if authenticated
    val isAuthenticated: Flow<Boolean> = dataStore.data.map { preferences ->
        !preferences[AUTH_TOKEN].isNullOrBlank()
    }

    // Onboarding
    val hasCompletedOnboarding: Flow<Boolean> = dataStore.data.map { preferences ->
        preferences[HAS_COMPLETED_ONBOARDING] ?: false
    }

    fun setOnboardingCompleted() {
        CoroutineScope(Dispatchers.IO).launch {
            dataStore.edit { preferences ->
                preferences[HAS_COMPLETED_ONBOARDING] = true
            }
        }
    }

    // Language
    val selectedLanguage: Flow<String> = dataStore.data.map { preferences ->
        preferences[SELECTED_LANGUAGE] ?: "en"
    }

    suspend fun saveLanguage(language: String) {
        dataStore.edit { preferences ->
            preferences[SELECTED_LANGUAGE] = language
        }
    }

    // Clear session (logout)
    suspend fun clearSession() {
        dataStore.edit { preferences ->
            preferences.remove(AUTH_TOKEN)
            preferences.remove(USER_DATA)
        }
    }

    // Save both token and user at once
    suspend fun saveSession(token: String, user: User) {
        dataStore.edit { preferences ->
            preferences[AUTH_TOKEN] = token
            preferences[USER_DATA] = gson.toJson(user)
        }
    }
}
