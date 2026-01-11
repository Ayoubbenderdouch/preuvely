<?php

namespace App\Filament\Dataentry\Resources\StoreResource\Pages;

use App\Filament\Dataentry\Resources\StoreResource;
use Filament\Actions;
use Filament\Infolists\Infolist;
use Filament\Infolists\Components;
use Filament\Resources\Pages\ViewRecord;

class ViewStore extends ViewRecord
{
    protected static string $resource = StoreResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\EditAction::make()
                ->label('Edit Store')
                ->icon('heroicon-o-pencil'),
        ];
    }

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Components\Section::make('Store Details')
                    ->icon('heroicon-o-building-storefront')
                    ->columns(3)
                    ->schema([
                        Components\ImageEntry::make('logo')
                            ->label('')
                            ->circular()
                            ->size(100)
                            ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&color=007359&background=e8f5f0&size=200'),

                        Components\Grid::make(1)
                            ->columnSpan(2)
                            ->schema([
                                Components\TextEntry::make('name')
                                    ->label('Store Name')
                                    ->size('lg')
                                    ->weight('bold'),

                                Components\TextEntry::make('description')
                                    ->label('Description')
                                    ->placeholder('No description provided')
                                    ->columnSpan(2),

                                Components\TextEntry::make('city')
                                    ->label('City')
                                    ->icon('heroicon-o-map-pin')
                                    ->placeholder('No city specified'),

                                Components\TextEntry::make('categories.name_en')
                                    ->label('Categories')
                                    ->badge()
                                    ->separator(','),
                            ]),
                    ]),

                Components\Section::make('Status')
                    ->icon('heroicon-o-shield-check')
                    ->columns(3)
                    ->schema([
                        Components\IconEntry::make('is_verified')
                            ->label('Verification Status')
                            ->boolean()
                            ->trueIcon('heroicon-o-check-badge')
                            ->falseIcon('heroicon-o-clock')
                            ->trueColor('success')
                            ->falseColor('warning'),

                        Components\TextEntry::make('status')
                            ->label('Store Status')
                            ->badge()
                            ->color(fn ($state) => $state === 'active' ? 'success' : 'danger'),

                        Components\TextEntry::make('created_at')
                            ->label('Date Added')
                            ->dateTime('F j, Y \a\t g:i A'),
                    ]),

                Components\Section::make('Social Links')
                    ->icon('heroicon-o-link')
                    ->columns(2)
                    ->schema([
                        Components\RepeatableEntry::make('links')
                            ->label('')
                            ->columnSpan(2)
                            ->schema([
                                Components\TextEntry::make('platform')
                                    ->badge()
                                    ->color(fn ($state) => match ($state) {
                                        'instagram' => 'pink',
                                        'tiktok' => 'gray',
                                        'facebook' => 'info',
                                        'website' => 'success',
                                        default => 'gray',
                                    }),
                                Components\TextEntry::make('url')
                                    ->label('URL')
                                    ->url(fn ($state) => $state)
                                    ->openUrlInNewTab()
                                    ->color('primary'),
                                Components\TextEntry::make('handle')
                                    ->label('Handle')
                                    ->placeholder('-'),
                            ])
                            ->columns(3),
                    ]),

                Components\Section::make('Contact Information')
                    ->icon('heroicon-o-phone')
                    ->columns(2)
                    ->collapsed()
                    ->schema([
                        Components\TextEntry::make('contacts.whatsapp')
                            ->label('WhatsApp')
                            ->icon('heroicon-o-chat-bubble-left-ellipsis')
                            ->placeholder('Not provided'),
                        Components\TextEntry::make('contacts.phone')
                            ->label('Phone')
                            ->icon('heroicon-o-phone')
                            ->placeholder('Not provided'),
                    ]),
            ]);
    }
}
