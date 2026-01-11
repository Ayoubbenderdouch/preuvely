<?php

use App\Enums\ReplyStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('store_replies', function (Blueprint $table) {
            $table->id();
            $table->foreignId('review_id')->constrained()->cascadeOnDelete();
            $table->foreignId('store_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('reply_text', 300);
            $table->string('status')->default(ReplyStatus::Visible->value);
            $table->timestamps();

            $table->unique('review_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('store_replies');
    }
};
