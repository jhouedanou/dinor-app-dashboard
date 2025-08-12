<template>
  <component 
    :is="iconComponent"
    :size="size"
    :color="color"
    :stroke-width="strokeWidth"
    :class="iconClass"
    v-bind="$attrs"
  />
</template>

<script setup>
import { computed } from 'vue'

// Mapping des icônes Material vers Lucide + support direct Lucide
const iconMapping = {
  // Navigation
  'home': 'LucideHome',
  'apps': 'LucideHome',
  'restaurant': 'LucideChefHat',
  'chef-hat': 'LucideChefHat',
  'lightbulb': 'LucideLightbulb',
  'event': 'LucideCalendar',
  'calendar': 'LucideCalendar',
  'calendar_today': 'LucideCalendar',
  'play_circle': 'LucidePlayCircle',
  'play-circle': 'LucidePlayCircle',
  'person': 'LucideUser',
  'user': 'LucideUser',
  'arrow_back': 'LucideArrowLeft',
  
  // Actions
  'favorite': 'LucideHeart',
  'favorite_border': 'LucideHeart',
  'share': 'LucideShare2',
  'location_on': 'LucideMapPin',
  'tag': 'LucideTag',
  'category': 'LucideTag',
  'schedule': 'LucideClock',
  'group': 'LucideUsers',
  'info': 'LucideInfo',
  'delete': 'LucideTrash2',
  'calendar_month': 'LucideCalendarPlus',
  'error': 'LucideAlertCircle',
  'expand_less': 'LucideChevronUp',
  'expand_more': 'LucideChevronDown',
  'comment': 'LucideMessageCircle',
  'star': 'LucideStar',
  'settings': 'LucideSettings',
  'menu': 'LucideMenu',
  'close': 'LucideX',
  'search': 'LucideSearch',
  'filter_list': 'LucideFilter',
  'grid_view': 'LucideGrid',
  'list': 'LucideList',
  'more_vert': 'LucideMoreVertical',
  'download': 'LucideDownload',
  'upload': 'LucideUpload',
  'bookmark': 'LucideBookmark',
  'bookmark_added': 'LucideBookmarkCheck',
  'visibility': 'LucideEye',
  'visibility_off': 'LucideEyeOff',
  'add': 'LucidePlus',
  'remove': 'LucideMinus',
  'check': 'LucideCheck',
  'chevron_left': 'LucideChevronLeft',
  'chevron_right': 'LucideChevronRight',
  'fullscreen': 'LucideMaximize2',
  'fullscreen_exit': 'LucideMinimize2',
  'refresh': 'LucideRotateCcw',
  'notifications': 'LucideBell',
  'notifications_off': 'LucideBellOff',
  'mail': 'LucideMail',
  'phone': 'LucidePhone',
  'public': 'LucideGlobe',
  'send': 'LucideSend',
  'content_copy': 'LucideCopy',
  'open_in_new': 'LucideExternalLink',
  'edit': 'LucideEdit',
  'save': 'LucideSave',
  'logout': 'LucideLogOut',
  'login': 'LucideLogIn',
  'person_add': 'LucideUserPlus',
  'verified_user': 'LucideUserCheck',
  'person_remove': 'LucideUserX',
  'security': 'LucideShield',
  'lock': 'LucideLock',
  'lock_open': 'LucideUnlock',
  'key': 'LucideKey',
  'bolt': 'LucideZap',
  'wifi': 'LucideWifi',
  'wifi_off': 'LucideWifiOff',
  'smartphone': 'LucideSmartphone',
  'tablet': 'LucideTablet',
  'computer': 'LucideMonitor',
  'camera': 'LucideCamera',
  'image': 'LucideImage',
  'video': 'LucideVideo',
  'mic': 'LucideMic',
  'volume_up': 'LucideVolume2',
  'volume_off': 'LucideVolumeX',
  'play_arrow': 'LucidePlayCircle',
  'play_circle': 'LucidePlayCircle',
  'pause': 'LucidePauseCircle',
  'stop': 'LucideStopCircle',
  'skip_previous': 'LucideSkipBack',
  'skip_next': 'LucideSkipForward',
  'rotate_right': 'LucideRotateCw',
  'loading': 'LucideLoader',
  'check_circle': 'LucideCheckCircle',
  'cancel': 'LucideXCircle',
  'warning': 'LucideAlertTriangle',
  'help': 'LucideHelpCircle',
  'award': 'LucideAward',
  'trophy': 'LucideTrophy',
  'target': 'LucideTarget',
  'trending_up': 'LucideTrendingUp',
  'trending_down': 'LucideTrendingDown',
  'bar_chart': 'LucideBarChart3',
  'pie_chart': 'LucidePieChart',
  'activity': 'LucideActivity',
  'restaurant_menu': 'LucideUtensils',
  'coffee': 'LucideCoffee',
  'place': 'LucideMapPin',
  'timer': 'LucideTimer',
  'hourglass': 'LucideHourglass',
  'alarm': 'LucideAlarmClock',
  'stopwatch': 'LucideStopwatch',
  'tune': 'LucideSettings',
  'filter_list': 'LucideFilter'
}

const props = defineProps({
  name: {
    type: String,
    required: true
  },
  size: {
    type: [String, Number],
    default: 24
  },
  color: {
    type: String,
    default: 'currentColor'
  },
  strokeWidth: {
    type: [String, Number],
    default: 2
  },
  filled: {
    type: Boolean,
    default: false
  }
})

// Composant d'icône à utiliser avec support des icônes filled
const iconComponent = computed(() => {
  let iconName = props.name
  
  // Si filled est true, utiliser des variantes filled spéciales
  if (props.filled) {
    const filledMapping = {
      'home': 'LucideHome',
      'chef-hat': 'LucideChefHat', 
      'lightbulb': 'LucideLightbulb',
      'calendar': 'LucideCalendar',
      'play-circle': 'LucidePlayCircle',
      'user': 'LucideUser'
    }
    
    if (filledMapping[iconName]) {
      return filledMapping[iconName]
    }
  }
  
  // Vérifier d'abord le mapping
  const mappedIcon = iconMapping[iconName]
  if (mappedIcon) {
    return mappedIcon
  }
  
  // Essayer les noms Lucide directs (convertir kebab-case vers PascalCase)
  const lucideName = 'Lucide' + iconName
    .split('-')
    .map(word => word.charAt(0).toUpperCase() + word.slice(1))
    .join('')
  
  // Pour les icônes du menu, on accepte les noms Lucide directs  
  if (iconName.includes('-') || ['home', 'user', 'calendar', 'lightbulb'].includes(iconName)) {
    return lucideName
  }
  
  // Fallback vers l'icône par défaut
  console.warn(`Icône non mappée: ${iconName}`)
  return 'LucideHelpCircle'
})

// Classes CSS pour l'icône
const iconClass = computed(() => {
  return [
    'dinor-icon',
    `dinor-icon--${props.name}`,
    {
      'dinor-icon--filled': props.filled
    }
  ]
})
</script>

<style scoped>
.dinor-icon {
  display: inline-block;
  vertical-align: middle;
  transition: all 0.2s ease;
}

.dinor-icon--filled {
  fill: currentColor;
  stroke: currentColor;
  stroke-width: 2;
  opacity: 1 !important;
  visibility: visible !important;
  font-weight: 600;
}

.dinor-icon:hover {
  transform: scale(1.1);
}

/* Styles spécifiques pour certaines icônes */
.dinor-icon--favorite {
  color: #E53E3E;
}

.dinor-icon--favorite:not(.dinor-icon--filled) {
  fill: none;
  stroke: #E53E3E;
}

.dinor-icon--star {
  color: #F4D03F;
}

.dinor-icon--location_on {
  color: #E53E3E;
}

.dinor-icon--schedule {
  color: #4A90E2;
}

.dinor-icon--group {
  color: #7B68EE;
}

.dinor-icon--info {
  color: #17A2B8;
}

.dinor-icon--error {
  color: #DC3545;
}

.dinor-icon--check {
  color: #28A745;
}

.dinor-icon--warning {
  color: #FFC107;
}

/* DEBUG: Ensure all icon elements are always visible */
.dinor-icon,
.dinor-icon * {
  opacity: 1 !important;
  visibility: visible !important;
  display: inline-block !important;
}
</style>