export const COLORS = {
  // Couleurs principales Dinor (exactes depuis Vue)
  PRIMARY_RED: '#E53E3E',      // Header, favoris
  GOLDEN: '#F4D03F',           // Bottom nav
  ORANGE_ACCENT: '#FF6B35',    // État actif
  
  // Texte
  WHITE: '#FFFFFF',            // Texte sur rouge
  DARK_GRAY: '#2D3748',        // Titres
  MEDIUM_GRAY: '#4A5568',      // Corps de texte
  
  // Arrière-plans
  BACKGROUND: '#F5F5F5',       // Fond général
  SURFACE: '#FFFFFF',          // Cartes, surfaces
  
  // États
  SHADOW: 'rgba(0, 0, 0, 0.1)',
  HOVER_OVERLAY: 'rgba(255, 255, 255, 0.1)',
  ACTIVE_BACKGROUND: 'rgba(255, 107, 53, 0.1)',
  
  // Erreurs et succès
  ERROR: '#DC3545',
  SUCCESS: '#28A745',
  WARNING: '#FFC107',
  INFO: '#17A2B8',
} as const;