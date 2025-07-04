window.OneSignalDeferred = window.OneSignalDeferred || [];
OneSignalDeferred.push(async function(OneSignal) {
  // N'initialiser OneSignal qu'en production
  if (import.meta.env.PROD) {
    await OneSignal.init({
      appId: "7703701f-3c33-408d-99e0-db5c4da8918a",
      allowLocalhostAsSecureOrigin: true, // Garder pour tests locaux si besoin
      autoRegister: true,
      notifyButton: {
        enable: false // Désactiver le bouton par défaut OneSignal
      }
    });

    console.log('✅ OneSignal initialized successfully in production');

    // Demander la permission pour les notifications
    const permission = await OneSignal.Notifications.requestPermission();
    console.log('🔔 Notification permission:', permission);
  } else {
    console.log('🔧 OneSignal: Disabled in development mode.');
  }
});