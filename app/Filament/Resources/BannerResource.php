<?php

namespace App\Filament\Resources;

use App\Filament\Resources\BannerResource\Pages;
use App\Models\Banner;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Forms\Set;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Livewire\Features\SupportFileUploads\TemporaryUploadedFile;

class BannerResource extends Resource
{
    protected static ?string $model = Banner::class;
    protected static ?string $navigationIcon = 'heroicon-o-photo';
    protected static ?string $navigationGroup = 'Content';
    protected static ?string $navigationLabel = 'Banners';
    protected static ?int $navigationSort = 1;

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::active()->count() ?: null;
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Banner Content')
                    ->description('Title and subtitle are optional')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('Title (English)')
                            ->maxLength(100)
                            ->placeholder('Optional'),
                        Forms\Components\TextInput::make('title_ar')
                            ->label('Title (Arabic)')
                            ->maxLength(100)
                            ->placeholder('Optional'),
                        Forms\Components\TextInput::make('title_fr')
                            ->label('Title (French)')
                            ->maxLength(100)
                            ->placeholder('Optional'),
                        Forms\Components\TextInput::make('subtitle')
                            ->label('Subtitle (English)')
                            ->maxLength(200)
                            ->placeholder('Optional'),
                        Forms\Components\TextInput::make('subtitle_ar')
                            ->label('Subtitle (Arabic)')
                            ->maxLength(200)
                            ->placeholder('Optional'),
                        Forms\Components\TextInput::make('subtitle_fr')
                            ->label('Subtitle (French)')
                            ->maxLength(200)
                            ->placeholder('Optional'),
                    ])
                    ->columns(3),

                Forms\Components\Section::make('Banner Image')
                    ->schema([
                        Forms\Components\FileUpload::make('image_upload')
                            ->label('Banner Image')
                            ->image()
                            ->imageResizeMode('cover')
                            ->imageCropAspectRatio('16:9')
                            ->imageResizeTargetWidth('1200')
                            ->imageResizeTargetHeight('675')
                            ->maxSize(5120)
                            ->disk('local')
                            ->directory('temp-banners')
                            ->visibility('private')
                            ->dehydrated(false)
                            ->afterStateUpdated(function ($state, Set $set) {
                                if ($state instanceof TemporaryUploadedFile) {
                                    $contents = file_get_contents($state->getRealPath());
                                    $mimeType = $state->getMimeType();
                                    $base64 = 'data:' . $mimeType . ';base64,' . base64_encode($contents);
                                    $set('image_data', $base64);
                                }
                            })
                            ->required(fn ($record) => $record === null || empty($record->image_data)),
                        Forms\Components\Hidden::make('image_data'),
                        Forms\Components\Placeholder::make('current_image')
                            ->label('Current Image')
                            ->content(fn ($record) => $record && $record->image_data
                                ? new \Illuminate\Support\HtmlString('<img src="' . $record->image_data . '" style="max-width: 300px; border-radius: 8px;" />')
                                : 'No image uploaded')
                            ->visible(fn ($record) => $record !== null),
                        Forms\Components\ColorPicker::make('background_color')
                            ->label('Background Color (Fallback)')
                            ->default('#22C55E'),
                    ])
                    ->columns(1),

                Forms\Components\Section::make('Link Settings')
                    ->schema([
                        Forms\Components\Select::make('link_type')
                            ->label('Link Type')
                            ->options([
                                'none' => 'No Link',
                                'store' => 'Store',
                                'category' => 'Category',
                                'url' => 'External URL',
                            ])
                            ->default('none')
                            ->reactive(),
                        Forms\Components\TextInput::make('link_value')
                            ->label('Link Value')
                            ->helperText('Store slug, category slug, or full URL')
                            ->visible(fn ($get) => $get('link_type') !== 'none'),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Display Settings')
                    ->schema([
                        Forms\Components\TextInput::make('sort_order')
                            ->label('Sort Order')
                            ->numeric()
                            ->default(0)
                            ->helperText('Lower numbers appear first'),
                        Forms\Components\Toggle::make('is_active')
                            ->label('Active')
                            ->default(true),
                        Forms\Components\DatePicker::make('starts_at')
                            ->label('Start Date')
                            ->helperText('Leave empty for immediate'),
                        Forms\Components\DatePicker::make('ends_at')
                            ->label('End Date')
                            ->helperText('Leave empty for no expiry'),
                    ])
                    ->columns(4),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('image_data')
                    ->label('Image')
                    ->width(120)
                    ->height(68)
                    ->defaultImageUrl(fn ($record) => null),
                Tables\Columns\TextColumn::make('title')
                    ->label('Title')
                    ->searchable()
                    ->limit(30),
                Tables\Columns\TextColumn::make('link_type')
                    ->label('Link')
                    ->badge()
                    ->color(fn (string $state) => match ($state) {
                        'store' => 'success',
                        'category' => 'info',
                        'url' => 'warning',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('sort_order')
                    ->label('Order')
                    ->sortable(),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('Active')
                    ->boolean(),
                Tables\Columns\TextColumn::make('starts_at')
                    ->label('Starts')
                    ->dateTime('M d, Y')
                    ->placeholder('Immediate'),
                Tables\Columns\TextColumn::make('ends_at')
                    ->label('Ends')
                    ->dateTime('M d, Y')
                    ->placeholder('Never'),
            ])
            ->defaultSort('sort_order')
            ->filters([
                Tables\Filters\TernaryFilter::make('is_active')
                    ->label('Active'),
                Tables\Filters\SelectFilter::make('link_type')
                    ->options([
                        'none' => 'No Link',
                        'store' => 'Store',
                        'category' => 'Category',
                        'url' => 'External URL',
                    ]),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('toggle')
                    ->label(fn (Banner $record) => $record->is_active ? 'Deactivate' : 'Activate')
                    ->icon(fn (Banner $record) => $record->is_active ? 'heroicon-o-x-circle' : 'heroicon-o-check-circle')
                    ->color(fn (Banner $record) => $record->is_active ? 'danger' : 'success')
                    ->action(fn (Banner $record) => $record->update(['is_active' => !$record->is_active])),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ])
            ->reorderable('sort_order');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListBanners::route('/'),
            'create' => Pages\CreateBanner::route('/create'),
            'edit' => Pages\EditBanner::route('/{record}/edit'),
        ];
    }
}
