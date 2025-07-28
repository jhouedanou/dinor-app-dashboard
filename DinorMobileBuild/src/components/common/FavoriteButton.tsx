import React, { useRef, useEffect } from 'react';
import {
  TouchableOpacity,
  Text,
  View,
  StyleSheet,
  Animated,
  Alert,
} from 'react-native';
import { DinorIcon } from '../icons/DinorIcon';
import { COLORS, TYPOGRAPHY } from '../../styles/colors';
import { useLikes, ContentType } from '../../hooks/useLikes';
import { useAuthStore } from '../../stores/authStore';

interface FavoriteButtonProps {
  contentType: ContentType;
  contentId: number;
  initialIsFavorited?: boolean;
  size?: 'small' | 'medium' | 'large';
  variant?: 'default' | 'minimal';
  onAuthRequired?: () => void;
}

export const FavoriteButton: React.FC<FavoriteButtonProps> = ({
  contentType,
  contentId,
  initialIsFavorited = false,
  size = 'medium',
  variant = 'default',
  onAuthRequired,
}) => {
  const { isAuthenticated } = useAuthStore();
  const scaleAnimation = useRef(new Animated.Value(1)).current;
  
  const { isFavorited, loading, toggleFavorite } = useLikes(
    contentType,
    contentId,
    {
      isFavorited: initialIsFavorited,
    }
  );

  // Animate on favorite
  useEffect(() => {
    if (isFavorited) {
      Animated.sequence([
        Animated.timing(scaleAnimation, {
          toValue: 1.2,
          duration: 150,
          useNativeDriver: true,
        }),
        Animated.timing(scaleAnimation, {
          toValue: 1,
          duration: 150,
          useNativeDriver: true,
        }),
      ]).start();
    }
  }, [isFavorited]);

  const handlePress = async () => {
    if (!isAuthenticated) {
      if (onAuthRequired) {
        onAuthRequired();
      } else {
        Alert.alert(
          'Authentification requise',
          'Vous devez être connecté pour ajouter ce contenu aux favoris.',
          [{ text: 'OK' }]
        );
      }
      return;
    }

    await toggleFavorite();
  };

  const getSizes = () => {
    switch (size) {
      case 'small':
        return {
          iconSize: 16,
          padding: 6,
        };
      case 'large':
        return {
          iconSize: 28,
          padding: 12,
        };
      default: // medium
        return {
          iconSize: 20,
          padding: 8,
        };
    }
  };

  const sizes = getSizes();
  const bookmarkColor = isFavorited ? COLORS.GOLDEN : COLORS.MEDIUM_GRAY;
  const bookmarkIcon = isFavorited ? 'bookmark-filled' : 'bookmark';

  if (variant === 'minimal') {
    return (
      <TouchableOpacity
        onPress={handlePress}
        disabled={loading}
        style={[styles.minimalButton, { padding: sizes.padding }]}
        activeOpacity={0.7}
      >
        <Animated.View style={{ transform: [{ scale: scaleAnimation }] }}>
          <DinorIcon 
            name={bookmarkIcon} 
            size={sizes.iconSize} 
            color={bookmarkColor} 
          />
        </Animated.View>
      </TouchableOpacity>
    );
  }

  return (
    <TouchableOpacity
      onPress={handlePress}
      disabled={loading}
      style={[
        styles.defaultButton,
        { padding: sizes.padding },
        isFavorited && styles.favoritedButton,
      ]}
      activeOpacity={0.7}
    >
      <Animated.View style={{ transform: [{ scale: scaleAnimation }] }}>
        <DinorIcon 
          name={bookmarkIcon} 
          size={sizes.iconSize} 
          color={isFavorited ? COLORS.WHITE : bookmarkColor} 
        />
      </Animated.View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  minimalButton: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  defaultButton: {
    backgroundColor: 'transparent',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: COLORS.MEDIUM_GRAY,
    alignItems: 'center',
    justifyContent: 'center',
    minWidth: 40,
    minHeight: 40,
  },
  favoritedButton: {
    backgroundColor: COLORS.GOLDEN,
    borderColor: COLORS.GOLDEN,
  },
});