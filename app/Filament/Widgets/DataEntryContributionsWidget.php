<?php

namespace App\Filament\Widgets;

use App\Models\Store;
use App\Models\User;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class DataEntryContributionsWidget extends BaseWidget
{
    protected static ?int $sort = 2;

    protected int | string | array $columnSpan = 'full';

    public function getTableHeading(): string
    {
        return 'Data Entry Contributions';
    }

    public function table(Table $table): Table
    {
        return $table
            ->query(
                User::query()
                    ->whereHas('roles', fn (Builder $q) => $q->where('name', 'data_entry'))
                    ->withCount(['submittedStores as total_stores'])
                    ->withCount(['submittedStores as verified_stores' => fn ($q) => $q->where('is_verified', true)])
                    ->withCount(['submittedStores as pending_stores' => fn ($q) => $q->where('is_verified', false)])
                    ->withCount(['submittedStores as this_week' => fn ($q) => $q->where('created_at', '>=', now()->startOfWeek())])
                    ->orderByDesc('total_stores')
            )
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Employee')
                    ->searchable()
                    ->icon('heroicon-o-user')
                    ->weight('bold'),
                Tables\Columns\TextColumn::make('email')
                    ->label('Email')
                    ->searchable()
                    ->color('gray')
                    ->size('sm'),
                Tables\Columns\TextColumn::make('total_stores')
                    ->label('Total Stores')
                    ->badge()
                    ->color('primary')
                    ->sortable(),
                Tables\Columns\TextColumn::make('verified_stores')
                    ->label('Verified')
                    ->badge()
                    ->color('success')
                    ->sortable(),
                Tables\Columns\TextColumn::make('pending_stores')
                    ->label('Pending')
                    ->badge()
                    ->color('warning')
                    ->sortable(),
                Tables\Columns\TextColumn::make('this_week')
                    ->label('This Week')
                    ->badge()
                    ->color('info')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Joined')
                    ->since()
                    ->color('gray'),
            ])
            ->defaultSort('total_stores', 'desc')
            ->emptyStateHeading('No data entry employees yet')
            ->emptyStateDescription('Create data entry users to start tracking contributions')
            ->emptyStateIcon('heroicon-o-users');
    }
}
