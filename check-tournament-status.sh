#!/bin/bash

echo "🏆 ===== STATUT DU TOURNOI DINOR 2025 ===== 🏆"
echo ""

echo "📊 STATISTIQUES GÉNÉRALES:"
docker exec dinor-app php artisan tinker --execute="
echo '- Équipes: ' . App\Models\Team::count() . PHP_EOL;
echo '- Matchs total: ' . App\Models\FootballMatch::count() . PHP_EOL;
echo '- Utilisateurs: ' . App\Models\User::count() . PHP_EOL;
echo '- Prédictions: ' . App\Models\Prediction::count() . PHP_EOL;
"

echo ""
echo "⚽ MATCHS PAR STATUT:"
docker exec dinor-app php artisan tinker --execute="
echo '- À venir: ' . App\Models\FootballMatch::where('status', 'scheduled')->count() . PHP_EOL;
echo '- En cours: ' . App\Models\FootballMatch::where('status', 'live')->count() . PHP_EOL;
echo '- Terminés: ' . App\Models\FootballMatch::where('status', 'finished')->count() . PHP_EOL;
"

echo ""
echo "🎯 PRÉDICTIONS:"
docker exec dinor-app php artisan tinker --execute="
echo '- Calculées: ' . App\Models\Prediction::where('is_calculated', true)->count() . PHP_EOL;
echo '- En attente: ' . App\Models\Prediction::where('is_calculated', false)->count() . PHP_EOL;
"

echo ""
echo "🏅 TOURNOI 'COUPE DINOR 2025':"
docker exec dinor-app php artisan tinker --execute="
echo '- Matchs du tournoi: ' . App\Models\FootballMatch::where('competition', 'Coupe Dinor 2025')->count() . PHP_EOL;
echo '- Prédictions tournoi: ' . App\Models\Prediction::whereHas('footballMatch', function(\$q) { \$q->where('competition', 'Coupe Dinor 2025'); })->count() . PHP_EOL;
"

echo ""
echo "📱 API ENDPOINTS DISPONIBLES:"
echo "- GET /api/v1/matches - Liste des matchs"
echo "- GET /api/v1/matches/upcoming/list - Matchs à venir"
echo "- GET /api/v1/predictions - Prédictions (authentifié)"
echo "- POST /api/v1/predictions - Créer une prédiction (authentifié)"

echo ""
echo "✅ Le tournoi de test est prêt pour les pronostics!"
echo "🌐 PWA accessible sur: http://localhost:3002/pwa/"
echo "⚙️  Admin Filament: http://localhost:8000/admin"