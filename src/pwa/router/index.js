import { createRouter, createWebHistory } from 'vue-router'

// Lazy load components
const Home = () => import('@/views/Home.vue')
const RecipesList = () => import('@/views/RecipesList.vue')
const TipsList = () => import('@/views/TipsList.vue')
const EventsList = () => import('@/views/EventsList.vue')
const PagesList = () => import('@/views/PagesList.vue')
const DinorTV = () => import('@/views/DinorTV.vue')

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
    path: '/tips',
    name: 'tips',
    component: TipsList,
    meta: { title: 'Astuces' }
  },
  {
    path: '/events',
    name: 'events',
    component: EventsList,
    meta: { title: 'Événements' }
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