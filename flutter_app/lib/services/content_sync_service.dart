/// CONTENT_SYNC_SERVICE.DART - SERVICE DE SYNCHRONISATION DU CONTENU
/// 
/// FONCTIONNALITÉS :
/// - Synchronisation automatique des compteurs de likes
/// - Mise à jour en arrière-plan
/// - Gestion intelligente de la bande passante
/// - Retry automatique avec backoff exponentiel
library;

import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'local_database_service.dart';

class ContentSyncService {
  static final ContentSyncService _instance = ContentSyncService._internal();
  factory ContentSyncService() => _instance;
  ContentSyncService._internal();

  static const String baseUrl = 'https://new.dinorapp.com/api/v1';
  final LocalDatabaseService _localDB = LocalDatabaseService();
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  int _retryCount = 0;
  static const int maxRetries = 3;

  // Démarrer la synchronisation automatique
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      syncAllContent();
    });
    print('🔄 [ContentSync] Auto-sync démarré (toutes les 2 minutes)');
  }

  // Arrêter la synchronisation automatique
  void stopAutoSync() {
    _syncTimer?.cancel();
    print('⏹️ [ContentSync] Auto-sync arrêté');
  }

  // Synchroniser tout le contenu
  Future<void> syncAllContent() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    print('🔄 [ContentSync] Début synchronisation complète...');
    
    try {
      await Future.wait([
        _syncLikeCounts(),
        _syncContentMetadata(),
      ]);
      
      _retryCount = 0; // Reset retry count on success
      print('✅ [ContentSync] Synchronisation complète réussie');
    } catch (e) {
      print('❌ [ContentSync] Erreur synchronisation: $e');
      _handleSyncError();
    } finally {
      _isSyncing = false;
    }
  }

  // Synchroniser les compteurs de likes
  Future<void> _syncLikeCounts() async {
    try {
      print('❤️ [ContentSync] Synchronisation compteurs likes...');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/content/likes/bulk'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final likeCounts = data['data'] as Map<String, dynamic>;
          final Map<String, int> counts = {};
          
          // Convertir les données au format attendu
          for (final entry in likeCounts.entries) {
            final parts = entry.key.split(':');
            if (parts.length == 2) {
              final key = '${parts[0]}_${parts[1]}';
              counts[key] = (entry.value as num).toInt();
            }
          }
          
          // Sauvegarder localement
          await _localDB.saveLikeCounts(counts);
          print('✅ [ContentSync] ${counts.length} compteurs likes synchronisés');
        }
      }
    } catch (e) {
      print('❌ [ContentSync] Erreur sync likes: $e');
      rethrow;
    }
  }

  // Synchroniser les métadonnées du contenu
  Future<void> _syncContentMetadata() async {
    try {
      print('📊 [ContentSync] Synchronisation métadonnées...');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/content/metadata/updated'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final updates = data['data'] as List;
          
          for (final update in updates) {
            await _updateContentMetadata(update);
          }
          
          print('✅ [ContentSync] ${updates.length} métadonnées mises à jour');
        }
      }
    } catch (e) {
      print('❌ [ContentSync] Erreur sync métadonnées: $e');
      rethrow;
    }
  }

  // Mettre à jour les métadonnées d'un contenu spécifique
  Future<void> _updateContentMetadata(Map<String, dynamic> update) async {
    try {
      final type = update['type'];
      final itemId = update['id'].toString();
      final likesCount = update['likes_count'] ?? 0;
      final commentsCount = update['comments_count'] ?? 0;
      
      // Mettre à jour le cache local
      final likeCounts = await _localDB.getLikeCounts();
      final key = '${type}_$itemId';
      likeCounts[key] = likesCount;
      
      await _localDB.saveLikeCounts(likeCounts);
      
      print('📝 [ContentSync] Métadonnées mises à jour: $type:$itemId ($likesCount likes, $commentsCount comments)');
    } catch (e) {
      print('❌ [ContentSync] Erreur mise à jour métadonnées: $e');
    }
  }

  // Synchroniser un contenu spécifique
  Future<Map<String, dynamic>?> syncSpecificContent(String type, String itemId) async {
    try {
      print('🎯 [ContentSync] Sync spécifique: $type:$itemId');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/content/$type/$itemId/stats'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final stats = data['data'];
          
          // Mettre à jour le cache local
          final likeCounts = await _localDB.getLikeCounts();
          final key = '${type}_$itemId';
          likeCounts[key] = stats['likes_count'] ?? 0;
          
          await _localDB.saveLikeCounts(likeCounts);
          
          print('✅ [ContentSync] Stats synchronisées: $type:$itemId');
          return stats;
        }
      }
    } catch (e) {
      print('❌ [ContentSync] Erreur sync spécifique: $e');
    }
    
    return null;
  }

  // Gestion des erreurs avec retry
  void _handleSyncError() {
    _retryCount++;
    
    if (_retryCount <= maxRetries) {
      final delay = Duration(seconds: 30 * _retryCount); // Backoff exponentiel
      print('🔄 [ContentSync] Retry ${'_retryCount'}/$maxRetries dans ${delay.inSeconds}s');
      
      Timer(delay, () {
        if (!_isSyncing) {
          syncAllContent();
        }
      });
    } else {
      print('❌ [ContentSync] Max retries atteint, abandon');
      _retryCount = 0;
    }
  }

  // Synchronisation forcée (pour les pull-to-refresh)
  Future<void> forceSyncAll() async {
    print('🔄 [ContentSync] Synchronisation forcée...');
    _retryCount = 0; // Reset retry count
    await syncAllContent();
  }

  // Méthodes utilitaires
  Future<Map<String, String>> _getHeaders() async {
    final authState = await _localDB.getAuthState();
    
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    if (authState != null && authState['token'] != null) {
      headers['Authorization'] = 'Bearer ${authState['token']}';
    }
    
    return headers;
  }

  // Statistiques de synchronisation
  Map<String, dynamic> getSyncStats() {
    return {
      'is_syncing': _isSyncing,
      'retry_count': _retryCount,
      'auto_sync_active': _syncTimer?.isActive ?? false,
    };
  }

  // Cleanup
  void dispose() {
    _syncTimer?.cancel();
    print('🧹 [ContentSync] Service nettoyé');
  }
}

// Provider pour le service de synchronisation
final contentSyncServiceProvider = Provider<ContentSyncService>((ref) {
  final service = ContentSyncService();
  
  // Démarrer la synchronisation automatique
  service.startAutoSync();
  
  // Cleanup automatique
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

// State pour le statut de synchronisation
class SyncStatus {
  final bool isSyncing;
  final DateTime? lastSync;
  final String? error;
  final int retryCount;

  const SyncStatus({
    this.isSyncing = false,
    this.lastSync,
    this.error,
    this.retryCount = 0,
  });

  SyncStatus copyWith({
    bool? isSyncing,
    DateTime? lastSync,
    String? error,
    int? retryCount,
  }) {
    return SyncStatus(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSync: lastSync ?? this.lastSync,
      error: error,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

// Notifier pour le statut de synchronisation
class SyncStatusNotifier extends StateNotifier<SyncStatus> {
  final ContentSyncService _syncService;
  Timer? _statusTimer;

  SyncStatusNotifier(this._syncService) : super(const SyncStatus()) {
    _startStatusUpdates();
  }

  void _startStatusUpdates() {
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final stats = _syncService.getSyncStats();
      state = state.copyWith(
        isSyncing: stats['is_syncing'],
        retryCount: stats['retry_count'],
      );
    });
  }

  Future<void> forceSync() async {
    state = state.copyWith(isSyncing: true, error: null);
    
    try {
      await _syncService.forceSyncAll();
      state = state.copyWith(
        isSyncing: false,
        lastSync: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}

// Provider pour le statut de synchronisation
final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncStatus>((ref) {
  final syncService = ref.read(contentSyncServiceProvider);
  return SyncStatusNotifier(syncService);
});