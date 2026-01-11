<?php

namespace App\Filament\Resources\ReviewResource\Pages;

use App\Enums\ReviewStatus;
use App\Filament\Resources\ReviewResource;
use App\Models\AuditLog;
use Filament\Actions;
use Filament\Forms;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;

class ViewReview extends ViewRecord
{
    protected static string $resource = ReviewResource::class;

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Section::make('Review Details')
                    ->schema([
                        TextEntry::make('store.name')
                            ->label('Store'),
                        TextEntry::make('user.name')
                            ->label('Reviewer'),
                        TextEntry::make('stars')
                            ->label('Rating')
                            ->formatStateUsing(fn ($state) => str_repeat('⭐', $state)." ({$state}/5)"),
                        TextEntry::make('comment')
                            ->label('Comment')
                            ->columnSpanFull(),
                    ])
                    ->columns(3),

                Section::make('Status')
                    ->schema([
                        TextEntry::make('status')
                            ->badge()
                            ->color(fn ($state) => match ($state->value) {
                                'approved' => 'success',
                                'rejected' => 'danger',
                                default => 'warning',
                            }),
                        TextEntry::make('is_high_risk')
                            ->label('High Risk')
                            ->badge()
                            ->formatStateUsing(fn ($state) => $state ? 'Yes' : 'No')
                            ->color(fn ($state) => $state ? 'danger' : 'success'),
                        TextEntry::make('auto_approved')
                            ->label('Auto Approved')
                            ->badge()
                            ->formatStateUsing(fn ($state) => $state ? 'Yes' : 'No')
                            ->color(fn ($state) => $state ? 'info' : 'gray'),
                        TextEntry::make('rejected_reason')
                            ->label('Rejection Reason')
                            ->visible(fn ($record) => $record->status === ReviewStatus::Rejected)
                            ->columnSpanFull(),
                    ])
                    ->columns(3),

                Section::make('Proof Images')
                    ->description('Images uploaded by the reviewer as proof')
                    ->schema([
                        RepeatableEntry::make('proofs')
                            ->schema([
                                ImageEntry::make('file_path')
                                    ->label('')
                                    ->disk('public')
                                    ->height(200)
                                    ->extraImgAttributes(['class' => 'rounded-lg shadow-md']),
                                TextEntry::make('status')
                                    ->badge()
                                    ->color(fn ($state) => match ($state->value) {
                                        'approved' => 'success',
                                        'rejected' => 'danger',
                                        default => 'warning',
                                    }),
                                TextEntry::make('created_at')
                                    ->label('Uploaded')
                                    ->dateTime(),
                            ])
                            ->columns(3)
                            ->grid(2),
                    ])
                    ->collapsible()
                    ->visible(fn ($record) => $record->proofs->isNotEmpty()),

                Section::make('Timestamps')
                    ->schema([
                        TextEntry::make('created_at')
                            ->label('Submitted')
                            ->dateTime(),
                        TextEntry::make('approved_at')
                            ->label('Approved At')
                            ->dateTime()
                            ->visible(fn ($record) => $record->approved_at !== null),
                        TextEntry::make('approver.name')
                            ->label('Approved By')
                            ->visible(fn ($record) => $record->approved_by !== null),
                    ])
                    ->columns(3),
            ]);
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('approve')
                ->label('Approve')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->visible(fn () => $this->record->status === ReviewStatus::Pending)
                ->requiresConfirmation()
                ->action(function () {
                    $this->record->update([
                        'status' => ReviewStatus::Approved,
                        'approved_by' => auth()->id(),
                        'approved_at' => now(),
                    ]);
                    $this->record->store->recalculateRatings();
                    AuditLog::log('review.approved', 'Review', $this->record->id);
                }),
            Actions\Action::make('reject')
                ->label('Reject')
                ->icon('heroicon-o-x-circle')
                ->color('danger')
                ->visible(fn () => $this->record->status !== ReviewStatus::Rejected)
                ->form([
                    Forms\Components\Textarea::make('rejected_reason')
                        ->label('Rejection Reason')
                        ->required()
                        ->maxLength(500),
                ])
                ->action(function (array $data) {
                    $this->record->update([
                        'status' => ReviewStatus::Rejected,
                        'rejected_reason' => $data['rejected_reason'],
                    ]);
                    $this->record->store->recalculateRatings();
                    AuditLog::log('review.rejected', 'Review', $this->record->id, null, [
                        'reason' => $data['rejected_reason'],
                    ]);
                }),
        ];
    }
}
