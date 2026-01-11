<?php

namespace App\Providers\Filament;

use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\AuthenticateSession;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Widgets;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\View\Middleware\ShareErrorsFromSession;

class DataentryPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->id('dataentry')
            ->path('dataentry')
            ->login()
            ->brandName('Preuvely Data Entry')
            ->brandLogo(null)
            ->favicon(asset('favicon.ico'))
            ->colors([
                'primary' => Color::Emerald,
                'danger' => Color::Rose,
                'warning' => Color::Amber,
                'success' => Color::Green,
                'info' => Color::Sky,
            ])
            ->font('Inter')
            ->darkMode()
            ->sidebarCollapsibleOnDesktop()
            ->navigationGroups([
                'Stores',
            ])
            ->discoverResources(in: app_path('Filament/Dataentry/Resources'), for: 'App\\Filament\\Dataentry\\Resources')
            ->discoverPages(in: app_path('Filament/Dataentry/Pages'), for: 'App\\Filament\\Dataentry\\Pages')
            ->pages([
                \App\Filament\Dataentry\Pages\Dashboard::class,
            ])
            ->discoverWidgets(in: app_path('Filament/Dataentry/Widgets'), for: 'App\\Filament\\Dataentry\\Widgets')
            ->widgets([])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])
            ->authMiddleware([
                Authenticate::class,
            ])
            ->authGuard('web')
            ->profile()
            ->maxContentWidth('full')
            ->topNavigation(false);
    }
}
