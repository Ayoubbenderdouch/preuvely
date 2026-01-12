<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Filament\Resources\UserResource;
use App\Models\User;
use Filament\Actions;
use Filament\Forms;
use Filament\Resources\Pages\ListRecords;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class ListUsers extends ListRecords
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\Action::make('createDataEntry')
                ->label('+ Data Entry Mitarbeiter')
                ->color('success')
                ->icon('heroicon-o-user-plus')
                ->form([
                    Forms\Components\TextInput::make('name')
                        ->label('Name')
                        ->required()
                        ->maxLength(255),
                    Forms\Components\TextInput::make('email')
                        ->label('Email')
                        ->email()
                        ->required()
                        ->unique('users', 'email')
                        ->maxLength(255),
                    Forms\Components\TextInput::make('password')
                        ->label('Passwort')
                        ->password()
                        ->required()
                        ->minLength(8)
                        ->maxLength(255),
                ])
                ->action(function (array $data): void {
                    $user = User::create([
                        'name' => $data['name'],
                        'email' => $data['email'],
                        'password' => Hash::make($data['password']),
                        'email_verified_at' => now(),
                    ]);

                    $user->assignRole('data_entry');

                    \Filament\Notifications\Notification::make()
                        ->title('Data Entry Mitarbeiter erstellt')
                        ->body("Login: {$data['email']} unter /dataentry")
                        ->success()
                        ->send();
                }),
            Actions\CreateAction::make(),
        ];
    }
}
