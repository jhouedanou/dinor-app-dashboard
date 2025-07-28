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
import { useLikes, ContentType, formatLikeCount } from '../../hooks/useLikes';
import { useAuthStore } from '../../stores/authStore';

interface LikeButtonProps {
  contentType: ContentType;
  contentId: number;
  initialIsLiked?: boolean;
  initialLikesCount?: number;
  size?: 'small' | 'medium' | 'large';
  variant?: 'default' | 'compact' | 'minimal';
  showCount?: boolean;
  onAuthRequired?: () => void;
}

export const LikeButton: React.FC<LikeButtonProps> = ({
  contentType,
  contentId,
  initialIsLiked = false,
  initialLikesCount = 0,
  size = 'medium',
  variant = 'default',
  showCount = true,
  onAuthRequired,
}) => {
  const { isAuthenticated } = useAuthStore();
  const scaleAnimation = useRef(new Animated.Value(1)).current;
  
  const { isLiked, likesCount, loading, toggleLike } = useLikes(
    contentType,
    contentId,
    {
      isLiked: initialIsLiked,
      likesCount: initialLikesCount,
    }
  );

  // Animate on like
  useEffect(() => {
    if (isLiked) {
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
  }, [isLiked]);

  const handlePress = async () => {
    if (!isAuthenticated) {
      if (onAuthRequired) {
        onAuthRequired();
      } else {
        Alert.alert(
          'Authentification requise',
          'Vous devez être connecté pour aimer ce contenu.',
          [{ text: 'OK' }]
        );
      }
      return;
    }

    await toggleLike();
  };

  const getSizes = () => {
    switch (size) {
      case 'small':
        return {
          iconSize: 16,
          fontSize: TYPOGRAPHY.fontSize.xs,
          padding: 6,
        };
      case 'large':
        return {
          iconSize: 28,
          fontSize: TYPOGRAPHY.fontSize.md,
          padding: 12,
        };
      default: // medium
        return {
          iconSize: 20,
          fontSize: TYPOGRAPHY.fontSize.sm,
          padding: 8,
        };
    }
  };

  const sizes = getSizes();
  const heartColor = isLiked ? COLORS.PRIMARY_RED : COLORS.MEDIUM_GRAY;
  const heartIcon = isLiked ? 'heart-filled' : 'heart';

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
            name={heartIcon} 
            size={sizes.iconSize} 
            color={heartColor} 
          />
        </Animated.View>
      </TouchableOpacity>
    );
  }

  if (variant === 'compact') {
    return (
      <TouchableOpacity
        onPress={handlePress}
        disabled={loading}
        style={[styles.compactButton, { padding: sizes.padding }]}
        activeOpacity={0.7}
      >
        <Animated.View style={{ transform: [{ scale: scaleAnimation }] }}>
          <DinorIcon 
            name={heartIcon} 
            size={sizes.iconSize} 
            color={heartColor} 
          />
        </Animated.View>
        {showCount && (
          <Text style={[styles.compactCount, { fontSize: sizes.fontSize }]}>
            {formatLikeCount(likesCount)}
          </Text>
        )}
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
        isLiked && styles.likedButton,
      ]}
      activeOpacity={0.7}
    >
      <Animated.View 
        style={[
          styles.defaultContent,
          { transform: [{ scale: scaleAnimation }] }
        ]}
      >
        <DinorIcon 
          name={heartIcon} 
          size={sizes.iconSize} 
          color={isLiked ? COLORS.WHITE : heartColor} 
        />
        {showCount && (
          <Text style={[
            styles.defaultCount,
            { fontSize: sizes.fontSize },
            isLiked && styles.likedCount,
          ]}>
            {formatLikeCount(likesCount)}
          </Text>
        )}
      </Animated.View>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  minimalButton: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  compactButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  compactCount: {
    marginLeft: 6,
    color: COLORS.MEDIUM_GRAY,
    fontWeight: '500',
  },
  defaultButton: {
    backgroundColor: 'transparent',
    borderRadius: 20,
    borderWidth: 1,
    borderColor: COLORS.MEDIUM_GRAY,
    alignItems: 'center',
    justifyContent: 'center',
    minWidth: 60,
  },
  likedButton: {
    backgroundColor: COLORS.PRIMARY_RED,
    borderColor: COLORS.PRIMARY_RED,
  },
  defaultContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  defaultCount: {
    marginLeft: 6,
    color: COLORS.MEDIUM_GRAY,
    fontWeight: '500',
  },
  likedCount: {
    color: COLORS.WHITE,
  },
});