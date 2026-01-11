<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AuditLogResource\Pages;
use App\Models\AuditLog;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class AuditLogResource extends Resource
{
    protected static ?string $model = AuditLog::class;
    protected static ?string $navigationIcon = 'heroicon-o-document-text';
    protected static ?string $navigationGroup = 'Administration';
    protected static ?string $navigationLabel = 'Audit Logs';
    protected static ?int $navigationSort = 2;

    public static function canCreate(): bool
    {
        return false;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Log Details')
                    ->schema([
                        Forms\Components\Placeholder::make('actor')
                            ->label('Actor')
                            ->content(fn ($record) => $record?->actor?->name ?? 'System'),
                        Forms\Components\Placeholder::make('action')
                            ->label('Action')
                            ->content(fn ($record) => $record?->action),
                        Forms\Components\Placeholder::make('entity')
                            ->label('Entity')
                            ->content(fn ($record) => $record?->entity_type . ' #' . $record?->entity_id),
                        Forms\Components\Placeholder::make('meta')
                            ->label('Metadata')
                            ->content(fn ($record) => json_encode($record?->meta, JSON_PRETTY_PRINT)),
                        Forms\Components\Placeholder::make('created_at')
                            ->label('Date')
                            ->content(fn ($record) => $record?->created_at?->format('Y-m-d H:i:s')),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('actor.name')
                    ->label('Actor')
                    ->default('System')
                    ->searchable(),
                Tables\Columns\TextColumn::make('action')
                    ->badge()
                    ->searchable(),
                Tables\Columns\TextColumn::make('entity_type')
                    ->label('Entity Type'),
                Tables\Columns\TextColumn::make('entity_id')
                    ->label('Entity ID'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('action')
                    ->options(fn () => AuditLog::distinct()->pluck('action', 'action')->toArray()),
                Tables\Filters\SelectFilter::make('entity_type')
                    ->options(fn () => AuditLog::distinct()->pluck('entity_type', 'entity_type')->toArray()),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAuditLogs::route('/'),
        ];
    }
}
