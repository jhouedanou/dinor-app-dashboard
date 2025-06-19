<?php

namespace App\Console\Commands;

use App\Models\AdminUser;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class CreateTestAdmin extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'admin:create-test';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Create a test admin user';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $email = 'admin@dinor.com';
        $password = 'password';
        
        // Vérifier si l'admin existe déjà
        if (AdminUser::where('email', $email)->exists()) {
            $this->info('Admin user already exists!');
            return;
        }
        
        AdminUser::create([
            'name' => 'Admin Dinor',
            'email' => $email,
            'password' => Hash::make($password),
        ]);
        
        $this->info('Test admin user created successfully!');
        $this->info('Email: ' . $email);
        $this->info('Password: ' . $password);
        $this->info('You can now login at: http://localhost:8000/admin');
    }
}
