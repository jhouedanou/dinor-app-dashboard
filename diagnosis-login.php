<?php

// Script de diagnostic pour les problèmes de connexion
// Usage: php diagnosis-login.php

echo "=== Diagnostic des problèmes de connexion Dashboard Dinor ===\n\n";

// Configuration de base de données
$host = 'localhost';
$dbname = 'dinor_app'; // Adaptez selon votre configuration
$username = 'root';    // Adaptez selon votre configuration
$password = '';        // Adaptez selon votre configuration

// Test de connexion à la base de données
echo "1. Test de connexion à la base de données...\n";
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "   ✅ Connexion réussie\n\n";
} catch (PDOException $e) {
    echo "   ❌ Erreur: " . $e->getMessage() . "\n";
    echo "   💡 Vérifiez les paramètres de connexion dans le script\n\n";
    exit(1);
}

// Vérifier l'existence de la table admin_users
echo "2. Vérification de la table 'admin_users'...\n";
try {
    $stmt = $pdo->query("DESCRIBE admin_users");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "   ✅ Table 'admin_users' trouvée\n";
    echo "   📊 Colonnes: " . implode(', ', $columns) . "\n\n";
} catch (PDOException $e) {
    echo "   ❌ Table 'admin_users' non trouvée ou erreur: " . $e->getMessage() . "\n";
    echo "   💡 Exécutez les migrations Laravel\n\n";
    exit(1);
}

// Compter les utilisateurs admin
echo "3. Analyse des utilisateurs administrateurs...\n";
$stmt = $pdo->query("SELECT COUNT(*) as count FROM admin_users");
$totalAdmins = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
echo "   👥 Nombre total d'admins: $totalAdmins\n";

if ($totalAdmins == 0) {
    echo "   ⚠️  Aucun utilisateur admin trouvé!\n";
    echo "   💡 Utilisez le script 'create-production-admin.php' pour en créer un\n\n";
} else {
    // Lister les admins existants
    $stmt = $pdo->query("SELECT id, name, email, is_active, created_at, last_login_at FROM admin_users ORDER BY created_at DESC");
    $admins = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    echo "   📋 Liste des administrateurs:\n";
    foreach ($admins as $admin) {
        echo "      - ID: {$admin['id']}\n";
        echo "        Nom: {$admin['name']}\n";
        echo "        Email: {$admin['email']}\n";
        echo "        Actif: " . ($admin['is_active'] ? 'Oui' : 'Non') . "\n";
        echo "        Créé: {$admin['created_at']}\n";
        echo "        Dernière connexion: " . ($admin['last_login_at'] ?? 'Jamais') . "\n";
        echo "        ---\n";
    }
}

// Vérifier l'utilisateur spécifique
echo "\n4. Vérification de l'utilisateur 'admin@dinor.app'...\n";
$targetEmail = 'admin@dinor.app';
$stmt = $pdo->prepare("SELECT * FROM admin_users WHERE email = ?");
$stmt->execute([$targetEmail]);
$targetAdmin = $stmt->fetch(PDO::FETCH_ASSOC);

if ($targetAdmin) {
    echo "   ✅ Utilisateur trouvé!\n";
    echo "   📧 Email: {$targetAdmin['email']}\n";
    echo "   👤 Nom: {$targetAdmin['name']}\n";
    echo "   🟢 Actif: " . ($targetAdmin['is_active'] ? 'Oui' : 'Non') . "\n";
    echo "   📅 Créé: {$targetAdmin['created_at']}\n";
    echo "   🔐 Hash du mot de passe: " . substr($targetAdmin['password'], 0, 20) . "...\n";
    
    // Test du mot de passe
    $testPassword = 'Dinor2024!Admin';
    if (password_verify($testPassword, $targetAdmin['password'])) {
        echo "   ✅ Le mot de passe '$testPassword' correspond!\n";
    } else {
        echo "   ❌ Le mot de passe '$testPassword' ne correspond PAS!\n";
        echo "   💡 Le mot de passe a peut-être été changé\n";
    }
} else {
    echo "   ❌ Utilisateur '$targetEmail' non trouvé!\n";
    echo "   💡 Utilisez le script 'create-production-admin.php' pour le créer\n";
}

// Vérifier les tables de session
echo "\n5. Vérification des sessions...\n";
try {
    $stmt = $pdo->query("SHOW TABLES LIKE 'sessions'");
    if ($stmt->rowCount() > 0) {
        echo "   ✅ Table 'sessions' trouvée\n";
        
        // Compter les sessions actives
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM sessions WHERE last_activity > " . (time() - 7200));
        $activeSessions = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
        echo "   🔄 Sessions actives (dernières 2h): $activeSessions\n";
        
        // Nettoyer les anciennes sessions
        $stmt = $pdo->exec("DELETE FROM sessions WHERE last_activity < " . (time() - 86400));
        echo "   🧹 Anciennes sessions nettoyées: $stmt\n";
    } else {
        echo "   ⚠️  Table 'sessions' non trouvée\n";
        echo "   💡 Cela peut causer des problèmes de connexion\n";
    }
} catch (Exception $e) {
    echo "   ⚠️  Erreur lors de la vérification des sessions: " . $e->getMessage() . "\n";
}

// Vérifications de configuration
echo "\n6. Recommandations de configuration...\n";
echo "   🌐 Assurez-vous que ces variables d'environnement sont définies:\n";
echo "      APP_URL=https://new.dinorapp.com\n";
echo "      SESSION_DOMAIN=.dinorapp.com\n";
echo "      SESSION_SECURE_COOKIE=true\n";
echo "      SESSION_SAME_SITE=lax\n";
echo "      SANCTUM_STATEFUL_DOMAINS=new.dinorapp.com,dinorapp.com\n";

echo "\n   🔧 Commandes Laravel à exécuter si possible:\n";
echo "      php artisan config:clear\n";
echo "      php artisan cache:clear\n";
echo "      php artisan route:clear\n";
echo "      php artisan view:clear\n";

echo "\n   🔍 Fichiers de logs à vérifier:\n";
echo "      - storage/logs/laravel.log\n";
echo "      - Logs du serveur web (Apache/Nginx)\n";
echo "      - Logs PHP\n";

echo "\n=== Résumé du diagnostic ===\n";
if ($totalAdmins > 0 && $targetAdmin && $targetAdmin['is_active']) {
    if (password_verify('Dinor2024!Admin', $targetAdmin['password'])) {
        echo "✅ Configuration semble correcte pour la connexion\n";
        echo "🚀 Vous devriez pouvoir vous connecter avec:\n";
        echo "   📧 Email: admin@dinor.app\n";
        echo "   🔑 Mot de passe: Dinor2024!Admin\n";
        echo "   🌐 URL: https://new.dinorapp.com/admin/login\n";
    } else {
        echo "⚠️  Utilisateur trouvé mais mot de passe incorrect\n";
        echo "💡 Utilisez le script 'create-production-admin.php' pour réinitialiser\n";
    }
} else {
    echo "❌ Problèmes détectés - utilisateur manquant ou inactif\n";
    echo "💡 Créez l'utilisateur admin avec 'create-production-admin.php'\n";
}

echo "\n🏁 Diagnostic terminé!\n"; 