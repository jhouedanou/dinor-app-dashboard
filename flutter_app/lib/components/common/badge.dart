import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Badge extends StatelessWidget {
  final String text;
  final String icon;
  final String variant; // 'primary', 'secondary', 'neutral'
  final String size; // 'small', 'medium', 'large'

  const Badge({
    Key? key,
    required this.text,
    required this.icon,
    this.variant = 'primary',
    this.size = 'medium',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _getPadding(),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconData(),
            size: _getIconSize(),
            color: _getTextColor(),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
              color: _getTextColor(),
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case 'small':
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case 'large':
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      default: // medium
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    }
  }

  double _getBorderRadius() {
    switch (size) {
      case 'small':
        return 8;
      case 'large':
        return 16;
      default: // medium
        return 12;
    }
  }

  double _getIconSize() {
    switch (size) {
      case 'small':
        return 14;
      case 'large':
        return 20;
      default: // medium
        return 16;
    }
  }

  double _getFontSize() {
    switch (size) {
      case 'small':
        return 12;
      case 'large':
        return 16;
      default: // medium
        return 14;
    }
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case 'primary':
        return const Color(0xFFF4D03F);
      case 'secondary':
        return const Color(0xFFFF6B35);
      case 'neutral':
        return Colors.white.withOpacity(0.9);
      default:
        return const Color(0xFFF4D03F);
    }
  }

  Color _getBorderColor() {
    switch (variant) {
      case 'primary':
        return const Color(0xFFE2E8F0);
      case 'secondary':
        return const Color(0xFFFF6B35);
      case 'neutral':
        return const Color(0xFFE2E8F0);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case 'primary':
        return const Color(0xFF2D3748);
      case 'secondary':
        return Colors.white;
      case 'neutral':
        return const Color(0xFF2D3748);
      default:
        return const Color(0xFF2D3748);
    }
  }

  IconData _getIconData() {
    switch (icon) {
      case 'restaurant':
        return LucideIcons.utensils;
      case 'tag':
        return LucideIcons.tag;
      case 'star':
        return LucideIcons.star;
      case 'schedule':
        return LucideIcons.clock;
      case 'heart':
        return LucideIcons.heart;
      case 'message':
        return LucideIcons.messageCircle;
      case 'users':
        return LucideIcons.users;
      case 'chef':
        return LucideIcons.chefHat;
      default:
        return LucideIcons.tag;
    }
  }
} 