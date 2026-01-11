<?php

namespace App\Filament\Dataentry\Widgets;

use App\Models\Store;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Support\Facades\Auth;

class RecentStoresWidget extends BaseWidget
{
    protected static ?int $sort = 2;

    protected int | string | array $columnSpan = 'full';

    protected static ?string $heading = 'Recent Stores You Added';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Store::query()
                    ->where('submitted_by', Auth::id())
                    ->latest()
                    ->limit(5)
            )
            ->columns([
                Tables\Columns\ImageColumn::make('logo')
                    ->label('')
                    ->disk('public')
                    ->circular()
                    ->size(40)
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&color=007359&background=e8f5f0'),

                Tables\Columns\TextColumn::make('name')
                    ->label('Store Name')
                    ->searchable()
                    ->weight('bold')
                    ->description(fn ($record) => $record->categories->pluck('name_en')->implode(', ')),

                Tables\Columns\TextColumn::make('links_count')
                    ->label('Links')
                    ->counts('links')
                    ->badge()
                    ->color('gray'),

                Tables\Columns\IconColumn::make('is_verified')
                    ->label('Verified')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-badge')
                    ->falseIcon('heroicon-o-clock')
                    ->trueColor('success')
                    ->falseColor('warning'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Added')
                    ->since()
                    ->color('gray'),
            ])
            ->paginated(false)
            ->emptyStateHeading('No stores yet')
            ->emptyStateDescription('Click the "Add Store" button to add your first store!')
            ->emptyStateIcon('heroicon-o-building-storefront')
            ->emptyStateActions([
                Tables\Actions\Action::make('addStore')
                    ->label('Add Your First Store')
                    ->url(fn () => route('filament.dataentry.resources.stores.create'))
                    ->icon('heroicon-o-plus')
                    ->button(),
            ]);
    }
}
