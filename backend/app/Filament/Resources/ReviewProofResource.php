<?php

namespace App\Filament\Resources;

use App\Enums\ProofStatus;
use App\Enums\ReviewStatus;
use App\Filament\Resources\ReviewProofResource\Pages;
use App\Models\AuditLog;
use App\Models\ReviewProof;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ReviewProofResource extends Resource
{
    protected static ?string $model = ReviewProof::class;
    protected static ?string $navigationIcon = 'heroicon-o-photo';
    protected static ?string $navigationGroup = 'Moderation';
    protected static ?string $navigationLabel = 'Review Proofs';
    protected static ?int $navigationSort = 2;

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', ProofStatus::Pending)->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Proof Details')
                    ->schema([
                        Forms\Components\Placeholder::make('review_info')
                            ->label('Review')
                            ->content(fn ($record) => $record?->review?->store?->name . ' - ' . $record?->review?->stars . ' stars'),
                        Forms\Components\Placeholder::make('user_info')
                            ->label('Reviewer')
                            ->content(fn ($record) => $record?->review?->user?->name),
                        Forms\Components\FileUpload::make('file_path')
                            ->label('Proof Image')
                            ->image()
                            ->disk('public')
                            ->disabled(),
                    ]),

                Forms\Components\Section::make('Moderation')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->options(collect(ProofStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()]))
                            ->required(),
                        Forms\Components\Textarea::make('rejected_reason')
                            ->rows(3),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('file_path')
                    ->label('Proof')
                    ->disk('public')
                    ->width(80)
                    ->height(60),
                Tables\Columns\TextColumn::make('review.store.name')
                    ->label('Store')
                    ->searchable()
                    ->limit(30),
                Tables\Columns\TextColumn::make('review.user.name')
                    ->label('Reviewer')
                    ->searchable(),
                Tables\Columns\TextColumn::make('review.stars')
                    ->label('Stars'),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (ProofStatus $state) => $state->color()),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(collect(ProofStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()])),
            ])
            ->actions([
                Tables\Actions\Action::make('preview')
                    ->label('Preview')
                    ->icon('heroicon-o-eye')
                    ->url(fn (ReviewProof $record) => $record->url, true),
                Tables\Actions\Action::make('approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn (ReviewProof $record) => $record->status === ProofStatus::Pending)
                    ->requiresConfirmation()
                    ->action(function (ReviewProof $record) {
                        $record->update([
                            'status' => ProofStatus::Approved,
                            'reviewed_by' => auth()->id(),
                            'reviewed_at' => now(),
                        ]);

                        // Also approve the review
                        $record->review->update([
                            'status' => ReviewStatus::Approved,
                            'approved_by' => auth()->id(),
                            'approved_at' => now(),
                        ]);
                        $record->review->store->recalculateRatings();

                        AuditLog::log('proof.approved', 'ReviewProof', $record->id);
                        AuditLog::log('review.approved', 'Review', $record->review_id, null, [
                            'via_proof_approval' => true,
                        ]);
                    }),
                Tables\Actions\Action::make('reject')
                    ->label('Reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (ReviewProof $record) => $record->status === ProofStatus::Pending)
                    ->form([
                        Forms\Components\Textarea::make('rejected_reason')
                            ->label('Rejection Reason')
                            ->required()
                            ->maxLength(500),
                    ])
                    ->action(function (ReviewProof $record, array $data) {
                        $record->update([
                            'status' => ProofStatus::Rejected,
                            'reviewed_by' => auth()->id(),
                            'reviewed_at' => now(),
                            'rejected_reason' => $data['rejected_reason'],
                        ]);

                        AuditLog::log('proof.rejected', 'ReviewProof', $record->id, null, [
                            'reason' => $data['rejected_reason'],
                        ]);
                    }),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListReviewProofs::route('/'),
        ];
    }
}
