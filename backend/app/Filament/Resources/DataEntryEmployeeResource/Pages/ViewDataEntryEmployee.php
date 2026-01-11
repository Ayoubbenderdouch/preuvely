<?php

namespace App\Filament\Resources\DataEntryEmployeeResource\Pages;

use App\Filament\Resources\DataEntryEmployeeResource;
use Filament\Resources\Pages\ViewRecord;
use Illuminate\Database\Eloquent\Builder;

class ViewDataEntryEmployee extends ViewRecord
{
    protected static string $resource = DataEntryEmployeeResource::class;

    protected function mutateFormDataBeforeFill(array $data): array
    {
        // Add computed counts
        $data['total_stores'] = $this->record->submittedStores()->count();
        $data['verified_stores'] = $this->record->submittedStores()->where('is_verified', true)->count();
        $data['pending_stores'] = $this->record->submittedStores()->where('is_verified', false)->count();

        return $data;
    }
}
