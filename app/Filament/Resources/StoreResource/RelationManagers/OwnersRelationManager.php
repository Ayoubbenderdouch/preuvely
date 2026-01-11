<?php

namespace App\Filament\Resources\StoreResource\RelationManagers;

use App\Enums\OwnerRole;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class OwnersRelationManager extends RelationManager
{
    protected static string $relationship = 'owners';
    protected static ?string $title = 'Store Owners';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('user_id')
                    ->relationship('user', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),
                Forms\Components\Select::make('role')
                    ->options(collect(OwnerRole::cases())->mapWithKeys(fn ($r) => [$r->value => $r->label()]))
                    ->default(OwnerRole::Owner->value)
                    ->required(),
            ]);
    }

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->searchable(),
                Tables\Columns\TextColumn::make('email'),
                Tables\Columns\TextColumn::make('pivot.role')
                    ->label('Role')
                    ->badge(),
                Tables\Columns\TextColumn::make('pivot.created_at')
                    ->label('Added')
                    ->dateTime(),
            ])
            ->headerActions([
                Tables\Actions\AttachAction::make()
                    ->form(fn (Tables\Actions\AttachAction $action) => [
                        $action->getRecordSelect(),
                        Forms\Components\Select::make('role')
                            ->options(collect(OwnerRole::cases())->mapWithKeys(fn ($r) => [$r->value => $r->label()]))
                            ->default(OwnerRole::Owner->value)
                            ->required(),
                    ]),
            ])
            ->actions([
                Tables\Actions\DetachAction::make(),
            ]);
    }
}
