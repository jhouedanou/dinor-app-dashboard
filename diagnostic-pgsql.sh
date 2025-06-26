#!/bin/bash

echo "=== DIAGNOSTIC POSTGRESQL ET PHP ===\n"

echo "1. EXTENSIONS PHP INSTALLÉES:"
echo "-----------------------------"
php -m | grep -i pdo
php -m | grep -i pgsql
echo ""

echo "2. CONFIGURATION PHP PDO:"
echo "-------------------------"
php -i | grep -i pdo
echo ""

echo "3. TEST DE CONNEXION POSTGRESQL:"
echo "--------------------------------"
# Test de connexion basique
php -r "
try {
    \$pdo = new PDO('pgsql:host=dinor-postgres;port=5432;dbname=postgres', 'postgres', 'postgres');
    echo '✓ Connexion PostgreSQL réussie via PDO\n';
} catch (Exception \$e) {
    echo '✗ Erreur connexion PostgreSQL: ' . \$e->getMessage() . '\n';
}
"

echo ""
echo "4. VÉRIFICATION DE LA CONNECTIVITÉ RÉSEAU:"
echo "------------------------------------------"
# Vérification si le conteneur postgres est accessible
if command -v nc &> /dev/null; then
    if nc -z dinor-postgres 5432; then
        echo "✓ dinor-postgres:5432 est accessible"
    else
        echo "✗ dinor-postgres:5432 n'est pas accessible"
    fi
else
    echo "⚠ netcat non disponible pour tester la connectivité"
fi

echo ""
echo "5. VARIABLES D'ENVIRONNEMENT DB:"
echo "--------------------------------"
echo "DB_CONNECTION=$(grep ^DB_CONNECTION .env 2>/dev/null || echo 'Non défini')"
echo "DB_HOST=$(grep ^DB_HOST .env 2>/dev/null || echo 'Non défini')"
echo "DB_PORT=$(grep ^DB_PORT .env 2>/dev/null || echo 'Non défini')"
echo "DB_DATABASE=$(grep ^DB_DATABASE .env 2>/dev/null || echo 'Non défini')"

echo ""
echo "6. RECOMMANDATIONS DE DÉBOGAGE:"
echo "------------------------------"
echo "Si 'could not find driver' apparaît:"
echo "- Installez l'extension PHP PostgreSQL: apt-get install php-pgsql"
echo "- Redémarrez PHP/Apache/Nginx après l'installation"
echo "- Vérifiez que pdo_pgsql est dans php -m"
echo ""
echo "Si la connexion échoue:"
echo "- Vérifiez que PostgreSQL est démarré"
echo "- Vérifiez les credentials dans .env"
echo "- Testez la connexion réseau vers le serveur DB"
echo ""
echo "=== FIN DU DIAGNOSTIC POSTGRESQL ==="