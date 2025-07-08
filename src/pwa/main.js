import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import App from './App.vue'

// Import global styles
import './assets/styles/main.scss'

// Importation des stores
import { useAppStore } from './stores/app'

// Import du service OneSignal
import { oneSignalService } from './services/oneSignal'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Configuration globale des stores
const appStore = useAppStore()

// Fonction pour détecter si Material Symbols se charge correctement
function detectMaterialSymbols() {
  console.log('🔍 [Main] Vérification du chargement de Material Symbols...');
  
  // Créer un élément de test
  const testElement = document.createElement('span');
  testElement.className = 'material-symbols-outlined';
  testElement.textContent = 'home';
  testElement.style.position = 'absolute';
  testElement.style.left = '-9999px';
  testElement.style.top = '-9999px';
  testElement.style.visibility = 'hidden';
  
  document.body.appendChild(testElement);
  
  // Laisser le temps au navigateur de calculer les styles
  setTimeout(() => {
    const computedStyle = window.getComputedStyle(testElement);
    const fontFamily = computedStyle.getPropertyValue('font-family');
    
    console.log('📝 [Main] Font family détectée:', fontFamily);
    
    // Vérifier si Material Symbols est bien chargé
    const isMaterialSymbolsLoaded = fontFamily.includes('Material Symbols Outlined') || 
                                   fontFamily.includes('Material Symbols');
    
    if (!isMaterialSymbolsLoaded) {
      console.log('⚠️ [Main] Material Symbols non détecté, activation des emoji...');
      document.documentElement.classList.add('force-emoji');
    } else {
      console.log('✅ [Main] Material Symbols détecté et fonctionnel');
      document.documentElement.classList.remove('force-emoji');
    }
    
    // Nettoyer l'élément de test
    document.body.removeChild(testElement);
  }, 100);
}

// Fonction pour forcer les emoji (pour test)
window.toggleEmojiMode = function() {
  const isForced = document.documentElement.classList.contains('force-emoji');
  if (isForced) {
    document.documentElement.classList.remove('force-emoji');
    console.log('✅ [Main] Mode icônes Material Symbols activé');
  } else {
    document.documentElement.classList.add('force-emoji');
    console.log('🎭 [Main] Mode emoji forcé activé');
  }
}

// Attendre que les polices se chargent
if (document.fonts && document.fonts.ready) {
  document.fonts.ready.then(() => {
    setTimeout(detectMaterialSymbols, 500);
  });
} else {
  // Fallback pour les navigateurs plus anciens
  setTimeout(detectMaterialSymbols, 2000);
}

// Re-vérifier au chargement complet de la page
window.addEventListener('load', () => {
  setTimeout(detectMaterialSymbols, 1000);
});

console.log('🚀 [Main] Système de détection Material Symbols initialisé');
console.log('💡 [Main] Tapez toggleEmojiMode() dans la console pour basculer entre icônes et emoji');

// Vérifier le chargement des polices quand l'application est montée
app.mount('#app')

// Gestion des erreurs globales
app.config.errorHandler = (error, instance, errorInfo) => {
  console.error('Global error:', error, errorInfo)
}

// Support PWA avec détection automatique du device
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/pwa/sw.js')
    .then(registration => {
      console.log('Service Worker registered:', registration)
    })
    .catch(error => {
      console.error('Service Worker registration failed:', error)
    })
}

// Optimisation pour les appareils tactiles
if ('ontouchstart' in window) {
  document.body.classList.add('touch-device')
}

// Détection de la connexion réseau
function updateOnlineStatus() {
  if (navigator.onLine) {
    document.body.classList.remove('offline')
    appStore.setOnlineStatus(true)
  } else {
    document.body.classList.add('offline')
    appStore.setOnlineStatus(false)
  }
}

window.addEventListener('online', updateOnlineStatus)
window.addEventListener('offline', updateOnlineStatus)

// Initialiser le statut
updateOnlineStatus()

// Initialiser OneSignal après le montage de l'app
console.log('🔔 [Main] Initialisation du service OneSignal...')

// Exposer le service globalement pour debug
window.oneSignalService = oneSignalService