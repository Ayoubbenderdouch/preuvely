<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Enums\ClaimStatus;
use App\Enums\ReviewStatus;
use App\Enums\StoreStatus;
use App\Filament\Resources\UserResource;
use App\Filament\Resources\ReviewResource;
use App\Filament\Resources\StoreResource;
use App\Filament\Resources\StoreClaimRequestResource;
use App\Models\User;
use Filament\Actions;
use Filament\Infolists\Components\Grid;
use Filament\Infolists\Components\Group;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\Split;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;
use Filament\Support\Enums\FontWeight;
use Illuminate\Support\HtmlString;

class ViewUser extends ViewRecord
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make(),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                // User Profile Section
                Section::make('User Profile')
                    ->schema([
                        Split::make([
                            ImageEntry::make('avatar')
                                ->circular()
                                ->defaultImageUrl(fn (User $record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&background=6366f1&color=fff&size=128')
                                ->size(100)
                                ->grow(false),
                            Group::make([
                                TextEntry::make('name')
                                    ->weight(FontWeight::Bold)
                                    ->size(TextEntry\TextEntrySize::Large),
                                TextEntry::make('email')
                                    ->icon('heroicon-o-envelope')
                                    ->copyable()
                                    ->copyMessage('Email copied!'),
                                TextEntry::make('phone')
                                    ->icon('heroicon-o-phone')
                                    ->placeholder('No phone number')
                                    ->copyable(),
                                TextEntry::make('created_at')
                                    ->label('Member since')
                                    ->icon('heroicon-o-calendar')
                                    ->dateTime('M d, Y'),
                                TextEntry::make('roles.name')
                                    ->label('Roles')
                                    ->badge()
                                    ->color('primary'),
                                TextEntry::make('email_verified_at')
                                    ->label('Email Verified')
                                    ->icon(fn ($state) => $state ? 'heroicon-o-check-badge' : 'heroicon-o-x-circle')
                                    ->formatStateUsing(fn ($state) => $state ? 'Verified on ' . $state->format('M d, Y') : 'Not verified')
                                    ->color(fn ($state) => $state ? 'success' : 'danger'),
                            ])->grow(),
                        ])->from('md'),
                    ]),

                // Statistics Section
                Section::make('Activity Statistics')
                    ->schema([
                        Grid::make(4)
                            ->schema([
                                TextEntry::make('submitted_stores_count')
                                    ->label('Stores Submitted')
                                    ->state(fn (User $record) => $record->submittedStores()->count())
                                    ->icon('heroicon-o-building-storefront')
                                    ->color('primary')
                                    ->weight(FontWeight::Bold)
                                    ->size(TextEntry\TextEntrySize::Large),
                                TextEntry::make('reviews_count')
                                    ->label('Reviews Written')
                                    ->state(fn (User $record) => $record->reviews()->count())
                                    ->icon('heroicon-o-star')
                                    ->color('warning')
                                    ->weight(FontWeight::Bold)
                                    ->size(TextEntry\TextEntrySize::Large),
                                TextEntry::make('approved_reviews_count')
                                    ->label('Approved Reviews')
                                    ->state(fn (User $record) => $record->reviews()->where('status', ReviewStatus::Approved)->count())
                                    ->icon('heroicon-o-check-circle')
                                    ->color('success')
                                    ->weight(FontWeight::Bold)
                                    ->size(TextEntry\TextEntrySize::Large),
                                TextEntry::make('claims_count')
                                    ->label('Store Claims')
                                    ->state(fn (User $record) => $record->claimRequests()->count())
                                    ->icon('heroicon-o-hand-raised')
                                    ->color('info')
                                    ->weight(FontWeight::Bold)
                                    ->size(TextEntry\TextEntrySize::Large),
                            ]),
                    ]),

                // Recent Submitted Stores
                Section::make('Submitted Stores')
                    ->description('Stores submitted by this user')
                    ->collapsible()
                    ->schema([
                        RepeatableEntry::make('submittedStores')
                            ->schema([
                                Grid::make(5)
                                    ->schema([
                                        TextEntry::make('name')
                                            ->label('Store Name')
                                            ->weight(FontWeight::SemiBold)
                                            ->url(fn ($record) => StoreResource::getUrl('view', ['record' => $record])),
                                        TextEntry::make('city')
                                            ->label('City')
                                            ->placeholder('N/A'),
                                        TextEntry::make('status')
                                            ->badge()
                                            ->color(fn (StoreStatus $state) => $state->color()),
                                        TextEntry::make('is_verified')
                                            ->label('Verified')
                                            ->formatStateUsing(fn ($state) => $state ? 'Yes' : 'No')
                                            ->icon(fn ($state) => $state ? 'heroicon-o-check-badge' : 'heroicon-o-x-mark')
                                            ->color(fn ($state) => $state ? 'success' : 'gray'),
                                        TextEntry::make('created_at')
                                            ->label('Created')
                                            ->dateTime('M d, Y'),
                                    ]),
                            ])
                            ->placeholder('No stores submitted yet.')
                            ->contained(false),
                    ])
                    ->visible(fn (User $record) => $record->submittedStores()->exists()),

                // Recent Reviews
                Section::make('Reviews')
                    ->description('Reviews written by this user')
                    ->collapsible()
                    ->schema([
                        RepeatableEntry::make('reviews')
                            ->schema([
                                Grid::make(5)
                                    ->schema([
                                        TextEntry::make('store.name')
                                            ->label('Store')
                                            ->weight(FontWeight::SemiBold)
                                            ->url(fn ($record) => StoreResource::getUrl('view', ['record' => $record->store])),
                                        TextEntry::make('stars')
                                            ->label('Rating')
                                            ->formatStateUsing(fn ($state) => str_repeat('*', $state) . ' (' . $state . '/5)'),
                                        TextEntry::make('comment')
                                            ->label('Review')
                                            ->limit(50)
                                            ->tooltip(fn ($state) => $state),
                                        TextEntry::make('status')
                                            ->badge()
                                            ->color(fn (ReviewStatus $state) => $state->color()),
                                        TextEntry::make('created_at')
                                            ->label('Date')
                                            ->dateTime('M d, Y'),
                                    ]),
                            ])
                            ->placeholder('No reviews written yet.')
                            ->contained(false),
                    ])
                    ->visible(fn (User $record) => $record->reviews()->exists()),

                // Store Claims
                Section::make('Store Claims')
                    ->description('Store ownership claim requests by this user')
                    ->collapsible()
                    ->schema([
                        RepeatableEntry::make('claimRequests')
                            ->schema([
                                Grid::make(5)
                                    ->schema([
                                        TextEntry::make('store.name')
                                            ->label('Store')
                                            ->weight(FontWeight::SemiBold)
                                            ->url(fn ($record) => StoreResource::getUrl('view', ['record' => $record->store])),
                                        TextEntry::make('requester_name')
                                            ->label('Contact Name'),
                                        TextEntry::make('requester_phone')
                                            ->label('Contact Phone'),
                                        TextEntry::make('status')
                                            ->badge()
                                            ->color(fn (ClaimStatus $state) => $state->color()),
                                        TextEntry::make('created_at')
                                            ->label('Date')
                                            ->dateTime('M d, Y'),
                                    ]),
                            ])
                            ->placeholder('No claim requests.')
                            ->contained(false),
                    ])
                    ->visible(fn (User $record) => $record->claimRequests()->exists()),

                // Owned Stores
                Section::make('Owned Stores')
                    ->description('Stores this user owns or manages')
                    ->collapsible()
                    ->schema([
                        RepeatableEntry::make('ownedStores')
                            ->schema([
                                Grid::make(5)
                                    ->schema([
                                        TextEntry::make('name')
                                            ->label('Store Name')
                                            ->weight(FontWeight::SemiBold)
                                            ->url(fn ($record) => StoreResource::getUrl('view', ['record' => $record])),
                                        TextEntry::make('city')
                                            ->label('City')
                                            ->placeholder('N/A'),
                                        TextEntry::make('pivot.role')
                                            ->label('Role')
                                            ->badge()
                                            ->color('info'),
                                        TextEntry::make('status')
                                            ->badge()
                                            ->color(fn (StoreStatus $state) => $state->color()),
                                        TextEntry::make('is_verified')
                                            ->label('Verified')
                                            ->formatStateUsing(fn ($state) => $state ? 'Yes' : 'No')
                                            ->icon(fn ($state) => $state ? 'heroicon-o-check-badge' : 'heroicon-o-x-mark')
                                            ->color(fn ($state) => $state ? 'success' : 'gray'),
                                    ]),
                            ])
                            ->placeholder('No owned stores.')
                            ->contained(false),
                    ])
                    ->visible(fn (User $record) => $record->ownedStores()->exists()),
            ]);
    }
}
