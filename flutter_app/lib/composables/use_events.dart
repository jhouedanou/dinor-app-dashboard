/**
 * USE_EVENTS.DART - COMPOSABLE POUR ÉVÉNEMENTS
 * 
 * FIDÉLITÉ VUE :
 * - Même structure que useRecipes, useTips
 * - Même gestion d'état : loading, error, data
 * - Même système de rafraîchissement
 * - Même gestion des paramètres de requête
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class EventsState {
  final List<dynamic> events;
  final bool loading;
  final String? error;
  final Map<String, dynamic> meta;

  EventsState({
    required this.events,
    required this.loading,
    this.error,
    required this.meta,
  });

  EventsState copyWith({
    List<dynamic>? events,
    bool? loading,
    String? error,
    Map<String, dynamic>? meta,
  }) {
    return EventsState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      meta: meta ?? this.meta,
    );
  }
}

class EventsNotifier extends StateNotifier<EventsState> {
  final ApiService _apiService;
  
  EventsNotifier(this._apiService) : super(EventsState(
    events: [],
    loading: false,
    meta: {},
  ));

  Future<void> loadEvents({
    Map<String, dynamic>? params,
    bool forceRefresh = false,
  }) async {
    state = state.copyWith(loading: true, error: null);

    try {
      print('📅 [Events] Chargement des événements...');
      
      final data = await _apiService.get('/events',
        params: params,
        forceRefresh: forceRefresh,
      );

      if (data['success'] == true) {
        state = state.copyWith(
          events: data['data'] ?? [],
          meta: data['meta'] ?? {},
          loading: false,
        );
        print('✅ [Events] ${state.events.length} événements chargés');
      } else {
        throw Exception(data['message'] ?? 'Erreur lors du chargement des événements');
      }
    } catch (error) {
      print('❌ [Events] Erreur: $error');
      state = state.copyWith(
        error: error.toString(),
        loading: false,
      );
    }
  }

  Future<void> refresh() async {
    await loadEvents(forceRefresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final eventsProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return EventsNotifier(apiService);
}); 