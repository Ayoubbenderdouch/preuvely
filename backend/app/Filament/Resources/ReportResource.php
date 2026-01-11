<?php

namespace App\Filament\Resources;

use App\Enums\ReplyStatus;
use App\Enums\ReportReason;
use App\Enums\ReportStatus;
use App\Enums\ReviewStatus;
use App\Filament\Resources\ReportResource\Pages;
use App\Filament\Resources\UserResource;
use App\Models\AuditLog;
use App\Models\Report;
use App\Models\Review;
use App\Models\StoreReply;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class ReportResource extends Resource
{
    protected static ?string $model = Report::class;
    protected static ?string $navigationIcon = 'heroicon-o-flag';
    protected static ?string $navigationGroup = 'Moderation';
    protected static ?int $navigationSort = 3;

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::where('status', ReportStatus::Open)->count() ?: null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'danger';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Report Details')
                    ->schema([
                        Forms\Components\Placeholder::make('reporter')
                            ->label('Reporter')
                            ->content(fn ($record) => $record?->reporter?->name),
                        Forms\Components\Placeholder::make('reportable_type')
                            ->label('Content Type')
                            ->content(fn ($record) => class_basename($record?->reportable_type)),
                        Forms\Components\Placeholder::make('reason_label')
                            ->label('Reason')
                            ->content(fn ($record) => $record?->reason?->label()),
                        Forms\Components\Textarea::make('note')
                            ->disabled()
                            ->rows(3),
                    ])->columns(2),

                Forms\Components\Section::make('Status')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->options(collect(ReportStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()]))
                            ->required(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('#')
                    ->sortable(),
                Tables\Columns\TextColumn::make('store_name')
                    ->label('Store')
                    ->state(fn (Report $record) => self::getRelatedStore($record)?->name ?? 'N/A')
                    ->searchable(query: function ($query, string $search) {
                        // Custom search logic for polymorphic relation
                    }),
                Tables\Columns\TextColumn::make('reporter.name')
                    ->label('Reporter')
                    ->searchable()
                    ->url(fn (Report $record) => $record->reporter ? UserResource::getUrl('view', ['record' => $record->reporter]) : null)
                    ->color('primary'),
                Tables\Columns\TextColumn::make('reason')
                    ->badge()
                    ->formatStateUsing(fn (ReportReason $state) => $state->label())
                    ->color(fn (ReportReason $state) => match ($state) {
                        ReportReason::Spam => 'warning',
                        ReportReason::Abuse => 'danger',
                        ReportReason::Fake => 'danger',
                        ReportReason::Other => 'gray',
                    }),
                Tables\Columns\TextColumn::make('reportable_type')
                    ->label('Type')
                    ->formatStateUsing(fn ($state) => class_basename($state))
                    ->badge()
                    ->color('info'),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (ReportStatus $state) => $state->color()),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('Reported')
                    ->since()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(collect(ReportStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()])),
                Tables\Filters\SelectFilter::make('reason')
                    ->options(collect(ReportReason::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()])),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('View Details')
                    ->icon('heroicon-o-eye'),
                Tables\Actions\Action::make('banStore')
                    ->label('Ban Store')
                    ->icon('heroicon-o-no-symbol')
                    ->color('danger')
                    ->visible(fn (Report $record) => $record->status === ReportStatus::Open)
                    ->requiresConfirmation()
                    ->modalHeading('Ban Store')
                    ->modalDescription('This will suspend the store. Are you sure?')
                    ->action(function (Report $record) {
                        $store = self::getRelatedStore($record);
                        if ($store) {
                            $store->update(['status' => \App\Enums\StoreStatus::Suspended]);
                            $record->update([
                                'status' => ReportStatus::Resolved,
                                'handled_by' => auth()->id(),
                                'handled_at' => now(),
                            ]);
                            AuditLog::log('store.banned', 'Store', $store->id, null, [
                                'report_id' => $record->id,
                            ]);
                        }
                    }),
                Tables\Actions\Action::make('dismiss')
                    ->label('Dismiss')
                    ->icon('heroicon-o-x-mark')
                    ->color('gray')
                    ->visible(fn (Report $record) => $record->status === ReportStatus::Open)
                    ->requiresConfirmation()
                    ->action(function (Report $record) {
                        $record->update([
                            'status' => ReportStatus::Dismissed,
                            'handled_by' => auth()->id(),
                            'handled_at' => now(),
                        ]);
                        AuditLog::log('report.dismissed', 'Report', $record->id);
                    }),
            ]);
    }

    public static function getRelatedStore(Report $record): ?\App\Models\Store
    {
        $content = $record->reportable;

        if ($content instanceof \App\Models\Store) {
            return $content;
        }

        if ($content instanceof Review) {
            return $content->store;
        }

        if ($content instanceof StoreReply) {
            return $content->review?->store;
        }

        return null;
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListReports::route('/'),
            'view' => Pages\ViewReport::route('/{record}'),
        ];
    }
}
