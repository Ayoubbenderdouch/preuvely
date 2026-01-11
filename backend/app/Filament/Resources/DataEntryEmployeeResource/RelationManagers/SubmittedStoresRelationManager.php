<?php

namespace App\Filament\Resources\DataEntryEmployeeResource\RelationManagers;

use App\Enums\StoreStatus;
use App\Filament\Resources\StoreResource;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class SubmittedStoresRelationManager extends RelationManager
{
    protected static string $relationship = 'submittedStores';

    protected static ?string $title = 'Submitted Stores';

    protected static ?string $icon = 'heroicon-o-building-storefront';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('name')
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->label('')
                    ->disk('public')
                    ->circular()
                    ->size(40)
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name ?? 'S') . '&color=10b981&background=d1fae5&size=100'),
                Tables\Columns\TextColumn::make('name')
                    ->label('Store Name')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->description(fn ($record) => $record->categories->pluck('name_en')->implode(', ') ?: 'No category'),
                Tables\Columns\TextColumn::make('links_count')
                    ->label('Links')
                    ->counts('links')
                    ->badge()
                    ->color('info'),
                Tables\Columns\IconColumn::make('is_verified')
                    ->label('Verified')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-badge')
                    ->falseIcon('heroicon-o-clock')
                    ->trueColor('success')
                    ->falseColor('warning'),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (StoreStatus $state) => $state->color()),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Added')
                    ->since()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\TernaryFilter::make('is_verified')
                    ->label('Verified'),
            ])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('View Store')
                    ->icon('heroicon-o-eye')
                    ->url(fn ($record) => StoreResource::getUrl('view', ['record' => $record])),
                Tables\Actions\Action::make('verify')
                    ->label('Verify')
                    ->icon('heroicon-o-check-badge')
                    ->color('success')
                    ->visible(fn ($record) => !$record->is_verified)
                    ->requiresConfirmation()
                    ->action(function ($record) {
                        $record->update([
                            'is_verified' => true,
                            'verified_at' => now(),
                            'verified_by' => auth()->id(),
                        ]);
                    }),
            ])
            ->emptyStateHeading('No stores submitted yet')
            ->emptyStateDescription('This employee has not added any stores yet')
            ->emptyStateIcon('heroicon-o-building-storefront');
    }
}
