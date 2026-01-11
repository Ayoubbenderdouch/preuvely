<?php

namespace App\Filament\Resources;

use App\Enums\ReviewStatus;
use App\Enums\RiskLevel;
use App\Filament\Resources\CategoryResource\Pages;
use App\Models\Category;
use App\Models\Review;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Str;

class CategoryResource extends Resource
{
    protected static ?string $model = Category::class;
    protected static ?string $navigationIcon = 'heroicon-o-tag';
    protected static ?string $navigationGroup = 'Content';
    protected static ?int $navigationSort = 1;

    public static function getNavigationBadge(): ?string
    {
        $highRiskCount = static::getModel()::where('risk_level', RiskLevel::HighRisk)->count();
        return $highRiskCount > 0 ? "{$highRiskCount} high-risk" : null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'danger';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Category Names')
                    ->schema([
                        Forms\Components\TextInput::make('name_en')
                            ->label('Name (English)')
                            ->required()
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(fn ($state, Forms\Set $set) =>
                                $set('slug', Str::slug($state))
                            ),
                        Forms\Components\TextInput::make('name_ar')
                            ->label('Name (Arabic)')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\TextInput::make('name_fr')
                            ->label('Name (French)')
                            ->required()
                            ->maxLength(255),
                    ])->columns(3),

                Forms\Components\Section::make('Settings')
                    ->schema([
                        Forms\Components\TextInput::make('slug')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),
                        Forms\Components\TextInput::make('icon_key')
                            ->label('Icon Key')
                            ->placeholder('heroicon-o-...')
                            ->maxLength(100),
                        Forms\Components\Toggle::make('show_on_home')
                            ->label('Show on Home Screen')
                            ->helperText('Enable to display this category on the home screen.')
                            ->default(false),
                    ])->columns(2),

                Forms\Components\Section::make('Risk Level Settings')
                    ->description('Configure how reviews for stores in this category are handled.')
                    ->schema([
                        Forms\Components\Select::make('risk_level')
                            ->label('Risk Level')
                            ->options([
                                RiskLevel::Normal->value => 'Normal - Reviews are auto-approved',
                                RiskLevel::HighRisk->value => 'High Risk - Reviews require manual approval',
                            ])
                            ->default(RiskLevel::Normal->value)
                            ->required()
                            ->reactive()
                            ->afterStateUpdated(function ($state, $record) {
                                if ($record && $state === RiskLevel::HighRisk->value) {
                                    Notification::make()
                                        ->warning()
                                        ->title('High Risk Mode Enabled')
                                        ->body('Future reviews for stores in this category will require manual approval.')
                                        ->send();
                                }
                            }),
                        Forms\Components\Placeholder::make('risk_info')
                            ->label('Impact of Risk Level Setting')
                            ->content(function ($record) {
                                if (!$record) {
                                    return 'Save the category first to see impact information.';
                                }

                                $storeCount = $record->stores()->count();
                                $pendingReviews = Review::whereHas('store', function ($query) use ($record) {
                                    $query->whereHas('categories', function ($q) use ($record) {
                                        $q->where('categories.id', $record->id);
                                    });
                                })->where('status', ReviewStatus::Pending)->count();

                                if ($record->isHighRisk()) {
                                    return "This high-risk category has {$storeCount} store(s). There are currently {$pendingReviews} pending review(s) requiring manual approval.";
                                }

                                return "This category has {$storeCount} store(s). Reviews will be auto-approved if they meet the criteria.";
                            }),
                    ])
                    ->collapsible()
                    ->collapsed(false),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name_en')
                    ->label('Name (EN)')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('name_ar')
                    ->label('Name (AR)')
                    ->searchable()
                    ->toggleable(),
                Tables\Columns\TextColumn::make('slug')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('risk_level')
                    ->label('Risk Level')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state?->label() ?? 'Normal')
                    ->color(fn ($state) => $state?->color() ?? 'success')
                    ->icon(fn ($state) => $state === RiskLevel::HighRisk ? 'heroicon-o-exclamation-triangle' : 'heroicon-o-check-circle'),
                Tables\Columns\IconColumn::make('show_on_home')
                    ->label('Home Screen')
                    ->boolean()
                    ->trueIcon('heroicon-o-home')
                    ->falseIcon('heroicon-o-x-mark')
                    ->trueColor('success')
                    ->falseColor('gray')
                    ->sortable(),
                Tables\Columns\TextColumn::make('stores_count')
                    ->label('Stores')
                    ->counts('stores')
                    ->sortable(),
                Tables\Columns\TextColumn::make('pending_reviews_count')
                    ->label('Pending Reviews')
                    ->getStateUsing(function (Category $record) {
                        return Review::whereHas('store', function ($query) use ($record) {
                            $query->whereHas('categories', function ($q) use ($record) {
                                $q->where('categories.id', $record->id);
                            });
                        })->where('status', ReviewStatus::Pending)->count();
                    })
                    ->badge()
                    ->color(fn ($state) => $state > 0 ? 'warning' : 'gray'),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('risk_level')
                    ->label('Risk Level')
                    ->options([
                        RiskLevel::Normal->value => 'Normal',
                        RiskLevel::HighRisk->value => 'High Risk',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('toggleRiskLevel')
                    ->label(fn (Category $record) => $record->isHighRisk() ? 'Mark as Normal' : 'Mark as High Risk')
                    ->icon(fn (Category $record) => $record->isHighRisk() ? 'heroicon-o-shield-check' : 'heroicon-o-exclamation-triangle')
                    ->color(fn (Category $record) => $record->isHighRisk() ? 'success' : 'danger')
                    ->requiresConfirmation()
                    ->modalHeading(fn (Category $record) => $record->isHighRisk()
                        ? 'Mark Category as Normal Risk'
                        : 'Mark Category as High Risk')
                    ->modalDescription(fn (Category $record) => $record->isHighRisk()
                        ? 'Reviews for stores in this category will be eligible for auto-approval.'
                        : 'Reviews for stores in this category will require manual admin approval and will NOT be auto-approved.')
                    ->action(function (Category $record) {
                        $wasHighRisk = $record->isHighRisk();
                        $newRiskLevel = $wasHighRisk ? RiskLevel::Normal : RiskLevel::HighRisk;
                        $record->update(['risk_level' => $newRiskLevel]);

                        Notification::make()
                            ->success()
                            ->title('Risk Level Updated')
                            ->body($wasHighRisk
                                ? "Category '{$record->name_en}' is now marked as normal risk."
                                : "Category '{$record->name_en}' is now marked as high risk.")
                            ->send();
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\BulkAction::make('markHighRisk')
                        ->label('Mark as High Risk')
                        ->icon('heroicon-o-exclamation-triangle')
                        ->color('danger')
                        ->requiresConfirmation()
                        ->modalDescription('All selected categories will be marked as high risk. Reviews for stores in these categories will require manual approval.')
                        ->deselectRecordsAfterCompletion()
                        ->action(function ($records) {
                            $records->each(fn (Category $record) => $record->update(['risk_level' => RiskLevel::HighRisk]));
                            Notification::make()
                                ->success()
                                ->title('Categories Updated')
                                ->body($records->count() . ' category(ies) marked as high risk.')
                                ->send();
                        }),
                    Tables\Actions\BulkAction::make('markNormal')
                        ->label('Mark as Normal')
                        ->icon('heroicon-o-shield-check')
                        ->color('success')
                        ->requiresConfirmation()
                        ->modalDescription('All selected categories will be marked as normal risk. Reviews for stores in these categories will be eligible for auto-approval.')
                        ->deselectRecordsAfterCompletion()
                        ->action(function ($records) {
                            $records->each(fn (Category $record) => $record->update(['risk_level' => RiskLevel::Normal]));
                            Notification::make()
                                ->success()
                                ->title('Categories Updated')
                                ->body($records->count() . ' category(ies) marked as normal risk.')
                                ->send();
                        }),
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCategories::route('/'),
            'create' => Pages\CreateCategory::route('/create'),
            'edit' => Pages\EditCategory::route('/{record}/edit'),
        ];
    }
}
