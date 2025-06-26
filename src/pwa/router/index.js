import { createRouter, createWebHistory } from 'vue-router'

// Lazy load components
const RecipesList = () => import('@/views/RecipesList.vue')
const RecipeDetail = () => import('@/views/RecipeDetail.vue')
const TipsList = () => import('@/views/TipsList.vue')
const TipDetail = () => import('@/views/TipDetail.vue')
const EventsList = () => import('@/views/EventsList.vue')
const EventDetail = () => import('@/views/EventDetail.vue')
const PagesList = () => import('@/views/PagesList.vue')
const PageDetail = () => import('@/views/PageDetail.vue')
const DinorTV = () => import('@/views/DinorTV.vue')

const routes = [
  {
    path: '/',
    redirect: '/recipes'
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
    meta: { title: 'Recette' }
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
    meta: { title: 'Astuce' }
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
    meta: { title: 'Événement' }
  },
  {
    path: '/pages',
    name: 'pages',
    component: PagesList,
    meta: { title: 'Pages' }
  },
  {
    path: '/page/:id',
    name: 'page-detail',
    component: PageDetail,
    meta: { title: 'Page' }
  },
  {
    path: '/dinor-tv',
    name: 'dinor-tv',
    component: DinorTV,
    meta: { title: 'Dinor TV' }
  },
  {
    path: '/:pathMatch(.*)*',
    redirect: '/recipes'
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