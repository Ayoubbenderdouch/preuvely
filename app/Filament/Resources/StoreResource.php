<?php

namespace App\Filament\Resources;

use App\Enums\Platform;
use App\Enums\StoreStatus;
use App\Filament\Resources\StoreResource\Pages;
use App\Filament\Resources\StoreResource\RelationManagers;
use App\Filament\Resources\UserResource;
use App\Models\AuditLog;
use App\Models\Store;
use App\Services\NotificationService;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Forms\Set;
use Livewire\Features\SupportFileUploads\TemporaryUploadedFile;
use Filament\Infolists\Components\Grid;
use Filament\Infolists\Components\Group;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Support\Enums\FontWeight;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Support\Str;

class StoreResource extends Resource
{
    protected static ?string $model = Store::class;
    protected static ?string $navigationIcon = 'heroicon-o-building-storefront';
    protected static ?string $navigationGroup = 'Content';
    protected static ?int $navigationSort = 2;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Store Information')
                    ->schema([
                        Forms\Components\FileUpload::make('logo_upload')
                            ->label('Store Logo')
                            ->image()
                            ->imageResizeMode('cover')
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
                            }),
                        Forms\Components\Hidden::make('logo_data'),
                        Forms\Components\Placeholder::make('current_logo')
                            ->label('Current Logo')
                            ->content(fn ($record) => $record && $record->logo_data
                                ? new \Illuminate\Support\HtmlString('<img src="' . $record->logo_data . '" style="max-width: 150px; border-radius: 12px;" />')
                                : ($record && $record->logo
                                    ? new \Illuminate\Support\HtmlString('<img src="' . $record->full_logo_url . '" style="max-width: 150px; border-radius: 12px;" />')
                                    : 'No logo uploaded'))
                            ->visible(fn ($record) => $record !== null)
                            ->columnSpanFull(),
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255)
                            ->live(onBlur: true)
                            ->afterStateUpdated(function ($state, Forms\Set $set, $record) {
                                if (!$record) {
                                    $set('slug', Str::slug($state) . '-' . Str::random(6));
                                }
                            }),
                        Forms\Components\TextInput::make('slug')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),
                        Forms\Components\Textarea::make('description')
                            ->maxLength(2000)
                            ->rows(3)
                            ->columnSpanFull(),
                        Forms\Components\TextInput::make('city')
                            ->maxLength(100),
                    ])->columns(2),

                Forms\Components\Section::make('Categories')
                    ->schema([
                        Forms\Components\Select::make('categories')
                            ->relationship('categories', 'name_en')
                            ->multiple()
                            ->preload()
                            ->searchable(),
                    ]),

                Forms\Components\Section::make('Social Links')
                    ->description('Add or edit store social media links')
                    ->schema([
                        Forms\Components\Repeater::make('links')
                            ->relationship()
                            ->schema([
                                Forms\Components\Select::make('platform')
                                    ->options(collect(Platform::cases())->mapWithKeys(fn ($p) => [$p->value => $p->label()]))
                                    ->required(),
                                Forms\Components\TextInput::make('url')
                                    ->label('URL or Handle')
                                    ->required()
                                    ->maxLength(500)
                                    ->placeholder('https://instagram.com/store or @store'),
                                Forms\Components\TextInput::make('handle')
                                    ->label('Handle (optional)')
                                    ->maxLength(100)
                                    ->placeholder('@storename'),
                            ])
                            ->columns(3)
                            ->addActionLabel('Add Link')
                            ->reorderable()
                            ->collapsible(),
                    ]),

                Forms\Components\Section::make('Contact Information')
                    ->description('WhatsApp and phone number')
                    ->relationship('contacts')
                    ->schema([
                        Forms\Components\TextInput::make('whatsapp')
                            ->label('WhatsApp')
                            ->tel()
                            ->maxLength(20)
                            ->placeholder('+213 555 123 456'),
                        Forms\Components\TextInput::make('phone')
                            ->label('Phone')
                            ->tel()
                            ->maxLength(20)
                            ->placeholder('+213 555 123 456'),
                    ])->columns(2),

                Forms\Components\Section::make('Status')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->options(collect(StoreStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()]))
                            ->required(),
                        Forms\Components\Toggle::make('is_verified')
                            ->label('Verified Store'),
                    ])->columns(2),

                Forms\Components\Section::make('Ratings')
                    ->schema([
                        Forms\Components\TextInput::make('avg_rating_cache')
                            ->label('Average Rating')
                            ->disabled(),
                        Forms\Components\TextInput::make('reviews_count_cache')
                            ->label('Reviews Count')
                            ->disabled(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('full_logo_url')
                    ->label('Logo')
                    ->circular()
                    ->defaultImageUrl(fn ($record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&background=007359&color=fff'),
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('city')
                    ->searchable(),
                Tables\Columns\TextColumn::make('status')
                    ->badge()
                    ->color(fn (StoreStatus $state) => $state->color()),
                Tables\Columns\IconColumn::make('is_verified')
                    ->label('Verified')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-badge')
                    ->trueColor('success'),
                Tables\Columns\TextColumn::make('avg_rating_cache')
                    ->label('Rating')
                    ->formatStateUsing(fn ($state) => number_format($state, 1) . ' / 5'),
                Tables\Columns\TextColumn::make('reviews_count_cache')
                    ->label('Reviews'),
                Tables\Columns\TextColumn::make('submittedBy.name')
                    ->label('Submitted By')
                    ->placeholder('—')
                    ->badge()
                    ->color('info')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options(collect(StoreStatus::cases())->mapWithKeys(fn ($s) => [$s->value => $s->label()])),
                Tables\Filters\TernaryFilter::make('is_verified')
                    ->label('Verified'),
                Tables\Filters\SelectFilter::make('submitted_by')
                    ->label('Submitted By')
                    ->relationship('submittedBy', 'name')
                    ->searchable()
                    ->preload(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make(),
                Tables\Actions\EditAction::make(),
                Tables\Actions\Action::make('verify')
                    ->label('Verify')
                    ->icon('heroicon-o-check-badge')
                    ->color('success')
                    ->visible(fn (Store $record) => !$record->is_verified)
                    ->requiresConfirmation()
                    ->action(function (Store $record) {
                        $record->update([
                            'is_verified' => true,
                            'verified_at' => now(),
                            'verified_by' => auth()->id(),
                        ]);
                        AuditLog::log('store.verified', 'Store', $record->id);

                        // Send notifications to store owners
                        $record->refresh();
                        NotificationService::storeVerified($record);

                        // Also notify the submitter if different from owners
                        NotificationService::storeVerifiedForSubmitter($record);
                    }),
                Tables\Actions\Action::make('unverify')
                    ->label('Remove Verification')
                    ->icon('heroicon-o-x-circle')
                    ->color('warning')
                    ->visible(fn (Store $record) => $record->is_verified)
                    ->requiresConfirmation()
                    ->action(function (Store $record) {
                        $record->update([
                            'is_verified' => false,
                            'verified_at' => null,
                            'verified_by' => null,
                        ]);
                        AuditLog::log('store.unverified', 'Store', $record->id);
                    }),
                Tables\Actions\Action::make('suspend')
                    ->label('Suspend')
                    ->icon('heroicon-o-no-symbol')
                    ->color('danger')
                    ->visible(fn (Store $record) => $record->status === StoreStatus::Active)
                    ->requiresConfirmation()
                    ->action(function (Store $record) {
                        $record->update(['status' => StoreStatus::Suspended]);
                        AuditLog::log('store.suspended', 'Store', $record->id);
                    }),
                Tables\Actions\Action::make('activate')
                    ->label('Activate')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->visible(fn (Store $record) => $record->status === StoreStatus::Suspended)
                    ->requiresConfirmation()
                    ->action(function (Store $record) {
                        $record->update(['status' => StoreStatus::Active]);
                        AuditLog::log('store.activated', 'Store', $record->id);
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                Section::make('Store Information')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                Group::make([
                                    ImageEntry::make('full_logo_url')
                                        ->label('Logo')
                                        ->circular()
                                        ->defaultImageUrl(fn (Store $record) => 'https://ui-avatars.com/api/?name=' . urlencode($record->name) . '&background=007359&color=fff&size=128')
                                        ->size(100),
                                ])->grow(false),
                                Group::make([
                                    TextEntry::make('name')
                                        ->weight(FontWeight::Bold)
                                        ->size(TextEntry\TextEntrySize::Large),
                                    TextEntry::make('slug')
                                        ->copyable(),
                                    TextEntry::make('city')
                                        ->placeholder('N/A'),
                                    TextEntry::make('description')
                                        ->placeholder('No description'),
                                ])->columnSpan(2),
                            ]),
                    ]),

                Section::make('Status & Verification')
                    ->schema([
                        Grid::make(4)
                            ->schema([
                                TextEntry::make('status')
                                    ->badge()
                                    ->color(fn (StoreStatus $state) => $state->color()),
                                TextEntry::make('is_verified')
                                    ->label('Verified')
                                    ->formatStateUsing(fn ($state) => $state ? 'Yes' : 'No')
                                    ->icon(fn ($state) => $state ? 'heroicon-o-check-badge' : 'heroicon-o-x-mark')
                                    ->color(fn ($state) => $state ? 'success' : 'gray'),
                                TextEntry::make('avg_rating_cache')
                                    ->label('Rating')
                                    ->formatStateUsing(fn ($state) => $state ? number_format($state, 1) . ' / 5' : 'N/A'),
                                TextEntry::make('reviews_count_cache')
                                    ->label('Reviews'),
                            ]),
                    ]),

                Section::make('Categories')
                    ->schema([
                        TextEntry::make('categories.name_en')
                            ->label('Categories')
                            ->badge()
                            ->color('primary'),
                    ]),

                Section::make('Submission & Verification Details')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                TextEntry::make('submittedBy.name')
                                    ->label('Submitted By')
                                    ->placeholder('N/A')
                                    ->url(fn (Store $record) => $record->submittedBy ? UserResource::getUrl('view', ['record' => $record->submittedBy]) : null)
                                    ->color('primary'),
                                TextEntry::make('verifiedByUser.name')
                                    ->label('Verified By')
                                    ->placeholder('Not verified')
                                    ->url(fn (Store $record) => $record->verifiedByUser ? UserResource::getUrl('view', ['record' => $record->verifiedByUser]) : null)
                                    ->color('primary'),
                                TextEntry::make('verified_at')
                                    ->label('Verified At')
                                    ->dateTime('M d, Y H:i')
                                    ->placeholder('N/A'),
                            ]),
                        Grid::make(2)
                            ->schema([
                                TextEntry::make('created_at')
                                    ->label('Created At')
                                    ->dateTime('M d, Y H:i'),
                                TextEntry::make('updated_at')
                                    ->label('Updated At')
                                    ->dateTime('M d, Y H:i'),
                            ]),
                    ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            RelationManagers\LinksRelationManager::class,
            RelationManagers\OwnersRelationManager::class,
            RelationManagers\ClaimRequestsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListStores::route('/'),
            'create' => Pages\CreateStore::route('/create'),
            'view' => Pages\ViewStore::route('/{record}'),
            'edit' => Pages\EditStore::route('/{record}/edit'),
        ];
    }
}
