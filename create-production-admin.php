<?php

// Script pour créer/réinitialiser l'utilisateur admin en production
// Usage: php create-production-admin.php

echo "=== Création/Réinitialisation Admin Dinor Dashboard ===\n";

// Configuration de base de données (à adapter selon votre environnement)
$host = 'localhost';
$dbname = 'dinor_app'; // Adaptez selon votre configuration
$username = 'root';    // Adaptez selon votre configuration
$password = '';        // Adaptez selon votre configuration

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Connexion à la base de données réussie\n";
} catch (PDOException $e) {
    echo "✗ Erreur de connexion : " . $e->getMessage() . "\n";
    echo "❌ Veuillez vérifier les paramètres de base de données dans le script\n";
    exit(1);
}

// Informations de l'admin
$adminEmail = 'admin@dinor.app';
$adminName = 'Administrateur Dinor';
$adminPassword = 'Dinor2024!Admin';

// Hacher le mot de passe (Laravel utilise bcrypt)
$hashedPassword = password_hash($adminPassword, PASSWORD_DEFAULT);

// Vérifier si l'admin existe déjà
$stmt = $pdo->prepare("SELECT id, name, email FROM admin_users WHERE email = ?");
$stmt->execute([$adminEmail]);
$existingAdmin = $stmt->fetch(PDO::FETCH_ASSOC);

if ($existingAdmin) {
    echo "👤 Utilisateur admin trouvé: {$existingAdmin['name']} ({$existingAdmin['email']})\n";
    echo "🔄 Mise à jour du mot de passe...\n";
    
    // Mettre à jour le mot de passe
    $stmt = $pdo->prepare("UPDATE admin_users SET password = ?, updated_at = NOW() WHERE email = ?");
    $stmt->execute([$hashedPassword, $adminEmail]);
    
    echo "✅ Mot de passe mis à jour avec succès!\n";
} else {
    echo "➕ Création d'un nouvel utilisateur admin...\n";
    
    // Créer un nouveau admin
    $stmt = $pdo->prepare("INSERT INTO admin_users (name, email, password, email_verified_at, is_active, created_at, updated_at) VALUES (?, ?, ?, NOW(), 1, NOW(), NOW())");
    $stmt->execute([$adminName, $adminEmail, $hashedPassword]);
    
    echo "✅ Utilisateur admin créé avec succès!\n";
}

// Vérification finale
$stmt = $pdo->prepare("SELECT id, name, email, is_active FROM admin_users WHERE email = ?");
$stmt->execute([$adminEmail]);
$admin = $stmt->fetch(PDO::FETCH_ASSOC);

echo "\n=== Informations de connexion ===\n";
echo "🌐 URL de connexion: https://new.dinorapp.com/admin/login\n";
echo "📧 Email: $adminEmail\n";
echo "🔑 Mot de passe: $adminPassword\n";
echo "👤 Nom: {$admin['name']}\n";
echo "✅ Actif: " . ($admin['is_active'] ? 'Oui' : 'Non') . "\n";

echo "\n=== Vérifications supplémentaires ===\n";

// Vérifier les autres utilisateurs admin
$stmt = $pdo->query("SELECT COUNT(*) as count FROM admin_users");
$totalAdmins = $stmt->fetch(PDO::FETCH_ASSOC)['count'];
echo "👥 Nombre total d'admins: $totalAdmins\n";

// Vérifier la table des sessions si nécessaire
$stmt = $pdo->query("SHOW TABLES LIKE 'sessions'");
if ($stmt->rowCount() > 0) {
    echo "🗂️ Table des sessions: Présente\n";
} else {
    echo "⚠️ Table des sessions: Absente (peut causer des problèmes de connexion)\n";
}

echo "\n=== Résolution des problèmes potentiels ===\n";

// Nettoyer les anciennes sessions si nécessaire
try {
    $pdo->exec("DELETE FROM sessions WHERE last_activity < " . (time() - 3600));
    echo "🧹 Sessions expirées nettoyées\n";
} catch (Exception $e) {
    echo "⚠️ Impossible de nettoyer les sessions: " . $e->getMessage() . "\n";
}

echo "\n✅ Configuration terminée !\n";
echo "🚀 Vous pouvez maintenant vous connecter au dashboard.\n";

// Conseils supplémentaires
echo "\n=== Conseils si la connexion ne fonctionne toujours pas ===\n";
echo "1. Vérifiez que les variables d'environnement suivantes sont définies:\n";
echo "   - APP_URL=https://new.dinorapp.com\n";
echo "   - SESSION_DOMAIN=.dinorapp.com\n";
echo "   - SESSION_SECURE_COOKIE=true\n";
echo "\n2. Videz le cache Laravel si possible:\n";
echo "   - php artisan config:clear\n";
echo "   - php artisan cache:clear\n";
echo "   - php artisan route:clear\n";
echo "\n3. Vérifiez les logs d'erreur du serveur web\n";
echo "\n4. Assurez-vous que HTTPS est bien configuré\n"; 