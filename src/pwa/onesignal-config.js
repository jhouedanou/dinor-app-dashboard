window.OneSignalDeferred = window.OneSignalDeferred || [];
OneSignalDeferred.push(async function(OneSignal) {
  await OneSignal.init({
    appId: "7703701f-3c33-408d-99e0-db5c4da8918a",
    allowLocalhostAsSecureOrigin: true,
    autoRegister: true,
    notifyButton: {
      enable: false // Désactiver le bouton par défaut OneSignal
    }
  });
  
  console.log('✅ OneSignal initialized successfully');
  
  // Demander la permission pour les notifications
  const permission = await OneSignal.Notifications.requestPermission();
  console.log('🔔 Notification permission:', permission);
});