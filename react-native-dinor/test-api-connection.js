/**
 * Script de test pour vérifier la connexion à l'API Dinor
 * Usage: node test-api-connection.js
 */

const API_BASE_URL = 'https://new.dinorapp.com/api/v1';

async function testApiConnection() {
  console.log('🧪 Test de connexion à l\'API Dinor...\n');

  const endpoints = [
    '/recipes',
    '/tips', 
    '/events',
    '/categories',
    '/dinor-tv',
    '/banners'
  ];

  for (const endpoint of endpoints) {
    try {
      console.log(`📡 Test de ${endpoint}...`);
      
      const response = await fetch(`${API_BASE_URL}${endpoint}`);
      
      if (response.ok) {
        const data = await response.json();
        console.log(`✅ ${endpoint} - Status: ${response.status}`);
        console.log(`   📊 Données reçues: ${data.data?.length || 0} éléments`);
      } else {
        console.log(`❌ ${endpoint} - Status: ${response.status} ${response.statusText}`);
      }
    } catch (error) {
      console.log(`❌ ${endpoint} - Erreur: ${error.message}`);
    }
    console.log('');
  }

  // Test d'authentification
  console.log('🔐 Test d\'authentification...');
  try {
    const response = await fetch(`${API_BASE_URL}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        email: 'test@example.com',
        password: 'password'
      })
    });

    if (response.ok) {
      console.log('✅ Endpoint d\'authentification accessible');
    } else {
      console.log(`❌ Authentification - Status: ${response.status}`);
    }
  } catch (error) {
    console.log(`❌ Authentification - Erreur: ${error.message}`);
  }

  console.log('\n🎯 Test terminé !');
}

// Lancer le test
testApiConnection().catch(console.error); 