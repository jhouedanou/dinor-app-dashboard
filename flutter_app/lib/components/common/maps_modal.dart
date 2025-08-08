import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MapsModal extends StatelessWidget {
  final String location;

  const MapsModal({
    super.key,
    required this.location,
  });

  String get mapsUrl {
    final encodedLocation = Uri.encodeComponent(location);
    return 'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
  }

  String get appleMapsUrl {
    final encodedLocation = Uri.encodeComponent(location);
    return 'http://maps.apple.com/?q=$encodedLocation';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon et titre
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4D03F).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.mapPin,
                  size: 32,
                  color: Color(0xFFF4D03F),
                ),
              ),
              const SizedBox(height: 16),
              
              // Titre
              const Text(
                'Ouvrir la localisation',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Adresse
              Text(
                location,
                style: const TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              
              // Boutons d'action
              Column(
                children: [
                  // Google Maps
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(),
                      icon: const Icon(LucideIcons.map, size: 18),
                      label: const Text('Ouvrir dans Google Maps'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Apple Maps (iOS seulement)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openAppleMaps(),
                      icon: const Icon(LucideIcons.mapPin, size: 18),
                      label: const Text('Ouvrir dans Apple Maps'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Bouton annuler
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Annuler',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: Color(0xFF718096),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps() async {
    try {
      final uri = Uri.parse(mapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('📍 [MapsModal] Ouverture Google Maps: $location');
      } else {
        throw Exception('Impossible d\'ouvrir Google Maps');
      }
    } catch (e) {
      print('❌ [MapsModal] Erreur Google Maps: $e');
      // Fallback vers navigateur web
      _openInBrowser();
    }
  }

  Future<void> _openAppleMaps() async {
    try {
      final uri = Uri.parse(appleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('📍 [MapsModal] Ouverture Apple Maps: $location');
      } else {
        // Fallback vers Google Maps
        _openGoogleMaps();
      }
    } catch (e) {
      print('❌ [MapsModal] Erreur Apple Maps: $e');
      // Fallback vers Google Maps
      _openGoogleMaps();
    }
  }

  Future<void> _openInBrowser() async {
    try {
      final uri = Uri.parse(mapsUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('📍 [MapsModal] Ouverture navigateur: $location');
    } catch (e) {
      print('❌ [MapsModal] Erreur navigateur: $e');
    }
  }
}

// Fonction utilitaire pour afficher la modal
void showMapsModal(BuildContext context, String location) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => MapsModal(location: location),
  );
}