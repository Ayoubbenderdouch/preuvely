<?php

namespace App\Filament\Resources\StoreResource\RelationManagers;

use App\Enums\Platform;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class LinksRelationManager extends RelationManager
{
    protected static string $relationship = 'links';
    protected static ?string $title = 'Store Links';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('platform')
                    ->options(collect(Platform::cases())->mapWithKeys(fn ($p) => [$p->value => $p->label()]))
                    ->required(),
                Forms\Components\TextInput::make('url')
                    ->url()
                    ->required()
                    ->maxLength(500),
                Forms\Components\TextInput::make('handle')
                    ->maxLength(100),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('platform')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state->label()),
                Tables\Columns\TextColumn::make('url')
                    ->url(fn ($record) => $record->url, true)
                    ->limit(50),
                Tables\Columns\TextColumn::make('handle'),
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ]);
    }
}
