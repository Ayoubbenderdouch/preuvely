<?php

namespace App\Filament\Resources\ReportResource\Pages;

use App\Enums\ReportStatus;
use App\Enums\ReviewStatus;
use App\Enums\ReplyStatus;
use App\Enums\StoreStatus;
use App\Filament\Resources\ReportResource;
use App\Models\AuditLog;
use App\Models\Review;
use App\Models\Store;
use App\Models\StoreReply;
use Filament\Actions;
use Filament\Infolists\Components\Grid;
use Filament\Infolists\Components\Group;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;

class ViewReport extends ViewRecord
{
    protected static string $resource = ReportResource::class;

    public function infolist(Infolist $infolist): Infolist
    {
        return $infolist
            ->schema([
                // Report Status Banner
                Section::make('Report Status')
                    ->schema([
                        TextEntry::make('status')
                            ->badge()
                            ->color(fn ($state) => $state->color()),
                        TextEntry::make('reason')
                            ->badge()
                            ->formatStateUsing(fn ($state) => $state->label()),
                        TextEntry::make('created_at')
                            ->label('Reported At')
                            ->dateTime(),
                        TextEntry::make('handled_at')
                            ->label('Handled At')
                            ->dateTime()
                            ->visible(fn ($record) => $record->handled_at !== null),
                    ])->columns(4),

                // Reporter Info
                Section::make('Reporter Information')
                    ->description('Who submitted this report')
                    ->icon('heroicon-o-user')
                    ->schema([
                        TextEntry::make('reporter.name')
                            ->label('Name'),
                        TextEntry::make('reporter.email')
                            ->label('Email')
                            ->copyable(),
                        TextEntry::make('reporter.phone')
                            ->label('Phone')
                            ->default('Not provided'),
                        TextEntry::make('reporter.created_at')
                            ->label('Account Created')
                            ->dateTime(),
                        TextEntry::make('note')
                            ->label('Report Note')
                            ->columnSpanFull(),
                    ])->columns(4),

                // Reported Content Section
                Section::make('Reported Content')
                    ->description('The content that was reported')
                    ->icon('heroicon-o-flag')
                    ->schema([
                        TextEntry::make('reportable_type')
                            ->label('Content Type')
                            ->formatStateUsing(fn ($state) => class_basename($state))
                            ->badge(),
                        TextEntry::make('reported_content_text')
                            ->label('Content')
                            ->state(function ($record) {
                                $content = $record->reportable;
                                return match (true) {
                                    $content instanceof Review => $content->comment ?? 'No comment',
                                    $content instanceof StoreReply => $content->reply_text ?? 'No reply text',
                                    $content instanceof Store => 'Store: ' . $content->name,
                                    default => 'Unknown content',
                                };
                            })
                            ->columnSpanFull(),
                    ])->columns(2),

                // Store Information (if reportable is Review or Store)
                Section::make('Store Information')
                    ->description('Details about the reported store')
                    ->icon('heroicon-o-building-storefront')
                    ->schema([
                        ImageEntry::make('store_logo')
                            ->label('Logo')
                            ->state(function ($record) {
                                $store = $this->getRelatedStore($record);
                                return $store?->logo ? asset('storage/' . $store->logo) : null;
                            })
                            ->circular()
                            ->size(80),
                        TextEntry::make('store_name')
                            ->label('Store Name')
                            ->state(fn ($record) => $this->getRelatedStore($record)?->name ?? 'N/A')
                            ->weight('bold'),
                        TextEntry::make('store_slug')
                            ->label('Slug')
                            ->state(fn ($record) => $this->getRelatedStore($record)?->slug ?? 'N/A')
                            ->copyable(),
                        TextEntry::make('store_status')
                            ->label('Store Status')
                            ->state(fn ($record) => $this->getRelatedStore($record)?->status ?? 'N/A')
                            ->badge()
                            ->color(fn ($state) => $state === StoreStatus::Active ? 'success' : 'danger'),
                        TextEntry::make('store_verified')
                            ->label('Verified')
                            ->state(fn ($record) => $this->getRelatedStore($record)?->is_verified ? 'Yes' : 'No')
                            ->badge()
                            ->color(fn ($state) => $state === 'Yes' ? 'success' : 'gray'),
                        TextEntry::make('store_rating')
                            ->label('Average Rating')
                            ->state(fn ($record) => number_format($this->getRelatedStore($record)?->avg_rating_cache ?? 0, 1) . ' / 5'),
                        TextEntry::make('store_reviews_count')
                            ->label('Total Reviews')
                            ->state(fn ($record) => $this->getRelatedStore($record)?->reviews_count_cache ?? 0),
                        TextEntry::make('store_created_at')
                            ->label('Store Created')
                            ->state(fn ($record) => $this->getRelatedStore($record)?->created_at?->format('M d, Y H:i') ?? 'N/A'),
                    ])->columns(4)
                    ->visible(fn ($record) => $this->getRelatedStore($record) !== null),

                // Review Details (if reportable is Review)
                Section::make('Review Details')
                    ->description('Information about the reported review')
                    ->icon('heroicon-o-star')
                    ->schema([
                        TextEntry::make('review_rating')
                            ->label('Rating')
                            ->state(fn ($record) => $record->reportable instanceof Review ? $record->reportable->rating . ' stars' : 'N/A'),
                        TextEntry::make('review_status')
                            ->label('Review Status')
                            ->state(fn ($record) => $record->reportable instanceof Review ? $record->reportable->status : 'N/A')
                            ->badge(),
                        TextEntry::make('review_has_proof')
                            ->label('Has Proof')
                            ->state(fn ($record) => $record->reportable instanceof Review ? ($record->reportable->proofs()->exists() ? 'Yes' : 'No') : 'N/A')
                            ->badge()
                            ->color(fn ($state) => $state === 'Yes' ? 'success' : 'gray'),
                        TextEntry::make('review_created_at')
                            ->label('Review Date')
                            ->state(fn ($record) => $record->reportable instanceof Review ? $record->reportable->created_at->format('M d, Y H:i') : 'N/A'),
                        TextEntry::make('review_author')
                            ->label('Review Author')
                            ->state(fn ($record) => $record->reportable instanceof Review ? ($record->reportable->user?->name ?? 'Anonymous') : 'N/A'),
                        TextEntry::make('review_author_email')
                            ->label('Author Email')
                            ->state(fn ($record) => $record->reportable instanceof Review ? ($record->reportable->user?->email ?? 'N/A') : 'N/A')
                            ->copyable(),
                    ])->columns(3)
                    ->visible(fn ($record) => $record->reportable instanceof Review),
            ]);
    }

    protected function getRelatedStore($record): ?Store
    {
        $content = $record->reportable;

        if ($content instanceof Store) {
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

    protected function getHeaderActions(): array
    {
        return [
            // Hide Content Action
            Actions\Action::make('hideContent')
                ->label('Hide Content')
                ->icon('heroicon-o-eye-slash')
                ->color('warning')
                ->visible(fn () => $this->record->status === ReportStatus::Open)
                ->requiresConfirmation()
                ->modalHeading('Hide Reported Content')
                ->modalDescription('This will hide the reported content from public view. Are you sure?')
                ->action(function () {
                    $content = $this->record->reportable;

                    if ($content instanceof Review) {
                        $content->update(['status' => ReviewStatus::Rejected]);
                        $content->store->recalculateRatings();
                    } elseif ($content instanceof StoreReply) {
                        $content->update(['status' => ReplyStatus::Hidden]);
                    }

                    $this->record->update([
                        'status' => ReportStatus::Resolved,
                        'handled_by' => auth()->id(),
                        'handled_at' => now(),
                    ]);

                    AuditLog::log('report.content_hidden', 'Report', $this->record->id);
                    Notification::make()->title('Content hidden successfully')->success()->send();
                }),

            // Ban Store Action
            Actions\Action::make('banStore')
                ->label('Ban Store')
                ->icon('heroicon-o-building-storefront')
                ->color('danger')
                ->visible(fn () => $this->getRelatedStore($this->record)?->status === StoreStatus::Active)
                ->requiresConfirmation()
                ->modalHeading('Ban Store')
                ->modalDescription('This will suspend the store and hide it from public listings. This action can be reversed later.')
                ->action(function () {
                    $store = $this->getRelatedStore($this->record);
                    if ($store) {
                        $store->update(['status' => StoreStatus::Suspended]);

                        // Also resolve the report
                        $this->record->update([
                            'status' => ReportStatus::Resolved,
                            'handled_by' => auth()->id(),
                            'handled_at' => now(),
                        ]);

                        AuditLog::log('store.banned', 'Store', $store->id, null, [
                            'report_id' => $this->record->id,
                            'reason' => $this->record->reason->value,
                        ]);

                        Notification::make()->title('Store has been banned')->success()->send();
                    }
                }),

            // Unban Store Action
            Actions\Action::make('unbanStore')
                ->label('Unban Store')
                ->icon('heroicon-o-check-circle')
                ->color('success')
                ->visible(fn () => $this->getRelatedStore($this->record)?->status === StoreStatus::Suspended)
                ->requiresConfirmation()
                ->modalHeading('Unban Store')
                ->modalDescription('This will reactivate the store and make it visible in public listings again.')
                ->action(function () {
                    $store = $this->getRelatedStore($this->record);
                    if ($store) {
                        $store->update(['status' => StoreStatus::Active]);

                        AuditLog::log('store.unbanned', 'Store', $store->id, null, [
                            'report_id' => $this->record->id,
                        ]);

                        Notification::make()->title('Store has been reactivated')->success()->send();
                    }
                }),

            // Dismiss Report Action
            Actions\Action::make('dismiss')
                ->label('Dismiss Report')
                ->icon('heroicon-o-x-mark')
                ->color('gray')
                ->visible(fn () => $this->record->status === ReportStatus::Open)
                ->requiresConfirmation()
                ->modalHeading('Dismiss Report')
                ->modalDescription('This will mark the report as a false/invalid report. No action will be taken against the content.')
                ->action(function () {
                    $this->record->update([
                        'status' => ReportStatus::Dismissed,
                        'handled_by' => auth()->id(),
                        'handled_at' => now(),
                    ]);

                    AuditLog::log('report.dismissed', 'Report', $this->record->id);
                    Notification::make()->title('Report dismissed')->success()->send();
                }),

            Actions\Action::make('back')
                ->label('Back to List')
                ->icon('heroicon-o-arrow-left')
                ->url(ReportResource::getUrl('index'))
                ->color('gray'),
        ];
    }
}
