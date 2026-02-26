import 'package:flutter/material.dart';
import 'dart:io';

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Afficher seulement sur macOS/desktop
    if (!Platform.isMacOS) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Mode hors ligne - Données de démonstration affichées',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}