import 'package:flutter/material.dart';
import '../../services/navigation_service.dart';
import '../../styles/shadows.dart';

class SimpleBottomNavigation extends StatefulWidget {
  const SimpleBottomNavigation({Key? key}) : super(key: key);

  @override
  State<SimpleBottomNavigation> createState() => _SimpleBottomNavigationState();
}

class _SimpleBottomNavigationState extends State<SimpleBottomNavigation> {
  String _currentRoute = '/';
  bool _isNavigating = false;
  String? _lastPressedItem;
  
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

  // Méthode de sécurité pour réinitialiser l'état de navigation
  void _resetNavigationState() {
    if (mounted) {
      setState(() {
        _isNavigating = false;
        _lastPressedItem = null;
      });
      print('🔄 [BottomNav] État de navigation réinitialisé');
    }
  }

  void _onRouteChanged(String newRoute) {
    if (mounted) {
      setState(() {
        _currentRoute = newRoute;
        // Force reset navigation state when route changes
        _isNavigating = false;
        _lastPressedItem = null;
      });
      print('🧭 [BottomNav] Route changée: $_currentRoute');
    }
  }

  void _handleItemClick(Map<String, dynamic> item) async {
    final path = item['path'] as String;
    final itemName = item['name'] as String;
    
    // Prevent double navigation only, allow same route navigation
    if (_isNavigating) {
      print('🚫 [BottomNav] Already navigating, ignoring: $path');
      return;
    }
    
    print('🎯 [BottomNav] Navigation vers: $path');
    
    // Set navigation state immediately for UI feedback
    setState(() {
      _isNavigating = true;
      _lastPressedItem = itemName;
    });
    
    try {
      // Use pushNamed for normal navigation, pushReplacementNamed only for home
      if (path == '/') {
        await NavigationService.pushNamedAndClearStack('/');
      } else {
        await NavigationService.pushNamed(path);
      }
      
      // Reset navigation state immediately after successful navigation
      if (mounted) {
        setState(() {
          _isNavigating = false;
          _lastPressedItem = null;
        });
      }
    } catch (e) {
      print('❌ [BottomNav] Erreur navigation: $e');
      // Reset navigation state on error
      if (mounted) {
        setState(() {
          _isNavigating = false;
          _lastPressedItem = null;
        });
      }
    }
    
    // Timeout de sécurité pour éviter le blocage
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && _isNavigating) {
        print('⚠️ [BottomNav] Timeout de sécurité - réinitialisation de l\'état');
        _resetNavigationState();
      }
    });
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
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFFF4D03F), // Fond doré Dinor
        boxShadow: AppShadows.softTop,
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
    final itemName = item['name'] as String;
    final isPressed = _lastPressedItem == itemName;

    return GestureDetector(
      onTap: () => _handleItemClick(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône avec animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform: Matrix4.identity()
                ..scale(isPressed ? 0.95 : 1.0),
              child: Icon(
                icon,
                size: 24,
                color: isActive 
                  ? const Color(0xFFFF6B35) // Orange actif
                  : const Color(0xFF2D3748), // Gris inactif
              ),
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
            // Indicateur actif fin sous le label
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 6),
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