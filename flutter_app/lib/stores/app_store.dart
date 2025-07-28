/**
 * APP_STORE.DART - CONVERSION FIDÈLE DE app.js Vue/Pinia
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - État identique : loading, error, online, installPrompt, isInstalled
 * - Actions identiques : setLoading, setError, setOnlineStatus
 * - PWA simulation : InstallPrompt équivalent
 * - Network listeners identiques
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

// Provider pour l'état global de l'application
final appStoreProvider = ChangeNotifierProvider<AppStore>((ref) => AppStore());

class AppStore extends ChangeNotifier {
  static AppStore? _instance;
  static AppStore get instance => _instance ??= AppStore._();
  
  AppStore._() {
    _initializeNetworkListeners();
  }
  
  // État identique à app.js Vue
  bool _loading = false;
  String? _error;
  bool _online = true;
  bool _isInstalled = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Getters identiques à app.js
  bool get loading => _loading;
  String? get error => _error;
  bool get online => _online;
  bool get isInstalled => _isInstalled;
  
  // IDENTIQUE à setLoading() Vue
  void setLoading(bool state) {
    _loading = state;
    notifyListeners();
  }
  
  // IDENTIQUE à setError() Vue
  void setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }
  
  // IDENTIQUE à clearError() Vue
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // IDENTIQUE à setOnlineStatus() Vue
  void setOnlineStatus(bool status) {
    _online = status;
    notifyListeners();
    print('🌐 [AppStore] Statut réseau mis à jour: ${status ? "en ligne" : "hors ligne"}');
  }
  
  // IDENTIQUE à setInstallationStatus() Vue
  void setInstallationStatus(bool status) {
    _isInstalled = status;
    notifyListeners();
  }
  
  // Simulation PWA install (équivalent showInstallPrompt() Vue)
  Future<bool> showInstallPrompt() async {
    // En Flutter mobile, l'app est déjà "installée"
    // Mais on peut simuler le comportement pour cohérence
    print('📱 [AppStore] Simulation install prompt (déjà installé sur mobile)');
    setInstallationStatus(true);
    return true;
  }
  
  // REPRODUCTION EXACTE de initializeNetworkListeners() Vue
  void _initializeNetworkListeners() {
    print('🌐 [AppStore] Initialisation des listeners réseau');
    
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      final isOnline = result != ConnectivityResult.none;
      setOnlineStatus(isOnline);
    });
    
    // Vérification initiale du statut réseau
    _checkInitialNetworkStatus();
  }
  
  Future<void> _checkInitialNetworkStatus() async {
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;
    setOnlineStatus(isOnline);
  }
  
  // IDENTIQUE à initializePWAListeners() Vue (adaptation mobile)
  void initializePWAListeners() {
    print('📱 [AppStore] Initialisation PWA listeners (adaptation mobile)');
    
    // Sur mobile, l'app est considérée comme "installée" par défaut
    setInstallationStatus(true);
    
    // Simulation des événements PWA pour compatibilité
    print('✅ [AppStore] PWA listeners initialisés (mode mobile)');
  }
  
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
  
  // Méthodes utilitaires pour l'état global
  void showGlobalLoading() {
    setLoading(true);
  }
  
  void hideGlobalLoading() {
    setLoading(false);
  }
  
  void showGlobalError(String message) {
    setError(message);
  }
  
  void clearGlobalError() {
    clearError();
  }
  
  // Initialisation globale (équivalent aux listeners main.js Vue)
  static Future<void> initialize() async {
    final store = AppStore.instance;
    store._initializeNetworkListeners();
    store.initializePWAListeners();
    print('✅ [AppStore] Store global initialisé');
  }
}