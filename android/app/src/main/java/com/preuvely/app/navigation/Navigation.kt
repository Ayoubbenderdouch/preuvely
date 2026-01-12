package com.preuvely.app.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.preuvely.app.ui.screens.MainScreen
import com.preuvely.app.ui.screens.auth.AuthScreen
import com.preuvely.app.ui.screens.store.StoreDetailsScreen
import com.preuvely.app.ui.screens.category.CategoryStoresScreen
import com.preuvely.app.ui.screens.user.UserProfileScreen
import com.preuvely.app.ui.screens.editstore.EditStoreScreen
import com.preuvely.app.ui.screens.notifications.NotificationsScreen
import com.preuvely.app.ui.screens.onboarding.OnboardingScreen
import com.preuvely.app.ui.screens.mystores.MyStoresScreen
import com.preuvely.app.ui.screens.profile.LegalScreen
import com.preuvely.app.ui.screens.profile.LegalType

sealed class Screen(val route: String) {
    object Onboarding : Screen("onboarding")
    object Main : Screen("main")
    object Auth : Screen("auth")
    object StoreDetails : Screen("store/{slug}") {
        fun createRoute(slug: String) = "store/$slug"
    }
    object CategoryStores : Screen("category/{categoryId}/{categorySlug}") {
        fun createRoute(categoryId: Int, categorySlug: String) = "category/$categoryId/$categorySlug"
    }
    object UserProfile : Screen("user/{userId}") {
        fun createRoute(userId: Int) = "user/$userId"
    }
    object EditStore : Screen("edit-store/{storeId}") {
        fun createRoute(storeId: Int) = "edit-store/$storeId"
    }
    object MyStores : Screen("my-stores")
    object Notifications : Screen("notifications")
    object Terms : Screen("terms")
    object Privacy : Screen("privacy")
}

@Composable
fun PreuvelyNavHost(
    navController: NavHostController = rememberNavController(),
    startDestination: String = Screen.Main.route
) {
    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable(Screen.Onboarding.route) {
            OnboardingScreen(
                onComplete = {
                    navController.navigate(Screen.Main.route) {
                        popUpTo(Screen.Onboarding.route) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.Main.route) {
            MainScreen(
                onNavigateToStore = { slug ->
                    navController.navigate(Screen.StoreDetails.createRoute(slug))
                },
                onNavigateToCategory = { categoryId, categorySlug ->
                    navController.navigate(Screen.CategoryStores.createRoute(categoryId, categorySlug))
                },
                onNavigateToAuth = {
                    navController.navigate(Screen.Auth.route)
                },
                onNavigateToUser = { userId ->
                    navController.navigate(Screen.UserProfile.createRoute(userId))
                },
                onNavigateToEditStore = { storeId ->
                    navController.navigate(Screen.EditStore.createRoute(storeId))
                },
                onNavigateToNotifications = {
                    navController.navigate(Screen.Notifications.route)
                },
                onNavigateToMyStores = {
                    navController.navigate(Screen.MyStores.route)
                },
                onNavigateToTerms = {
                    navController.navigate(Screen.Terms.route)
                },
                onNavigateToPrivacy = {
                    navController.navigate(Screen.Privacy.route)
                }
            )
        }

        composable(Screen.Auth.route) {
            AuthScreen(
                onNavigateBack = { navController.popBackStack() },
                onAuthSuccess = { navController.popBackStack() }
            )
        }

        composable(
            route = Screen.StoreDetails.route,
            arguments = listOf(navArgument("slug") { type = NavType.StringType })
        ) { backStackEntry ->
            val slug = backStackEntry.arguments?.getString("slug") ?: ""
            StoreDetailsScreen(
                slug = slug,
                onNavigateBack = { navController.popBackStack() },
                onNavigateToUser = { userId ->
                    navController.navigate(Screen.UserProfile.createRoute(userId))
                },
                onNavigateToAuth = {
                    navController.navigate(Screen.Auth.route)
                }
            )
        }

        composable(
            route = Screen.CategoryStores.route,
            arguments = listOf(
                navArgument("categoryId") { type = NavType.IntType },
                navArgument("categorySlug") { type = NavType.StringType }
            )
        ) {
            CategoryStoresScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToStore = { storeSlug ->
                    navController.navigate(Screen.StoreDetails.createRoute(storeSlug))
                }
            )
        }

        composable(
            route = Screen.UserProfile.route,
            arguments = listOf(navArgument("userId") { type = NavType.IntType })
        ) {
            UserProfileScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToStore = { slug ->
                    navController.navigate(Screen.StoreDetails.createRoute(slug))
                }
            )
        }

        composable(
            route = Screen.EditStore.route,
            arguments = listOf(navArgument("storeId") { type = NavType.IntType })
        ) {
            EditStoreScreen(
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(Screen.MyStores.route) {
            MyStoresScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToEditStore = { storeId ->
                    navController.navigate(Screen.EditStore.createRoute(storeId))
                },
                onNavigateToStore = { slug ->
                    navController.navigate(Screen.StoreDetails.createRoute(slug))
                }
            )
        }

        composable(Screen.Notifications.route) {
            NotificationsScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToStore = { slug ->
                    navController.navigate(Screen.StoreDetails.createRoute(slug))
                }
            )
        }

        composable(Screen.Terms.route) {
            LegalScreen(
                legalType = LegalType.TERMS,
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable(Screen.Privacy.route) {
            LegalScreen(
                legalType = LegalType.PRIVACY,
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}
