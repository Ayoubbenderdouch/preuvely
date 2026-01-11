<?php

use App\Enums\RiskLevel;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            $table->string('risk_level')->default(RiskLevel::Normal->value)->after('slug');
        });

        // Migrate existing is_high_risk values to risk_level
        DB::table('categories')
            ->where('is_high_risk', true)
            ->update(['risk_level' => RiskLevel::HighRisk->value]);

        // Drop the old is_high_risk column
        Schema::table('categories', function (Blueprint $table) {
            $table->dropColumn('is_high_risk');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            $table->boolean('is_high_risk')->default(false)->after('slug');
        });

        // Migrate risk_level back to is_high_risk
        DB::table('categories')
            ->where('risk_level', RiskLevel::HighRisk->value)
            ->update(['is_high_risk' => true]);

        Schema::table('categories', function (Blueprint $table) {
            $table->dropColumn('risk_level');
        });
    }
};
