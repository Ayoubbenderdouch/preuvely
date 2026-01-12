<?php

namespace App\Filament\Resources;

use App\Enums\ClaimStatus;
use App\Filament\Resources\StoreClaimRequestResource\Pages;
use App\Filament\Resources\UserResource;
use App\Models\StoreClaimRequest;
use App\Services\NotificationService;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class StoreClaimRequestResource extends Resource
{
    protected static ?string $model = StoreClaimRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-hand-raised';

    protected static ?string $navigationLabel = 'Claim Requests';

    protected static ?string $modelLabel = 'Claim Request';

    protected static ?string $pluralModelLabel = 'Claim Requests';

    protected static ?string $navigationGroup = 'Store Management';

    protected static ?int $navigationSort = 2;

    public static function getNavigationBadge(): ?string
    {
        $count = static::getModel()::where('status', ClaimStatus::Pending)->count();

        return $count > 0 ? (string) $count : null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Request Details')
                    ->schema([
                        Forms\Components\Select::make('store_id')
                            ->relationship('store', 'name')
                            ->disabled()
                            ->required(),
                        Forms\Components\Select::make('user_id')
                            ->relationship('user', 'name')
                            ->disabled()
                            ->required(),
                        Forms\Components\TextInput::make('requester_name')
                            ->disabled()
                            ->required(),
                        Forms\Components\TextInput::make('requester_phone')
                            ->tel()
                            ->disabled()
                            ->required(),
                        Forms\Components\Textarea::make('note')
                            ->disabled()
                            ->columnSpanFull(),
                    ])->columns(2),

                Forms\Components\Section::make('Status')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->options(ClaimStatus::class)
                            ->required(),
                        Forms\Components\Textarea::make('reject_reason')
                            ->label('Rejection Reason')
                            ->helperText('Required when rejecting a claim')
                            ->columnSpanFull()
                            ->visible(fn (Forms\Get $get) => $get('status') === ClaimStatus::Rejected->value),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('ID')
                    ->sortable(),
                Tables\Columns\TextColumn::make('store.name')
                    ->label('Store')
                    ->searchable()
                    ->sortable()
                    ->limit(30),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('User')
                    ->searchable()
                    ->sortable()
                    ->url(fn (StoreClaimRequest $record) => $record->user ? UserResource::getUrl('view', ['record' => $record->user]) : null)
                    ->color('primary'),
                Tables\Columns\TextColumn::make('requester_name')
                    ->label('Requester Name')
                    ->searchable(),
                Tables\Columns\TextColumn::make('requester_phone')
                    ->label('Phone')
                    ->searchable()
                    ->copyable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (ClaimStatus $state): string => $state->color()),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Submitted')
                    ->dateTime('M j, Y H:i')
                    ->sortable(),
                Tables\Columns\TextColumn::make('handler.name')
                    ->label('Handled By')
                    ->placeholder('-')
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('handled_at')
                    ->label('Handled At')
                    ->dateTime('M j, Y H:i')
                    ->placeholder('-')
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(ClaimStatus::class),
            ])
            ->actions([
                Tables\Actions\Action::make('approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->modalHeading('Approve Claim Request')
                    ->modalDescription('This will add the user as store owner AND verify the store. The owner can then reply to reviews.')
                    ->visible(fn (StoreClaimRequest $record) => $record->isPending())
                    ->action(function (StoreClaimRequest $record) {
                        $record->update([
                            'status' => ClaimStatus::Approved,
                            'handled_by' => auth()->id(),
                            'handled_at' => now(),
                        ]);

                        // Add user as store owner
                        $record->store->owners()->syncWithoutDetaching([
                            $record->user_id => ['role' => 'owner'],
                        ]);

                        // Verify the store (owner can now reply to reviews)
                        $wasNotVerified = !$record->store->is_verified;
                        if ($wasNotVerified) {
                            $record->store->update([
                                'is_verified' => true,
                                'verified_at' => now(),
                                'verified_by' => auth()->id(),
                            ]);
                        }

                        // Send notification to the user about claim approval
                        NotificationService::claimApproved($record);

                        // If store was just verified, also send store verified notification
                        if ($wasNotVerified) {
                            $record->store->refresh();
                            NotificationService::storeVerified($record->store);
                        }

                        Notification::make()
                            ->title('Claim approved - User is now store owner')
                            ->body('Store has been verified. Owner can now reply to reviews.')
                            ->success()
                            ->send();
                    }),

                Tables\Actions\Action::make('reject')
                    ->label('Reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->modalHeading('Reject Claim Request')
                    ->form([
                        Forms\Components\Textarea::make('reject_reason')
                            ->label('Reason for rejection')
                            ->required()
                            ->maxLength(500),
                    ])
                    ->visible(fn (StoreClaimRequest $record) => $record->isPending())
                    ->action(function (StoreClaimRequest $record, array $data) {
                        $record->update([
                            'status' => ClaimStatus::Rejected,
                            'handled_by' => auth()->id(),
                            'handled_at' => now(),
                            'reject_reason' => $data['reject_reason'],
                        ]);

                        // Send notification to the user about claim rejection
                        NotificationService::claimRejected($record, $data['reject_reason']);

                        Notification::make()
                            ->title('Claim rejected')
                            ->success()
                            ->send();
                    }),

                Tables\Actions\Action::make('resync_owner')
                    ->label('Re-sync Owner')
                    ->icon('heroicon-o-arrow-path')
                    ->color('warning')
                    ->requiresConfirmation()
                    ->modalHeading('Re-sync Store Owner')
                    ->modalDescription('This will re-add the user as store owner. Use this if the owner wasn\'t properly added during approval.')
                    ->visible(fn (StoreClaimRequest $record) => $record->isApproved())
                    ->action(function (StoreClaimRequest $record) {
                        // Re-add user as store owner
                        $record->store->owners()->syncWithoutDetaching([
                            $record->user_id => ['role' => 'owner'],
                        ]);

                        // Log for debugging
                        \Log::info('Re-synced store owner', [
                            'claim_id' => $record->id,
                            'store_id' => $record->store_id,
                            'user_id' => $record->user_id,
                            'owners_after' => $record->store->owners()->pluck('users.id')->toArray(),
                        ]);

                        Notification::make()
                            ->title('Owner re-synced successfully')
                            ->body('User ID ' . $record->user_id . ' is now owner of store ID ' . $record->store_id)
                            ->success()
                            ->send();
                    }),

                Tables\Actions\ViewAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStoreClaimRequests::route('/'),
            'view' => Pages\ViewStoreClaimRequest::route('/{record}'),
            'edit' => Pages\EditStoreClaimRequest::route('/{record}/edit'),
        ];
    }
}
