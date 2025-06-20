#!/bin/bash

echo "🌐 VÉRIFICATION CONFIGURATION NGINX - FORGE"
echo "============================================"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_error() { echo -e "${RED}❌ $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_info() { echo "ℹ️  $1"; }

# Chemins Forge typiques
NGINX_SITES="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"
SITE_NAME="new.dinorapp.com"
SITE_CONFIG="$NGINX_SITES/$SITE_NAME"

echo ""
echo "1️⃣ VÉRIFICATION DE LA CONFIGURATION NGINX"
echo "========================================="

# Vérifier que le fichier de configuration existe
if [ -f "$SITE_CONFIG" ]; then
    log_success "Configuration Nginx trouvée: $SITE_CONFIG"
else
    log_error "Configuration Nginx non trouvée!"
    echo "Cherchons dans les autres emplacements..."
    find /etc/nginx -name "*dinor*" -o -name "*new.dinorapp*" 2>/dev/null
fi

echo ""
echo "2️⃣ VÉRIFICATION DU DOCUMENT ROOT"
echo "==============================="

if [ -f "$SITE_CONFIG" ]; then
    CURRENT_ROOT=$(grep -E "^\s*root\s+" "$SITE_CONFIG" | head -1 | awk '{print $2}' | sed 's/;//')
    log_info "Document root actuel: $CURRENT_ROOT"
    
    EXPECTED_ROOT="/home/forge/new.dinorapp.com/public"
    if [ "$CURRENT_ROOT" = "$EXPECTED_ROOT" ]; then
        log_success "Document root correct"
    else
        log_error "Document root incorrect!"
        log_info "Attendu: $EXPECTED_ROOT"
        log_info "Actuel: $CURRENT_ROOT"
    fi
else
    log_warning "Impossible de vérifier le document root"
fi

echo ""
echo "3️⃣ VÉRIFICATION DES RÈGLES DE RÉÉCRITURE"
echo "========================================"

if [ -f "$SITE_CONFIG" ]; then
    if grep -q "try_files.*index\.php" "$SITE_CONFIG"; then
        log_success "Règles try_files configurées"
    else
        log_error "Règles try_files manquantes ou incorrectes"
    fi
    
    if grep -q "location.*\.php" "$SITE_CONFIG"; then
        log_success "Configuration PHP trouvée"
    else
        log_error "Configuration PHP manquante"
    fi
fi

echo ""
echo "4️⃣ VÉRIFICATION DE LA SYNTAXE NGINX"
echo "==================================="

# Test de la syntaxe Nginx
if nginx -t > /dev/null 2>&1; then
    log_success "Syntaxe Nginx valide"
else
    log_error "Erreur de syntaxe Nginx!"
    log_info "Détails de l'erreur:"
    nginx -t
fi

echo ""
echo "5️⃣ CONFIGURATION NGINX RECOMMANDÉE"
echo "=================================="

cat << 'EOF'
# Configuration Nginx recommandée pour Laravel sur Forge:

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name new.dinorapp.com;
    root /home/forge/new.dinorapp.com/public;

    # SSL Configuration (géré par Forge)
    ssl_certificate /etc/nginx/ssl/new.dinorapp.com/server.crt;
    ssl_certificate_key /etc/nginx/ssl/new.dinorapp.com/server.key;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    # CRITIQUE: Ces règles de réécriture
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    # CRITIQUE: Configuration PHP-FPM
    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}

# Redirection HTTP vers HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name new.dinorapp.com;
    return 301 https://$server_name$request_uri;
}
EOF

echo ""
echo "6️⃣ TESTS DE CONNECTIVITÉ"
echo "========================"

# Test des ports
log_info "Test du port 80:"
if ss -tlnp | grep -q ":80 "; then
    log_success "Port 80 ouvert"
else
    log_error "Port 80 fermé ou non utilisé"
fi

log_info "Test du port 443:"
if ss -tlnp | grep -q ":443 "; then
    log_success "Port 443 ouvert"
else
    log_error "Port 443 fermé ou non utilisé"
fi

echo ""
echo "7️⃣ LOGS NGINX"
echo "============="

log_info "Dernières erreurs Nginx:"
if [ -f "/var/log/nginx/error.log" ]; then
    tail -5 /var/log/nginx/error.log | grep -E "(error|crit)" || log_success "Aucune erreur récente"
else
    log_warning "Log d'erreur Nginx non trouvé"
fi

echo ""
echo "8️⃣ ACTIONS RECOMMANDÉES"
echo "======================="

echo ""
log_info "Si le document root est incorrect:"
echo "1. Allez dans Forge → Sites → new.dinorapp.com → Meta"
echo "2. Changez 'Document Root' pour '/public'"
echo "3. Sauvegardez"

echo ""
log_info "Si la configuration Nginx a des erreurs:"
echo "1. Allez dans Forge → Sites → new.dinorapp.com → Nginx Configuration"
echo "2. Copiez la configuration recommandée ci-dessus"
echo "3. Adaptez les chemins SSL si nécessaire"

echo ""
log_info "Test rapide - Essayez ces URLs:"
echo "- https://new.dinorapp.com/index.php (doit rediriger vers /admin)"
echo "- https://new.dinorapp.com/admin (doit afficher la page de connexion)"

echo ""
log_success "Vérification terminée!" 