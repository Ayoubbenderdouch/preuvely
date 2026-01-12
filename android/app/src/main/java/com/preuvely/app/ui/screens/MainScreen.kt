package com.preuvely.app.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.foundation.Image
import com.preuvely.app.R
import com.preuvely.app.ui.screens.home.HomeScreen
import com.preuvely.app.ui.screens.search.SearchScreen
import com.preuvely.app.ui.screens.addstore.AddStoreScreen
import com.preuvely.app.ui.screens.profile.ProfileScreen
import com.preuvely.app.ui.theme.*

enum class TabItem(
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
    val labelRes: Int,
    val iconRes: Int
) {
    Home(Icons.Filled.Home, Icons.Outlined.Home, R.string.tab_home, R.drawable.ic_home),
    Search(Icons.Filled.Search, Icons.Outlined.Search, R.string.tab_search, R.drawable.ic_search),
    Add(Icons.Filled.Add, Icons.Outlined.Add, R.string.tab_add, R.drawable.ic_add),
    Profile(Icons.Filled.Person, Icons.Outlined.Person, R.string.tab_profile, R.drawable.ic_profile)
}

@Composable
fun MainScreen(
    onNavigateToStore: (String) -> Unit,
    onNavigateToCategory: (Int, String) -> Unit,
    onNavigateToAuth: () -> Unit,
    onNavigateToUser: (Int) -> Unit,
    onNavigateToEditStore: (Int) -> Unit,
    onNavigateToNotifications: () -> Unit,
    onNavigateToMyStores: () -> Unit = {},
    onNavigateToTerms: () -> Unit = {},
    onNavigateToPrivacy: () -> Unit = {}
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    var addButtonRotation by remember { mutableFloatStateOf(0f) }

    val animatedRotation by animateFloatAsState(
        targetValue = addButtonRotation,
        animationSpec = spring(dampingRatio = 0.6f),
        label = "rotation"
    )

    Box(modifier = Modifier.fillMaxSize()) {
        // Content
        when (selectedTab) {
            0 -> HomeScreen(
                onNavigateToStore = onNavigateToStore,
                onNavigateToCategory = onNavigateToCategory,
                onNavigateToNotifications = onNavigateToNotifications,
                onNavigateToSearch = { selectedTab = 1 }
            )
            1 -> SearchScreen(
                onNavigateToStore = onNavigateToStore,
                onNavigateToAddStore = { selectedTab = 2 }
            )
            2 -> AddStoreScreen(
                onNavigateToStore = onNavigateToStore,
                onNavigateToAuth = onNavigateToAuth
            )
            3 -> ProfileScreen(
                onNavigateToAuth = onNavigateToAuth,
                onNavigateToStore = onNavigateToStore,
                onNavigateToUser = onNavigateToUser,
                onNavigateToEditStore = onNavigateToEditStore,
                onNavigateToNotifications = onNavigateToNotifications,
                onNavigateToTerms = onNavigateToTerms,
                onNavigateToPrivacy = onNavigateToPrivacy
            )
        }

        // Floating Tab Bar
        Box(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .padding(bottom = 28.dp)
        ) {
            // Tab bar background
            Box(
                modifier = Modifier
                    .shadow(
                        elevation = 20.dp,
                        shape = RoundedCornerShape(35.dp),
                        ambientColor = Color.Black.copy(alpha = 0.15f),
                        spotColor = Color.Black.copy(alpha = 0.15f)
                    )
                    .clip(RoundedCornerShape(35.dp))
                    .background(
                        color = White.copy(alpha = 0.95f)
                    )
                    .padding(horizontal = 24.dp, vertical = 12.dp)
            ) {
                Row(
                    horizontalArrangement = Arrangement.spacedBy(24.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    TabItem.entries.forEachIndexed { index, tab ->
                        TabButton(
                            tab = tab,
                            isSelected = selectedTab == index,
                            onClick = { selectedTab = index }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun TabButton(
    tab: TabItem,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.92f else 1f,
        animationSpec = spring(dampingRatio = 0.7f),
        label = "scale"
    )

    val label = stringResource(tab.labelRes)
    Column(
        modifier = Modifier
            .scale(scale)
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            )
            .padding(horizontal = 8.dp, vertical = 4.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Image(
            painter = painterResource(id = tab.iconRes),
            contentDescription = label,
            modifier = Modifier
                .size(38.dp)
                .alpha(if (isSelected) 1f else 0.5f),
            contentScale = ContentScale.Fit
        )
        Spacer(modifier = Modifier.height(6.dp))
        Text(
            text = label,
            style = PreuvelyTypography.caption1.copy(
                fontWeight = if (isSelected) androidx.compose.ui.text.font.FontWeight.SemiBold
                    else androidx.compose.ui.text.font.FontWeight.Normal
            ),
            color = if (isSelected) PrimaryGreen else Gray2
        )
    }
}

@Composable
private fun AddTabButton(
    isSelected: Boolean,
    rotation: Float,
    onClick: () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.9f else 1f,
        animationSpec = spring(dampingRatio = 0.7f),
        label = "scale"
    )

    Column(
        modifier = Modifier
            .scale(scale)
            .clickable(
                interactionSource = interactionSource,
                indication = null,
                onClick = onClick
            )
            .padding(horizontal = Spacing.md, vertical = Spacing.xs),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Image(
            painter = painterResource(id = R.drawable.ic_add),
            contentDescription = "Add",
            modifier = Modifier
                .size(32.dp)
                .alpha(if (isSelected) 1f else 0.5f),
            contentScale = ContentScale.Fit
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = "Add",
            style = PreuvelyTypography.caption2.copy(
                fontWeight = if (isSelected) androidx.compose.ui.text.font.FontWeight.SemiBold
                    else androidx.compose.ui.text.font.FontWeight.Normal
            ),
            color = if (isSelected) PrimaryGreen else Gray2
        )
    }
}
