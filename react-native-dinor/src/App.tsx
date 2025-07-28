/**
 * APP PRINCIPAL - ASSEMBLAGE FINAL
 * 
 * Intégration complète de tous les composants convertis
 * avec fidélité absolue à l'application Vue.js originale
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  StyleSheet,
  StatusBar
} from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import AppHeader from './components/common/AppHeader';
import LoadingScreen from './components/common/LoadingScreen';
import AuthModal from './components/common/AuthModal';
import ShareModal from './components/common/ShareModal';
import DinorIcon from './components/icons/DinorIcon';

// Screens
import {
  HomeScreen,
  RecipesScreen,
  TipsScreen,
  EventsScreen,
  DinorTVScreen,
  ProfileScreen,
} from './screens';

import { useAuthStore, useAppStore } from './stores';
import { COLORS } from './styles';

const Tab = createBottomTabNavigator();

const App: React.FC = () => {
  // États modales (identique Vue)
  const [showAuthModal, setShowAuthModal] = useState(false);
  const [showShareModal, setShowShareModal] = useState(false);
  const [currentShareData, setCurrentShareData] = useState({});
  const [showLoading, setShowLoading] = useState(true);
  
  // États header dynamiques (identique Vue)
  const [headerState, setHeaderState] = useState({
    title: 'Dinor',
    showFavorite: false,
    favoriteType: null as string | null,
    favoriteItemId: null as number | null,
    isContentFavorited: false,
    showShare: false,
    backPath: null as string | null,
  });

  // Stores
  const { isAuthenticated } = useAuthStore();
  const { initializeNetworkListeners } = useAppStore();

  // Loading screen 2.5s (identique Vue)
  useEffect(() => {
    const timer = setTimeout(() => {
      setShowLoading(false);
      console.log('🎉 [App] Chargement terminé, app prête !');
    }, 2500);
    
    // Initialiser les listeners réseau
    initializeNetworkListeners();
    
    return () => clearTimeout(timer);
  }, []);

  // Gestion événements navigation (identique Vue)
  const handleNavigationStateChange = (state: any) => {
    const currentRoute = getCurrentRoute(state);
    updateHeaderForRoute(currentRoute);
  };

  const getCurrentRoute = (state: any): any => {
    if (!state || !state.routes) return null;
    
    const route = state.routes[state.index];
    if (route.state) {
      return getCurrentRoute(route.state);
    }
    
    return route;
  };

  const updateHeaderForRoute = (route: any) => {
    if (!route) return;
    
    // Logique identique Vue updateTitle()
    const routeToHeaderMap: Record<string, any> = {
      'Home': { title: 'Dinor', showFavorite: false, showShare: false },
      'Recipes': { title: 'Recettes', showFavorite: false, showShare: false },
      'Tips': { title: 'Astuces', showFavorite: false, showShare: false },
      'Events': { title: 'Événements', showFavorite: false, showShare: false },
      'DinorTV': { title: 'Dinor TV', showFavorite: false, showShare: false },
      'Profile': { title: 'Profil', showFavorite: false, showShare: false },
    };
    
    const newHeaderState = routeToHeaderMap[route.name] || {
      title: 'Dinor',
      showFavorite: false,
      showShare: false,
      backPath: 'Home'
    };
    
    setHeaderState(newHeaderState);
  };

  const handleAuthRequired = () => {
    console.log('🔒 [App] Authentification requise');
    setShowAuthModal(true);
  };

  const handleShare = () => {
    console.log('🎯 [App] handleShare appelé!');
    
    // Logique partage identique Vue
    const shareData = {
      title: headerState.title || 'Dinor',
      text: `Découvrez ${headerState.title} sur Dinor`,
      url: 'https://dinor.app'
    };
    
    setCurrentShareData(shareData);
    setShowShareModal(true);
  };

  const handleFavoriteUpdate = (updatedFavorite: any) => {
    console.log('🌟 [App] Favori mis à jour:', updatedFavorite);
    setHeaderState(prev => ({
      ...prev,
      isContentFavorited: updatedFavorite.isFavorited
    }));
  };

  // Configuration des onglets (identique Vue menuItems)
  const getTabIconName = (routeName: string): string => {
    const iconMap: Record<string, string> = {
      'Home': 'home',
      'Recipes': 'chef-hat', 
      'Tips': 'lightbulb',
      'Events': 'calendar',
      'DinorTV': 'play-circle',
      'Profile': 'user'
    };
    return iconMap[routeName] || 'home';
  };

  const getTabLabel = (routeName: string): string => {
    const labelMap: Record<string, string> = {
      'Home': 'Accueil',
      'Recipes': 'Recettes',
      'Tips': 'Astuces',
      'Events': 'Événements',
      'DinorTV': 'DinorTV',
      'Profile': 'Profil'
    };
    return labelMap[routeName] || routeName;
  };

  // Loading screen initial (identique Vue)
  if (showLoading) {
    return (
      <LoadingScreen 
        visible={showLoading}
        duration={2500}
        onComplete={() => setShowLoading(false)}
      />
    );
  }

  return (
    <SafeAreaProvider>
      <StatusBar barStyle="light-content" backgroundColor={COLORS.PRIMARY_RED} />
      
      <NavigationContainer onStateChange={handleNavigationStateChange}>
        <View style={styles.appContainer}>
          {/* Header avec état dynamique (identique Vue) */}
          <AppHeader
            title={headerState.title}
            showFavorite={headerState.showFavorite}
            favoriteType={headerState.favoriteType as any}
            favoriteItemId={headerState.favoriteItemId}
            initialFavorited={headerState.isContentFavorited}
            showShare={headerState.showShare}
            backPath={headerState.backPath}
            onFavoriteUpdated={handleFavoriteUpdate}
            onShare={handleShare}
            onAuthRequired={handleAuthRequired}
          />
          
          {/* Navigation Tabs avec style exact (identique Vue) */}
          <Tab.Navigator
            screenOptions={({ route }) => ({
              headerShown: false,
              tabBarIcon: ({ focused, size }) => {
                const iconName = getTabIconName(route.name);
                return (
                  <DinorIcon 
                    name={iconName} 
                    size={24}
                    color={focused ? COLORS.ORANGE_ACCENT : 'rgba(0, 0, 0, 0.7)'}
                    filled={focused}
                  />
                );
              },
              tabBarLabel: getTabLabel(route.name),
              tabBarActiveTintColor: COLORS.ORANGE_ACCENT, // #FF6B35 exact
              tabBarInactiveTintColor: 'rgba(0, 0, 0, 0.7)', // Couleur exacte Vue
              tabBarStyle: styles.bottomNavigation,
              tabBarLabelStyle: styles.navLabel,
              tabBarItemStyle: styles.navItem,
            })}
          >
            <Tab.Screen name="Home" component={HomeScreen} />
            <Tab.Screen name="Recipes" component={RecipesScreen} />
            <Tab.Screen name="Tips" component={TipsScreen} />
            <Tab.Screen name="Events" component={EventsScreen} />
            <Tab.Screen name="DinorTV" component={DinorTVScreen} />
            <Tab.Screen 
              name="Profile" 
              component={ProfileScreen}
              listeners={({ navigation }) => ({
                tabPress: (e) => {
                  // Gestion auth pour Profile (identique Vue)
                  if (!isAuthenticated) {
                    e.preventDefault();
                    handleAuthRequired();
                  }
                },
              })}
            />
          </Tab.Navigator>

          {/* Modales identiques Vue */}
          <AuthModal 
            visible={showAuthModal}
            onClose={() => setShowAuthModal(false)}
            onAuthenticated={(user) => {
              console.log('✅ [App] Utilisateur authentifié:', user);
              setShowAuthModal(false);
            }}
          />
          
          <ShareModal
            visible={showShareModal}
            shareData={currentShareData}
            onClose={() => setShowShareModal(false)}
          />
        </View>
      </NavigationContainer>
    </SafeAreaProvider>
  );
};

const styles = StyleSheet.create({
  appContainer: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
  },
  
  // Bottom Navigation - REPRODUCTION EXACTE du CSS Vue
  bottomNavigation: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: COLORS.GOLDEN, // #F4D03F exactement identique
    borderTopWidth: 1,
    borderTopColor: 'rgba(0, 0, 0, 0.1)', // border exact
    height: 80, // 80px exact
    paddingHorizontal: 16, // padding exact
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -4 },
    shadowOpacity: 0.1,
    shadowRadius: 20,
    elevation: 10, // Android shadow
  },
  
  navItem: {
    paddingVertical: 8, // padding exact
    paddingHorizontal: 4, // padding exact
    borderRadius: 16, // border-radius exact
    minWidth: 0,
    maxWidth: 80, // max-width exact
  },
  
  navLabel: {
    fontSize: 12, // 12px exact
    fontWeight: '500', // 500 exact
    fontFamily: 'Roboto', // Roboto exact
    lineHeight: 14.4, // 1.2 * 12px exact
    textAlign: 'center' as const,
  },
});

export default App;