<?php

namespace App\Filament\Dataentry\Pages;

use App\Models\Store;
use Filament\Pages\Dashboard as BaseDashboard;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\Auth;

class Dashboard extends BaseDashboard
{
    protected static ?string $navigationIcon = 'heroicon-o-home';

    protected static string $view = 'filament.dataentry.pages.dashboard';

    protected static ?string $title = 'Dashboard';

    public function getWidgets(): array
    {
        return [
            \App\Filament\Dataentry\Widgets\DataEntryStatsWidget::class,
            \App\Filament\Dataentry\Widgets\RecentStoresWidget::class,
        ];
    }

    public function getColumns(): int | string | array
    {
        return 1;
    }
}
