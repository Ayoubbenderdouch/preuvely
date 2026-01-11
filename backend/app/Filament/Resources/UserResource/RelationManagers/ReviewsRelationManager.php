<?php

namespace App\Filament\Resources\UserResource\RelationManagers;

use App\Enums\ReviewStatus;
use App\Filament\Resources\ReviewResource;
use App\Filament\Resources\StoreResource;
use App\Models\AuditLog;
use App\Models\Review;
use Filament\Forms;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ReviewsRelationManager extends RelationManager
{
    protected static string $relationship = 'reviews';
    protected static ?string $title = 'Reviews';
    protected static ?string $icon = 'heroicon-o-star';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('id')
            ->columns([
                Tables\Columns\TextColumn::make('store.name')
                    ->label('Store')
                    ->searchable()
                    ->sortable()
                    ->limit(30)
                    ->url(fn (Review $record) => $record->store ? StoreResource::getUrl('view', ['record' => $record->store]) : null)
                    ->description(fn (Review $record) => $record->store?->categories->pluck('name_en')->implode(', ')),
                Tables\Columns\TextColumn::make('stars')
                    ->label('Rating')
                    ->formatStateUsing(fn ($state) => str_repeat('*', $state) . ' (' . $state . '/5)'),
                Tables\Columns\TextColumn::make('comment')
                    ->label('Review')
                    ->limit(40)
                    ->wrap()
                    ->tooltip(fn ($state) => $state),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (Review $record): string => ReviewResource::getStatusBadgeColor($record))
                    ->formatStateUsing(fn (Review $record): string => ReviewResource::getStatusBadgeLabel($record)),
                Tables\Columns\IconColumn::make('is_high_risk')
                    ->label('High Risk')
                    ->boolean()
                    ->trueIcon('heroicon-o-exclamation-triangle')
                    ->trueColor('danger')
                    ->falseIcon('heroicon-o-check-circle')
                    ->falseColor('gray'),
                Tables\Columns\TextColumn::make('proofs_count')
                    ->label('Proofs')
                    ->counts('proofs'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Date')
                    ->dateTime('M d, Y')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(collect(ReviewStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()])),
                Tables\Filters\TernaryFilter::make('is_high_risk')
                    ->label('High Risk'),
            ])
            ->headerActions([])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('View')
                    ->icon('heroicon-o-eye')
                    ->url(fn (Review $record) => ReviewResource::getUrl('view', ['record' => $record])),
                Tables\Actions\Action::make('approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn (Review $record) => $record->status === ReviewStatus::Pending)
                    ->requiresConfirmation()
                    ->action(function (Review $record) {
                        $record->update([
                            'status' => ReviewStatus::Approved,
                            'approved_by' => auth()->id(),
                            'approved_at' => now(),
                        ]);
                        $record->store->recalculateRatings();
                        AuditLog::log('review.approved', 'Review', $record->id);
                    }),
                Tables\Actions\Action::make('reject')
                    ->label('Reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (Review $record) => $record->status !== ReviewStatus::Rejected)
                    ->form([
                        Forms\Components\Textarea::make('rejected_reason')
                            ->label('Rejection Reason')
                            ->required()
                            ->maxLength(500),
                    ])
                    ->action(function (Review $record, array $data) {
                        $record->update([
                            'status' => ReviewStatus::Rejected,
                            'rejected_reason' => $data['rejected_reason'],
                        ]);
                        $record->store->recalculateRatings();
                        AuditLog::log('review.rejected', 'Review', $record->id, null, [
                            'reason' => $data['rejected_reason'],
                        ]);
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('approveSelected')
                        ->label('Approve Selected')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->action(function ($records) {
                            $records->each(function (Review $record) {
                                if ($record->status === ReviewStatus::Pending) {
                                    $record->update([
                                        'status' => ReviewStatus::Approved,
                                        'approved_by' => auth()->id(),
                                        'approved_at' => now(),
                                    ]);
                                    $record->store->recalculateRatings();
                                    AuditLog::log('review.approved', 'Review', $record->id);
                                }
                            });
                        }),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }
}
