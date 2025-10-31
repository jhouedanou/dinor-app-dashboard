/**
 * Configuration Firebase pour l'application PWA
 */

import { initializeApp } from 'firebase/app'
import { getAnalytics, isSupported } from 'firebase/analytics'

// Configuration Firebase avec les vraies clés du projet
const firebaseConfig = {
  apiKey: "AIzaSyCq37nk-Cjt0r3n-QDqZ6R2rB0JOSJQtfM",
  authDomain: "dinor-app-2.firebaseapp.com",
  projectId: "dinor-app-2",
  storageBucket: "dinor-app-2.firebasestorage.app",
  messagingSenderId: "225643560458",
  appId: "1:225643560458:web:184dbda2374aa43e5e29f3",
  measurementId: "G-XXXXXXXXXX" // À remplacer par votre vraie Measurement ID si Analytics web est configuré
}

// Initialiser Firebase
const app = initializeApp(firebaseConfig)

// Initialiser Analytics seulement si supporté
let analytics = null

const initializeAnalytics = async () => {
  try {
    const supported = await isSupported()
    if (supported) {
      analytics = getAnalytics(app)
      console.log('Firebase Analytics initialisé')
      return analytics
    } else {
      console.warn('Firebase Analytics non supporté dans cet environnement')
      return null
    }
  } catch (error) {
    console.error('Erreur lors de l\'initialisation de Firebase Analytics:', error)
    return null
  }
}

// Exporter l'app et les services
export { app, analytics, initializeAnalytics }

// Configuration par défaut pour le développement
export const isDevelopment = process.env.NODE_ENV === 'development'
export const isProduction = process.env.NODE_ENV === 'production'

// Désactiver Analytics en développement si souhaité
export const analyticsEnabled = isProduction || process.env.VITE_FIREBASE_ANALYTICS_ENABLED === 'true'