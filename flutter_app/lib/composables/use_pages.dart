/**
 * USE_PAGES.DART - COMPOSABLE POUR LA GESTION DES PAGES
 * 
 * FONCTIONNALITÉS :
 * - Récupération des pages depuis l'API
 * - Gestion du cache et du state
 * - Méthodes pour afficher les pages comme onglets
 * - Support du mode hors ligne
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// Modèle pour une page
class PageModel {
  final String id;
  final String title;
  final String? url;
  final String? embedUrl;
  final bool isExternal;
  final bool isPublished;
  final int order;
  final String? content;
  final String? metaTitle;
  final String? metaDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PageModel({
    required this.id,
    required this.title,
    this.url,
    this.embedUrl,
    this.isExternal = false,
    this.isPublished = true,
    this.order = 0,
    this.content,
    this.metaTitle,
    this.metaDescription,
    this.createdAt,
    this.updatedAt,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    return PageModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      url: json['url'],
      embedUrl: json['embed_url'],
      isExternal: json['is_external'] ?? false,
      isPublished: json['is_published'] ?? true,
      order: json['order'] ?? 0,
      content: json['content'],
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'embed_url': embedUrl,
      'is_external': isExternal,
      'is_published': isPublished,
      'order': order,
      'content': content,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// State pour les pages
class PagesState {
  final List<PageModel> pages;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  PagesState({
    this.pages = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  PagesState copyWith({
    List<PageModel>? pages,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return PagesState(
      pages: pages ?? this.pages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Notifier pour la gestion des pages
class PagesNotifier extends StateNotifier<PagesState> {
  final Ref _ref;
  late final ApiService _apiService;

  PagesNotifier(this._ref) : super(PagesState()) {
    _apiService = _ref.read(apiServiceProvider);
  }

  // Charger les pages depuis l'API
  Future<void> loadPages({bool forceRefresh = false}) async {
    if (state.isLoading) return;

    // Si on a déjà des données et qu'on ne force pas le refresh, ne pas recharger
    if (!forceRefresh && state.pages.isNotEmpty && state.error == null) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.getMenuPages();

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> pagesData = response['data'] as List<dynamic>;
        final List<PageModel> pages = pagesData
            .map((pageData) => PageModel.fromJson(pageData))
            .where((page) => page.isPublished)
            .toList();
        
        // Trier par ordre
        pages.sort((a, b) => a.order.compareTo(b.order));

        state = state.copyWith(
          pages: pages,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );

        print('✅ [UsePages] ${pages.length} pages chargées avec succès');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['error'] ?? 'Erreur lors du chargement des pages',
        );
        print('❌ [UsePages] Erreur API: ${response['error']}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur de connexion: $e',
      );
      print('❌ [UsePages] Exception: $e');
    }
  }

  // Rafraîchir les pages
  Future<void> refreshPages() async {
    await loadPages(forceRefresh: true);
  }

  // Obtenir une page par ID
  PageModel? getPageById(String id) {
    try {
      return state.pages.firstWhere((page) => page.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les pages visibles pour la navigation
  List<PageModel> getNavigationPages() {
    return state.pages
        .where((page) => page.isPublished && (page.embedUrl != null || page.url != null))
        .toList();
  }

  // Vider le cache
  void clearCache() {
    state = PagesState();
    print('🧹 [UsePages] Cache des pages vidé');
  }
}

// Provider pour les pages
final usePagesProvider = StateNotifierProvider<PagesNotifier, PagesState>((ref) {
  return PagesNotifier(ref);
});

// Provider pour obtenir les pages de navigation
final navigationPagesProvider = Provider<List<PageModel>>((ref) {
  final pagesState = ref.watch(usePagesProvider);
  return pagesState.pages.where((page) => page.isPublished && page.url != null).toList();
});

// Provider pour vérifier si on a des pages
final hasPagesProvider = Provider<bool>((ref) {
  final pages = ref.watch(navigationPagesProvider);
  return pages.isNotEmpty;
});