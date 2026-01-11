<?php

namespace App\Filament\Resources\UserResource\RelationManagers;

use App\Enums\StoreStatus;
use App\Filament\Resources\StoreResource;
use App\Models\AuditLog;
use App\Models\Store;
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
                    ->disk('public')
                    ->circular()
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&background=22c55e&color=fff'),
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->description(fn (Store $record) => $record->categories->pluck('name_en')->implode(', ')),
                Tables\Columns\TextColumn::make('city')
                    ->searchable()
                    ->placeholder('N/A'),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (StoreStatus $state) => $state->color()),
                Tables\Columns\IconColumn::make('is_verified')
                    ->label('Verified')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-badge')
                    ->trueColor('success'),
                Tables\Columns\TextColumn::make('avg_rating_cache')
                    ->label('Rating')
                    ->formatStateUsing(fn ($state) => $state ? number_format($state, 1) . '/5' : 'N/A'),
                Tables\Columns\TextColumn::make('reviews_count_cache')
                    ->label('Reviews'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Submitted')
                    ->dateTime('M d, Y')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(collect(StoreStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()])),
                Tables\Filters\TernaryFilter::make('is_verified')
                    ->label('Verified'),
            ])
            ->headerActions([])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('View')
                    ->icon('heroicon-o-eye')
                    ->url(fn (Store $record) => StoreResource::getUrl('view', ['record' => $record])),
                Tables\Actions\Action::make('edit')
                    ->label('Edit')
                    ->icon('heroicon-o-pencil')
                    ->url(fn (Store $record) => StoreResource::getUrl('edit', ['record' => $record])),
                Tables\Actions\Action::make('verify')
                    ->label('Verify')
                    ->icon('heroicon-o-check-badge')
                    ->color('success')
                    ->visible(fn (Store $record) => !$record->is_verified)
                    ->requiresConfirmation()
                    ->action(function (Store $record) {
                        $record->update([
                            'is_verified' => true,
                            'verified_at' => now(),
                            'verified_by' => auth()->id(),
                        ]);
                        AuditLog::log('store.verified', 'Store', $record->id);
                    }),
                Tables\Actions\Action::make('suspend')
                    ->label('Suspend')
                    ->icon('heroicon-o-no-symbol')
                    ->color('danger')
                    ->visible(fn (Store $record) => $record->status === StoreStatus::Active)
                    ->requiresConfirmation()
                    ->action(function (Store $record) {
                        $record->update(['status' => StoreStatus::Suspended]);
                        AuditLog::log('store.suspended', 'Store', $record->id);
                    }),
            ])
            ->bulkActions([])
            ->defaultSort('created_at', 'desc');
    }
}
