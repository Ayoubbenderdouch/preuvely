<?php

use App\Enums\ReviewStatus;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('store_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->tinyInteger('stars')->unsigned();
            $table->text('comment');
            $table->string('status')->default(ReviewStatus::Pending->value);
            $table->boolean('is_high_risk')->default(false);
            $table->string('ip_hash')->nullable();
            $table->string('ua_hash')->nullable();
            $table->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('approved_at')->nullable();
            $table->text('rejected_reason')->nullable();
            $table->timestamps();

            $table->unique(['store_id', 'user_id']);
            $table->index(['status', 'is_high_risk']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
