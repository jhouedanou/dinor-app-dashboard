import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import App from './App.vue'

// Import Lucide icons - seulement les icônes nécessaires
import { 
  Home, 
  ChefHat, 
  Lightbulb, 
  Calendar, 
  Play, 
  User, 
  ArrowLeft, 
  Heart, 
  Share2, 
  MapPin, 
  Tag, 
  Clock, 
  Users, 
  Info, 
  Trash2, 
  CalendarPlus, 
  AlertCircle,
  ChevronUp,
  ChevronDown,
  MessageCircle,
  Star,
  Settings,
  Menu,
  X,
  Search,
  Filter,
  Grid,
  List,
  MoreVertical,
  Download,
  Upload,
  Bookmark,
  BookmarkCheck,
  Eye,
  EyeOff,
  Plus,
  Minus,
  Check,
  ChevronLeft,
  ChevronRight,
  Maximize2,
  Minimize2,
  RotateCcw,
  Bell,
  BellOff,
  Mail,
  Phone,
  Globe,
  Facebook,
  Twitter,
  Instagram,
  Youtube,
  Linkedin,
  Send,
  Copy,
  ExternalLink,
  Edit,
  Save,
  LogOut,
  LogIn,
  UserPlus,
  UserCheck,
  UserX,
  Shield,
  Lock,
  Unlock,
  Key,
  Zap,
  Wifi,
  WifiOff,
  Smartphone,
  Tablet,
  Monitor,
  Camera,
  Image,
  Video,
  Mic,
  Volume2,
  VolumeX,
  PlayCircle,
  PauseCircle,
  StopCircle,
  SkipBack,
  SkipForward,
  RefreshCw,
  RotateCw,
  Loader,
  CheckCircle,
  XCircle,
  AlertTriangle,
  HelpCircle,
  Award,
  Trophy,
  Target,
  TrendingUp,
  TrendingDown,
  BarChart3,
  PieChart,
  Activity,
  Utensils,
  Coffee,
  Restaurant,
  CalendarDays,
  CalendarCheck,
  CalendarX,
  CalendarClock,
  Timer,
  Hourglass,
  AlarmClock,
  Stopwatch
} from 'lucide-vue-next'

// Import global styles
import './assets/styles/main.scss'

// Importation des stores
import { useAppStore } from './stores/app'

// Import du service OneSignal
import { oneSignalService } from './services/oneSignal'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Register Lucide icons globally
app.component('LucideHome', Home)
app.component('LucideChefHat', ChefHat)
app.component('LucideLightbulb', Lightbulb)
app.component('LucideCalendar', Calendar)
app.component('LucidePlay', Play)
app.component('LucideUser', User)
app.component('LucideArrowLeft', ArrowLeft)
app.component('LucideHeart', Heart)
app.component('LucideShare2', Share2)
app.component('LucideMapPin', MapPin)
app.component('LucideTag', Tag)
app.component('LucideClock', Clock)
app.component('LucideUsers', Users)
app.component('LucideInfo', Info)
app.component('LucideTrash2', Trash2)
app.component('LucideCalendarPlus', CalendarPlus)
app.component('LucideAlertCircle', AlertCircle)
app.component('LucideChevronUp', ChevronUp)
app.component('LucideChevronDown', ChevronDown)
app.component('LucideMessageCircle', MessageCircle)
app.component('LucideStar', Star)
app.component('LucideSettings', Settings)
app.component('LucideMenu', Menu)
app.component('LucideX', X)
app.component('LucideSearch', Search)
app.component('LucideFilter', Filter)
app.component('LucideGrid', Grid)
app.component('LucideList', List)
app.component('LucideMoreVertical', MoreVertical)
app.component('LucideDownload', Download)
app.component('LucideUpload', Upload)
app.component('LucideBookmark', Bookmark)
app.component('LucideBookmarkCheck', BookmarkCheck)
app.component('LucideEye', Eye)
app.component('LucideEyeOff', EyeOff)
app.component('LucidePlus', Plus)
app.component('LucideMinus', Minus)
app.component('LucideCheck', Check)
app.component('LucideChevronLeft', ChevronLeft)
app.component('LucideChevronRight', ChevronRight)
app.component('LucideMaximize2', Maximize2)
app.component('LucideMinimize2', Minimize2)
app.component('LucideRotateCcw', RotateCcw)
app.component('LucideBell', Bell)
app.component('LucideBellOff', BellOff)
app.component('LucideMail', Mail)
app.component('LucidePhone', Phone)
app.component('LucideGlobe', Globe)
app.component('LucideFacebook', Facebook)
app.component('LucideTwitter', Twitter)
app.component('LucideInstagram', Instagram)
app.component('LucideYoutube', Youtube)
app.component('LucideLinkedin', Linkedin)
app.component('LucideSend', Send)
app.component('LucideCopy', Copy)
app.component('LucideExternalLink', ExternalLink)
app.component('LucideEdit', Edit)
app.component('LucideSave', Save)
app.component('LucideLogOut', LogOut)
app.component('LucideLogIn', LogIn)
app.component('LucideUserPlus', UserPlus)
app.component('LucideUserCheck', UserCheck)
app.component('LucideUserX', UserX)
app.component('LucideShield', Shield)
app.component('LucideLock', Lock)
app.component('LucideUnlock', Unlock)
app.component('LucideKey', Key)
app.component('LucideZap', Zap)
app.component('LucideWifi', Wifi)
app.component('LucideWifiOff', WifiOff)
app.component('LucideSmartphone', Smartphone)
app.component('LucideTablet', Tablet)
app.component('LucideMonitor', Monitor)
app.component('LucideCamera', Camera)
app.component('LucideImage', Image)
app.component('LucideVideo', Video)
app.component('LucideMic', Mic)
app.component('LucideVolume2', Volume2)
app.component('LucideVolumeX', VolumeX)
app.component('LucidePlayCircle', PlayCircle)
app.component('LucidePauseCircle', PauseCircle)
app.component('LucideStopCircle', StopCircle)
app.component('LucideSkipBack', SkipBack)
app.component('LucideSkipForward', SkipForward)
app.component('LucideRefreshCw', RefreshCw)
app.component('LucideRotateCw', RotateCw)
app.component('LucideLoader', Loader)
app.component('LucideCheckCircle', CheckCircle)
app.component('LucideXCircle', XCircle)
app.component('LucideAlertTriangle', AlertTriangle)
app.component('LucideHelpCircle', HelpCircle)
app.component('LucideAward', Award)
app.component('LucideTrophy', Trophy)
app.component('LucideTarget', Target)
app.component('LucideTrendingUp', TrendingUp)
app.component('LucideTrendingDown', TrendingDown)
app.component('LucideBarChart3', BarChart3)
app.component('LucidePieChart', PieChart)
app.component('LucideActivity', Activity)
app.component('LucideUtensils', Utensils)
app.component('LucideCoffee', Coffee)
app.component('LucideRestaurant', Restaurant)
app.component('LucideCalendarDays', CalendarDays)
app.component('LucideCalendarCheck', CalendarCheck)
app.component('LucideCalendarX', CalendarX)
app.component('LucideCalendarClock', CalendarClock)
app.component('LucideTimer', Timer)
app.component('LucideHourglass', Hourglass)
app.component('LucideAlarmClock', AlarmClock)
app.component('LucideStopwatch', Stopwatch)

// Configuration globale des stores
const appStore = useAppStore()

// Fonction pour détecter si Material Symbols se charge correctement
function detectMaterialSymbols() {
  console.log('🔍 [Main] Vérification du chargement de Material Symbols...');
  
  // Créer un élément de test
  const testElement = document.createElement('span');
  testElement.className = 'material-symbols-outlined';
  testElement.textContent = 'home';
  testElement.style.position = 'absolute';
  testElement.style.left = '-9999px';
  testElement.style.top = '-9999px';
  testElement.style.visibility = 'hidden';
  
  document.body.appendChild(testElement);
  
  // Laisser le temps au navigateur de calculer les styles
  setTimeout(() => {
    const computedStyle = window.getComputedStyle(testElement);
    const fontFamily = computedStyle.getPropertyValue('font-family');
    
    console.log('📝 [Main] Font family détectée:', fontFamily);
    
    // Vérifier si Material Symbols est bien chargé
    const isMaterialSymbolsLoaded = fontFamily.includes('Material Symbols Outlined') || 
                                   fontFamily.includes('Material Symbols');
    
    if (!isMaterialSymbolsLoaded) {
      console.log('⚠️ [Main] Material Symbols non détecté, activation des emoji...');
      document.documentElement.classList.add('force-emoji');
    } else {
      console.log('✅ [Main] Material Symbols détecté et fonctionnel');
      document.documentElement.classList.remove('force-emoji');
    }
    
    // Nettoyer l'élément de test
    document.body.removeChild(testElement);
  }, 100);
}

// Fonction pour forcer les emoji (pour test)
window.toggleEmojiMode = function() {
  const isForced = document.documentElement.classList.contains('force-emoji');
  if (isForced) {
    document.documentElement.classList.remove('force-emoji');
    console.log('✅ [Main] Mode icônes Material Symbols activé');
  } else {
    document.documentElement.classList.add('force-emoji');
    console.log('🎭 [Main] Mode emoji forcé activé');
  }
}

// Attendre que les polices se chargent
if (document.fonts && document.fonts.ready) {
  document.fonts.ready.then(() => {
    setTimeout(detectMaterialSymbols, 500);
  });
} else {
  // Fallback pour les navigateurs plus anciens
  setTimeout(detectMaterialSymbols, 2000);
}

// Re-vérifier au chargement complet de la page
window.addEventListener('load', () => {
  setTimeout(detectMaterialSymbols, 1000);
});

console.log('🚀 [Main] Système de détection Material Symbols initialisé');
console.log('💡 [Main] Tapez toggleEmojiMode() dans la console pour basculer entre icônes et emoji');

// Vérifier le chargement des polices quand l'application est montée
app.mount('#app')

// Gestion des erreurs globales
app.config.errorHandler = (error, instance, errorInfo) => {
  console.error('Global error:', error, errorInfo)
}

// Support PWA avec service worker CORRIGÉ (n'interfère plus avec la navigation)
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/pwa/sw.js')
    .then(registration => {
      console.log('✅ Service Worker correctement enregistré:', registration.scope)
    })
    .catch(error => {
      console.error('❌ Erreur enregistrement Service Worker:', error)
    })
}

// Optimisation pour les appareils tactiles
if ('ontouchstart' in window) {
  document.body.classList.add('touch-device')
}

// Détection de la connexion réseau
function updateOnlineStatus() {
  if (navigator.onLine) {
    document.body.classList.remove('offline')
    appStore.setOnlineStatus(true)
  } else {
    document.body.classList.add('offline')
    appStore.setOnlineStatus(false)
  }
}

window.addEventListener('online', updateOnlineStatus)
window.addEventListener('offline', updateOnlineStatus)

// Initialiser le statut
updateOnlineStatus()

// Initialiser OneSignal après le montage de l'app
console.log('🔔 [Main] Initialisation du service OneSignal...')

// Exposer le service globalement pour debug
window.oneSignalService = oneSignalService