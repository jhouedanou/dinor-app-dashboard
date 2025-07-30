import 'package:flutter/material.dart';

import '../services/navigation_service.dart';
import '../components/common/unified_content_list.dart';
import '../components/common/content_item_card.dart';

class SimpleEventsScreen extends StatefulWidget {
  const SimpleEventsScreen({Key? key}) : super(key: key);

  @override
  State<SimpleEventsScreen> createState() => _SimpleEventsScreenState();
}

class _SimpleEventsScreenState extends State<SimpleEventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Événements',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => NavigationService.pop(),
        ),
      ),
      body: UnifiedContentList(
        contentType: 'event',
        apiEndpoint: 'https://new.dinorapp.com/api/v1/events',
        itemsPerPage: 4,
        enableSearch: true,
        enableFilters: true,
        useGridView: false,
        itemBuilder: (item) => ContentItemCard(
          contentType: 'event',
          item: item,
          onTap: () => _navigateToEventDetail(item['id']?.toString() ?? ''),
        ),
        titleExtractor: (item) => item['title']?.toString() ?? '',
        imageExtractor: (item) => item['image']?.toString() ?? item['thumbnail']?.toString() ?? '',
        descriptionExtractor: (item) => item['description']?.toString() ?? '',
        onItemTap: (item) => () => _navigateToEventDetail(item['id']?.toString() ?? ''),
      ),
    );
  }

  void _navigateToEventDetail(String eventId) {
    if (eventId.isNotEmpty) {
      NavigationService.pushNamed('/event-detail-unified/$eventId');
    }
  }
}