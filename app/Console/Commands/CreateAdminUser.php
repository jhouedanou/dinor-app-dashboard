<?php

namespace App\Console\Commands;

use App\Models\AdminUser;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class CreateAdminUser extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'admin:create 
                           {--email=admin@dinor.app : Email de l\'administrateur} 
                           {--password=Dinor2024!Admin : Mot de passe de l\'administrateur}
                           {--name=Administrateur Dinor : Nom de l\'administrateur}
                           {--force : Forcer la création même si l\'utilisateur existe}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Créer un utilisateur administrateur pour le dashboard Dinor';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $email = $this->option('email');
        $password = $this->option('password');
        $name = $this->option('name');
        $force = $this->option('force');

        $this->info("=== Création d'un utilisateur administrateur ===");
        $this->info("Email: $email");
        $this->info("Nom: $name");

        // Vérifier si l'admin existe déjà
        $existingAdmin = AdminUser::where('email', $email)->first();

        if ($existingAdmin) {
            if (!$force) {
                $this->warn("⚠️  Un administrateur avec cet email existe déjà !");
                $this->info("ID: {$existingAdmin->id}");
                $this->info("Nom: {$existingAdmin->name}");
                $this->info("Email: {$existingAdmin->email}");
                $this->info("Créé le: {$existingAdmin->created_at}");
                
                if ($this->confirm('Voulez-vous mettre à jour le mot de passe ?')) {
                    $existingAdmin->password = Hash::make($password);
                    $existingAdmin->name = $name;
                    $existingAdmin->is_active = true;
                    $existingAdmin->save();
                    
                    $this->info("✅ Mot de passe mis à jour avec succès !");
                } else {
                    $this->info("Aucune modification effectuée.");
                }
                
                return Command::SUCCESS;
            } else {
                $this->info("🔄 Mise à jour forcée de l'administrateur existant...");
                $existingAdmin->password = Hash::make($password);
                $existingAdmin->name = $name;
                $existingAdmin->is_active = true;
                $existingAdmin->save();
                
                $this->info("✅ Administrateur mis à jour avec succès !");
                return Command::SUCCESS;
            }
        }

        // Créer le nouvel administrateur
        try {
            $admin = AdminUser::create([
                'name' => $name,
                'email' => $email,
                'password' => Hash::make($password),
                'email_verified_at' => now(),
                'is_active' => true,
            ]);

            $this->info("✅ Administrateur créé avec succès !");
            $this->info("");
            $this->info("=== Informations de connexion ===");
            $this->info("🌐 URL: " . config('app.url') . "/admin/login");
            $this->info("📧 Email: $email");
            $this->info("🔑 Mot de passe: $password");
            $this->info("👤 Nom: $name");
            $this->info("🆔 ID: {$admin->id}");
            
            $this->warn("⚠️  Assurez-vous de noter ces informations en lieu sûr !");

            return Command::SUCCESS;

        } catch (\Exception $e) {
            $this->error("❌ Erreur lors de la création de l'administrateur : " . $e->getMessage());
            return Command::FAILURE;
        }
    }
}
