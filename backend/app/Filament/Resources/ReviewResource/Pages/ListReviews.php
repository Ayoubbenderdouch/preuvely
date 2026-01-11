<?php

namespace App\Filament\Resources\ReviewResource\Pages;

use App\Enums\ReviewStatus;
use App\Filament\Resources\ReviewResource;
use Filament\Actions;
use Filament\Resources\Components\Tab;
use Filament\Resources\Pages\ListRecords;
use Illuminate\Database\Eloquent\Builder;

class ListReviews extends ListRecords
{
    protected static string $resource = ReviewResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('high_risk_queue')
                ->label('High Risk Queue')
                ->icon('heroicon-o-exclamation-triangle')
                ->color('danger')
                ->url(ReviewResource::getUrl('high-risk'))
                ->badge(fn () => ReviewResource::getModel()::where('is_high_risk', true)->where('status', ReviewStatus::Pending)->count())
                ->badgeColor('danger'),
        ];
    }

    public function getTabs(): array
    {
        $model = ReviewResource::getModel();

        return [
            'all' => Tab::make('All Reviews')
                ->icon('heroicon-o-inbox'),

            'pending' => Tab::make('All Pending')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', ReviewStatus::Pending))
                ->badge(fn () => $model::where('status', ReviewStatus::Pending)->count())
                ->badgeColor('warning')
                ->icon('heroicon-o-clock'),

            'high_risk_pending' => Tab::make('High Risk Pending')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('is_high_risk', true)->where('status', ReviewStatus::Pending))
                ->badge(fn () => $model::where('is_high_risk', true)->where('status', ReviewStatus::Pending)->count())
                ->badgeColor('danger')
                ->icon('heroicon-o-exclamation-triangle'),

            'auto_approved' => Tab::make('Auto Approved')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('auto_approved', true))
                ->badge(fn () => $model::where('auto_approved', true)->count())
                ->badgeColor('success')
                ->icon('heroicon-o-bolt'),

            'manually_approved' => Tab::make('Manually Approved')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', ReviewStatus::Approved)->where('auto_approved', false))
                ->badge(fn () => $model::where('status', ReviewStatus::Approved)->where('auto_approved', false)->count())
                ->badgeColor('info')
                ->icon('heroicon-o-hand-raised'),

            'rejected' => Tab::make('Rejected')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', ReviewStatus::Rejected))
                ->badge(fn () => $model::where('status', ReviewStatus::Rejected)->count())
                ->badgeColor('gray')
                ->icon('heroicon-o-x-circle'),
        ];
    }
}
