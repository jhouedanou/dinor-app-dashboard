<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\AdminUser;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AdminUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Utilisation sécurisée des variables d'environnement
        $adminEmail = env('ADMIN_DEFAULT_EMAIL', 'admin@dinor.app');
        $adminName = env('ADMIN_DEFAULT_NAME', 'AdministrateurDinor');
        
        // Générer un mot de passe sécurisé aléatoire si non défini
        $adminPassword = env('ADMIN_DEFAULT_PASSWORD');
        if (!$adminPassword) {
            $adminPassword = bin2hex(random_bytes(12));
            $this->command->warn("⚠️ Aucun mot de passe admin défini dans .env. Mot de passe généré automatiquement.");
        }

        $this->command->info("🚀 === CRÉATION/MISE À JOUR ADMIN DINOR DASHBOARD ===");
        $this->command->info("📧 Email admin: {$adminEmail}");
        $this->command->info("👤 Nom admin: {$adminName}");

        try {
            DB::beginTransaction();

            $existingAdmin = AdminUser::where('email', $adminEmail)->first();

            if ($existingAdmin) {
                $this->command->info("👤 Utilisateur admin existant trouvé (ID: {$existingAdmin->id})");
                
                // Mettre à jour seulement le nom et l'état actif (pas le mot de passe)
                $existingAdmin->update([
                    'name' => $adminName,
                    'email_verified_at' => now(),
                    'is_active' => true,
                    'updated_at' => now(),
                ]);
                
                $this->command->info("✅ Utilisateur admin mis à jour avec succès!");
                
            } else {
                $newAdmin = AdminUser::create([
                    'name' => $adminName,
                    'email' => $adminEmail,
                    'password' => Hash::make($adminPassword),
                    'email_verified_at' => now(),
                    'is_active' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
                
                $this->command->info("✅ Nouvel utilisateur admin créé avec succès (ID: {$newAdmin->id})!");
            }

            DB::commit();

            $finalCheck = AdminUser::where('email', $adminEmail)->first();
            if ($finalCheck && $finalCheck->is_active) {
                $this->command->info("🔍 Vérification finale: ✅ Admin actif et opérationnel");
            } else {
                $this->command->error("❌ Problème lors de la vérification finale");
            }

        } catch (\Exception $e) {
            DB::rollBack();
            $this->command->error("❌ Erreur lors de la création/mise à jour de l'admin: " . $e->getMessage());
            throw $e;
        }

        $totalAdmins = AdminUser::count();
        $activeAdmins = AdminUser::where('is_active', true)->count();
        
        $this->command->info("");
        $this->command->info("📊 === STATISTIQUES ADMIN ===");
        $this->command->info("👥 Total administrateurs: {$totalAdmins}");
        $this->command->info("✅ Administrateurs actifs: {$activeAdmins}");
        $this->command->info("");
        $this->command->info("🌐 === INFORMATIONS DE CONNEXION ===");
        $this->command->info("🔗 URL Dashboard: " . config('app.url') . "/admin/login");
        $this->command->info("📧 Email: {$adminEmail}");
        
        // Afficher le mot de passe seulement pour les nouveaux comptes
        if (!$existingAdmin) {
            $this->command->info("🔑 Mot de passe initial: {$adminPassword}");
            $this->command->warn("⚠️ IMPORTANT: Changez ce mot de passe lors de votre première connexion!");
        } else {
            $this->command->info("🔑 Mot de passe: [Inchangé - utilisez votre mot de passe actuel]");
        }
        
        $this->command->info("");
    }
} 