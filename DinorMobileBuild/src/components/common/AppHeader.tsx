/**
 * Composant AppHeader - En-tête de l'application fusionné
 */

import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import DinorIcon from '@/components/icons/DinorIcon';
import ShareService from '@/services/shareService';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

interface AppHeaderProps {
  title?: string;
  showBack?: boolean;
  showFavorite?: boolean;
  showShare?: boolean;
  favoriteType?: string;
  favoriteItemId?: string;
  initialFavorited?: boolean;
  onBackPress?: () => void;
  onFavoritePress?: () => void;
  onSharePress?: () => void;
}

const AppHeader: React.FC<AppHeaderProps> = ({
  title = 'Dinor',
  showBack = false,
  showFavorite = false,
  showShare = false,
  favoriteType,
  favoriteItemId,
  initialFavorited = false,
  onBackPress,
  onFavoritePress,
  onSharePress,
}) => {
  const navigation = useNavigation();

  const handleBackPress = () => {
    if (onBackPress) {
      onBackPress();
    } else {
      navigation.goBack();
    }
  };

  const handleFavoritePress = () => {
    if (onFavoritePress) {
      onFavoritePress();
    } else {
      // TODO: Implémenter la logique des favoris
      console.log('⭐ [AppHeader] Toggle favorite');
    }
  };

  const handleSharePress = async () => {
    if (onSharePress) {
      onSharePress();
    } else {
      // Utiliser le partage natif
      await ShareService.shareContent({
        title: title,
        text: `Découvrez ${title} sur Dinor`,
        url: 'https://dinor.app',
        type: favoriteType as any,
        id: favoriteItemId,
      });
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        {/* Bouton retour */}
        <View style={styles.leftSection}>
          {showBack && (
            <TouchableOpacity style={styles.button} onPress={handleBackPress}>
              <DinorIcon name="arrow-left" size={24} color={COLORS.WHITE} />
            </TouchableOpacity>
          )}
        </View>

        {/* Titre centré */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>{title}</Text>
        </View>

        {/* Actions à droite */}
        <View style={styles.rightSection}>
          {showFavorite && (
            <TouchableOpacity style={styles.button} onPress={handleFavoritePress}>
              <DinorIcon 
                name={initialFavorited ? "heart" : "heart-outline"} 
                size={24} 
                color={initialFavorited ? COLORS.YELLOW : COLORS.WHITE} 
              />
            </TouchableOpacity>
          )}
          {showShare && (
            <TouchableOpacity style={styles.button} onPress={handleSharePress}>
              <DinorIcon name="share" size={24} color={COLORS.WHITE} />
            </TouchableOpacity>
          )}
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: COLORS.PRIMARY_RED, // Fond rouge
    borderBottomWidth: 0,
    paddingTop: DIMENSIONS.STATUS_BAR_HEIGHT || 0,
    height: DIMENSIONS.HEADER_HEIGHT + (DIMENSIONS.STATUS_BAR_HEIGHT || 0),
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 4,
  },
  content: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: DIMENSIONS.SPACING_4,
  },
  leftSection: {
    flex: 1,
    alignItems: 'flex-start',
  },
  titleSection: {
    flex: 2,
    alignItems: 'center',
  },
  rightSection: {
    flex: 1,
    alignItems: 'flex-end',
    flexDirection: 'row',
    gap: 8,
  },
  title: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semiBold,
    color: COLORS.WHITE,
    fontFamily: TYPOGRAPHY.fontFamily.heading,
    textAlign: 'center',
  },
  button: {
    width: 44,
    height: 44,
    justifyContent: 'center',
    alignItems: 'center',
    borderRadius: 22,
  },
});

export default AppHeader; 