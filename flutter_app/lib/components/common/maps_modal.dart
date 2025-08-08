import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MapsModal extends StatefulWidget {
  final String location;

  const MapsModal({
    super.key,
    required this.location,
  });

  @override
  State<MapsModal> createState() => _MapsModalState();
}

class _MapsModalState extends State<MapsModal> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  String? errorMessage;

  String get mapsUrl {
    final encodedLocation = Uri.encodeComponent(widget.location);
    // Utiliser Google Maps standard dans une WebView - plus compatible
    return 'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
        child: Column(
          children: [
            // Header avec titre et bouton fermer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4D03F).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.mapPin,
                    size: 20,
                    color: const Color(0xFFF4D03F),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Localisation',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.location,
                          style: const TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton ouvrir dans Maps externe
                  IconButton(
                    onPressed: _openExternalMaps,
                    icon: Icon(
                      LucideIcons.externalLink,
                      size: 18,
                      color: const Color(0xFF3182CE),
                    ),
                    tooltip: 'Ouvrir dans Maps',
                  ),
                  // Bouton fermer
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: const Color(0xFF718096),
                    ),
                    tooltip: 'Fermer',
                  ),
                ],
              ),
            ),
            
            // WebView avec Google Maps
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(mapsUrl),
                      ),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          useShouldOverrideUrlLoading: true,
                          mediaPlaybackRequiresUserGesture: false,
                          transparentBackground: true,
                        ),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                          domStorageEnabled: true,
                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                        ),
                      ),
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                      },
                      onLoadStop: (controller, url) async {
                        setState(() {
                          isLoading = false;
                        });
                      },
                      onReceivedError: (controller, request, error) {
                        setState(() {
                          isLoading = false;
                          errorMessage = 'Erreur de chargement de la carte';
                        });
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        // Permettre la navigation dans Google Maps
                        return NavigationActionPolicy.ALLOW;
                      },
                    ),
                    
                    // Indicateur de chargement
                    if (isLoading)
                      Container(
                        color: Colors.white,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFFF4D03F),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Chargement de la carte...',
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 14,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Message d'erreur
                    if (errorMessage != null)
                      Container(
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                size: 48,
                                color: const Color(0xFF718096),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMessage!,
                                style: const TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 16,
                                  color: Color(0xFF718096),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _openExternalMaps,
                                icon: Icon(
                                  LucideIcons.externalLink,
                                  size: 16,
                                ),
                                label: const Text('Ouvrir dans Maps'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF4D03F),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternalMaps() async {
    try {
      await InAppBrowser.openWithSystemBrowser(
        url: WebUri(mapsUrl),
      );
      
      print('📍 [MapsModal] Ouverture Maps externe: ${widget.location}');
    } catch (e) {
      print('❌ [MapsModal] Erreur ouverture Maps externe: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'ouvrir Maps: ${widget.location}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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