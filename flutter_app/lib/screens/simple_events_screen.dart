import 'package:flutter/material.dart';

import '../services/navigation_service.dart';
import '../components/common/unified_content_list.dart';
import '../components/common/content_item_card.dart';

class SimpleEventsScreen extends StatefulWidget {
  const SimpleEventsScreen({super.key});

  @override
  State<SimpleEventsScreen> createState() => _SimpleEventsScreenState();
}

class _SimpleEventsScreenState extends State<SimpleEventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header secondaire collé sans espace
          Container(
            width: double.infinity,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
                  onPressed: () => NavigationService.pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Événements',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Pour équilibrer le bouton retour
              ],
            ),
          ),
          // Contenu principal
          Expanded(
            child: UnifiedContentList(
              contentType: 'event',
              apiEndpoint: 'https://new.dinorapp.com/api/v1/events',
              itemsPerPage: 3,
              enableSearch: true,
              enableFilters: true,
              useGridView: false,
              enableInfiniteScroll: true,
              itemBuilder: (item) => ContentItemCard(
                contentType: 'event',
                item: item,
                onTap: () => _navigateToEventDetail(item['id']?.toString() ?? ''),
                compact: false,
              ),
              titleExtractor: (item) => item['title']?.toString() ?? '',
              imageExtractor: (item) => item['image']?.toString() ?? item['thumbnail']?.toString() ?? '',
              descriptionExtractor: (item) => item['description']?.toString() ?? '',
              onItemTap: (item) => () => _navigateToEventDetail(item['id']?.toString() ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEventDetail(String eventId) {
    if (eventId.isNotEmpty) {
      NavigationService.pushNamed('/event-detail-unified/$eventId');
    }
  }
}