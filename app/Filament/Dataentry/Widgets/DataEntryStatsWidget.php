<?php

namespace App\Filament\Dataentry\Widgets;

use App\Models\Store;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class DataEntryStatsWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $user = Auth::user();

        // Stores submitted by this user
        $totalStores = Store::where('submitted_by', $user->id)->count();
        $thisWeekStores = Store::where('submitted_by', $user->id)
            ->where('created_at', '>=', Carbon::now()->startOfWeek())
            ->count();
        $thisMonthStores = Store::where('submitted_by', $user->id)
            ->where('created_at', '>=', Carbon::now()->startOfMonth())
            ->count();
        $pendingStores = Store::where('submitted_by', $user->id)
            ->where('is_verified', false)
            ->count();
        $verifiedStores = Store::where('submitted_by', $user->id)
            ->where('is_verified', true)
            ->count();

        // Calculate trend (compare to last week)
        $lastWeekStores = Store::where('submitted_by', $user->id)
            ->whereBetween('created_at', [
                Carbon::now()->subWeek()->startOfWeek(),
                Carbon::now()->subWeek()->endOfWeek()
            ])
            ->count();

        $trend = $lastWeekStores > 0
            ? round((($thisWeekStores - $lastWeekStores) / $lastWeekStores) * 100)
            : ($thisWeekStores > 0 ? 100 : 0);

        return [
            Stat::make('Total Stores Added', $totalStores)
                ->description('All time')
                ->descriptionIcon('heroicon-m-building-storefront')
                ->color('primary')
                ->chart([7, 12, 15, 20, 18, 25, $thisWeekStores]),

            Stat::make('This Week', $thisWeekStores)
                ->description($trend >= 0 ? "+{$trend}% from last week" : "{$trend}% from last week")
                ->descriptionIcon($trend >= 0 ? 'heroicon-m-arrow-trending-up' : 'heroicon-m-arrow-trending-down')
                ->color($trend >= 0 ? 'success' : 'danger'),

            Stat::make('This Month', $thisMonthStores)
                ->description(Carbon::now()->format('F Y'))
                ->descriptionIcon('heroicon-m-calendar')
                ->color('info'),

            Stat::make('Verified', $verifiedStores)
                ->description("{$pendingStores} pending verification")
                ->descriptionIcon('heroicon-m-check-badge')
                ->color('success'),
        ];
    }
}
