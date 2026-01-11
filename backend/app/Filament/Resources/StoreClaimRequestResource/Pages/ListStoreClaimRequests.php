<?php

namespace App\Filament\Resources\StoreClaimRequestResource\Pages;

use App\Filament\Resources\StoreClaimRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListStoreClaimRequests extends ListRecords
{
    protected static string $resource = StoreClaimRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
