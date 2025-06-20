<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\AdminUser;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class ProductionAdminSeeder extends Seeder
{
    /**
     * Seeder spécialisé pour créer l'admin en production
     * Utilise toujours les mêmes identifiants que localement
     */
    public function run(): void
    {
        // Identifiants fixes pour assurer la cohérence entre local et production
        $adminData = [
            'email' => 'admin@dinor.app',
            'password' => 'Dinor2024!Admin',
            'name' => 'Administrateur Dinor'
        ];

        $this->command->info("🚀 === PRODUCTION ADMIN SEEDER ===");
        $this->command->info("📧 Email: {$adminData['email']}");
        $this->command->info("👤 Nom: {$adminData['name']}");
        $this->command->info("🔑 Mot de passe: {$adminData['password']}");

        try {
            DB::beginTransaction();

            // Supprimer tous les anciens admins pour éviter les conflits
            $oldAdminsCount = AdminUser::count();
            if ($oldAdminsCount > 0) {
                $this->command->warn("🗑️ Suppression de {$oldAdminsCount} ancien(s) admin(s)...");
                AdminUser::truncate();
            }

            // Créer le nouvel admin avec des données fixes
            $admin = AdminUser::create([
                'name' => $adminData['name'],
                'email' => $adminData['email'],
                'password' => Hash::make($adminData['password']),
                'email_verified_at' => now(),
                'is_active' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            DB::commit();

            // Vérifications finales
            $this->command->info("✅ Admin créé avec succès (ID: {$admin->id})");
            
            // Test de mot de passe
            if (Hash::check($adminData['password'], $admin->password)) {
                $this->command->info("🔑 Test mot de passe: ✅ RÉUSSI");
            } else {
                $this->command->error("🔑 Test mot de passe: ❌ ÉCHEC");
                throw new \Exception("Erreur de vérification du mot de passe");
            }

            // Vérification activité
            if ($admin->is_active) {
                $this->command->info("👤 Statut admin: ✅ ACTIF");
            } else {
                $this->command->error("👤 Statut admin: ❌ INACTIF");
                throw new \Exception("Admin créé mais inactif");
            }

            $this->command->info("");
            $this->command->info("🎉 === ADMIN PRODUCTION CONFIGURÉ ===");
            $this->command->info("🌐 URL: " . config('app.url') . "/admin/login");
            $this->command->info("📧 Email: {$adminData['email']}");
            $this->command->info("🔑 Mot de passe: {$adminData['password']}");
            $this->command->info("");
            $this->command->warn("⚠️  IDENTIFIANTS IDENTIQUES AU LOCAL");

        } catch (\Exception $e) {
            DB::rollBack();
            $this->command->error("❌ Erreur: " . $e->getMessage());
            throw $e;
        }
    }
} 