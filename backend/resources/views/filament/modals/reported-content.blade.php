<div class="p-4">
    <h3 class="text-lg font-medium mb-4">Reported Content</h3>

    <div class="bg-gray-100 dark:bg-gray-800 rounded-lg p-4">
        <p class="text-gray-700 dark:text-gray-300">{{ $text }}</p>
    </div>

    @if($content instanceof \App\Models\Review)
        <div class="mt-4 text-sm text-gray-500">
            <p><strong>Store:</strong> {{ $content->store->name ?? 'Unknown' }}</p>
            <p><strong>Rating:</strong> {{ $content->stars }} / 5</p>
            <p><strong>Status:</strong> {{ $content->status->label() }}</p>
        </div>
    @elseif($content instanceof \App\Models\StoreReply)
        <div class="mt-4 text-sm text-gray-500">
            <p><strong>Store:</strong> {{ $content->store->name ?? 'Unknown' }}</p>
            <p><strong>Status:</strong> {{ $content->status->label() }}</p>
        </div>
    @endif
</div>
