<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Tournament;
use App\Models\TournamentParticipant;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SiaProsperSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->command->info('👤 Création de l\'utilisateur Sia Popo Prosper...');
        
        // Créer ou mettre à jour l'utilisateur Sia Popo Prosper
        $user = User::updateOrCreate(
            ['email' => 'admin@dinor.app'],
            [
                'name' => 'Sia Popo Prosper',
                'password' => Hash::make(env('ADMIN_DEFAULT_PASSWORD', 'changeme-' . Str::random(16))),
                'email_verified_at' => now(),
                'role' => 'moderator',
                'is_active' => true,
            ]
        );

        $this->command->info("✅ Utilisateur créé/mis à jour: {$user->name} ({$user->email})");

        // Inscrire l'utilisateur aux tournois disponibles
        $tournaments = Tournament::where('is_public', true)
            ->whereIn('status', ['registration_open', 'active'])
            ->get();

        if ($tournaments->isEmpty()) {
            $this->command->warn('⚠️ Aucun tournoi disponible pour inscription');
            return;
        }

        $inscriptions = 0;
        foreach ($tournaments as $tournament) {
            // Vérifier si l'utilisateur peut s'inscrire
            if ($tournament->canUserRegister($user)) {
                $participant = $tournament->registerUser($user);
                if ($participant) {
                    $inscriptions++;
                    $this->command->info("✅ Inscrit au tournoi: {$tournament->name}");
                }
            } else {
                // Vérifier s'il est déjà inscrit
                $alreadyRegistered = TournamentParticipant::where('tournament_id', $tournament->id)
                    ->where('user_id', $user->id)
                    ->exists();
                
                if ($alreadyRegistered) {
                    $this->command->info("ℹ️ Déjà inscrit au tournoi: {$tournament->name}");
                } else {
                    $this->command->warn("⚠️ Impossible de s'inscrire au tournoi: {$tournament->name} (raison: " . $this->getRegistrationIssue($tournament) . ")");
                }
            }
        }

        if ($inscriptions > 0) {
            $this->command->info("🎉 {$inscriptions} inscription(s) réussie(s) au total");
            
            // Mettre à jour les leaderboards pour les tournois où l'utilisateur s'est inscrit
            foreach ($tournaments as $tournament) {
                if (TournamentParticipant::where('tournament_id', $tournament->id)
                    ->where('user_id', $user->id)
                    ->exists()) {
                    $tournament->updateLeaderboard($user);
                }
            }
            
            $this->command->info("📊 Leaderboards mis à jour");
        }

        // Afficher un résumé
        $this->displayUserSummary($user);
    }

    private function getRegistrationIssue(Tournament $tournament): string
    {
        $now = now();
        
        if ($tournament->status !== 'registration_open') {
            return "inscriptions fermées (statut: {$tournament->status})";
        }
        
        if ($tournament->registration_start && $now < $tournament->registration_start) {
            return 'inscriptions pas encore ouvertes';
        }
        
        if ($tournament->registration_end && $now > $tournament->registration_end) {
            return 'inscriptions fermées (date limite dépassée)';
        }
        
        if ($tournament->max_participants && $tournament->participants_count >= $tournament->max_participants) {
            return 'nombre maximum de participants atteint';
        }
        
        return 'raison inconnue';
    }

    private function displayUserSummary(User $user): void
    {
        $this->command->info('');
        $this->command->info('=== RÉSUMÉ UTILISATEUR ===');
        $this->command->info("👤 Nom: {$user->name}");
        $this->command->info("📧 Email: {$user->email}");
        $this->command->info("🎭 Rôle: {$user->role}");
        
        $tournamentsCount = TournamentParticipant::where('user_id', $user->id)->count();
        $this->command->info("🏆 Tournois actifs: {$tournamentsCount}");
        
        if ($tournamentsCount > 0) {
            $tournaments = Tournament::whereHas('participants', function ($query) use ($user) {
                $query->where('user_id', $user->id);
            })->get(['name']);
            
            $this->command->info('📋 Tournois inscrits:');
            foreach ($tournaments as $tournament) {
                $this->command->info("   - {$tournament->name}");
            }
        }
        
        $this->command->info('');
        $this->command->info('🔗 Connexion:');
        $this->command->info("   Email: {$user->email}");
        $this->command->info('   Mot de passe: [configuré dans .env ADMIN_DEFAULT_PASSWORD]');
        $this->command->info('');
    }
} 