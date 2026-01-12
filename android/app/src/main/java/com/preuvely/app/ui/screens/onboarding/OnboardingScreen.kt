package com.preuvely.app.ui.screens.onboarding

import androidx.annotation.DrawableRes
import androidx.annotation.StringRes
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.Crossfade
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.preuvely.app.R
import com.preuvely.app.ui.components.PrimaryButton
import com.preuvely.app.ui.theme.*
import kotlinx.coroutines.launch

data class OnboardingPage(
    @DrawableRes val imageRes: Int,
    @StringRes val titleRes: Int,
    @StringRes val descriptionRes: Int
)

private val onboardingPages = listOf(
    OnboardingPage(
        imageRes = R.drawable.onboarding_1,
        titleRes = R.string.onboarding_1_title,
        descriptionRes = R.string.onboarding_1_subtitle
    ),
    OnboardingPage(
        imageRes = R.drawable.onboarding_2,
        titleRes = R.string.onboarding_2_title,
        descriptionRes = R.string.onboarding_2_subtitle
    ),
    OnboardingPage(
        imageRes = R.drawable.onboarding_3,
        titleRes = R.string.onboarding_3_title,
        descriptionRes = R.string.onboarding_3_subtitle
    )
)

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun OnboardingScreen(
    onComplete: () -> Unit
) {
    val pagerState = rememberPagerState(pageCount = { onboardingPages.size })
    val coroutineScope = rememberCoroutineScope()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(White)
    ) {
        // Top section with image
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
        ) {
            // Background image with crossfade
            Crossfade(
                targetState = pagerState.currentPage,
                label = "background"
            ) { page ->
                Image(
                    painter = painterResource(id = onboardingPages[page].imageRes),
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            }

            // Skip button overlay
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .statusBarsPadding()
                    .padding(Spacing.screenPadding),
                horizontalArrangement = Arrangement.End
            ) {
                AnimatedVisibility(
                    visible = pagerState.currentPage < onboardingPages.size - 1,
                    enter = fadeIn(),
                    exit = fadeOut()
                ) {
                    TextButton(onClick = onComplete) {
                        Text(
                            text = stringResource(R.string.onboarding_skip),
                            style = PreuvelyTypography.subheadlineBold,
                            color = White
                        )
                    }
                }
            }
        }

        // Bottom section with white background
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(White)
                .padding(horizontal = Spacing.screenPadding)
                .padding(top = Spacing.md)
                .navigationBarsPadding(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Pages content (title and description)
            HorizontalPager(
                state = pagerState
            ) { page ->
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Title
                    Text(
                        text = stringResource(onboardingPages[page].titleRes),
                        style = PreuvelyTypography.title2,
                        color = PrimaryGreen,
                        textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(Spacing.sm))

                    // Description
                    Text(
                        text = stringResource(onboardingPages[page].descriptionRes),
                        style = PreuvelyTypography.body,
                        color = TextSecondary,
                        textAlign = TextAlign.Center,
                        modifier = Modifier.padding(horizontal = Spacing.md)
                    )
                }
            }

            Spacer(modifier = Modifier.height(Spacing.md))

            // Page indicators
            Row(
                horizontalArrangement = Arrangement.spacedBy(Spacing.sm),
                modifier = Modifier.padding(bottom = Spacing.md)
            ) {
                repeat(onboardingPages.size) { index ->
                    PageIndicator(isActive = index == pagerState.currentPage)
                }
            }

            // Buttons
            if (pagerState.currentPage == onboardingPages.size - 1) {
                // Last page - Get Started button
                PrimaryButton(
                    text = stringResource(R.string.onboarding_get_started),
                    onClick = onComplete,
                    icon = Icons.Default.ArrowForward
                )
            } else {
                // Continue button
                PrimaryButton(
                    text = stringResource(R.string.onboarding_continue),
                    onClick = {
                        coroutineScope.launch {
                            pagerState.animateScrollToPage(pagerState.currentPage + 1)
                        }
                    },
                    icon = Icons.Default.ArrowForward
                )
            }

            Spacer(modifier = Modifier.height(Spacing.sm))
        }
    }
}

@Composable
private fun OnboardingPageContent(page: OnboardingPage) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = Spacing.md),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Title
        Text(
            text = stringResource(page.titleRes),
            style = PreuvelyTypography.title2,
            color = PrimaryGreen,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(Spacing.md))

        // Description
        Text(
            text = stringResource(page.descriptionRes),
            style = PreuvelyTypography.body,
            color = TextSecondary,
            textAlign = TextAlign.Center,
            modifier = Modifier.padding(horizontal = Spacing.lg)
        )
    }
}

@Composable
private fun PageIndicator(isActive: Boolean) {
    Box(
        modifier = Modifier
            .size(
                width = if (isActive) 24.dp else 8.dp,
                height = 8.dp
            )
            .clip(RoundedCornerShape(4.dp))
            .background(
                if (isActive) {
                    Brush.linearGradient(listOf(PrimaryGreen, PrimaryGreenLight))
                } else {
                    Brush.linearGradient(listOf(Gray5, Gray5))
                }
            )
    )
}
