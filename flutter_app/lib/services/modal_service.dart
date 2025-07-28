/**
 * MODAL_SERVICE.DART - SERVICE DE MODAL CUSTOM SANS GOROUTER
 * 
 * Système de modal sûr qui utilise GlobalKey et évite les problèmes
 * de contexte avec GoRouter. Remplace showDialog par un système custom.
 */

import 'package:flutter/material.dart';
import 'navigation_service.dart';

class ModalService {
  static OverlayEntry? _currentModal;
  static final List<OverlayEntry> _modalStack = [];
  
  // Afficher une modal custom
  static void showModal({
    required Widget child,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
    VoidCallback? onDismiss,
  }) {
    final context = NavigationService.context;
    if (context == null) {
      print('❌ [ModalService] Contexte non disponible pour afficher la modal');
      return;
    }
    
    final overlay = Overlay.of(context);
    
    final overlayEntry = OverlayEntry(
      builder: (context) => _ModalWrapper(
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        onDismiss: () {
          dismissModal();
          onDismiss?.call();
        },
        child: child,
      ),
    );
    
    overlay.insert(overlayEntry);
    _modalStack.add(overlayEntry);
    _currentModal = overlayEntry;
    
    print('✅ [ModalService] Modal affichée');
  }
  
  // Fermer la modal actuelle
  static void dismissModal() {
    if (_modalStack.isNotEmpty) {
      final modal = _modalStack.removeLast();
      modal.remove();
      _currentModal = _modalStack.isNotEmpty ? _modalStack.last : null;
      print('✅ [ModalService] Modal fermée');
    }
  }
  
  // Fermer toutes les modals
  static void dismissAllModals() {
    for (final modal in _modalStack) {
      modal.remove();
    }
    _modalStack.clear();
    _currentModal = null;
    print('✅ [ModalService] Toutes les modals fermées');
  }
  
  // Vérifier si une modal est ouverte
  static bool get hasModal => _modalStack.isNotEmpty;
  
  // Afficher une modal d'authentification
  static void showAuthModal({
    String message = '',
    VoidCallback? onClose,
    VoidCallback? onAuthenticated,
  }) {
    showModal(
      child: _AuthModalContent(
        message: message,
        onClose: () {
          dismissModal();
          onClose?.call();
        },
        onAuthenticated: () {
          dismissModal();
          onAuthenticated?.call();
        },
      ),
    );
  }
  
  // Afficher une modal de partage
  static void showShareModal({
    required Map<String, dynamic> shareData,
    VoidCallback? onClose,
  }) {
    showModal(
      child: _ShareModalContent(
        shareData: shareData,
        onClose: () {
          dismissModal();
          onClose?.call();
        },
      ),
    );
  }
  
  // Afficher une modal de confirmation
  static void showConfirmationModal({
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    showModal(
      child: _ConfirmationModalContent(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {
          dismissModal();
          onConfirm?.call();
        },
        onCancel: () {
          dismissModal();
          onCancel?.call();
        },
      ),
    );
  }
}

// Widget wrapper pour les modals
class _ModalWrapper extends StatelessWidget {
  final Widget child;
  final Color barrierColor;
  final bool barrierDismissible;
  final VoidCallback onDismiss;
  
  const _ModalWrapper({
    required this.child,
    required this.barrierColor,
    required this.barrierDismissible,
    required this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Barrier
          GestureDetector(
            onTap: barrierDismissible ? onDismiss : null,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: barrierColor,
            ),
          ),
          // Modal content
          Center(child: child),
        ],
      ),
    );
  }
}

// Contenu de la modal d'authentification
class _AuthModalContent extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final VoidCallback onAuthenticated;
  
  const _AuthModalContent({
    required this.message,
    required this.onClose,
    required this.onAuthenticated,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 48,
            color: Color(0xFFE53E3E),
          ),
          const SizedBox(height: 16),
          const Text(
            'Authentification requise',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onClose,
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: Color(0xFF718096),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAuthenticated,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Contenu de la modal de partage
class _ShareModalContent extends StatelessWidget {
  final Map<String, dynamic> shareData;
  final VoidCallback onClose;
  
  const _ShareModalContent({
    required this.shareData,
    required this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.share,
            size: 48,
            color: Color(0xFFE53E3E),
          ),
          const SizedBox(height: 16),
          Text(
            'Partager ${shareData['title'] ?? 'ce contenu'}',
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // TODO: Implémenter les options de partage
          const Text(
            'Options de partage à implémenter',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Fermer',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Contenu de la modal de confirmation
class _ConfirmationModalContent extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  
  const _ConfirmationModalContent({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF4A5568),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      color: Color(0xFF718096),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53E3E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}