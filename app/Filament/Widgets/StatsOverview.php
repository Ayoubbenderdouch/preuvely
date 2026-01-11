<?php

namespace App\Filament\Widgets;

use App\Enums\ProofStatus;
use App\Enums\ReportStatus;
use App\Enums\ReviewStatus;
use App\Models\Report;
use App\Models\Review;
use App\Models\ReviewProof;
use App\Models\Store;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Total Stores', Store::count())
                ->description('Active stores in the platform')
                ->color('primary')
                ->icon('heroicon-o-building-storefront'),

            Stat::make('Data Entry Submissions', Store::whereNotNull('submitted_by')->count())
                ->description(Store::whereNotNull('submitted_by')->where('is_verified', false)->count() . ' pending verification')
                ->color('info')
                ->icon('heroicon-o-user-plus'),

            Stat::make('Pending Reviews', Review::where('status', ReviewStatus::Pending)->count())
                ->description('Awaiting approval')
                ->color('warning')
                ->icon('heroicon-o-clock'),

            Stat::make('Pending Proofs', ReviewProof::where('status', ProofStatus::Pending)->count())
                ->description('Proofs to review')
                ->color('warning')
                ->icon('heroicon-o-photo'),

            Stat::make('Open Reports', Report::where('status', ReportStatus::Open)->count())
                ->description('Reports to handle')
                ->color('danger')
                ->icon('heroicon-o-flag'),
        ];
    }
}
