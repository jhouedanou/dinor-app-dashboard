// Service Worker Registration Script - DÉSACTIVÉ pour Filament
console.log('🚫 Service Worker registration désactivé pour éviter les conflits avec Filament');

// Si on est vraiment dans la PWA (pas dans une iframe ou popup), activer le SW
if ('serviceWorker' in navigator && 
    window.location.pathname.startsWith('/pwa/') && 
    !window.location.pathname.startsWith('/admin') &&
    window === window.top) {
  
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/pwa/sw.js')
      .then((registration) => {
        console.log('✅ PWA SW registered: ', registration);
      })
      .catch((registrationError) => {
        console.log('❌ PWA SW registration failed: ', registrationError);
      });
  });
}
