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
        // Forcer l'utilisation des valeurs par défaut pour la production
        $adminEmail = env('ADMIN_DEFAULT_EMAIL', 'admin@dinor.app');
        $adminPassword = env('ADMIN_DEFAULT_PASSWORD', 'Dinor2024!Admin');
        $adminName = env('ADMIN_DEFAULT_NAME', 'Administrateur Dinor');

        $this->command->info("🚀 === CRÉATION/MISE À JOUR ADMIN DINOR DASHBOARD ===");
        $this->command->info("📧 Email admin: {$adminEmail}");
        $this->command->info("👤 Nom admin: {$adminName}");

        try {
            // Démarrer une transaction pour assurer la cohérence
            DB::beginTransaction();

            // Vérifier si l'admin existe déjà
            $existingAdmin = AdminUser::where('email', $adminEmail)->first();

            if ($existingAdmin) {
                $this->command->info("👤 Utilisateur admin existant trouvé (ID: {$existingAdmin->id})");
                
                // Toujours mettre à jour le mot de passe et les informations
                $existingAdmin->update([
                    'name' => $adminName,
                    'password' => Hash::make($adminPassword),
                    'email_verified_at' => now(),
                    'is_active' => true,
                    'updated_at' => now(),
                ]);
                
                $this->command->info("✅ Utilisateur admin mis à jour avec succès!");
                
            } else {
                // Créer un nouvel administrateur
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

            // Valider la transaction
            DB::commit();

            // Vérification finale
            $finalCheck = AdminUser::where('email', $adminEmail)->first();
            if ($finalCheck && $finalCheck->is_active) {
                $this->command->info("🔍 Vérification finale: ✅ Admin actif et opérationnel");
                
                // Test du mot de passe
                if (Hash::check($adminPassword, $finalCheck->password)) {
                    $this->command->info("🔑 Test mot de passe: ✅ OK");
                } else {
                    $this->command->error("🔑 Test mot de passe: ❌ ÉCHEC");
                }
            } else {
                $this->command->error("❌ Problème lors de la vérification finale");
            }

        } catch (\Exception $e) {
            // Annuler la transaction en cas d'erreur
            DB::rollBack();
            $this->command->error("❌ Erreur lors de la création/mise à jour de l'admin: " . $e->getMessage());
            throw $e;
        }

        // Statistiques finales
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
        $this->command->info("🔑 Mot de passe: {$adminPassword}");
        $this->command->info("");
        $this->command->warn("⚠️  IMPORTANT: Notez ces informations en lieu sûr!");
        $this->command->info("");
    }
} 