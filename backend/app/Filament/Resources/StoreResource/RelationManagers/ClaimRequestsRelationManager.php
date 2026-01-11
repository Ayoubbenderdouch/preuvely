<?php

namespace App\Filament\Resources\StoreResource\RelationManagers;

use App\Enums\ClaimStatus;
use App\Enums\OwnerRole;
use App\Models\AuditLog;
use Filament\Forms;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ClaimRequestsRelationManager extends RelationManager
{
    protected static string $relationship = 'claimRequests';
    protected static ?string $title = 'Claim Requests';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('user.name')
                    ->label('User'),
                Tables\Columns\TextColumn::make('requester_name'),
                Tables\Columns\TextColumn::make('requester_phone'),
                Tables\Columns\TextColumn::make('note')
                    ->limit(50),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (ClaimStatus $state) => $state->color()),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(collect(ClaimStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()])),
            ])
            ->actions([
                Tables\Actions\Action::make('approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn ($record) => $record->status === ClaimStatus::Pending)
                    ->form([
                        Forms\Components\Toggle::make('verify_store')
                            ->label('Also verify the store')
                            ->default(false),
                    ])
                    ->action(function ($record, array $data) {
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
                    ->visible(fn ($record) => $record->status === ClaimStatus::Pending)
                    ->form([
                        Forms\Components\Textarea::make('reject_reason')
                            ->label('Rejection Reason')
                            ->required()
                            ->maxLength(500),
                    ])
                    ->action(function ($record, array $data) {
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
            ]);
    }
}
