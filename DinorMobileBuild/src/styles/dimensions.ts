import { Dimensions } from 'react-native';

const { width: screenWidth, height: screenHeight } = Dimensions.get('window');

export const DIMENSIONS = {
  // Layout principal
  SCREEN_WIDTH: screenWidth,
  SCREEN_HEIGHT: screenHeight,
  
  // Navigation (exactes depuis Vue CSS)
  BOTTOM_NAV_HEIGHT: 80,       // 80px exact
  HEADER_HEIGHT: 60,           // 60px exact
  
  // Icônes (exactes depuis Vue)
  ICON_SIZE_SM: 20,
  ICON_SIZE_MD: 24,            // 24px exact par défaut
  ICON_SIZE_LG: 28,
  
  // Espacement (identique SCSS)
  SPACING_2: 8,
  SPACING_3: 12,
  SPACING_4: 16,               // 16px exact
  SPACING_6: 24,
  
  // Border radius
  BORDER_RADIUS: 8,            // 8px exact
  BORDER_RADIUS_FULL: 50,
  
  // Typographie
  TEXT_SM: 12,                 // 12px exact
  TEXT_MD: 16,                 // 16px exact
  TEXT_LG: 20,                 // 20px exact
} as const;