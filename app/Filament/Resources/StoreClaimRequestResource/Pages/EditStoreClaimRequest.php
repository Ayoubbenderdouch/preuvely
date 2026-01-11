<?php

namespace App\Filament\Resources\StoreClaimRequestResource\Pages;

use App\Filament\Resources\StoreClaimRequestResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditStoreClaimRequest extends EditRecord
{
    protected static string $resource = StoreClaimRequestResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
