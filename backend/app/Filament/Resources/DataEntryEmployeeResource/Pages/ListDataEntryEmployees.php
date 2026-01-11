<?php

namespace App\Filament\Resources\DataEntryEmployeeResource\Pages;

use App\Filament\Resources\DataEntryEmployeeResource;
use Filament\Resources\Pages\ListRecords;

class ListDataEntryEmployees extends ListRecords
{
    protected static string $resource = DataEntryEmployeeResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
