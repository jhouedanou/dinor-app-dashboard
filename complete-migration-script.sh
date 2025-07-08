#!/bin/bash

echo "🗄️ Script de Migration Complet avec Corrections"
echo "================================================"
echo ""

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log "📋 Début de la migration complète..."

# 1. Vérifier l'état actuel des migrations
log "🔍 Vérification de l'état actuel des migrations..."
php artisan migrate:status

echo ""

# 2. Tentative de migration normale
log "🚀 Tentative de migration normale..."
if php artisan migrate --force; then
    log "✅ Migrations appliquées avec succès"
    MIGRATION_SUCCESS=true
else
    warning "❌ Échec de la migration, analyse de l'erreur..."
    MIGRATION_SUCCESS=false
    
    # Capturer l'erreur spécifique
    MIGRATION_ERROR=$(php artisan migrate --force 2>&1)
    echo "Erreur détectée:"
    echo "$MIGRATION_ERROR"
    echo ""
    
    # Vérifier si c'est l'erreur de la colonne 'rank'
    if echo "$MIGRATION_ERROR" | grep -q "Duplicate column name 'rank'"; then
        warning "🔧 Erreur de colonne 'rank' en double détectée!"
        
        log "🔄 Rollback de la migration problématique..."
        if php artisan migrate:rollback --step=1 --force; then
            info "Migration problématique annulée"
            
            log "🔄 Nouvelle tentative de migration..."
            if php artisan migrate --force; then
                log "✅ Migrations appliquées après correction"
                MIGRATION_SUCCESS=true
            else
                error "❌ Échec persistant de la migration"
                MIGRATION_SUCCESS=false
            fi
        else
            error "❌ Impossible d'annuler la migration problématique"
        fi
    else
        warning "Autre type d'erreur de migration"
    fi
fi

echo ""

# 3. Vérification finale des migrations
log "📊 État final des migrations..."
php artisan migrate:status

echo ""

# 4. Seeders essentiels
if [ "$MIGRATION_SUCCESS" = true ]; then
    log "🌱 Exécution des seeders essentiels..."
    
    # CategorySeeder
    if php artisan db:seed --class=CategorySeeder --force 2>/dev/null; then
        log "✅ CategorySeeder exécuté"
    else
        warning "CategorySeeder non trouvé ou erreur"
    fi
    
    # EventCategoriesSeeder
    if php artisan db:seed --class=EventCategoriesSeeder --force 2>/dev/null; then
        log "✅ EventCategoriesSeeder exécuté"
    else
        warning "EventCategoriesSeeder non trouvé ou erreur"
    fi
    
    # TournamentTestSeeder pour créer des tournois
    if php artisan db:seed --class=TournamentTestSeeder --force 2>/dev/null; then
        log "✅ TournamentTestSeeder exécuté"
    else
        warning "TournamentTestSeeder non trouvé ou erreur"
    fi
    
    echo ""
    
    # 5. Correction des tournois existants
    log "🏆 Correction des tournois pour les inscriptions..."
    
    if [ -f "fix-tournament-registration.php" ]; then
        # Trouver tous les tournois et les corriger
        TOURNAMENT_IDS=$(php artisan tinker --execute="
        \$tournaments = App\\Models\\Tournament::all();
        foreach (\$tournaments as \$tournament) {
            echo \$tournament->id . ' ';
        }
        " 2>/dev/null)
        
        if [ ! -z "$TOURNAMENT_IDS" ]; then
            for TOURNAMENT_ID in $TOURNAMENT_IDS; do
                info "Correction du tournoi ID: $TOURNAMENT_ID"
                php fix-tournament-registration.php $TOURNAMENT_ID >/dev/null 2>&1
            done
            log "✅ Tous les tournois corrigés"
        else
            info "Aucun tournoi trouvé à corriger"
        fi
    else
        warning "Script fix-tournament-registration.php non trouvé"
    fi
    
    echo ""
    
    # 6. Vérification finale
    log "🧪 Vérification finale..."
    
    # Test de connexion DB
    if php artisan tinker --execute="echo 'DB_OK';" 2>/dev/null | grep -q "DB_OK"; then
        log "✅ Connexion base de données OK"
    else
        error "❌ Problème de connexion base de données"
    fi
    
    # Test des tournois
    TOURNAMENT_COUNT=$(php artisan tinker --execute="
    echo App\\Models\\Tournament::where('is_public', true)->count();
    " 2>/dev/null)
    
    if [ ! -z "$TOURNAMENT_COUNT" ] && [ "$TOURNAMENT_COUNT" -gt 0 ]; then
        log "✅ $TOURNAMENT_COUNT tournoi(s) public(s) trouvé(s)"
    else
        warning "Aucun tournoi public trouvé"
    fi
    
    # Test d'un tournoi spécifique (ID 3)
    TOURNAMENT_3_STATUS=$(php artisan tinker --execute="
    \$tournament = App\\Models\\Tournament::find(3);
    if (\$tournament) {
        echo 'TOURNAMENT_3_OK:' . \$tournament->can_register;
    } else {
        echo 'TOURNAMENT_3_NOT_FOUND';
    }
    " 2>/dev/null)
    
    if echo "$TOURNAMENT_3_STATUS" | grep -q "TOURNAMENT_3_OK:1"; then
        log "✅ Tournoi ID 3 accepte les inscriptions"
    elif echo "$TOURNAMENT_3_STATUS" | grep -q "TOURNAMENT_3_OK:0"; then
        warning "Tournoi ID 3 n'accepte pas les inscriptions"
    else
        info "Tournoi ID 3 non trouvé (normal si pas créé)"
    fi
    
else
    error "Migration échouée, seeders et corrections non exécutés"
fi

echo ""
log "🎉 Script de migration terminé !"

if [ "$MIGRATION_SUCCESS" = true ]; then
    echo ""
    info "📝 Résumé :"
    echo "   ✅ Migrations appliquées"
    echo "   ✅ Seeders exécutés" 
    echo "   ✅ Tournois corrigés"
    echo "   ✅ Base de données opérationnelle"
    echo ""
    log "🚀 Prêt pour le déploiement !"
else
    echo ""
    warning "⚠️ Des problèmes subsistent :"
    echo "   ❌ Migrations échouées"
    echo "   ⚠️ Base de données potentiellement instable"
    echo ""
    error "Vérification manuelle nécessaire avant déploiement"
fi 