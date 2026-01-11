<?php

namespace App\Filament\Resources\ReviewProofResource\Pages;

use App\Enums\ProofStatus;
use App\Filament\Resources\ReviewProofResource;
use Filament\Resources\Components\Tab;
use Filament\Resources\Pages\ListRecords;
use Illuminate\Database\Eloquent\Builder;

class ListReviewProofs extends ListRecords
{
    protected static string $resource = ReviewProofResource::class;

    public function getTabs(): array
    {
        return [
            'pending' => Tab::make('Pending')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', ProofStatus::Pending))
                ->badge(fn () => ReviewProofResource::getModel()::where('status', ProofStatus::Pending)->count()),
            'all' => Tab::make('All'),
            'approved' => Tab::make('Approved')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', ProofStatus::Approved)),
            'rejected' => Tab::make('Rejected')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', ProofStatus::Rejected)),
        ];
    }
}
