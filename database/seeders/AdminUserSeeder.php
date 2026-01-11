<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class AdminUserSeeder extends Seeder
{
    public function run(): void
    {
        // Create admin role
        $adminRole = Role::firstOrCreate(['name' => 'admin', 'guard_name' => 'web']);

        // Get admin credentials from environment or use secure defaults
        $adminEmail = env('ADMIN_EMAIL', 'admin@preuvely.dz');
        $adminPassword = env('ADMIN_PASSWORD', 'Pr3uvely!@Adm1n#2025Secure');

        // Create or update admin user
        $admin = User::updateOrCreate(
            ['email' => $adminEmail],
            [
                'name' => 'Admin',
                'email' => $adminEmail,
                'phone' => '+213555000000',
                'password' => Hash::make($adminPassword),
                'email_verified_at' => now(),
            ]
        );

        $admin->assignRole($adminRole);

        $this->command->info("Admin user created: {$adminEmail}");
    }
}
