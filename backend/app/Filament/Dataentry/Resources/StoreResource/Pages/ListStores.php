<?php

namespace App\Filament\Dataentry\Resources\StoreResource\Pages;

use App\Filament\Dataentry\Resources\StoreResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListStores extends ListRecords
{
    protected static string $resource = StoreResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make()
                ->label('Add New Store')
                ->icon('heroicon-o-plus-circle')
                ->color('primary'),
        ];
    }

    protected function getHeaderWidgets(): array
    {
        return [];
    }

    public function getTitle(): string
    {
        return 'My Stores';
    }

    public function getSubheading(): ?string
    {
        return 'All stores you have added to Preuvely';
    }
}
