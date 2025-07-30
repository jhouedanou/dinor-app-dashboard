import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

import 'like_button.dart';

class UnifiedContentActions extends StatelessWidget {
  final String contentType;
  final String contentId;
  final String title;
  final String description;
  final String shareUrl;
  final String? imageUrl;
  final bool initialLiked;
  final int initialLikeCount;
  final VoidCallback? onAuthRequired;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const UnifiedContentActions({
    super.key,
    required this.contentType,
    required this.contentId,
    required this.title,
    required this.description,
    required this.shareUrl,
    this.imageUrl,
    this.initialLiked = false,
    this.initialLikeCount = 0,
    this.onAuthRequired,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    print('❤️  [LikeButton] Building for: $contentType, ID: $contentId');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Like Button
          Expanded(
            child: LikeButton(
              type: contentType,
              itemId: contentId,
              initialLiked: initialLiked,
              initialCount: initialLikeCount,
              showCount: true,
              size: 'medium',
              onAuthRequired: onAuthRequired,
            ),
          ),
          
          const SizedBox(width: 12),

          // Refresh Button
          if (onRefresh != null)
            IconButton(
              onPressed: isLoading ? null : onRefresh,
              icon: Icon(
                LucideIcons.refreshCw,
                size: 20,
                color: isLoading ? Colors.grey : const Color(0xFF49454F),
              ),
              tooltip: 'Actualiser les données',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF8F9FA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(12),
              ),
            ),

          const SizedBox(width: 8),

          // Share Button
          IconButton(
            onPressed: () => {}, // La logique est maintenant dans le FAB
            icon: const Icon(
              LucideIcons.share,
              size: 20,
              color: Color(0xFF49454F),
            ),
            tooltip: 'Partager ce contenu',
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF8F9FA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }


}

class UnifiedContentActionBar extends StatelessWidget {
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  const UnifiedContentActionBar({
    super.key,
    required this.actions,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: backgroundColor != null ? BoxDecoration(
        color: backgroundColor,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ) : null,
      child: Row(
        children: actions.map((action) => 
          actions.indexOf(action) == actions.length - 1 
            ? action 
            : Expanded(child: action)
        ).toList(),
      ),
    );
  }
}