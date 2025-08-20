import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'image_cache_service.dart';

class SplashScreenService {
  static const String _endpoint = '/v1/splash-screen/active';
  
  /// Configuration par défaut du splash screen
  static const Map<String, dynamic> _defaultConfig = {
    'is_active': true,
    'title': '',
    'subtitle': '',
    'duration': 2500,
    'background_type': 'gradient',
    'background_color_start': '#E53E3E',
    'background_color_end': '#C53030',
    'background_gradient_direction': 'top_left',
    'logo_type': 'default',
    'logo_size': 80,
    'logo_url': null,
    'text_color': '#FFFFFF',
    'progress_bar_color': '#F4D03F',
    'animation_type': 'default',
    'background_image_url': null,
  };

  /// Récupère la configuration active du splash screen
  static Future<Map<String, dynamic>> getActiveConfig() async {
    try {
      final response = await http.get(
        Uri.parse('https://new.dinorapp.com/api$_endpoint'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('🎨 [SplashScreenService] Réponse API: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final config = Map<String, dynamic>.from(data['data']);
          
          // Précharger l'image de fond en cache si elle existe
          final backgroundImageUrl = config['background_image_url'];
          if (backgroundImageUrl != null && backgroundImageUrl.isNotEmpty) {
            ImageCacheService.cacheImageUrl(backgroundImageUrl).then((_) {
              print('🎨 [SplashScreenService] Image de fond mise en cache');
            });
          }
          
          print('🎨 [SplashScreenService] Configuration récupérée: ${config}');
          return config;
        }
      }
      
      print('⚠️ [SplashScreenService] Utilisation de la configuration par défaut');
      return Map<String, dynamic>.from(_defaultConfig);
      
    } catch (e) {
      print('❌ [SplashScreenService] Erreur API: $e');
      return Map<String, dynamic>.from(_defaultConfig);
    }
  }

  /// Convertit une direction de dégradé depuis l'API vers Flutter
  static AlignmentGeometry getGradientAlignment(String direction, bool isStart) {
    switch (direction) {
      case 'top_left':
        return isStart ? Alignment.topLeft : Alignment.bottomRight;
      case 'top_right':
        return isStart ? Alignment.topRight : Alignment.bottomLeft;
      case 'bottom_left':
        return isStart ? Alignment.bottomLeft : Alignment.topRight;
      case 'bottom_right':
        return isStart ? Alignment.bottomRight : Alignment.topLeft;
      case 'vertical':
        return isStart ? Alignment.topCenter : Alignment.bottomCenter;
      case 'horizontal':
        return isStart ? Alignment.centerLeft : Alignment.centerRight;
      default:
        return isStart ? Alignment.topLeft : Alignment.bottomRight;
    }
  }

  /// Parse une couleur hexadécimale en Color Flutter
  static Color parseColor(String hexColor, {Color fallback = const Color(0xFF000000)}) {
    try {
      String colorString = hexColor.replaceAll('#', '');
      if (colorString.length == 6) {
        colorString = 'FF$colorString'; // Ajouter alpha si manquant
      }
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      print('⚠️ [SplashScreenService] Erreur parsing couleur $hexColor: $e');
      return fallback;
    }
  }
}