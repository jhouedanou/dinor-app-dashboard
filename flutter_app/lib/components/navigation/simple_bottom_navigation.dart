import 'package:flutter/material.dart';
import '../../services/navigation_service.dart';

class SimpleBottomNavigation extends StatefulWidget {
  const SimpleBottomNavigation({Key? key}) : super(key: key);

  @override
  State<SimpleBottomNavigation> createState() => _SimpleBottomNavigationState();
}

class _SimpleBottomNavigationState extends State<SimpleBottomNavigation> {
  String _currentRoute = '/';
  
  // Menu statique
  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'home',
      'path': '/',
      'icon': Icons.home,
      'label': 'Accueil',
    },
    {
      'name': 'recipes',
      'path': '/recipes',
      'icon': Icons.restaurant,
      'label': 'Recettes',
    },
    {
      'name': 'tips',
      'path': '/tips',
      'icon': Icons.lightbulb,
      'label': 'Astuces',
    },
    {
      'name': 'events',
      'path': '/events',
      'icon': Icons.calendar_today,
      'label': 'Événements',
    },
    {
      'name': 'dinor-tv',
      'path': '/dinor-tv',
      'icon': Icons.play_circle,
      'label': 'DinorTV',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Écouter les changements de route
    NavigationService.addRouteChangeListener(_onRouteChanged);
    _currentRoute = NavigationService.currentRoute;
  }

  @override
  void dispose() {
    NavigationService.removeRouteChangeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged(String newRoute) {
    if (mounted) {
      setState(() {
        _currentRoute = newRoute;
      });
      print('🧭 [BottomNav] Route changée: $_currentRoute');
    }
  }

  void _handleItemClick(Map<String, dynamic> item) {
    final path = item['path'] as String;
    print('🎯 [BottomNav] Navigation vers: $path');
    
    if (path == '/') {
      NavigationService.pushNamedAndClearStack('/');
    } else {
      NavigationService.pushNamed(path);
    }
  }

  bool _isActive(Map<String, dynamic> item) {
    final path = item['path'] as String;
    if (path == '/') {
      return _currentRoute == '/';
    }
    return _currentRoute == path || _currentRoute.startsWith(path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: Color(0xFFF4D03F), // Fond doré Dinor
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 4,
            color: Color.fromRGBO(0, 0, 0, 0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _menuItems.map((item) => _buildNavItem(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(Map<String, dynamic> item) {
    final isActive = _isActive(item);
    final icon = item['icon'] as IconData;
    final label = item['label'] as String;

    return GestureDetector(
      onTap: () => _handleItemClick(item),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Icon(
              icon,
              size: 24,
              color: isActive 
                ? const Color(0xFFFF6B35) // Orange actif
                : const Color(0xFF2D3748), // Gris inactif
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive 
                  ? const Color(0xFFFF6B35) // Orange actif
                  : const Color(0xFF2D3748), // Gris inactif
              ),
              textAlign: TextAlign.center,
            ),
            // Indicateur actif
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 24,
                height: 2,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}