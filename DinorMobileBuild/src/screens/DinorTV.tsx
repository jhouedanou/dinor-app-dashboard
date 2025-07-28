/**
 * ÉCRAN CONVERTI : DinorTV
 * Écran simple pour le moment
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
} from 'react-native';

import DinorIcon from '@/components/icons/DinorIcon';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

const DinorTVScreen: React.FC = () => {
  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <DinorIcon name="play-circle" size={80} color={COLORS.PRIMARY_RED} />
        <Text style={styles.title}>Dinor TV</Text>
        <Text style={styles.description}>
          Découvrez bientôt nos vidéos exclusives !
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
  },
  
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 40,
    paddingBottom: DIMENSIONS.BOTTOM_NAV_HEIGHT,
  },
  
  title: {
    fontSize: TYPOGRAPHY.fontSize.lg + 8, // 28px
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.heading,
    marginTop: 24,
    marginBottom: 16,
    textAlign: 'center',
  },
  
  description: {
    fontSize: TYPOGRAPHY.fontSize.md + 2, // 18px
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    textAlign: 'center',
    lineHeight: 26,
  },
});

export default DinorTVScreen;