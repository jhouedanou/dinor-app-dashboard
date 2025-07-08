import { createRouter, createWebHistory } from 'vue-router'

// Lazy load components
const Home = () => import('@/views/Home.vue')
const RecipesList = () => import('@/views/RecipesList.vue')
const TipsList = () => import('@/views/TipsList.vue')
const EventsList = () => import('@/views/EventsList.vue')
const PagesList = () => import('@/views/PagesList.vue')
const DinorTV = () => import('@/views/DinorTV.vue')
const WebEmbed = () => import('@/views/WebEmbed.vue')
const Profile = () => import('@/views/Profile.vue')

// Detail components
const RecipeDetail = () => import('@/views/RecipeDetail.vue')
const TipDetail = () => import('@/views/TipDetail.vue')
const EventDetail = () => import('@/views/EventDetail.vue')

// Legal pages
const TermsOfService = () => import('@/views/TermsOfService.vue')
const PrivacyPolicy = () => import('@/views/PrivacyPolicy.vue')
const CookiePolicy = () => import('@/views/CookiePolicy.vue')

const routes = [
  {
    path: '/',
    name: 'home',
    component: Home,
    meta: { title: 'Accueil' }
  },
  {
    path: '/home',
    redirect: '/'
  },
  {
    path: '/recipes',
    name: 'recipes',
    component: RecipesList,
    meta: { title: 'Recettes' }
  },
  {
    path: '/recipe/:id',
    name: 'recipe-detail',
    component: RecipeDetail,
    meta: { title: 'Détail Recette' },
    props: true
  },
  {
    path: '/tips',
    name: 'tips',
    component: TipsList,
    meta: { title: 'Astuces' }
  },
  {
    path: '/tip/:id',
    name: 'tip-detail',
    component: TipDetail,
    meta: { title: 'Détail Astuce' },
    props: true
  },
  {
    path: '/events',
    name: 'events',
    component: EventsList,
    meta: { title: 'Événements' }
  },
  {
    path: '/event/:id',
    name: 'event-detail',
    component: EventDetail,
    meta: { title: 'Détail Événement' },
    props: true
  },
  {
    path: '/pages',
    name: 'pages',
    component: PagesList,
    meta: { title: 'Pages' }
  },
  {
    path: '/dinor-tv',
    name: 'dinor-tv',
    component: DinorTV,
    meta: { title: 'Dinor TV' }
  },
  {
    path: '/video/:id',
    redirect: to => '/dinor-tv'
  },
  {
    path: '/web-embed',
    name: 'web-embed',
    component: WebEmbed,
    meta: { title: 'Web Embed' }
  },
  {
    path: '/profile',
    name: 'profile',
    component: Profile,
    meta: { title: 'Profil' }
  },
  {
    path: '/terms',
    name: 'terms-of-service',
    component: TermsOfService,
    meta: { title: 'Conditions Générales d\'Utilisation' }
  },
  {
    path: '/privacy',
    name: 'privacy-policy',
    component: PrivacyPolicy,
    meta: { title: 'Politique de Confidentialité' }
  },
  {
    path: '/cookies',
    name: 'cookie-policy',
    component: CookiePolicy,
    meta: { title: 'Politique des Cookies' }
  },
  {
    path: '/predictions',
    name: 'predictions',
    component: () => import('@/views/Predictions.vue'),
    meta: { title: 'Pronostics' }
  },
  {
    path: '/predictions/teams',
    name: 'predictions-teams',
    component: () => import('@/views/PredictionsTeams.vue'),
    meta: { title: 'Équipes' }
  },
  {
    path: '/predictions/leaderboard',
    name: 'predictions-leaderboard',
    component: () => import('@/views/PredictionsLeaderboard.vue'),
    meta: { title: 'Classement' }
  },
  {
    path: '/predictions/tournaments',
    name: 'predictions-tournaments',
    component: () => import('@/views/Tournaments.vue'),
    meta: { title: 'Tournois' }
  },
  {
    path: '/predictions/betting',
    name: 'tournament-betting',
    component: () => import('@/views/TournamentBetting.vue'),
    meta: { title: 'Paris de Tournois' }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory('/pwa/'),
  routes
})

// Navigation guards
router.beforeEach((to, from, next) => {
  // Update document title
  if (to.meta.title) {
    document.title = `${to.meta.title} - Dinor App`
  }
  next()
})

export default router