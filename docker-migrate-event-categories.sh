#!/bin/bash

# Script de migration des catégories d'événements pour Docker
echo "🚀 === MIGRATION EVENT CATEGORIES DOCKER ==="
echo ""

# Fonction pour les logs
log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✅ $1"
}

log_warning() {
    echo "⚠️  $1"
}

log_error() {
    echo "❌ $1"
}

# Vérifier si Docker est en cours d'exécution
log_info "🐳 Vérification de Docker..."
if ! docker ps > /dev/null 2>&1; then
    log_error "Docker n'est pas en cours d'exécution. Démarrez Docker Desktop d'abord."
    exit 1
fi

# Démarrer les conteneurs si nécessaire
log_info "🚀 Démarrage des conteneurs Docker..."
docker compose up -d
if [ $? -ne 0 ]; then
    log_error "Impossible de démarrer les conteneurs Docker"
    exit 1
fi

# Attendre que la base de données soit prête
log_info "⏳ Attente de la base de données PostgreSQL..."
sleep 10

# Vérifier que les conteneurs sont en cours d'exécution
log_info "🔍 Vérification des conteneurs..."
if ! docker ps | grep -q "dinor-app"; then
    log_error "Le conteneur dinor-app n'est pas en cours d'exécution"
    exit 1
fi

if ! docker ps | grep -q "dinor-postgres"; then
    log_error "Le conteneur dinor-postgres n'est pas en cours d'exécution"
    exit 1
fi

log_success "Conteneurs Docker opérationnels"

# Exécuter toutes les migrations
log_info "🗄️ Exécution de toutes les migrations..."
docker exec -it dinor-app php artisan migrate --force
if [ $? -eq 0 ]; then
    log_success "Migrations générales exécutées"
else
    log_warning "Problème avec les migrations générales"
fi

# Migration spécifique de la table event_categories
log_info "🗄️ Migration spécifique : event_categories..."
docker exec -it dinor-app php artisan migrate --path=database/migrations/2025_01_01_000000_create_event_categories_table.php --force
if [ $? -eq 0 ]; then
    log_success "Table event_categories créée"
else
    log_error "Erreur lors de la création de event_categories"
fi

# Migration de l'ajout de event_category_id aux events
log_info "🗄️ Migration spécifique : ajout event_category_id aux events..."
docker exec -it dinor-app php artisan migrate --path=database/migrations/2025_01_01_000001_add_event_category_id_to_events_table.php --force
if [ $? -eq 0 ]; then
    log_success "Colonne event_category_id ajoutée aux events"
else
    log_error "Erreur lors de l'ajout de event_category_id"
fi

# Exécuter le seeder des catégories d'événements
log_info "🌱 Seeder des catégories d'événements..."
docker exec -it dinor-app php artisan db:seed --class=EventCategorySeeder --force
if [ $? -eq 0 ]; then
    log_success "Catégories d'événements créées"
else
    log_warning "Problème avec le seeder EventCategorySeeder (peut être déjà exécuté)"
fi

# Vérifier que les tables existent
log_info "🔍 Vérification des tables créées..."
docker exec -it dinor-postgres psql -U postgres -d postgres -c "\dt event_categories"
if [ $? -eq 0 ]; then
    log_success "Table event_categories confirmée dans la base de données"
else
    log_error "Table event_categories introuvable"
fi

# Afficher le contenu des catégories
log_info "📋 Vérification du contenu des catégories..."
docker exec -it dinor-postgres psql -U postgres -d postgres -c "SELECT id, name, slug FROM event_categories LIMIT 5;"

# Nettoyer les caches Laravel
log_info "🧹 Nettoyage des caches..."
docker exec -it dinor-app php artisan cache:clear
docker exec -it dinor-app php artisan config:clear
docker exec -it dinor-app php artisan view:clear

# Vérifier l'état des migrations
log_info "📊 État final des migrations..."
docker exec -it dinor-app php artisan migrate:status | grep event_categories

echo ""
log_success "=== MIGRATION TERMINÉE ==="
echo ""
echo "📋 Prochaines étapes :"
echo "1. Accédez à http://localhost:8000/admin"
echo "2. Connectez-vous avec admin@dinor.app / Dinor2024!Admin"
echo "3. Allez dans Configuration > Catégories d'événements"
echo "4. Créez ou modifiez les catégories selon vos besoins"
echo ""
echo "🔗 API disponible :"
echo "- GET http://localhost:8000/api/event-categories"
echo "- GET http://localhost:8000/api/events?event_category_id=X"
echo "" 