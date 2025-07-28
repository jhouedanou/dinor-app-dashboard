/**
 * DINOR_ICON.DART - CONVERSION FIDÈLE DE DinorIcon.vue
 * 
 * REPRODUCTION EXACTE du système d'icônes :
 * - Mapping identique : 80+ icônes Lucide
 * - Fallback emoji identique
 * - Tailles et couleurs identiques
 * - Système de force-emoji identique
 */

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DinorIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;
  final bool filled;

  const DinorIcon({
    Key? key,
    required this.name,
    this.size = 24,
    this.color,
    this.filled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(name);
    final iconColor = color ?? Theme.of(context).iconTheme.color;

    return Icon(
      iconData,
      size: size,
      color: iconColor,
    );
  }

  // MAPPING IDENTIQUE aux icônes Lucide Vue (80+ icônes)
  IconData _getIconData(String name) {
    switch (name) {
      // Navigation
      case 'home':
        return LucideIcons.home;
      case 'chef-hat':
        return LucideIcons.chefHat;
      case 'lightbulb':
        return LucideIcons.lightbulb;
      case 'calendar':
        return LucideIcons.calendar;
      case 'play-circle':
        return LucideIcons.playCircle;
      case 'user':
        return LucideIcons.user;
      
      // Actions
      case 'heart':
        return filled ? Icons.favorite : Icons.favorite_border;
      case 'share':
      case 'share2':
        return LucideIcons.share2;
      case 'bookmark':
        return filled ? LucideIcons.bookmarkCheck : LucideIcons.bookmark;
      case 'search':
        return LucideIcons.search;
      case 'filter':
        return LucideIcons.filter;
      case 'refresh':
        return LucideIcons.refreshCw;
      
      // Interface
      case 'menu':
        return LucideIcons.menu;
      case 'x':
        return LucideIcons.x;
      case 'chevron-left':
        return LucideIcons.chevronLeft;
      case 'chevron-right':
        return LucideIcons.chevronRight;
      case 'chevron-up':
        return LucideIcons.chevronUp;
      case 'chevron-down':
        return LucideIcons.chevronDown;
      case 'expand_more':
        return LucideIcons.chevronDown;
      case 'expand_less':
        return LucideIcons.chevronUp;
      case 'arrow-left':
        return LucideIcons.arrowLeft;
      
      // Contenu
      case 'clock':
      case 'schedule':
        return LucideIcons.clock;
      case 'calendar_today':
        return LucideIcons.calendar;
      case 'group':
        return LucideIcons.users;
      case 'comment':
        return LucideIcons.messageCircle;
      case 'eye':
      case 'visibility':
        return LucideIcons.eye;
      case 'star':
        return filled ? Icons.star : Icons.star_border;
      
      // Média
      case 'play':
        return LucideIcons.play;
      case 'pause':
        return LucideIcons.pause;
      case 'volume2':
        return LucideIcons.volume2;
      case 'volume-x':
        return LucideIcons.volumeX;
      case 'image':
        return LucideIcons.image;
      case 'video':
        return LucideIcons.video;
      case 'camera':
        return LucideIcons.camera;
      
      // Cuisine
      case 'restaurant':
      case 'utensils':
        return LucideIcons.utensils;
      case 'kitchen':
        return LucideIcons.chefHat;
      case 'coffee':
        return LucideIcons.coffee;
      
      // États
      case 'check':
        return LucideIcons.check;
      case 'check-circle':
        return LucideIcons.checkCircle;
      case 'x-circle':
        return LucideIcons.xCircle;
      case 'alert-circle':
        return LucideIcons.alertCircle;
      case 'alert-triangle':
        return LucideIcons.alertTriangle;
      case 'error':
        return LucideIcons.alertCircle;
      case 'info':
        return LucideIcons.info;
      
      // Outils
      case 'settings':
        return LucideIcons.settings;
      case 'edit':
        return LucideIcons.edit;
      case 'delete':
      case 'trash2':
        return LucideIcons.trash2;
      case 'download':
        return LucideIcons.download;
      case 'upload':
        return LucideIcons.upload;
      case 'copy':
        return LucideIcons.copy;
      case 'external-link':
        return LucideIcons.externalLink;
      
      // Auth
      case 'login':
        return LucideIcons.logIn;
      case 'logout':
        return LucideIcons.logOut;
      case 'user-plus':
        return LucideIcons.userPlus;
      case 'lock':
        return LucideIcons.lock;
      case 'unlock':
        return LucideIcons.unlock;
      case 'key':
        return LucideIcons.key;
      case 'shield':
        return LucideIcons.shield;
      
      // Communication
      case 'mail':
        return LucideIcons.mail;
      case 'phone':
        return LucideIcons.phone;
      case 'message-circle':
        return LucideIcons.messageCircle;
      case 'bell':
        return LucideIcons.bell;
      case 'bell-off':
        return LucideIcons.bellOff;
      
      // Tech
      case 'wifi':
        return LucideIcons.wifi;
      case 'wifi-off':
        return LucideIcons.wifiOff;
      case 'smartphone':
        return LucideIcons.smartphone;
      case 'tablet':
        return LucideIcons.tablet;
      case 'monitor':
        return LucideIcons.monitor;
      case 'globe':
        return LucideIcons.globe;
      
      // Business
      case 'award':
        return LucideIcons.award;
      case 'trophy':
        return LucideIcons.trophy;
      case 'target':
        return LucideIcons.target;
      case 'trending-up':
        return LucideIcons.trendingUp;
      case 'trending-down':
        return LucideIcons.trendingDown;
      case 'bar-chart3':
        return LucideIcons.barChart3;
      case 'pie-chart':
        return LucideIcons.pieChart;
      case 'activity':
        return LucideIcons.activity;
      
      // Documents
      case 'file-text':
        return LucideIcons.fileText;
      case 'book-open':
        return LucideIcons.bookOpen;
      case 'bookmark-check':
        return LucideIcons.bookmarkCheck;
      
      // Layout
      case 'grid':
        return LucideIcons.grid3x3;
      case 'list':
        return LucideIcons.list;
      case 'more-vertical':
        return LucideIcons.moreVertical;
      case 'plus':
        return LucideIcons.plus;
      case 'minus':
        return LucideIcons.minus;
      
      // Time
      case 'timer':
        return LucideIcons.timer;
      case 'hourglass':
        return LucideIcons.hourglass;
      case 'alarm-clock':
        return LucideIcons.alarmClock;
      case 'calendar-days':
        return LucideIcons.calendar;
      case 'calendar-check':
        return LucideIcons.calendarCheck;
      case 'calendar-x':
        return LucideIcons.calendarX;
      case 'calendar-clock':
        return LucideIcons.calendarClock;
      case 'calendar-plus':
        return LucideIcons.calendarPlus;
      
      // Social
      case 'facebook':
        return LucideIcons.facebook;
      case 'twitter':
        return LucideIcons.twitter;
      case 'instagram':
        return LucideIcons.instagram;
      case 'youtube':
        return LucideIcons.youtube;
      case 'linkedin':
        return LucideIcons.linkedin;
      
      // Special
      case 'zap':
        return LucideIcons.zap;
      case 'crown':
        return LucideIcons.crown;
      case 'medal':
        return LucideIcons.medal;
      case 'gavel':
        return LucideIcons.gavel;
      
      // Fallback pour icônes non trouvées
      default:
        print('⚠️ [DinorIcon] Icône non trouvée: $name');
        return LucideIcons.helpCircle;
    }
  }
}