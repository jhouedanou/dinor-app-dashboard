#!/bin/bash

echo "🚀 Script de configuration manuelle Dinor Dashboard"
echo "=================================================="

# Fonction pour vérifier si un conteneur existe
check_container() {
    if docker ps -a --format 'table {{.Names}}' | grep -q "$1"; then
        echo "✅ Conteneur $1 trouvé"
        return 0
    else
        echo "❌ Conteneur $1 non trouvé"
        return 1
    fi
}

# Fonction pour exécuter une commande dans le conteneur
exec_in_container() {
    local container=$1
    local command=$2
    echo "🔧 Exécution dans $container: $command"
    docker exec -it "$container" bash -c "$command"
}

echo ""
echo "1️⃣ Vérification de Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi

echo "✅ Docker est installé"

echo ""
echo "2️⃣ Arrêt des conteneurs existants..."
docker compose down

echo ""
echo "3️⃣ Construction des conteneurs..."
docker compose build --no-cache

echo ""
echo "4️⃣ Démarrage des conteneurs..."
docker compose up -d

echo ""
echo "5️⃣ Attente du démarrage des services..."
sleep 30

echo ""
echo "6️⃣ Vérification du statut des conteneurs..."
docker compose ps

echo ""
echo "7️⃣ Vérification des logs..."
docker compose logs --tail=10

# Si le conteneur app existe, continuer avec la configuration Laravel
if check_container "dinor-app"; then
    echo ""
    echo "8️⃣ Configuration Laravel..."
    
    echo "📦 Installation des dépendances Composer..."
    exec_in_container "dinor-app" "composer install --optimize-autoloader"
    
    echo "🔑 Génération de la clé d'application..."
    exec_in_container "dinor-app" "php artisan key:generate"
    
    echo "📧 Création de la table notifications..."
    exec_in_container "dinor-app" "php artisan notifications:table"
    
    echo "🗄️ Exécution des migrations..."
    exec_in_container "dinor-app" "php artisan migrate --force"
    
    echo "🧹 Nettoyage des caches..."
    exec_in_container "dinor-app" "php artisan optimize:clear"
    
    echo "🔗 Création du lien symbolique storage..."
    exec_in_container "dinor-app" "php artisan storage:link"
    
    echo "🎨 Génération des assets Filament..."
    exec_in_container "dinor-app" "php artisan filament:assets"
    
    echo "🔧 Application des corrections CSS..."
    exec_in_container "dinor-app" "php artisan cache:clear"
    exec_in_container "dinor-app" "php artisan config:clear"
    exec_in_container "dinor-app" "php artisan view:clear"
    
    echo "📦 Installation de Node.js..."
    exec_in_container "dinor-app" "curl -fsSL https://deb.nodesource.com/setup_18.x | bash -"
    exec_in_container "dinor-app" "apt-get install -y nodejs"
    
    echo "🔧 Installation des dépendances NPM..."
    exec_in_container "dinor-app" "npm install"
    
    echo "🏗️ Construction des assets frontend..."
    exec_in_container "dinor-app" "npm run build"
    
    echo "📁 Vérification des assets générés..."
    exec_in_container "dinor-app" "ls -la public/build/assets/"
    
    echo "🌱 Optionnel: Peuplement de la base de données..."
    read -p "Voulez-vous ajouter des données de test ? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        exec_in_container "dinor-app" "php artisan db:seed"
        exec_in_container "dinor-app" "php artisan db:seed --class=LikesAndCommentsSeeder"
    fi
    
    echo ""
    echo "✅ Configuration terminée !"
    echo ""
    echo "🌐 Accès aux services :"
    echo "   - Dashboard Admin: http://localhost:8000/admin"
    echo "   - API: http://localhost:8000/api/v1/"
    echo "   - PhpMyAdmin: http://localhost:8080"
    echo ""
    echo "🔐 Identifiants admin par défaut :"
    echo "   - Email: admin@dinor.app"
    echo "   - Mot de passe: Dinor2024!Admin"
    echo ""
    echo "💡 Commandes utiles :"
    echo "   - Réinitialiser mot de passe: docker exec -it dinor-app php artisan admin:reset-password [email]"
    echo "   - Créer un admin: docker exec -it dinor-app php artisan admin:reset-password [nouvel-email]"
    
else
    echo ""
    echo "❌ Le conteneur de l'application n'a pas pu être créé."
    echo "📋 Vérifiez les logs pour plus d'informations :"
    echo "   docker compose logs app"
fi

echo ""
echo "�� Script terminé." 