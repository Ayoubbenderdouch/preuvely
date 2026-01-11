<div class="space-y-4">
    @if($review->proofs->isEmpty())
        <div class="text-center py-8 text-gray-500">
            <x-heroicon-o-photo class="w-12 h-12 mx-auto mb-2 opacity-50" />
            <p>No proof images uploaded for this review.</p>
        </div>
    @else
        <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
            @foreach($review->proofs as $proof)
                <div class="relative group">
                    <a href="{{ $proof->url }}" target="_blank" class="block">
                        <img
                            src="{{ $proof->url }}"
                            alt="Proof Image {{ $loop->iteration }}"
                            class="w-full h-48 object-cover rounded-lg shadow-md hover:shadow-lg transition-shadow cursor-pointer"
                        />
                    </a>
                    <div class="absolute bottom-2 left-2 right-2">
                        <span class="inline-flex items-center px-2 py-1 text-xs font-medium rounded-full
                            @if($proof->status->value === 'approved') bg-green-100 text-green-800
                            @elseif($proof->status->value === 'rejected') bg-red-100 text-red-800
                            @else bg-yellow-100 text-yellow-800
                            @endif">
                            {{ ucfirst($proof->status->value) }}
                        </span>
                    </div>
                    <div class="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        <a href="{{ $proof->url }}" target="_blank"
                           class="inline-flex items-center justify-center w-8 h-8 bg-white rounded-full shadow-md hover:bg-gray-100">
                            <x-heroicon-o-arrow-top-right-on-square class="w-4 h-4 text-gray-600" />
                        </a>
                    </div>
                </div>
            @endforeach
        </div>

        <div class="mt-4 text-sm text-gray-500 text-center">
            {{ $review->proofs->count() }} proof image(s) uploaded
            <span class="mx-2">|</span>
            Click on an image to view full size
        </div>
    @endif
</div>
