<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DataEntryEmployeeResource\Pages;
use App\Filament\Resources\DataEntryEmployeeResource\RelationManagers;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Infolists\Components\Grid;
use Filament\Infolists\Components\Group;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Support\Enums\FontWeight;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class DataEntryEmployeeResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-group';

    protected static ?string $navigationLabel = 'Data Entry Team';

    protected static ?string $modelLabel = 'Data Entry Employee';

    protected static ?string $pluralModelLabel = 'Data Entry Employees';

    protected static ?string $navigationGroup = 'Team';

    protected static ?int $navigationSort = 10;

    public static function getNavigationBadge(): ?string
    {
        return static::getEloquentQuery()->count();
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->whereHas('roles', fn (Builder $q) => $q->where('name', 'data_entry'))
            ->withCount(['submittedStores as total_stores'])
            ->withCount(['submittedStores as verified_stores' => fn ($q) => $q->where('is_verified', true)])
            ->withCount(['submittedStores as pending_stores' => fn ($q) => $q->where('is_verified', false)]);
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Employee Information')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('email')
                            ->email()
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),
                        Forms\Components\TextInput::make('phone')
                            ->tel()
                            ->maxLength(20),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->label('Employee Name')
                    ->searchable()
                    ->sortable()
                    ->weight('bold')
                    ->icon('heroicon-o-user'),
                Tables\Columns\TextColumn::make('email')
                    ->searchable()
                    ->color('gray')
                    ->copyable(),
                Tables\Columns\TextColumn::make('total_stores')
                    ->label('Total Stores')
                    ->badge()
                    ->color('primary')
                    ->sortable(),
                Tables\Columns\TextColumn::make('verified_stores')
                    ->label('Verified')
                    ->badge()
                    ->color('success')
                    ->sortable(),
                Tables\Columns\TextColumn::make('pending_stores')
                    ->label('Pending')
                    ->badge()
                    ->color('warning')
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Joined')
                    ->since()
                    ->sortable(),
            ])
            ->defaultSort('total_stores', 'desc')
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('View Profile'),
            ])
            ->bulkActions([])
            ->emptyStateHeading('No data entry employees')
            ->emptyStateDescription('Create data entry users to start tracking contributions')
            ->emptyStateIcon('heroicon-o-user-group');
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Section::make('Employee Profile')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                TextEntry::make('name')
                                    ->label('Name')
                                    ->weight(FontWeight::Bold)
                                    ->size(TextEntry\TextEntrySize::Large)
                                    ->icon('heroicon-o-user'),
                                TextEntry::make('email')
                                    ->label('Email')
                                    ->copyable()
                                    ->icon('heroicon-o-envelope'),
                                TextEntry::make('phone')
                                    ->label('Phone')
                                    ->placeholder('Not provided')
                                    ->icon('heroicon-o-phone'),
                            ]),
                    ]),

                Section::make('Performance Statistics')
                    ->schema([
                        Grid::make(4)
                            ->schema([
                                TextEntry::make('total_stores')
                                    ->label('Total Stores Added')
                                    ->badge()
                                    ->color('primary')
                                    ->size(TextEntry\TextEntrySize::Large),
                                TextEntry::make('verified_stores')
                                    ->label('Verified Stores')
                                    ->badge()
                                    ->color('success')
                                    ->size(TextEntry\TextEntrySize::Large),
                                TextEntry::make('pending_stores')
                                    ->label('Pending Verification')
                                    ->badge()
                                    ->color('warning')
                                    ->size(TextEntry\TextEntrySize::Large),
                                TextEntry::make('created_at')
                                    ->label('Member Since')
                                    ->dateTime('M d, Y'),
                            ]),
                    ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\SubmittedStoresRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListDataEntryEmployees::route('/'),
            'view' => Pages\ViewDataEntryEmployee::route('/{record}'),
        ];
    }
}
