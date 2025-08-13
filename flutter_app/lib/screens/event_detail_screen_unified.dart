import '../services/navigation_service.dart';
/**
 * EVENT_DETAIL_SCREEN_UNIFIED.DART - VERSION UNIFIÉE DU DÉTAIL ÉVÉNEMENT
 * - Utilise les nouveaux composants unifiés
 * - Interface cohérente avec les autres types de contenu
 * - Pagination des commentaires intégrée
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

// Components unifiés
import '../components/common/image_gallery_carousel.dart';
import '../components/common/maps_modal.dart';
import '../components/common/unified_content_header.dart';
import '../components/common/unified_video_player.dart';
import '../components/common/unified_comments_section.dart';
import '../components/common/unified_content_actions.dart';
import '../components/common/unified_content_navigation.dart';
import '../components/common/accordion.dart';

// Services
import '../services/api_service.dart';
import '../services/share_service.dart';
import '../services/likes_service.dart';
import '../services/content_navigation_service.dart';
import '../composables/use_auth_handler.dart';
import '../stores/header_state.dart';

class EventDetailScreenUnified extends ConsumerStatefulWidget {
  final String id;
  
  const EventDetailScreenUnified({super.key, required this.id});

  @override
  ConsumerState<EventDetailScreenUnified> createState() => _EventDetailScreenUnifiedState();
}

class _EventDetailScreenUnifiedState extends ConsumerState<EventDetailScreenUnified> with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? _event;
  bool _loading = true;
  String? _error;
  bool _userLiked = false;
  
  // Navigation entre contenus
  String? _previousId;
  String? _nextId;
  String? _previousTitle;
  String? _nextTitle;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }


  Future<void> _loadEventDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final data = await apiService.get('/events/${widget.id}?include=category,organizer,location,gallery&fields=*');

      if (data['success'] == true) {
        print('📅 [EventDetailUnified] Données reçues: ${data['data']}');
        setState(() {
          _event = data['data'];
          _loading = false;
        });
        // Mettre à jour le sous-titre de l'en-tête avec le titre de l'événement
        if (mounted && _event != null) {
          final title = _event!['title']?.toString();
          if (title != null && title.isNotEmpty) {
            ref.read(headerSubtitleProvider.notifier).state = title;
          }
        }
        await _checkUserLike();
      } else {
        throw Exception(data['message'] ?? 'Erreur lors du chargement de l\'événement');
      }
    } catch (error) {
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    // Nettoyer le titre immédiatement lors de la destruction du widget
    ref.read(headerSubtitleProvider.notifier).state = null;
    print('🧹 [EventDetail] Titre nettoyé dans dispose()');
    super.dispose();
  }

  Future<void> _checkUserLike() async {
    if (_event != null) {
      final isLiked = ref.read(likesProvider.notifier).isLiked('event', widget.id);
      setState(() => _userLiked = isLiked);
    }
  }

  Future<void> _handleLikeAction() async {
    final authState = ref.read(useAuthHandlerProvider);
    
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour liker cet événement'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final success = await ref.read(likesProvider.notifier).toggleLike('event', widget.id);
      
      if (success) {
        setState(() => _userLiked = !_userLiked);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_userLiked ? '❤️ Événement ajouté aux favoris' : '💔 Événement retiré des favoris'),
            backgroundColor: const Color(0xFFE53E3E),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${error.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      print('❌ [EventDetailUnified] Erreur parsing date: $dateString');
      return dateString;
    }
  }

  String _getEventDate() {
    if (_event == null) return '';
    
    // Essayer différents champs possibles pour la date
    final possibleDateFields = [
      'date', 'event_date', 'start_date', 'scheduled_date', 
      'datetime', 'event_datetime', 'start_datetime', 'created_at',
      'published_at', 'event_start', 'begins_at'
    ];
    for (final field in possibleDateFields) {
      final value = _event![field];
      if (value != null && value.toString().isNotEmpty) {
        print('📅 [EventDetailUnified] Date trouvée dans $field: $value');
        return _formatDate(value.toString());
      }
    }
    
    print('⚠️ [EventDetailUnified] Aucune date trouvée dans: ${_event!.keys.toList()}');
    return '';
  }

  String _getEventTime() {
    if (_event == null) return '';
    
    // Essayer différents champs possibles pour l'heure
    final possibleTimeFields = [
      'time', 'event_time', 'start_time', 'scheduled_time',
      'hour', 'event_hour', 'start_hour', 'begin_time'
    ];
    for (final field in possibleTimeFields) {
      final value = _event![field];
      if (value != null && value.toString().isNotEmpty) {
        print('🕐 [EventDetailUnified] Heure trouvée dans $field: $value');
        return _formatTime(value.toString());
      }
    }
    
    print('⚠️ [EventDetailUnified] Aucune heure trouvée dans: ${_event!.keys.toList()}');
    return 'Non défini';
  }

  String _formatTime(String timeString) {
    // Si c'est déjà au bon format (HH:mm), le retourner
    if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(timeString)) {
      return timeString;
    }
    
    // Essayer de parser comme DateTime ISO pour extraire l'heure
    try {
      final dateTime = DateTime.parse(timeString);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      // Si ce n'est pas parsable, retourner tel quel
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_loading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_event == null) {
      return _buildNotFoundState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Hero Image avec composant unifié
          SliverToBoxAdapter(
            child: UnifiedContentHeader(
              imageUrl: _event!['image'] ?? 
                        _event!['thumbnail'] ?? 
                        _event!['image_url'] ?? 
                        _event!['thumbnail_url'] ?? 
                        _event!['featured_image'] ?? 
                        _event!['featured_image_url'] ?? '',
              contentType: 'event',
              customOverlay: Stack(
                children: [
                  // Gradient overlay pour améliorer la lisibilité
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black,
                            Colors.black,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Badges repositionnés
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        if (_getEventDate().isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4D03F),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Color(0xFF2D3748),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getEventDate(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (_event!['category'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.category,
                                  size: 14,
                                  color: Color(0xFF4A5568),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _event!['category']['name'] ?? _event!['category'].toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu de l'événement
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Stats avec composant unifié
                  UnifiedContentStats(
                    stats: [
                      {
                        'icon': LucideIcons.calendar,
                        'text': _getEventDate(),
                      },
                      {
                        'icon': LucideIcons.clock,
                        'text': _getEventTime(),
                      },
                      {
                        'icon': LucideIcons.heart,
                        'text': '${_event!['likes_count'] ?? 0}',
                      },
                      {
                        'icon': LucideIcons.messageCircle,
                        'text': '${_event!['comments_count'] ?? 0}',
                      },
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Titre de l'événement
                  Text(
                    _event!['title'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description (Accordion)
                  if (_event!['description'] != null && _event!['description'].isNotEmpty)
                    Accordion(
                      title: 'Description',
                      initiallyOpen: true,
                      child: Text(
                        _event!['description'],
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 16,
                          color: Color(0xFF4A5568),
                          height: 1.5,
                        ),
                      ),
                    ),

                  // Images et médias
                  _buildMediaSection(),
                  
                  // Vidéo promotionnelle
                  _buildVideoSection(),
                  
                  // Informations de localisation complètes
                  _buildLocationSection(),
                  
                  // Tarification
                  _buildPricingSection(),

                  // Inscription et participants
                  _buildRegistrationSection(),
                  
                  // Informations pratiques
                  _buildPracticalInfoSection(),
                  
                  // Contact et organisation
                  _buildContactSection(),

                  // Informations sur l'organisateur
                  _buildOrganizerSection(),

                  // Détails de l'événement
                  _buildEventDetails(),
                  const SizedBox(height: 24),

                  // Actions avec composant unifié
                  UnifiedContentActions(
                    contentType: 'event',
                    contentId: widget.id,
                    title: _event!['title'] ?? 'Événement',
                    description: _event!['description'] ?? 'Découvrez cet événement : ${_event!['title']}',
                    shareUrl: 'https://new.dinorapp.com/pwa/event/${widget.id}',
                    imageUrl: _event!['image'] ?? 
                              _event!['thumbnail'] ?? 
                              _event!['image_url'] ?? 
                              _event!['thumbnail_url'] ?? 
                              _event!['featured_image'] ?? 
                              _event!['featured_image_url'],
                    initialLiked: _userLiked,
                    initialLikeCount: _event!['likes_count'] ?? 0,
                    onRefresh: _loadEventDetails,
                    isLoading: _loading,
                  ),

                  // Comments avec composant unifié
                  const SizedBox(height: 24),
                  UnifiedCommentsSection(
                    contentType: 'event',
                    contentId: widget.id,
                    contentTitle: _event!['title'] ?? 'Événement',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => NavigationService.pop(),
          heroTag: 'back_fab',
          backgroundColor: Colors.white,
          mini: true,
          child: const Icon(LucideIcons.arrowLeft, color: Color(0xFF2D3748), size: 20),
        ),
        const SizedBox(height: 16),
        // Bouton Like flottant
        FloatingActionButton(
          onPressed: () => _handleLikeAction(),
          heroTag: 'like_fab',
          backgroundColor: _userLiked ? const Color(0xFFE53E3E) : Colors.white,
          mini: true,
          child: Icon(
            _userLiked ? LucideIcons.heart : LucideIcons.heart,
            color: _userLiked ? Colors.white : const Color(0xFFE53E3E),
            size: 20,
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: () {
            if (_event != null) {
              ref.read(shareServiceProvider).shareContent(
                type: 'event',
                id: widget.id,
                title: _event!['title'] ?? 'Événement',
                description: _event!['description'] ?? 'Découvrez cet événement',
                shareUrl: 'https://new.dinorapp.com/pwa/event/${widget.id}',
                imageUrl: _event!['image'] ?? 
                          _event!['thumbnail'] ?? 
                          _event!['image_url'] ?? 
                          _event!['thumbnail_url'] ?? 
                          _event!['featured_image'] ?? 
                          _event!['featured_image_url'],
              );
            }
          },
          heroTag: 'share_fab',
          backgroundColor: const Color(0xFFE53E3E),
          mini: true,
          child: const Icon(LucideIcons.share2, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4D03F)),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement de l\'événement...',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: Color(0xFF718096),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => NavigationService.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.alertCircle,
              size: 64,
              color: Color(0xFFE53E3E),
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEventDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4D03F),
                foregroundColor: const Color(0xFF2D3748),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Center(
        child: Text(
          'Événement non trouvé',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            color: Color(0xFF2D3748),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Accordion(
      title: title,
      initiallyOpen: false,
      child: content,
    );
  }

  Widget _buildEventDetails() {
    final date = _getEventDate();
    final time = _getEventTime();
    final location = _event!['location'] ?? 
                     _event!['venue'] ?? 
                     _event!['address'] ?? 
                     _event!['place'] ?? 
                     _event!['event_location'] ?? 
                     _event!['event_venue'] ?? '';
    final organizer = _event!['organizer'] ?? 
                      _event!['organiser'] ?? 
                      _event!['author'] ?? 
                      _event!['creator'] ?? 
                      _event!['event_organizer'] ?? 
                      _event!['host'] ?? '';

    if (date.isEmpty && time == 'Non défini' && location.isEmpty && organizer.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails de l\'événement',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          if (date.isNotEmpty) ...[
            _buildDetailRow(LucideIcons.calendar, 'Date', date),
            const SizedBox(height: 12),
          ],
          if (time != 'Non défini') ...[
            _buildDetailRow(LucideIcons.clock, 'Heure', time),
            const SizedBox(height: 12),
          ],
          if (location.isNotEmpty) ...[
            _buildLocationRow(location),
            const SizedBox(height: 12),
          ],
          if (organizer.isNotEmpty) ...[
            _buildDetailRow(LucideIcons.user, 'Organisateur', organizer),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFF4D03F),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.mapPin,
              size: 20,
              color: const Color(0xFFF4D03F),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lieu',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF718096),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => showMapsModal(context, location),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4D03F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFF4D03F),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4D03F),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              LucideIcons.map,
                              size: 14,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.externalLink,
                            size: 14,
                            color: Color(0xFF4A5568),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Boutons pour les cartes selon la plateforme
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _buildPlatformMapButtons(location),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(String location) async {
    try {
      final encodedLocation = Uri.encodeComponent(location);
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
      final googleMapsUri = Uri.parse(googleMapsUrl);
      
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        print('📍 [EventDetailUnified] Ouverture Google Maps: $location');
      } else {
        throw Exception('Impossible d\'ouvrir Google Maps');
      }
    } catch (e) {
      print('❌ [EventDetailUnified] Erreur ouverture Google Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir Google Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openAppleMaps(String location) async {
    try {
      final encodedLocation = Uri.encodeComponent(location);
      final appleMapsUrl = 'http://maps.apple.com/?q=$encodedLocation';
      final appleMapsUri = Uri.parse(appleMapsUrl);
      
      if (await canLaunchUrl(appleMapsUri)) {
        await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
        print('📍 [EventDetailUnified] Ouverture Apple Maps: $location');
      } else {
        throw Exception('Impossible d\'ouvrir Apple Maps');
      }
    } catch (e) {
      print('❌ [EventDetailUnified] Erreur ouverture Apple Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple Maps n\'est pas disponible sur cet appareil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openYandexMaps(String location) async {
    try {
      final encodedLocation = Uri.encodeComponent(location);
      final yandexMapsUrl = 'https://yandex.com/maps/?text=$encodedLocation';
      final yandexMapsUri = Uri.parse(yandexMapsUrl);
      
      if (await canLaunchUrl(yandexMapsUri)) {
        await launchUrl(yandexMapsUri, mode: LaunchMode.externalApplication);
        print('📍 [EventDetailUnified] Ouverture Yandex Maps: $location');
      } else {
        throw Exception('Impossible d\'ouvrir Yandex Maps');
      }
    } catch (e) {
      print('❌ [EventDetailUnified] Erreur ouverture Yandex Maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir Yandex Maps'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Sections de contenu manquantes
  Widget _buildMediaSection() {
    final images = _getEventImages();
    final videos = _getEventVideos();
    
    if (images.isEmpty && videos.isEmpty) return const SizedBox.shrink();
    
    return Accordion(
      title: 'Images et médias',
      initiallyOpen: images.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty) ...[
            ImageGalleryCarousel(
              images: images,
              title: 'Galerie photos',
              height: 240,
            ),
            const SizedBox(height: 12),
          ],
          if (videos.isNotEmpty) ...[
            const Text(
              'Vidéos disponibles',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: videos.take(3).map((video) => 
                Chip(label: Text('Vidéo ${videos.indexOf(video) + 1}'))
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    final videoUrl = _event!['video_url'] ?? 
                    _event!['promotional_video'] ?? 
                    _event!['promo_video'] ?? 
                    _event!['youtube_url'] ?? 
                    _event!['vimeo_url'];
    
    if (videoUrl == null) return const SizedBox.shrink();
    
    return Accordion(
      title: 'Vidéo promotionnelle',
      initiallyOpen: false,
      child: UnifiedVideoPlayer(
        videoUrl: videoUrl,
        title: 'Voir la vidéo promotionnelle',
        subtitle: 'Appuyez pour ouvrir',
      ),
    );
  }

  Widget _buildLocationSection() {
    return Accordion(
      title: 'Localisation complète',
      initiallyOpen: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLocationInfo(),
          const SizedBox(height: 16),
          _buildMapButtons(),
        ],
      ),
    );
  }

  Widget _buildRegistrationSection() {
    final registrationInfo = _getRegistrationInfo();
    if (registrationInfo.isEmpty) return const SizedBox.shrink();
    
    return Accordion(
      title: 'Inscription et participants',
      initiallyOpen: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: registrationInfo.entries.map((entry) => 
          _buildInfoRow(entry.key, entry.value)
        ).toList(),
      ),
    );
  }

  Widget _buildPracticalInfoSection() {
    final practicalInfo = _getPracticalInfo();
    if (practicalInfo.isEmpty) return const SizedBox.shrink();
    
    return Accordion(
      title: 'Informations pratiques',
      initiallyOpen: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: practicalInfo.entries.map((entry) => 
          _buildInfoRow(entry.key, entry.value)
        ).toList(),
      ),
    );
  }

  Widget _buildContactSection() {
    final contactInfo = _getContactInfo();
    if (contactInfo.isEmpty) return const SizedBox.shrink();
    
    return Accordion(
      title: 'Contact et organisation',
      initiallyOpen: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: contactInfo.entries.map((entry) => 
          _buildInfoRow(entry.key, entry.value)
        ).toList(),
      ),
    );
  }

  Widget _buildOrganizerSection() {
    final info = <String, String>{};
    final fields = {
      'organizer': 'Nom de l\'organisateur',
      'organiser': 'Nom de l\'organisateur',
      'organizer_description': 'À propos',
      'organizer_bio': 'Biographie',
      'organizer_email': 'Email',
      'organizer_phone': 'Téléphone',
      'organizer_website': 'Site web',
      'organizer_facebook': 'Facebook',
      'organizer_instagram': 'Instagram',
      'organizer_twitter': 'Twitter',
      'organizer_linkedin': 'LinkedIn',
    };
    fields.forEach((field, label) {
      final value = _event![field];
      if (value != null && value.toString().isNotEmpty) {
        info[label] = value.toString();
      }
    });
    if (info.isEmpty) return const SizedBox.shrink();
    return Accordion(
      title: 'Organisateur',
      initiallyOpen: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: info.entries.map((e) => _buildInfoRow(e.key, e.value)).toList(),
      ),
    );
  }

  Widget _buildPricingSection() {
    final info = <String, String>{};
    final priceFields = {
      'is_paid': 'Événement payant',
      'is_free': 'Événement gratuit',
      'price': 'Prix',
      'ticket_price': 'Prix du billet',
      'entry_fee': 'Frais d\'entrée',
      'fee': 'Frais',
      'cost': 'Coût',
      'price_min': 'Prix minimum',
      'price_max': 'Prix maximum',
      'currency': 'Devise',
      'registration_fee': 'Frais d\'inscription',
      'registration_status': 'Statut d\'inscription',
      'tickets_url': 'Lien billets',
      'registration_url': 'Lien d\'inscription',
    };
    priceFields.forEach((field, label) {
      final value = _event![field];
      if (value != null && value.toString().isNotEmpty && value.toString() != '0') {
        info[label] = value.toString();
      }
    });
    if (info.isEmpty) return const SizedBox.shrink();
    return Accordion(
      title: 'Tarification',
      initiallyOpen: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: info.entries.map((e) => _buildInfoRow(e.key, e.value)).toList(),
      ),
    );
  }

  // Méthodes utilitaires
  List<String> _getEventImages() {
    final images = <String>[];
    
    // Gallery URLs
    if (_event!['gallery_urls'] != null) {
      if (_event!['gallery_urls'] is List) {
        images.addAll(List<String>.from(_event!['gallery_urls']));
      }
    }
    
    // Images additionnelles
    final additionalImages = [
      'images', 'additional_images', 'media_gallery', 'photo_gallery'
    ];
    
    for (final field in additionalImages) {
      final value = _event![field];
      if (value != null) {
        if (value is List) {
          images.addAll(List<String>.from(value));
        } else if (value is String && value.isNotEmpty) {
          images.add(value);
        }
      }
    }
    
    return images;
  }

  List<String> _getEventVideos() {
    final videos = <String>[];
    
    final videoFields = [
      'videos', 'video_gallery', 'additional_videos', 'media_videos'
    ];
    
    for (final field in videoFields) {
      final value = _event![field];
      if (value != null) {
        if (value is List) {
          videos.addAll(List<String>.from(value));
        } else if (value is String && value.isNotEmpty) {
          videos.add(value);
        }
      }
    }
    
    return videos;
  }

  Map<String, String> _getRegistrationInfo() {
    final info = <String, String>{};
    
    final registrationFields = {
      'registration_required': 'Inscription requise',
      'registration_url': 'Lien d\'inscription',
      'registration_email': 'Email d\'inscription',
      'registration_phone': 'Téléphone d\'inscription',
      'registration_deadline': 'Date limite d\'inscription',
      'max_participants': 'Participants maximum',
      'current_participants': 'Participants actuels',
      'registration_fee': 'Frais d\'inscription',
      'registration_status': 'Statut d\'inscription',
    };
    
    registrationFields.forEach((field, label) {
      final value = _event![field];
      if (value != null && value.toString().isNotEmpty) {
        info[label] = value.toString();
      }
    });
    
    return info;
  }

  Map<String, String> _getPracticalInfo() {
    final info = <String, String>{};
    
    final practicalFields = {
      'dress_code': 'Code vestimentaire',
      'parking': 'Parking',
      'accessibility': 'Accessibilité',
      'age_restriction': 'Restriction d\'âge',
      'duration': 'Durée',
      'language': 'Langue',
      'equipment_needed': 'Équipement nécessaire',
      'what_to_bring': 'À apporter',
      'weather_dependency': 'Dépendant de la météo',
      'cancellation_policy': 'Politique d\'annulation',
    };
    
    practicalFields.forEach((field, label) {
      final value = _event![field];
      if (value != null && value.toString().isNotEmpty) {
        info[label] = value.toString();
      }
    });
    
    return info;
  }

  Map<String, String> _getContactInfo() {
    final info = <String, String>{};
    
    final contactFields = {
      'organizer': 'Organisateur',
      'organiser': 'Organisateur',
      'contact_name': 'Contact principal',
      'contact_email': 'Email de contact',
      'contact_phone': 'Téléphone de contact',
      'website': 'Site web',
      'social_media': 'Réseaux sociaux',
      'facebook': 'Facebook',
      'instagram': 'Instagram',
      'twitter': 'Twitter',
      'linkedin': 'LinkedIn',
    };
    
    contactFields.forEach((field, label) {
      final value = _event![field];
      if (value != null && value.toString().isNotEmpty) {
        info[label] = value.toString();
      }
    });
    
    return info;
  }

  Widget _buildLocationInfo() {
    final locationData = _getLocationData();
    if (locationData.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: locationData.entries.map((entry) => 
        _buildInfoRow(entry.key, entry.value)
      ).toList(),
    );
  }

  Map<String, String> _getLocationData() {
    final info = <String, String>{};
    
    final locationFields = {
      'location': 'Lieu',
      'venue': 'Salle/Venue',
      'address': 'Adresse',
      'city': 'Ville',
      'postal_code': 'Code postal',
      'region': 'Région',
      'country': 'Pays',
      'venue_type': 'Type de lieu',
      'venue_capacity': 'Capacité',
      'coordinates': 'Coordonnées GPS',
    };
    
    locationFields.forEach((field, label) {
      final value = _event![field];
      if (value != null && value.toString().isNotEmpty) {
        info[label] = value.toString();
      }
    });
    
    return info;
  }

  Widget _buildMapButtons() {
    final location = _event!['location'] ?? _event!['venue'] ?? '';
    if (location.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ouvrir dans :',
          style: const TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF4A5568),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._buildPlatformMapButtons(location),
            _buildCalendarButton(),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildPlatformMapButtons(String location) {
    final buttons = <Widget>[];
    
    // Google Maps (toujours disponible)
    buttons.add(_buildActionButton(
      'Google Maps',
      LucideIcons.map,
      () => _openGoogleMaps(location),
      const Color(0xFF4285F4),
    ));
    
    // Selon la plateforme
    try {
      if (Platform.isIOS) {
        buttons.add(_buildActionButton(
          'Apple Maps',
          LucideIcons.mapPin,
          () => _openAppleMaps(location),
          const Color(0xFF007AFF),
        ));
      }
      
      if (Platform.isAndroid) {
        buttons.add(_buildActionButton(
          'Yandex Maps',
          LucideIcons.mapPin,
          () => _openYandexMaps(location),
          const Color(0xFFFFCC00),
        ));
      }
    } catch (e) {
      // En cas d'erreur de plateforme, afficher tous les boutons
      buttons.add(_buildActionButton(
        'Apple Maps',
        LucideIcons.mapPin,
        () => _openAppleMaps(location),
        const Color(0xFF007AFF),
      ));
      buttons.add(_buildActionButton(
        'Yandex Maps',
        LucideIcons.mapPin,
        () => _openYandexMaps(location),
        const Color(0xFFFFCC00),
      ));
    }
    
    return buttons;
  }

  Widget _buildCalendarButton() {
    return _buildActionButton(
      'Calendrier',
      LucideIcons.calendar,
      () => _addToCalendar(),
      const Color(0xFFF4D03F),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF718096),
              ),
            ),
          ),
          Expanded(
            child: _buildValueWithOptionalPhoneLink(label, value),
          ),
        ],
      ),
    );
  }

  String _formatDisplayValue(dynamic raw) {
    if (raw == null) return '';
    // Booleens -> oui/non (minuscule pour non)
    if (raw is bool) return raw ? 'oui' : 'non';
    var value = raw.toString().trim();
    if (value.isEmpty) return '';
    final lower = value.toLowerCase();
    // Booléens sous forme texte / numérique
    if (lower == 'false' || lower == '0' || lower == 'no' || lower == 'non') return 'non';
    if (lower == 'true' || lower == '1' || lower == 'yes' || lower == 'oui') return 'oui';
    // Mappage de termes anglais courants -> français
    final translations = <String, String>{
      'free': 'gratuit',
      'paid': 'payant',
      'open': 'ouvert',
      'closed': 'fermé',
      'pending': 'en attente',
      'cancelled': 'annulé',
      'canceled': 'annulé',
      'confirmed': 'confirmé',
      'online': 'en ligne',
      'offline': 'sur place',
      'english': 'anglais',
      'french': 'français',
      'spanish': 'espagnol',
      'german': 'allemand',
      'all_ages': 'tous les âges',
      'alll_ages': 'tous les âges',
    };
    if (translations.containsKey(lower)) {
      return translations[lower]!;
    }
    return value;
  }

  Widget _buildValueWithOptionalPhoneLink(String label, String rawValue) {
    final value = _formatDisplayValue(rawValue);
    if (value.isEmpty) return const SizedBox.shrink();
    final isPhone = _isPhoneLabel(label) || _looksLikePhone(rawValue);
    if (!isPhone) {
      return Text(
        value,
        style: const TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14,
          color: Color(0xFF2D3748),
        ),
      );
    }
    return InkWell(
      onTap: () => _launchPhone(rawValue),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.phone, size: 16, color: Color(0xFF3182CE)),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14,
              color: Color(0xFF3182CE),
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  bool _isPhoneLabel(String label) {
    final l = label.toLowerCase();
    return l.contains('téléphone') || l.contains('phone') || l.contains('tel');
  }

  bool _looksLikePhone(String value) {
    final v = value.replaceAll(RegExp(r'[^0-9+]+'), '');
    return RegExp(r'^\+?[0-9]{6,}$').hasMatch(v);
  }

  Future<void> _launchPhone(String value) async {
    final normalized = value.replaceAll(RegExp(r'[^0-9+]+'), '');
    final uri = Uri.parse('tel:$normalized');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir l\'application téléphone'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addToCalendar() async {
    try {
      if (_event == null) return;
      
      final title = _event!['title'] ?? 'Événement';
      final description = _event!['description'] ?? '';
      final location = _event!['location'] ?? _event!['venue'] ?? '';
      
      // Parser la date et l'heure
      DateTime? startDate;
      final dateString = _getEventDate();
      final timeString = _getEventTime();
      
      if (dateString.isNotEmpty && timeString != 'Non défini') {
        try {
          final dateParts = dateString.split('/');
          final timeParts = timeString.split(':');
          
          if (dateParts.length == 3 && timeParts.length >= 2) {
            startDate = DateTime(
              int.parse(dateParts[2]), // année
              int.parse(dateParts[1]), // mois
              int.parse(dateParts[0]), // jour
              int.parse(timeParts[0]), // heure
              int.parse(timeParts[1]), // minute
            );
          }
        } catch (e) {
          print('❌ [EventDetailUnified] Erreur parsing date/heure: $e');
        }
      }
      
      startDate ??= DateTime.now();
      
      // Créer un événement de calendrier (URL scheme)
      final calendarUrl = 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=${Uri.encodeComponent(title)}&dates=${startDate.toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.')[0]}Z/${startDate.add(const Duration(hours: 2)).toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.')[0]}Z&details=${Uri.encodeComponent(description)}&location=${Uri.encodeComponent(location)}';
      
      await launchUrl(Uri.parse(calendarUrl), mode: LaunchMode.externalApplication);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ouverture du calendrier...'),
            backgroundColor: Color(0xFFF4D03F),
          ),
        );
      }
    } catch (e) {
      print('❌ [EventDetailUnified] Erreur calendrier: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le calendrier'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  


}