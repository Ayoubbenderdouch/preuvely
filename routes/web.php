<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use Symfony\Component\HttpFoundation\Response;

Route::get('/', function () {
    return view('welcome');
});

/**
 * Serve storage files directly (fallback for when storage:link doesn't work on Laravel Cloud)
 * This handles /storage/{path} requests by serving files from storage/app/public/
 */
Route::get('/storage/{path}', function (string $path) {
    // Prevent directory traversal attacks
    $path = str_replace(['..', '//'], '', $path);

    if (!Storage::disk('public')->exists($path)) {
        abort(404);
    }

    $file = Storage::disk('public')->get($path);
    $mimeType = Storage::disk('public')->mimeType($path);

    return response($file, 200)
        ->header('Content-Type', $mimeType)
        ->header('Cache-Control', 'public, max-age=31536000');
})->where('path', '.*')->name('storage.serve');
