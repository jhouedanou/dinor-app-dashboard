<?php

namespace App\Console\Commands;

use App\Models\AdminUser;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Hash;

class ResetAdminPassword extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'admin:reset-password {email? : Email de l\'administrateur} {--password= : Nouveau mot de passe (optionnel)}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Réinitialise le mot de passe d\'un administrateur';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $email = $this->argument('email');
        $password = $this->option('password');

        // Si aucun email n'est fourni, demander de le saisir
        if (!$email) {
            $email = $this->ask('Email de l\'administrateur');
        }

        // Validation de l'email
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            $this->error('Email invalide !');
            return Command::FAILURE;
        }

        // Rechercher l'administrateur
        $admin = AdminUser::where('email', $email)->first();

        if (!$admin) {
            $this->error("Aucun administrateur trouvé avec l'email : {$email}");
            
            // Proposer de créer un nouvel administrateur
            if ($this->confirm('Voulez-vous créer un nouvel administrateur ?')) {
                return $this->createAdmin($email, $password);
            }
            
            return Command::FAILURE;
        }

        // Si aucun mot de passe n'est fourni, demander de le saisir
        if (!$password) {
            $password = $this->secret('Nouveau mot de passe (laissez vide pour générer automatiquement)');
        }

        // Générer un mot de passe automatiquement si vide
        if (empty($password)) {
            $password = $this->generatePassword();
            $this->info("Mot de passe généré automatiquement : {$password}");
        }

        // Validation du mot de passe
        if (strlen($password) < 8) {
            $this->error('Le mot de passe doit contenir au moins 8 caractères !');
            return Command::FAILURE;
        }

        // Mettre à jour le mot de passe
        $admin->password = Hash::make($password);
        $admin->save();

        $this->info("✅ Mot de passe réinitialisé avec succès pour {$admin->name} ({$admin->email})");
        
        if (!$this->option('password') && !$this->hasArgument('password')) {
            $this->warn("🔑 Nouveau mot de passe : {$password}");
            $this->warn("⚠️  Assurez-vous de noter ce mot de passe en lieu sûr !");
        }

        return Command::SUCCESS;
    }

    /**
     * Créer un nouvel administrateur
     */
    private function createAdmin(string $email, ?string $password = null): int
    {
        $name = $this->ask('Nom complet de l\'administrateur');
        
        if (!$password) {
            $password = $this->secret('Mot de passe (laissez vide pour générer automatiquement)');
        }

        if (empty($password)) {
            $password = $this->generatePassword();
            $this->info("Mot de passe généré automatiquement : {$password}");
        }

        if (strlen($password) < 8) {
            $this->error('Le mot de passe doit contenir au moins 8 caractères !');
            return Command::FAILURE;
        }

        $admin = AdminUser::create([
            'name' => $name,
            'email' => $email,
            'password' => Hash::make($password),
            'email_verified_at' => now(),
        ]);

        $this->info("✅ Administrateur créé avec succès :");
        $this->info("   Nom : {$admin->name}");
        $this->info("   Email : {$admin->email}");
        $this->warn("🔑 Mot de passe : {$password}");
        $this->warn("⚠️  Assurez-vous de noter ces informations en lieu sûr !");

        return Command::SUCCESS;
    }

    /**
     * Générer un mot de passe sécurisé
     */
    private function generatePassword(int $length = 12): string
    {
        $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
        $password = '';
        
        for ($i = 0; $i < $length; $i++) {
            $password .= $chars[random_int(0, strlen($chars) - 1)];
        }
        
        return $password;
    }
}
