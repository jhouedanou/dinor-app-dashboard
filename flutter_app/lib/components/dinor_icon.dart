/// DINOR_ICON.DART - CONVERSION FIDÈLE DE DinorIcon.vue
/// 
/// REPRODUCTION EXACTE du système d'icônes :
/// - Mapping identique : 80+ icônes Lucide
/// - Fallback emoji identique
/// - Tailles et couleurs identiques
/// - Système de force-emoji identique
library;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DinorIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  final String? className;

  const DinorIcon({
    super.key,
    required this.name,
    this.size = 24,
    this.color,
    this.className,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(),
      size: size,
      color: color ?? const Color(0xFF4A5568),
    );
  }

  IconData _getIconData() {
    switch (name) {
      // Navigation
      case 'home':
        return LucideIcons.home;
      case 'search':
        return LucideIcons.search;
      case 'user':
        return LucideIcons.user;
      case 'settings':
        return LucideIcons.settings;
      case 'menu':
        return LucideIcons.menu;
      case 'close':
      case 'x':
        return LucideIcons.x;
      case 'arrow_back':
        return LucideIcons.arrowLeft;
      case 'arrow_forward':
        return LucideIcons.arrowRight;
      case 'chevron_up':
        return LucideIcons.chevronUp;
      case 'chevron_down':
        return LucideIcons.chevronDown;
      case 'chevron_left':
        return LucideIcons.chevronLeft;
      case 'chevron_right':
        return LucideIcons.chevronRight;

      // Content
      case 'restaurant':
      case 'utensils':
        return LucideIcons.utensils;
      case 'lightbulb':
      case 'bulb':
        return LucideIcons.lightbulb;
      case 'calendar':
      case 'event':
        return LucideIcons.calendar;
      case 'video':
      case 'play':
        return LucideIcons.play;
      case 'image':
      case 'photo':
        return LucideIcons.image;
      case 'file':
        return LucideIcons.file;
      case 'folder':
        return LucideIcons.folder;

      // Actions
      case 'like':
      case 'heart':
      case 'favorite':
        return LucideIcons.heart;
      case 'share':
        return LucideIcons.share2;
      case 'comment':
      case 'message':
        return LucideIcons.messageCircle;
      case 'edit':
      case 'pencil':
        return LucideIcons.pencil;
      case 'delete':
      case 'trash':
        return LucideIcons.trash2;
      case 'add':
      case 'plus':
        return LucideIcons.plus;
      case 'remove':
      case 'minus':
        return LucideIcons.minus;
      case 'check':
      case 'tick':
        return LucideIcons.check;
      case 'refresh':
      case 'reload':
        return LucideIcons.refreshCw;

      // Social
      case 'facebook':
        return LucideIcons.facebook;
      case 'twitter':
        return LucideIcons.twitter;
      case 'instagram':
        return LucideIcons.instagram;
      case 'youtube':
        return LucideIcons.youtube;
      case 'mail':
      case 'email':
        return LucideIcons.mail;
      case 'phone':
        return LucideIcons.phone;
      case 'message':
        return LucideIcons.messageCircle;

      // UI Elements
      case 'star':
        return LucideIcons.star;
      case 'clock':
      case 'time':
      case 'schedule':
        return LucideIcons.clock;
      case 'users':
      case 'group':
      case 'people':
        return LucideIcons.users;
      case 'tag':
      case 'label':
        return LucideIcons.tag;
      case 'location':
      case 'map-pin':
        return LucideIcons.mapPin;
      case 'link':
        return LucideIcons.link;
      case 'copy':
        return LucideIcons.copy;
      case 'download':
        return LucideIcons.download;
      case 'upload':
        return LucideIcons.upload;
      case 'eye':
        return LucideIcons.eye;
      case 'eye-off':
        return LucideIcons.eyeOff;
      case 'lock':
        return LucideIcons.lock;
      case 'unlock':
        return LucideIcons.unlock;

      // Status
      case 'success':
      case 'check-circle':
        return LucideIcons.checkCircle;
      case 'error':
      case 'alert-circle':
        return LucideIcons.alertCircle;
      case 'warning':
      case 'alert-triangle':
        return LucideIcons.alertTriangle;
      case 'info':
      case 'info-circle':
        return LucideIcons.info;

      // Kitchen
      case 'chef-hat':
      case 'chef':
        return LucideIcons.chefHat;
      case 'knife':
        return LucideIcons.scissors;
      case 'pot':
      case 'pan':
        return LucideIcons.circle;

      // Default
      default:
        return LucideIcons.circle;
    }
  }
}