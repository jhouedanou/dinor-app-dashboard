/**
 * Composant AppHeader - En-tête de l'application
 */

import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import DinorIcon from '@/components/icons/DinorIcon';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

interface AppHeaderProps {
  title?: string;
  showBack?: boolean;
  showMenu?: boolean;
  showSearch?: boolean;
  onBackPress?: () => void;
  onMenuPress?: () => void;
  onSearchPress?: () => void;
}

const AppHeader: React.FC<AppHeaderProps> = ({
  title = 'Dinor',
  showBack = false,
  showMenu = false,
  showSearch = false,
  onBackPress,
  onMenuPress,
  onSearchPress,
}) => {
  const navigation = useNavigation();

  const handleBackPress = () => {
    if (onBackPress) {
      onBackPress();
    } else {
      navigation.goBack();
    }
  };

  const handleMenuPress = () => {
    if (onMenuPress) {
      onMenuPress();
    }
  };

  const handleSearchPress = () => {
    if (onSearchPress) {
      onSearchPress();
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.content}>
        {/* Bouton retour ou menu */}
        <View style={styles.leftSection}>
          {showBack && (
            <TouchableOpacity style={styles.button} onPress={handleBackPress}>
              <DinorIcon name="back" size={24} color={COLORS.DARK_GRAY} />
            </TouchableOpacity>
          )}
          {showMenu && (
            <TouchableOpacity style={styles.button} onPress={handleMenuPress}>
              <DinorIcon name="menu" size={24} color={COLORS.DARK_GRAY} />
            </TouchableOpacity>
          )}
        </View>

        {/* Titre */}
        <View style={styles.titleSection}>
          <Text style={styles.title}>{title}</Text>
        </View>

        {/* Actions à droite */}
        <View style={styles.rightSection}>
          {showSearch && (
            <TouchableOpacity style={styles.button} onPress={handleSearchPress}>
              <DinorIcon name="search" size={24} color={COLORS.DARK_GRAY} />
            </TouchableOpacity>
          )}
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: COLORS.WHITE,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.BACKGROUND,
    paddingTop: DIMENSIONS.STATUS_BAR_HEIGHT || 0,
    height: DIMENSIONS.HEADER_HEIGHT + (DIMENSIONS.STATUS_BAR_HEIGHT || 0),
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
  },
  title: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.bold,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.heading,
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