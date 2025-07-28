/**
 * Composant DinorIcon - Système d'icônes pour l'application
 */

import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { COLORS, DIMENSIONS } from '@/styles';

interface DinorIconProps {
  name: string;
  size?: number;
  color?: string;
  style?: any;
  filled?: boolean;
}

const DinorIcon: React.FC<DinorIconProps> = ({ 
  name, 
  size = 24, 
  color = COLORS.DARK_GRAY,
  style,
  filled = false
}) => {
  // Mapping des icônes vers les emojis (temporaire)
  const iconMap: Record<string, string> = {
    // Navigation
    'home': '🏠',
    'recipes': '🍳',
    'tips': '💡',
    'events': '📅',
    'dinor-tv': '📺',
    'profile': '👤',
    
    // Actions
    'like': filled ? '❤️' : '🤍',
    'favorite': filled ? '⭐' : '☆',
    'share': '📤',
    'search': '🔍',
    'close': '❌',
    'menu': '☰',
    'back': '←',
    'forward': '→',
    
    // Contenu
    'time': '⏱️',
    'difficulty': '📊',
    'location': '📍',
    'date': '📅',
    'user': '👤',
    'settings': '⚙️',
    'logout': '🚪',
    
    // États
    'loading': '⏳',
    'error': '❌',
    'success': '✅',
    'warning': '⚠️',
    'info': 'ℹ️',
  };

  const icon = iconMap[name] || '❓';

  return (
    <View style={[styles.container, { width: size, height: size }, style]}>
      <Text style={[styles.icon, { fontSize: size * 0.8, color }]}>
        {icon}
      </Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  icon: {
    textAlign: 'center',
    lineHeight: 24,
  },
});

export default DinorIcon; 