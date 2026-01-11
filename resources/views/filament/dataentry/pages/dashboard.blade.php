<x-filament-panels::page>
    {{-- Welcome Banner --}}
    <div class="rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 p-6 text-white shadow-lg mb-6">
        <div class="flex items-center justify-between">
            <div>
                <h2 class="text-2xl font-bold mb-2">Welcome back, {{ auth()->user()->name }}! 👋</h2>
                <p class="text-emerald-100">
                    Ready to add more stores to Preuvely? Let's help users discover amazing e-commerce stores!
                </p>
            </div>
            <div class="hidden md:block">
                <a href="{{ route('filament.dataentry.resources.stores.create') }}"
                   class="inline-flex items-center px-6 py-3 bg-white text-emerald-700 font-semibold rounded-lg hover:bg-emerald-50 transition-colors shadow-md">
                    <x-heroicon-o-plus-circle class="w-5 h-5 mr-2" />
                    Add New Store
                </a>
            </div>
        </div>
    </div>

    {{-- Quick Actions --}}
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <a href="{{ route('filament.dataentry.resources.stores.create') }}"
           class="flex items-center p-4 bg-gray-800 dark:bg-gray-800 rounded-xl border-2 border-dashed border-emerald-500/50 hover:border-emerald-400 hover:bg-gray-700 transition-all group">
            <div class="p-3 bg-emerald-500/20 rounded-lg group-hover:bg-emerald-500/30 transition-colors">
                <x-heroicon-o-plus class="w-6 h-6 text-emerald-400" />
            </div>
            <div class="ml-4">
                <h3 class="font-semibold text-white">Add New Store</h3>
                <p class="text-sm text-gray-400">Create a new store entry</p>
            </div>
        </a>

        <a href="{{ route('filament.dataentry.resources.stores.index') }}"
           class="flex items-center p-4 bg-gray-800 dark:bg-gray-800 rounded-xl border border-gray-700 hover:border-emerald-500/50 hover:bg-gray-700 transition-all group">
            <div class="p-3 bg-gray-700 rounded-lg group-hover:bg-emerald-500/20 transition-colors">
                <x-heroicon-o-building-storefront class="w-6 h-6 text-gray-400 group-hover:text-emerald-400" />
            </div>
            <div class="ml-4">
                <h3 class="font-semibold text-white">View My Stores</h3>
                <p class="text-sm text-gray-400">Manage your store entries</p>
            </div>
        </a>

        <div class="flex items-center p-4 bg-gray-800 dark:bg-gray-800 rounded-xl border border-gray-700">
            <div class="p-3 bg-amber-500/20 rounded-lg">
                <x-heroicon-o-light-bulb class="w-6 h-6 text-amber-400" />
            </div>
            <div class="ml-4">
                <h3 class="font-semibold text-white">Pro Tip</h3>
                <p class="text-sm text-gray-400">Add at least one social link per store!</p>
            </div>
        </div>
    </div>

    {{-- Stats & Recent Stores --}}
    @livewire(\App\Filament\Dataentry\Widgets\DataEntryStatsWidget::class)

    <div class="mt-6">
        @livewire(\App\Filament\Dataentry\Widgets\RecentStoresWidget::class)
    </div>

    {{-- Guidelines Card --}}
    <div class="mt-6 bg-gray-800 dark:bg-gray-800 rounded-xl p-6 border border-gray-700">
        <h3 class="text-lg font-semibold text-white mb-4 flex items-center">
            <x-heroicon-o-clipboard-document-list class="w-5 h-5 mr-2 text-emerald-400" />
            Data Entry Guidelines
        </h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="flex items-start">
                <x-heroicon-o-check-circle class="w-5 h-5 text-emerald-400 mt-0.5 mr-2 flex-shrink-0" />
                <p class="text-sm text-gray-300">Always include at least one social media or website link</p>
            </div>
            <div class="flex items-start">
                <x-heroicon-o-check-circle class="w-5 h-5 text-emerald-400 mt-0.5 mr-2 flex-shrink-0" />
                <p class="text-sm text-gray-300">Use the correct store name as it appears online</p>
            </div>
            <div class="flex items-start">
                <x-heroicon-o-check-circle class="w-5 h-5 text-emerald-400 mt-0.5 mr-2 flex-shrink-0" />
                <p class="text-sm text-gray-300">Choose the most relevant categories (max 3)</p>
            </div>
            <div class="flex items-start">
                <x-heroicon-o-check-circle class="w-5 h-5 text-emerald-400 mt-0.5 mr-2 flex-shrink-0" />
                <p class="text-sm text-gray-300">Upload a clear logo when available</p>
            </div>
        </div>
    </div>
</x-filament-panels::page>
