// Service Worker Registration - COMPLÈTEMENT DÉSACTIVÉ
console.log('🚫 Service Worker registration complètement désactivé');

// Désinscrire tous les service workers existants
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(function(registrations) {
    for(let registration of registrations) {
      registration.unregister();
      console.log('🗑️ Service Worker désinscrit:', registration.scope);
    }
  });
}

// Script inerte - ne fait rien d'autre
console.log('✅ Pas d\'interférence avec Filament admin');

// Pour la PWA, utiliser /pwa/registerSW.js à la place
// Pour Filament admin, ce script ne fait rien
