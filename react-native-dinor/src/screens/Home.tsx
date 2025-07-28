/**
 * ÉCRAN CONVERTI : Home
 * 
 * FIDÉLITÉ VISUELLE :
 * - Layout identique avec carousels de contenus
 * - Cartes avec même design et métadonnées
 * - Couleurs et typographies exactes
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Chargement des dernières recettes, tips, events
 * - Actions like identiques
 * - Navigation vers pages détail identique
 */

import React, { useEffect } from 'react';
import {
  ScrollView,
  View,
  Text,
  StyleSheet,
  RefreshControl,
  Dimensions,
} from 'react-native';
import { useFocusEffect, useNavigation } from '@react-navigation/native';

import ContentCarousel from '@/components/common/ContentCarousel';
import LoadingScreen from '@/components/common/LoadingScreen';
import { useDataStore } from '@/stores';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

const { width: screenWidth } = Dimensions.get('window');

const HomeScreen: React.FC = () => {
  const navigation = useNavigation();
  
  // Store states (identique Vue computed)
  const {
    recipes,
    tips,
    events,
    recipesLoading,
    tipsLoading,
    eventsLoading,
    recipesError,
    tipsError,
    eventsError,
    fetchRecipes,
    fetchTips,
    fetchEvents,
    toggleLike,
  } = useDataStore();

  // Loading state global (identique Vue)
  const isLoading = recipesLoading && tipsLoading && eventsLoading;
  const isRefreshing = recipesLoading || tipsLoading || eventsLoading;

  // Derniers items (identique Vue computed)
  const latestRecipes = recipes.slice(0, 4);
  const latestTips = tips.slice(0, 4);
  const latestEvents = events.slice(0, 4);

  // Charger les données au focus (identique Vue onMounted)
  useFocusEffect(
    React.useCallback(() => {
      loadHomeData();
    }, [])
  );

  const loadHomeData = async () => {
    console.log('🏠 [Home] Chargement des données d\'accueil');
    
    // Charger en parallèle (identique Vue)
    await Promise.all([
      fetchRecipes({ limit: 4 }),
      fetchTips({ limit: 4 }),
      fetchEvents({ limit: 4 }),
    ]);
    
    console.log('✅ [Home] Données d\'accueil chargées');
  };

  // Refresh handler (pull to refresh)
  const handleRefresh = async () => {
    console.log('🔄 [Home] Refresh déclenché');
    await loadHomeData();
  };

  // Navigation handlers (identiques Vue)
  const handleRecipeClick = (recipe: any) => {
    console.log('🍳 [Home] Clic recette:', recipe.title);
    navigation.navigate('RecipeDetail', { id: recipe.id, recipe });
  };

  const handleTipClick = (tip: any) => {
    console.log('💡 [Home] Clic astuce:', tip.title);
    navigation.navigate('TipDetail', { id: tip.id, tip });
  };

  const handleEventClick = (event: any) => {
    console.log('📅 [Home] Clic événement:', event.title);
    navigation.navigate('EventDetail', { id: event.id, event });
  };

  // Like handlers (identiques Vue)
  const handleLike = async (type: 'recipes' | 'tips' | 'events', id: number) => {
    console.log('❤️ [Home] Toggle like:', { type, id });
    const result = await toggleLike(type, id);
    console.log('✅ [Home] Like result:', result);
  };

  // Formatters (identiques Vue)
  const getShortDescription = (text: string, limit = 80): string => {
    if (!text) return '';
    return text.length > limit ? `${text.substring(0, limit)}...` : text;
  };

  const getDifficultyLabel = (difficulty: string): string => {
    const labels = {
      'easy': 'Facile',
      'medium': 'Moyen',
      'hard': 'Difficile'
    };
    return labels[difficulty] || difficulty;
  };

  const formatDate = (dateString: string): string => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'short'
    });
  };

  // Loading screen initial (identique Vue)
  if (isLoading && recipes.length === 0 && tips.length === 0 && events.length === 0) {
    return <LoadingScreen visible={true} duration={1500} />;
  }

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.contentContainer}
      showsVerticalScrollIndicator={false}
      refreshControl={
        <RefreshControl
          refreshing={isRefreshing}
          onRefresh={handleRefresh}
          colors={[COLORS.PRIMARY_RED]}
          tintColor={COLORS.PRIMARY_RED}
        />
      }
    >
      {/* Zone de contenu principal (identique Vue .content-area) */}
      <View style={styles.contentArea}>
        
        {/* Recettes - 4 dernières (identique Vue) */}
        <ContentCarousel
          title="Dernières Recettes"
          items={latestRecipes}
          loading={recipesLoading}
          error={recipesError}
          contentType="recipes"
          viewAllLink="Recipes"
          onItemClick={handleRecipeClick}
          onLike={(id) => handleLike('recipes', id)}
          renderItem={(item) => (
            <View style={styles.recipeCard}>
              <View style={styles.cardImage}>
                {/* Image avec fallback */}
                <View style={styles.imagePlaceholder}>
                  <Text style={styles.placeholderText}>🍳</Text>
                </View>
                
                {/* Card overlay avec badges (identique Vue) */}
                <View style={styles.cardOverlay}>
                  {item.total_time && (
                    <View style={styles.timeBadge}>
                      <Text style={styles.badgeText}>{item.total_time}min</Text>
                    </View>
                  )}
                  {item.difficulty && (
                    <View style={styles.difficultyBadge}>
                      <Text style={styles.badgeText}>
                        {getDifficultyLabel(item.difficulty)}
                      </Text>
                    </View>
                  )}
                </View>
              </View>
              
              <View style={styles.cardContent}>
                <Text style={styles.cardTitle} numberOfLines={2}>
                  {item.title}
                </Text>
                <Text style={styles.cardDescription} numberOfLines={2}>
                  {getShortDescription(item.short_description)}
                </Text>
                
                <View style={styles.cardMeta}>
                  <View style={styles.likesContainer}>
                    <Text style={styles.likesText}>
                      ❤️ {item.likes_count || 0}
                    </Text>
                  </View>
                  <Text style={styles.dateText}>
                    {formatDate(item.created_at)}
                  </Text>
                </View>
              </View>
            </View>
          )}
        />

        {/* Astuces - 4 dernières (identique Vue) */}
        <ContentCarousel
          title="Dernières Astuces"
          items={latestTips}
          loading={tipsLoading}
          error={tipsError}
          contentType="tips"
          viewAllLink="Tips"
          onItemClick={handleTipClick}
          onLike={(id) => handleLike('tips', id)}
          renderItem={(item) => (
            <View style={styles.tipCard}>
              <View style={styles.tipIcon}>
                <Text style={styles.tipIconText}>💡</Text>
              </View>
              
              <View style={styles.cardContent}>
                <Text style={styles.cardTitle} numberOfLines={2}>
                  {item.title}
                </Text>
                <Text style={styles.cardDescription} numberOfLines={2}>
                  {getShortDescription(item.content)}
                </Text>
                
                <View style={styles.cardMeta}>
                  {item.estimated_time && (
                    <Text style={styles.timeText}>
                      ⏱️ {item.estimated_time}min
                    </Text>
                  )}
                  <Text style={styles.difficultyText}>
                    {getDifficultyLabel(item.difficulty_level)}
                  </Text>
                  <Text style={styles.dateText}>
                    {formatDate(item.created_at)}
                  </Text>
                </View>
              </View>
            </View>
          )}
        />

        {/* Événements - 4 derniers (identique Vue) */}
        <ContentCarousel
          title="Derniers Événements"
          items={latestEvents}
          loading={eventsLoading}
          error={eventsError}
          contentType="events"
          viewAllLink="Events"
          onItemClick={handleEventClick}
          onLike={(id) => handleLike('events', id)}
          renderItem={(item) => (
            <View style={styles.eventCard}>
              <View style={styles.eventImage}>
                <View style={styles.imagePlaceholder}>
                  <Text style={styles.placeholderText}>📅</Text>
                </View>
              </View>
              
              <View style={styles.cardContent}>
                <Text style={styles.cardTitle} numberOfLines={2}>
                  {item.title}
                </Text>
                <Text style={styles.cardDescription} numberOfLines={2}>
                  {getShortDescription(item.description)}
                </Text>
                
                <View style={styles.cardMeta}>
                  {item.date && (
                    <Text style={styles.eventDateText}>
                      📅 {formatDate(item.date)}
                    </Text>
                  )}
                  {item.location && (
                    <Text style={styles.locationText}>
                      📍 {item.location}
                    </Text>
                  )}
                </View>
              </View>
            </View>
          )}
        />
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND, // #F5F5F5 exact
  },
  
  contentContainer: {
    paddingBottom: DIMENSIONS.BOTTOM_NAV_HEIGHT + 20, // Espace pour bottom nav
  },
  
  // Zone de contenu principal (identique Vue .content-area)
  contentArea: {
    backgroundColor: COLORS.SURFACE, // #FFFFFF exact
    minHeight: DIMENSIONS.SCREEN_HEIGHT - 200,
    paddingVertical: 20,
    paddingHorizontal: DIMENSIONS.SPACING_4, // 16px exact
  },
  
  // RECIPE CARD (identique Vue .recipe-card)
  recipeCard: {
    backgroundColor: COLORS.WHITE,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    marginHorizontal: 8,
    width: 280, // Largeur fixe pour carousel
    shadowColor: COLORS.SHADOW,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  
  cardImage: {
    height: 160,
    borderTopLeftRadius: DIMENSIONS.BORDER_RADIUS,
    borderTopRightRadius: DIMENSIONS.BORDER_RADIUS,
    overflow: 'hidden',
    position: 'relative',
  },
  
  imagePlaceholder: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
    justifyContent: 'center',
    alignItems: 'center',
  },
  
  placeholderText: {
    fontSize: 48,
  },
  
  cardOverlay: {
    position: 'absolute',
    top: 8,
    right: 8,
    flexDirection: 'column',
    gap: 4,
  },
  
  timeBadge: {
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  
  difficultyBadge: {
    backgroundColor: COLORS.ORANGE_ACCENT,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  
  badgeText: {
    color: COLORS.WHITE,
    fontSize: TYPOGRAPHY.fontSize.sm - 1, // 11px
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
  
  cardContent: {
    padding: DIMENSIONS.SPACING_4, // 16px exact
  },
  
  cardTitle: {
    fontSize: TYPOGRAPHY.fontSize.md, // 16px exact
    fontWeight: TYPOGRAPHY.fontWeight.semibold, // 600 exact
    color: COLORS.DARK_GRAY, // #2D3748 exact
    fontFamily: TYPOGRAPHY.fontFamily.heading, // Open Sans exact
    marginBottom: 8,
    lineHeight: 22,
  },
  
  cardDescription: {
    fontSize: TYPOGRAPHY.fontSize.sm + 1, // 13px
    color: COLORS.MEDIUM_GRAY, // #4A5568 exact
    fontFamily: TYPOGRAPHY.fontFamily.primary, // Roboto exact
    lineHeight: 18,
    marginBottom: 12,
  },
  
  cardMeta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  
  likesContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  
  likesText: {
    fontSize: TYPOGRAPHY.fontSize.sm, // 12px exact
    color: COLORS.PRIMARY_RED,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
  
  dateText: {
    fontSize: TYPOGRAPHY.fontSize.sm, // 12px exact
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
  
  // TIP CARD (identique Vue .tip-card)
  tipCard: {
    backgroundColor: COLORS.GOLDEN, // #F4D03F exact (fond doré)
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    marginHorizontal: 8,
    width: 280,
    padding: DIMENSIONS.SPACING_4,
    shadowColor: COLORS.SHADOW,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  
  tipIcon: {
    alignSelf: 'center',
    marginBottom: 12,
  },
  
  tipIconText: {
    fontSize: 48,
  },
  
  timeText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.DARK_GRAY,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
  
  difficultyText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.DARK_GRAY,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
  
  // EVENT CARD
  eventCard: {
    backgroundColor: COLORS.WHITE,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    marginHorizontal: 8,
    width: 280,
    shadowColor: COLORS.SHADOW,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  
  eventImage: {
    height: 120,
    borderTopLeftRadius: DIMENSIONS.BORDER_RADIUS,
    borderTopRightRadius: DIMENSIONS.BORDER_RADIUS,
    overflow: 'hidden',
  },
  
  eventDateText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.PRIMARY_RED,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
  
  locationText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
  },
});

export default HomeScreen;