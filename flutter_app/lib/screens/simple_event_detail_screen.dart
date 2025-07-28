import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/navigation_service.dart';

class SimpleEventDetailScreen extends StatefulWidget {
  final String id;
  
  const SimpleEventDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<SimpleEventDetailScreen> createState() => _SimpleEventDetailScreenState();
}

class _SimpleEventDetailScreenState extends State<SimpleEventDetailScreen> {
  Map<String, dynamic>? event;
  bool isLoading = true;
  String? error;
  bool isInterested = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    try {
      print('🔄 [EventDetail] Chargement de l\'événement ${widget.id}...');
      
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api/v1/events/${widget.id}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📡 [EventDetail] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [EventDetail] Data reçue: ${data.toString().substring(0, 100)}...');
        
        setState(() {
          event = data['data'];
          isLoading = false;
          error = null;
        });
        
        print('📅 [EventDetail] Événement chargé: ${event?['title']}');
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [EventDetail] Erreur: $e');
      setState(() {
        isLoading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38A169)),
              ),
              SizedBox(height: 16),
              Text(
                'Chargement de l\'événement...',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Color(0xFF4A5568),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null || event == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Erreur'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
            onPressed: () => NavigationService.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Color(0xFF38A169),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Événement introuvable',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error ?? 'Cet événement n\'existe pas ou plus.',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    color: Color(0xFF4A5568),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => NavigationService.pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38A169),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final title = event!['title'] ?? event!['name'] ?? 'Événement';
    final description = event!['description'] ?? event!['excerpt'] ?? '';
    final location = event!['location'] ?? event!['venue'] ?? 'Lieu à définir';
    final date = event!['date'] ?? event!['start_date'] ?? event!['event_date'];
    final time = event!['time'] ?? event!['start_time'] ?? '';
    final price = event!['price'] ?? event!['cost'] ?? 'Gratuit';
    final imageUrl = event!['image'] ?? event!['featured_image'] ?? event!['thumbnail'];
    final organizer = event!['organizer'] ?? event!['host'] ?? 'Dinor';

    return CustomScrollView(
      slivers: [
        // App Bar avec image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFF38A169),
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
              onPressed: () => NavigationService.pop(),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isInterested ? Icons.bookmark : Icons.bookmark_border,
                  color: isInterested ? const Color(0xFF38A169) : const Color(0xFF2D3748),
                ),
                onPressed: () {
                  setState(() {
                    isInterested = !isInterested;
                  });
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.share, color: Color(0xFF2D3748)),
                onPressed: () {
                  // TODO: Implémenter le partage
                },
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF38A169), Color(0xFF2F855A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.event,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF38A169), Color(0xFF2F855A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.event,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ),
        
        // Contenu
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et informations principales
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge événement
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF38A169).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event,
                              size: 16,
                              color: Color(0xFF38A169),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Événement',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF38A169),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Titre
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                          height: 1.2,
                        ),
                      ),
                      
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            color: Color(0xFF4A5568),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Informations de l'événement
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF38A169).withOpacity(0.1),
                        const Color(0xFF2F855A).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF38A169).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildEventInfo(Icons.schedule, 'Date et heure', '$date${time.isNotEmpty ? ' à $time' : ''}'),
                      const Divider(height: 24, color: Color(0xFFE2E8F0)),
                      _buildEventInfo(Icons.location_on, 'Lieu', location),
                      const Divider(height: 24, color: Color(0xFFE2E8F0)),
                      _buildEventInfo(Icons.person, 'Organisateur', organizer),
                      const Divider(height: 24, color: Color(0xFFE2E8F0)),
                      _buildEventInfo(Icons.attach_money, 'Prix', price),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Boutons d'action
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implémenter l'inscription
                          },
                          icon: const Icon(Icons.event_available),
                          label: const Text('S\'inscrire'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF38A169),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implémenter l'ajout au calendrier
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Calendrier'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF38A169),
                          side: const BorderSide(color: Color(0xFF38A169)),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Section description détaillée
                if (description.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 24,
                              color: Color(0xFF38A169),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'À propos de cet événement',
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            _cleanHtmlContent(description),
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Color(0xFF2D3748),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF38A169).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF38A169),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF718096),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _cleanHtmlContent(String content) {
    return content
        .replaceAll(RegExp(r'<[^>]*>'), '') // Supprimer les balises HTML
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}