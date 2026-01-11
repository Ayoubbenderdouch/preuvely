<?php

namespace App\Filament\Resources;

use App\Enums\ReviewStatus;
use App\Filament\Resources\ReviewResource\Pages;
use App\Filament\Resources\UserResource;
use App\Models\AuditLog;
use App\Models\Review;
use App\Services\NotificationService;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Illuminate\Database\Eloquent\Builder;

class ReviewResource extends Resource
{
    protected static ?string $model = Review::class;
    protected static ?string $navigationIcon = 'heroicon-o-star';
    protected static ?string $navigationGroup = 'Moderation';
    protected static ?int $navigationSort = 1;

    public static function getNavigationBadge(): ?string
    {
        $pendingCount = static::getModel()::where('status', ReviewStatus::Pending)->count();
        $highRiskPending = static::getModel()::where('status', ReviewStatus::Pending)
            ->where('is_high_risk', true)
            ->count();

        if ($highRiskPending > 0) {
            return "{$highRiskPending} high-risk / {$pendingCount} pending";
        }

        return $pendingCount ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        $highRiskPending = static::getModel()::where('status', ReviewStatus::Pending)
            ->where('is_high_risk', true)
            ->count();

        return $highRiskPending > 0 ? 'danger' : 'warning';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Review Details')
                    ->schema([
                        Forms\Components\Select::make('store_id')
                            ->relationship('store', 'name')
                            ->disabled(),
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->disabled(),
                        Forms\Components\TextInput::make('stars')
                            ->disabled(),
                        Forms\Components\Textarea::make('comment')
                            ->disabled()
                            ->rows(4),
                    ])->columns(2),

                Forms\Components\Section::make('Moderation')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->options(collect(ReviewStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()]))
                            ->required(),
                        Forms\Components\Toggle::make('is_high_risk')
                            ->label('High Risk Category')
                            ->disabled()
                            ->helperText('Automatically set based on store category'),
                        Forms\Components\Toggle::make('auto_approved')
                            ->label('Auto Approved')
                            ->disabled()
                            ->helperText('Review was automatically approved by the system'),
                        Forms\Components\Textarea::make('rejected_reason')
                            ->rows(3),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('store.name')
                    ->label('Store')
                    ->searchable()
                    ->limit(30)
                    ->description(fn (Review $record) => $record->store?->categories->pluck('name_en')->implode(', ')),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('User')
                    ->searchable()
                    ->url(fn (Review $record) => $record->user ? UserResource::getUrl('view', ['record' => $record->user]) : null)
                    ->color('primary'),
                Tables\Columns\TextColumn::make('stars')
                    ->formatStateUsing(fn ($state) => str_repeat('*', $state)),
                Tables\Columns\TextColumn::make('comment')
                    ->limit(50)
                    ->wrap(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (Review $record): string => self::getStatusBadgeColor($record))
                    ->formatStateUsing(fn (Review $record): string => self::getStatusBadgeLabel($record)),
                Tables\Columns\IconColumn::make('is_high_risk')
                    ->label('High Risk')
                    ->boolean()
                    ->trueIcon('heroicon-o-exclamation-triangle')
                    ->trueColor('danger')
                    ->falseIcon('heroicon-o-check-circle')
                    ->falseColor('gray'),
                Tables\Columns\IconColumn::make('auto_approved')
                    ->label('Auto')
                    ->boolean()
                    ->trueIcon('heroicon-o-bolt')
                    ->trueColor('success')
                    ->falseIcon('heroicon-o-hand-raised')
                    ->falseColor('gray')
                    ->tooltip(fn (Review $record) => $record->auto_approved ? 'Auto-approved' : 'Manual review'),
                Tables\Columns\TextColumn::make('proofs_count')
                    ->label('Proofs')
                    ->counts('proofs')
                    ->badge()
                    ->color(fn ($state) => $state > 0 ? 'success' : 'gray'),
                Tables\Columns\ImageColumn::make('proofs.file_path')
                    ->label('Images')
                    ->disk('public')
                    ->circular()
                    ->stacked()
                    ->limit(3)
                    ->limitedRemainingText()
                    ->size(40),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('approved_at')
                    ->label('Approved At')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                SelectFilter::make('status')
                    ->options(collect(ReviewStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()])),
                TernaryFilter::make('is_high_risk')
                    ->label('High Risk Category'),
                TernaryFilter::make('auto_approved')
                    ->label('Auto Approved'),
                Filter::make('high_risk_pending')
                    ->label('High Risk Pending')
                    ->query(fn (Builder $query): Builder => $query->where('is_high_risk', true)->where('status', ReviewStatus::Pending))
                    ->toggle(),
                Filter::make('manually_approved')
                    ->label('Manually Approved')
                    ->query(fn (Builder $query): Builder => $query->where('status', ReviewStatus::Approved)->where('auto_approved', false))
                    ->toggle(),
                Filter::make('auto_approved_only')
                    ->label('Auto Approved Only')
                    ->query(fn (Builder $query): Builder => $query->where('auto_approved', true))
                    ->toggle(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
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

                        // Send notification to review author
                        NotificationService::reviewApproved($record);
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

                        // Send notification to review author
                        NotificationService::reviewRejected($record, $data['rejected_reason']);
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

                                    // Send notification to review author
                                    NotificationService::reviewApproved($record);
                                }
                            });
                        }),
                    Tables\Actions\BulkAction::make('rejectSelected')
                        ->label('Reject Selected')
                        ->icon('heroicon-o-x-circle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->deselectRecordsAfterCompletion()
                        ->form([
                            Forms\Components\Textarea::make('rejected_reason')
                                ->label('Rejection Reason (applied to all)')
                                ->required()
                                ->maxLength(500),
                        ])
                        ->action(function ($records, array $data) {
                            $records->each(function (Review $record) use ($data) {
                                if ($record->status !== ReviewStatus::Rejected) {
                                    $record->update([
                                        'status' => ReviewStatus::Rejected,
                                        'rejected_reason' => $data['rejected_reason'],
                                    ]);
                                    $record->store->recalculateRatings();
                                    AuditLog::log('review.rejected', 'Review', $record->id, null, [
                                        'reason' => $data['rejected_reason'],
                                    ]);

                                    // Send notification to review author
                                    NotificationService::reviewRejected($record, $data['rejected_reason']);
                                }
                            });
                        }),
                ]),
            ]);
    }

    /**
     * Get the badge color based on review status and flags.
     */
    public static function getStatusBadgeColor(Review $record): string
    {
        if ($record->status === ReviewStatus::Pending) {
            return $record->is_high_risk ? 'danger' : 'warning';
        }

        if ($record->status === ReviewStatus::Approved) {
            return $record->auto_approved ? 'success' : 'info';
        }

        return $record->status->color();
    }

    /**
     * Get the badge label based on review status and flags.
     */
    public static function getStatusBadgeLabel(Review $record): string
    {
        if ($record->status === ReviewStatus::Pending && $record->is_high_risk) {
            return 'High Risk - Pending';
        }

        if ($record->status === ReviewStatus::Approved && $record->auto_approved) {
            return 'Auto Approved';
        }

        if ($record->status === ReviewStatus::Approved && !$record->auto_approved) {
            return 'Manually Approved';
        }

        return $record->status->label();
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListReviews::route('/'),
            'high-risk' => Pages\HighRiskReviews::route('/high-risk'),
            'view' => Pages\ViewReview::route('/{record}'),
        ];
    }
}
