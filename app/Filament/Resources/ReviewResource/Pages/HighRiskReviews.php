<?php

namespace App\Filament\Resources\ReviewResource\Pages;

use App\Enums\ReviewStatus;
use App\Filament\Resources\ReviewResource;
use App\Models\AuditLog;
use App\Models\Review;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Pages\ListRecords;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class HighRiskReviews extends ListRecords
{
    protected static string $resource = ReviewResource::class;

    protected static ?string $title = 'High Risk Reviews Queue';

    protected static ?string $navigationIcon = 'heroicon-o-exclamation-triangle';

    protected function getTableQuery(): Builder
    {
        return parent::getTableQuery()
            ->where('is_high_risk', true)
            ->where('status', ReviewStatus::Pending)
            ->orderBy('created_at', 'asc'); // Oldest first for FIFO processing
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('back_to_all')
                ->label('Back to All Reviews')
                ->icon('heroicon-o-arrow-left')
                ->color('gray')
                ->url(ReviewResource::getUrl('index')),

            Actions\Action::make('refresh')
                ->label('Refresh')
                ->icon('heroicon-o-arrow-path')
                ->color('primary')
                ->action(fn () => $this->resetTable()),
        ];
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#')
                    ->sortable(),
                Tables\Columns\TextColumn::make('store.name')
                    ->label('Store')
                    ->searchable()
                    ->limit(30)
                    ->description(fn (Review $record) => $record->store?->categories->pluck('name_en')->implode(', ')),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('Reviewer')
                    ->searchable(),
                Tables\Columns\TextColumn::make('stars')
                    ->label('Rating')
                    ->formatStateUsing(fn ($state) => str_repeat('*', $state) . " ({$state}/5)"),
                Tables\Columns\TextColumn::make('comment')
                    ->label('Review Comment')
                    ->limit(100)
                    ->wrap()
                    ->searchable(),
                Tables\Columns\TextColumn::make('proofs_count')
                    ->label('Proofs')
                    ->counts('proofs')
                    ->badge()
                    ->color(fn ($state) => $state > 0 ? 'success' : 'warning'),
                Tables\Columns\ImageColumn::make('proofs.file_path')
                    ->label('Proof Images')
                    ->disk('public')
                    ->circular()
                    ->stacked()
                    ->limit(3)
                    ->limitedRemainingText()
                    ->size(50)
                    ->extraImgAttributes(['class' => 'object-cover'])
                    ->defaultImageUrl(url('/images/no-proof.png')),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Submitted')
                    ->dateTime()
                    ->sortable()
                    ->description(fn (Review $record) => $record->created_at->diffForHumans()),
            ])
            ->defaultSort('created_at', 'asc')
            ->poll('30s') // Auto-refresh every 30 seconds
            ->striped()
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->icon('heroicon-o-eye'),

                Tables\Actions\Action::make('view_proofs')
                    ->label('View Proofs')
                    ->icon('heroicon-o-photo')
                    ->color('info')
                    ->visible(fn (Review $record) => $record->proofs()->count() > 0)
                    ->modalHeading(fn (Review $record) => "Proof Images for Review #{$record->id}")
                    ->modalDescription(fn (Review $record) => "Store: {$record->store->name} | Reviewer: {$record->user->name} | Rating: {$record->stars}/5")
                    ->modalContent(fn (Review $record) => view('filament.modals.review-proofs', ['review' => $record]))
                    ->modalSubmitAction(false)
                    ->modalCancelActionLabel('Close'),

                Tables\Actions\Action::make('quick_approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('Approve High Risk Review')
                    ->modalDescription('Are you sure you want to approve this high-risk review? This action cannot be undone.')
                    ->modalSubmitActionLabel('Yes, Approve')
                    ->action(function (Review $record) {
                        $record->update([
                            'status' => ReviewStatus::Approved,
                            'approved_by' => auth()->id(),
                            'approved_at' => now(),
                            'auto_approved' => false,
                        ]);
                        $record->store->recalculateRatings();
                        AuditLog::log('review.approved', 'Review', $record->id, null, [
                            'high_risk' => true,
                            'approval_type' => 'manual',
                        ]);
                    })
                    ->successNotificationTitle('Review approved successfully'),

                Tables\Actions\Action::make('quick_reject')
                    ->label('Reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->form([
                        Forms\Components\Select::make('rejection_template')
                            ->label('Quick Rejection Reason')
                            ->options([
                                'fake_review' => 'Suspected fake or fraudulent review',
                                'no_proof' => 'Insufficient proof of purchase/interaction',
                                'inappropriate' => 'Inappropriate or offensive content',
                                'competitor' => 'Suspected competitor review',
                                'spam' => 'Spam or promotional content',
                                'other' => 'Other (specify below)',
                            ])
                            ->reactive()
                            ->afterStateUpdated(function ($state, Forms\Set $set) {
                                $templates = [
                                    'fake_review' => 'This review has been rejected as it appears to be fake or fraudulent.',
                                    'no_proof' => 'This review has been rejected due to insufficient proof of purchase or interaction with the store.',
                                    'inappropriate' => 'This review has been rejected due to inappropriate or offensive content.',
                                    'competitor' => 'This review has been rejected as it appears to be from a competitor.',
                                    'spam' => 'This review has been rejected as it contains spam or promotional content.',
                                    'other' => '',
                                ];
                                $set('rejected_reason', $templates[$state] ?? '');
                            }),
                        Forms\Components\Textarea::make('rejected_reason')
                            ->label('Rejection Reason')
                            ->required()
                            ->maxLength(500)
                            ->rows(3),
                    ])
                    ->action(function (Review $record, array $data) {
                        $record->update([
                            'status' => ReviewStatus::Rejected,
                            'rejected_reason' => $data['rejected_reason'],
                        ]);
                        $record->store->recalculateRatings();
                        AuditLog::log('review.rejected', 'Review', $record->id, null, [
                            'reason' => $data['rejected_reason'],
                            'high_risk' => true,
                        ]);
                    })
                    ->successNotificationTitle('Review rejected'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('bulk_approve')
                        ->label('Approve Selected')
                        ->icon('heroicon-o-check-circle')
                        ->color('success')
                        ->requiresConfirmation()
                        ->modalHeading('Approve Selected High Risk Reviews')
                        ->modalDescription('Are you sure you want to approve all selected high-risk reviews?')
                        ->deselectRecordsAfterCompletion()
                        ->action(function ($records) {
                            $records->each(function (Review $record) {
                                $record->update([
                                    'status' => ReviewStatus::Approved,
                                    'approved_by' => auth()->id(),
                                    'approved_at' => now(),
                                    'auto_approved' => false,
                                ]);
                                $record->store->recalculateRatings();
                                AuditLog::log('review.approved', 'Review', $record->id, null, [
                                    'high_risk' => true,
                                    'approval_type' => 'bulk_manual',
                                ]);
                            });
                        }),

                    Tables\Actions\BulkAction::make('bulk_reject')
                        ->label('Reject Selected')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->form([
                            Forms\Components\Textarea::make('rejected_reason')
                                ->label('Rejection Reason (applied to all)')
                                ->required()
                                ->maxLength(500)
                                ->default('This review has been rejected after manual review of high-risk content.'),
                        ])
                        ->action(function ($records, array $data) {
                            $records->each(function (Review $record) use ($data) {
                                $record->update([
                                    'status' => ReviewStatus::Rejected,
                                    'rejected_reason' => $data['rejected_reason'],
                                ]);
                                $record->store->recalculateRatings();
                                AuditLog::log('review.rejected', 'Review', $record->id, null, [
                                    'reason' => $data['rejected_reason'],
                                    'high_risk' => true,
                                ]);
                            });
                        }),
                ]),
            ])
            ->emptyStateHeading('No High Risk Reviews Pending')
            ->emptyStateDescription('All high-risk reviews have been processed. Great work!')
            ->emptyStateIcon('heroicon-o-check-circle');
    }

    protected function getHeaderWidgets(): array
    {
        return [
            // Could add stats widgets here
        ];
    }

    public function getSubheading(): ?string
    {
        $count = Review::where('is_high_risk', true)
            ->where('status', ReviewStatus::Pending)
            ->count();

        if ($count === 0) {
            return 'No high-risk reviews pending approval.';
        }

        $oldest = Review::where('is_high_risk', true)
            ->where('status', ReviewStatus::Pending)
            ->oldest()
            ->first();

        $waitTime = $oldest ? $oldest->created_at->diffForHumans() : 'N/A';

        return "{$count} high-risk review(s) pending. Oldest submitted {$waitTime}.";
    }
}
