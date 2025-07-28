/**
 * ÉCRAN CONVERTI : Profile
 * Écran de profil utilisateur
 */

import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';

import DinorIcon from '@/components/icons/DinorIcon';
import { useAuthStore } from '@/stores';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

const ProfileScreen: React.FC = () => {
  const navigation = useNavigation();
  
  const {
    user,
    isAuthenticated,
    userName,
    userEmail,
    logout,
    loading,
  } = useAuthStore();

  const handleLogout = () => {
    Alert.alert(
      'Déconnexion',
      'Êtes-vous sûr de vouloir vous déconnecter ?',
      [
        {
          text: 'Annuler',
          style: 'cancel',
        },
        {
          text: 'Déconnexion',
          style: 'destructive',
          onPress: async () => {
            await logout();
            navigation.navigate('Home' as never);
          },
        },
      ]
    );
  };

  if (!isAuthenticated) {
    return (
      <View style={styles.container}>
        <View style={styles.notAuthContent}>
          <DinorIcon name="user" size={80} color={COLORS.MEDIUM_GRAY} />
          <Text style={styles.notAuthTitle}>Connexion requise</Text>
          <Text style={styles.notAuthDescription}>
            Veuillez vous connecter pour accéder à votre profil
          </Text>
        </View>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* Header profil */}
      <View style={styles.profileHeader}>
        <View style={styles.avatar}>
          <DinorIcon name="user" size={48} color={COLORS.WHITE} />
        </View>
        
        <Text style={styles.userName}>{userName}</Text>
        <Text style={styles.userEmail}>{userEmail}</Text>
      </View>

      {/* Menu options */}
      <View style={styles.menuSection}>
        <TouchableOpacity style={styles.menuItem}>
          <DinorIcon name="favorite" size={24} color={COLORS.PRIMARY_RED} />
          <Text style={styles.menuText}>Mes favoris</Text>
          <DinorIcon name="chevron_right" size={20} color={COLORS.MEDIUM_GRAY} />
        </TouchableOpacity>

        <TouchableOpacity style={styles.menuItem}>
          <DinorIcon name="settings" size={24} color={COLORS.MEDIUM_GRAY} />
          <Text style={styles.menuText}>Paramètres</Text>
          <DinorIcon name="chevron_right" size={20} color={COLORS.MEDIUM_GRAY} />
        </TouchableOpacity>

        <TouchableOpacity style={styles.menuItem}>
          <DinorIcon name="help" size={24} color={COLORS.MEDIUM_GRAY} />
          <Text style={styles.menuText}>Aide</Text>
          <DinorIcon name="chevron_right" size={20} color={COLORS.MEDIUM_GRAY} />
        </TouchableOpacity>
      </View>

      {/* Actions */}
      <View style={styles.actionsSection}>
        <TouchableOpacity 
          style={styles.logoutButton}
          onPress={handleLogout}
          disabled={loading}
        >
          <DinorIcon name="logout" size={20} color={COLORS.ERROR} />
          <Text style={styles.logoutText}>Se déconnecter</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
  },
  
  content: {
    paddingBottom: DIMENSIONS.BOTTOM_NAV_HEIGHT + 20,
    flexGrow: 1,
  },
  
  // Not authenticated state
  notAuthContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 40,
    paddingBottom: DIMENSIONS.BOTTOM_NAV_HEIGHT,
  },
  
  notAuthTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg + 4, // 24px
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.heading,
    marginTop: 24,
    marginBottom: 12,
    textAlign: 'center',
  },
  
  notAuthDescription: {
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    textAlign: 'center',
    lineHeight: 22,
  },
  
  // Profile header
  profileHeader: {
    backgroundColor: COLORS.WHITE,
    alignItems: 'center',
    paddingVertical: 32,
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: COLORS.PRIMARY_RED,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  
  userName: {
    fontSize: TYPOGRAPHY.fontSize.lg + 2, // 22px
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.heading,
    marginBottom: 4,
  },
  
  userEmail: {
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
  
  // Menu section
  menuSection: {
    backgroundColor: COLORS.WHITE,
    marginBottom: 20,
  },
  
  menuItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 16,
    paddingHorizontal: 20,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0, 0, 0, 0.05)',
  },
  
  menuText: {
    flex: 1,
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    marginLeft: 16,
  },
  
  // Actions section
  actionsSection: {
    backgroundColor: COLORS.WHITE,
  },
  
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    paddingHorizontal: 20,
    gap: 8,
  },
  
  logoutText: {
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.ERROR,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
});

export default ProfileScreen;