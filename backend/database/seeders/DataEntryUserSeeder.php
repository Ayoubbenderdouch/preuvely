<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class DataEntryUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Ensure the data_entry role exists
        $role = Role::firstOrCreate(
            ['name' => 'data_entry', 'guard_name' => 'web']
        );

        // Create data entry users
        $dataEntryUsers = [
            [
                'name' => 'Data Entry 1',
                'email' => 'dataentry1@preuvely.com',
                'password' => Hash::make('dataentry123'),
            ],
            [
                'name' => 'Data Entry 2',
                'email' => 'dataentry2@preuvely.com',
                'password' => Hash::make('dataentry123'),
            ],
            [
                'name' => 'Data Entry 3',
                'email' => 'dataentry3@preuvely.com',
                'password' => Hash::make('dataentry123'),
            ],
        ];

        foreach ($dataEntryUsers as $userData) {
            $user = User::firstOrCreate(
                ['email' => $userData['email']],
                [
                    'name' => $userData['name'],
                    'password' => $userData['password'],
                    'email_verified_at' => now(),
                ]
            );

            // Assign the data_entry role
            if (!$user->hasRole('data_entry')) {
                $user->assignRole('data_entry');
            }

            $this->command->info("Created/Updated data entry user: {$userData['email']}");
        }

        $this->command->info('');
        $this->command->info('===========================================');
        $this->command->info('Data Entry Users Created!');
        $this->command->info('===========================================');
        $this->command->info('');
        $this->command->info('Login URL: /dataentry');
        $this->command->info('');
        $this->command->info('Credentials:');
        $this->command->info('  Email: dataentry1@preuvely.com');
        $this->command->info('  Password: dataentry123');
        $this->command->info('');
        $this->command->info('  Email: dataentry2@preuvely.com');
        $this->command->info('  Password: dataentry123');
        $this->command->info('');
        $this->command->info('  Email: dataentry3@preuvely.com');
        $this->command->info('  Password: dataentry123');
        $this->command->info('');
    }
}
