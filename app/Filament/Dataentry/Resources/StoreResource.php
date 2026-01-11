<?php

namespace App\Filament\Dataentry\Resources;

use App\Filament\Dataentry\Resources\StoreResource\Pages;
use App\Models\Store;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Forms\Set;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Livewire\Features\SupportFileUploads\TemporaryUploadedFile;

class StoreResource extends Resource
{
    protected static ?string $model = Store::class;

    protected static ?string $navigationIcon = 'heroicon-o-building-storefront';

    protected static ?string $navigationLabel = 'My Stores';

    protected static ?string $modelLabel = 'Store';

    protected static ?int $navigationSort = 1;

    public static function getNavigationBadge(): ?string
    {
        return static::getEloquentQuery()->count();
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->where('submitted_by', Auth::id())
            ->latest();
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                // Store Name & Category
                Forms\Components\Section::make()
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('Store Name')
                            ->placeholder('z.B. Fashion Store DZ')
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(fn (Forms\Set $set, ?string $state) =>
                                $state ? $set('slug', Str::slug($state)) : null
                            )
                            ->columnSpan(2),

                        Forms\Components\Hidden::make('slug'),

                        Forms\Components\Select::make('categories')
                            ->label('Categories')
                            ->relationship('categories', 'name_en')
                            ->multiple()
                            ->searchable()
                            ->preload()
                            ->placeholder('Select categories...')
                            ->columnSpan(2),
                    ])
                    ->columns(2),

                // Logo (Required)
                Forms\Components\Section::make('Store Logo')
                    ->description('Upload the store logo')
                    ->icon('heroicon-o-photo')
                    ->schema([
                        Forms\Components\FileUpload::make('logo_upload')
                            ->label('Upload Logo')
                            ->image()
                            ->imageResizeMode('cover')
                            ->imageCropAspectRatio('1:1')
                            ->imageResizeTargetWidth('400')
                            ->imageResizeTargetHeight('400')
                            ->maxSize(2048)
                            ->disk('local')
                            ->directory('temp-logos')
                            ->visibility('private')
                            ->dehydrated(false)
                            ->afterStateUpdated(function ($state, Set $set) {
                                if ($state instanceof TemporaryUploadedFile) {
                                    $contents = file_get_contents($state->getRealPath());
                                    $mimeType = $state->getMimeType();
                                    $base64 = 'data:' . $mimeType . ';base64,' . base64_encode($contents);
                                    $set('logo_data', $base64);
                                }
                            })
                            ->required(fn ($record) => $record === null || empty($record->logo_data)),
                        Forms\Components\Hidden::make('logo_data'),
                        Forms\Components\Placeholder::make('current_logo')
                            ->label('Current Logo')
                            ->content(fn ($record) => $record && $record->logo_data
                                ? new \Illuminate\Support\HtmlString('<img src="' . $record->logo_data . '" style="max-width: 150px; border-radius: 12px;" />')
                                : ($record && $record->logo
                                    ? new \Illuminate\Support\HtmlString('<img src="' . $record->full_logo_url . '" style="max-width: 150px; border-radius: 12px;" />')
                                    : 'No logo uploaded'))
                            ->visible(fn ($record) => $record !== null),
                    ]),

                // Social Links
                Forms\Components\Section::make('Social Media & Website')
                    ->icon('heroicon-o-link')
                    ->schema([
                        Forms\Components\TextInput::make('instagram_url')
                            ->label('Instagram')
                            ->placeholder('https://instagram.com/...')
                            ->url()
                            ->prefixIcon('heroicon-o-camera'),

                        Forms\Components\TextInput::make('tiktok_url')
                            ->label('TikTok')
                            ->placeholder('https://tiktok.com/@...')
                            ->url()
                            ->prefixIcon('heroicon-o-musical-note'),

                        Forms\Components\TextInput::make('facebook_url')
                            ->label('Facebook')
                            ->placeholder('https://facebook.com/...')
                            ->url()
                            ->prefixIcon('heroicon-o-hand-thumb-up'),

                        Forms\Components\TextInput::make('website_url')
                            ->label('Website')
                            ->placeholder('https://...')
                            ->url()
                            ->prefixIcon('heroicon-o-globe-alt'),
                    ])
                    ->columns(2),

                // WhatsApp
                Forms\Components\Section::make('Contact')
                    ->icon('heroicon-o-phone')
                    ->schema([
                        Forms\Components\TextInput::make('whatsapp')
                            ->label('WhatsApp Number')
                            ->placeholder('+213 5XX XXX XXX')
                            ->tel()
                            ->prefixIcon('heroicon-o-chat-bubble-left-ellipsis'),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('full_logo_url')
                    ->label('')
                    ->circular()
                    ->size(45)
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name ?? 'S') . '&color=007359&background=d1fae5&size=100'),

                Tables\Columns\TextColumn::make('name')
                    ->label('Store')
                    ->searchable()
                    ->weight('bold')
                    ->description(fn ($record) => $record->categories->pluck('name_en')->implode(', ') ?: 'No category'),

                Tables\Columns\TextColumn::make('links_count')
                    ->label('Links')
                    ->counts('links')
                    ->badge()
                    ->color('success'),

                Tables\Columns\IconColumn::make('is_verified')
                    ->label('Status')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-badge')
                    ->falseIcon('heroicon-o-clock')
                    ->trueColor('success')
                    ->falseColor('warning'),

                Tables\Columns\TextColumn::make('created_at')
                    ->label('Added')
                    ->since(),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([
                Tables\Actions\EditAction::make()->iconButton(),
                Tables\Actions\DeleteAction::make()->iconButton(),
            ])
            ->emptyStateHeading('No stores yet')
            ->emptyStateDescription('Click "Add Store" to add your first one!')
            ->emptyStateIcon('heroicon-o-building-storefront');
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStores::route('/'),
            'create' => Pages\CreateStore::route('/create'),
            'edit' => Pages\EditStore::route('/{record}/edit'),
        ];
    }
}
