#!/bin/bash

# Script de diagnostic de la base de données Docker
echo "🔍 === DIAGNOSTIC BASE DE DONNÉES DOCKER ==="
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

# Vérifier Docker
log_info "🐳 Vérification de Docker..."
if ! docker ps > /dev/null 2>&1; then
    log_error "Docker n'est pas en cours d'exécution"
    exit 1
fi

# Vérifier les conteneurs
log_info "📦 État des conteneurs..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""

# Vérifier la connexion à la base de données
log_info "🗄️ Test de connexion PostgreSQL..."
if docker exec -it dinor-postgres pg_isready -U postgres > /dev/null 2>&1; then
    log_success "PostgreSQL est accessible"
else
    log_error "PostgreSQL n'est pas accessible"
    exit 1
fi

# Lister toutes les tables
log_info "📋 Tables existantes dans la base de données..."
docker exec -it dinor-postgres psql -U postgres -d postgres -c "\dt" 2>/dev/null | grep -E "event_categories|events|categories"

echo ""

# Vérifier spécifiquement la table event_categories
log_info "🔍 Vérification de la table event_categories..."
if docker exec -it dinor-postgres psql -U postgres -d postgres -c "\d event_categories" > /dev/null 2>&1; then
    log_success "Table event_categories existe"
    docker exec -it dinor-postgres psql -U postgres -d postgres -c "\d event_categories"
    echo ""
    log_info "📊 Contenu de event_categories..."
    docker exec -it dinor-postgres psql -U postgres -d postgres -c "SELECT COUNT(*) as total_categories FROM event_categories;"
    docker exec -it dinor-postgres psql -U postgres -d postgres -c "SELECT id, name, slug, is_active FROM event_categories LIMIT 10;"
else
    log_error "Table event_categories n'existe pas"
fi

echo ""

# Vérifier la table events
log_info "🔍 Vérification de la table events..."
if docker exec -it dinor-postgres psql -U postgres -d postgres -c "\d events" > /dev/null 2>&1; then
    log_success "Table events existe"
    # Vérifier si la colonne event_category_id existe
    if docker exec -it dinor-postgres psql -U postgres -d postgres -c "\d events" | grep -q "event_category_id"; then
        log_success "Colonne event_category_id existe dans events"
    else
        log_warning "Colonne event_category_id manquante dans events"
    fi
else
    log_error "Table events n'existe pas"
fi

echo ""

# État des migrations Laravel
log_info "📊 État des migrations Laravel..."
docker exec -it dinor-app php artisan migrate:status 2>/dev/null | grep -E "event_categories|events"

echo ""

# Test de l'API si possible
log_info "🌐 Test de l'API event-categories..."
if curl -s http://localhost:8000/api/event-categories > /dev/null 2>&1; then
    log_success "API event-categories accessible"
    curl -s http://localhost:8000/api/event-categories | head -c 500
    echo "..."
else
    log_warning "API event-categories non accessible (normal si l'app n'est pas encore démarrée)"
fi

echo ""
log_success "=== DIAGNOSTIC TERMINÉ ==="
echo "" 