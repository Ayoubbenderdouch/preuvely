<?php

namespace App\Filament\Resources\UserResource\RelationManagers;

use App\Enums\ClaimStatus;
use App\Enums\OwnerRole;
use App\Filament\Resources\StoreResource;
use App\Filament\Resources\StoreClaimRequestResource;
use App\Models\AuditLog;
use App\Models\StoreClaimRequest;
use Filament\Forms;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ClaimsRelationManager extends RelationManager
{
    protected static string $relationship = 'claimRequests';
    protected static ?string $title = 'Store Claims';
    protected static ?string $icon = 'heroicon-o-hand-raised';

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('id')
            ->columns([
                Tables\Columns\TextColumn::make('store.name')
                    ->label('Store')
                    ->searchable()
                    ->sortable()
                    ->url(fn (StoreClaimRequest $record) => $record->store ? StoreResource::getUrl('view', ['record' => $record->store]) : null),
                Tables\Columns\TextColumn::make('requester_name')
                    ->label('Contact Name')
                    ->searchable(),
                Tables\Columns\TextColumn::make('requester_phone')
                    ->label('Contact Phone'),
                Tables\Columns\TextColumn::make('note')
                    ->label('Note')
                    ->limit(40)
                    ->tooltip(fn ($state) => $state),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (ClaimStatus $state) => $state->color()),
                Tables\Columns\TextColumn::make('handler.name')
                    ->label('Handled By')
                    ->placeholder('Not handled'),
                Tables\Columns\TextColumn::make('handled_at')
                    ->label('Handled At')
                    ->dateTime('M d, Y')
                    ->placeholder('Pending'),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Submitted')
                    ->dateTime('M d, Y')
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(collect(ClaimStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()])),
            ])
            ->headerActions([])
            ->actions([
                Tables\Actions\Action::make('view')
                    ->label('View')
                    ->icon('heroicon-o-eye')
                    ->url(fn (StoreClaimRequest $record) => StoreClaimRequestResource::getUrl('view', ['record' => $record])),
                Tables\Actions\Action::make('approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn (StoreClaimRequest $record) => $record->status === ClaimStatus::Pending)
                    ->form([
                        Forms\Components\Toggle::make('verify_store')
                            ->label('Also verify the store')
                            ->default(false),
                    ])
                    ->action(function (StoreClaimRequest $record, array $data) {
                        $record->update([
                            'status' => ClaimStatus::Approved,
                            'handled_by' => auth()->id(),
                            'handled_at' => now(),
                        ]);

                        // Add user as owner
                        $record->store->owners()->syncWithoutDetaching([
                            $record->user_id => ['role' => OwnerRole::Owner->value],
                        ]);

                        // Optionally verify store
                        if ($data['verify_store']) {
                            $record->store->update([
                                'is_verified' => true,
                                'verified_at' => now(),
                                'verified_by' => auth()->id(),
                            ]);
                        }

                        AuditLog::log('claim.approved', 'StoreClaimRequest', $record->id, null, [
                            'store_verified' => $data['verify_store'],
                        ]);
                    }),
                Tables\Actions\Action::make('reject')
                    ->label('Reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->visible(fn (StoreClaimRequest $record) => $record->status === ClaimStatus::Pending)
                    ->form([
                        Forms\Components\Textarea::make('reject_reason')
                            ->label('Rejection Reason')
                            ->required()
                            ->maxLength(500),
                    ])
                    ->action(function (StoreClaimRequest $record, array $data) {
                        $record->update([
                            'status' => ClaimStatus::Rejected,
                            'handled_by' => auth()->id(),
                            'handled_at' => now(),
                            'reject_reason' => $data['reject_reason'],
                        ]);

                        AuditLog::log('claim.rejected', 'StoreClaimRequest', $record->id, null, [
                            'reason' => $data['reject_reason'],
                        ]);
                    }),
            ])
            ->bulkActions([])
            ->defaultSort('created_at', 'desc');
    }
}
