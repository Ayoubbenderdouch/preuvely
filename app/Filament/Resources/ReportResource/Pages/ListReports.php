<?php

namespace App\Filament\Resources\ReportResource\Pages;

use App\Enums\ReportStatus;
use App\Filament\Resources\ReportResource;
use Filament\Resources\Components\Tab;
use Filament\Resources\Pages\ListRecords;
use Illuminate\Database\Eloquent\Builder;

class ListReports extends ListRecords
{
    protected static string $resource = ReportResource::class;

    public function getTabs(): array
    {
        return [
            'open' => Tab::make('Open')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', ReportStatus::Open))
                ->badge(fn () => ReportResource::getModel()::where('status', ReportStatus::Open)->count()),
            'all' => Tab::make('All'),
            'resolved' => Tab::make('Resolved')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', ReportStatus::Resolved)),
            'dismissed' => Tab::make('Dismissed')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', ReportStatus::Dismissed)),
        ];
    }
}
