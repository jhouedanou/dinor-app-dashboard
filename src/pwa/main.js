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
  CalendarDays,
  CalendarCheck,
  CalendarX,
  CalendarClock,
  Timer,
  Hourglass,
  AlarmClock,
  BookOpen,
  ShieldCheck,
  Gavel,
  FileText,
  Target,
  Crown,
  Medal,
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
app.component('LucideCalendarDays', CalendarDays)
app.component('LucideCalendarCheck', CalendarCheck)
app.component('LucideCalendarX', CalendarX)
app.component('LucideCalendarClock', CalendarClock)
app.component('LucideTimer', Timer)
app.component('LucideHourglass', Hourglass)
app.component('LucideAlarmClock', AlarmClock)
app.component('LucideBookOpen', BookOpen)
app.component('LucideShieldCheck', ShieldCheck)
app.component('LucideGavel', Gavel)
app.component('LucideFileText', FileText)
app.component('LucideTarget', Target)
app.component('LucideCrown', Crown)
app.component('LucideMedal', Medal)

// Configuration globale des stores
const appStore = useAppStore()

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