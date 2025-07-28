/**
 * ÉCRAN CONVERTI : Recipes
 * 
 * FIDÉLITÉ VISUELLE :
 * - Liste des recettes avec même design de cartes
 * - Search et filtres identiques Vue
 * - Pull to refresh et pagination
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Chargement avec pagination
 * - Recherche en temps réel
 * - Navigation vers détail identique
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  RefreshControl,
  TextInput,
  ActivityIndicator,
} from 'react-native';
import { useFocusEffect, useNavigation } from '@react-navigation/native';

import DinorIcon from '@/components/icons/DinorIcon';
import { useDataStore } from '@/stores';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

const RecipesScreen: React.FC = () => {
  const navigation = useNavigation();
  
  // Store states
  const {
    recipes,
    recipesLoading,
    recipesError,
    fetchRecipes,
    toggleLike,
  } = useDataStore();

  // Local states
  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  const [page, setPage] = useState(1);
  const [hasMoreData, setHasMoreData] = useState(true);

  // Filtrer les recettes selon la recherche (identique Vue computed)
  const filteredRecipes = recipes.filter(recipe =>
    recipe.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    (recipe.short_description && recipe.short_description.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  // Charger les données au focus
  useFocusEffect(
    React.useCallback(() => {
      if (recipes.length === 0) {
        loadRecipes(true);
      }
    }, [])
  );

  const loadRecipes = async (reset = false) => {
    const currentPage = reset ? 1 : page;
    
    if (reset) {
      setPage(1);
      setHasMoreData(true);
    }

    console.log('🍳 [Recipes] Chargement recettes page:', currentPage);
    
    const params = {
      page: currentPage,
      limit: 20,
      ...(searchQuery && { search: searchQuery })
    };

    const result = await fetchRecipes(params);
    
    if (result.length < 20) {
      setHasMoreData(false);
    }

    if (!reset) {
      setPage(prev => prev + 1);
    }
    
    console.log('✅ [Recipes] Recettes chargées:', result.length);
  };

  // Refresh handler
  const handleRefresh = async () => {
    setRefreshing(true);
    await loadRecipes(true);
    setRefreshing(false);
  };

  // Load more handler
  const handleLoadMore = async () => {
    if (!loadingMore && hasMoreData && !recipesLoading) {
      setLoadingMore(true);
      await loadRecipes(false);
      setLoadingMore(false);
    }
  };

  // Search handler
  const handleSearch = (query: string) => {
    setSearchQuery(query);
    // Debounce search si nécessaire
  };

  // Navigation handler
  const handleRecipeClick = (recipe: any) => {
    console.log('🍳 [Recipes] Navigation vers recette:', recipe.title);
    navigation.navigate('RecipeDetail', { id: recipe.id, recipe });
  };

  // Like handler
  const handleLike = async (id: number) => {
    console.log('❤️ [Recipes] Toggle like:', id);
    await toggleLike('recipes', id);
  };

  // Formatters (identiques Vue)
  const getShortDescription = (text: string, limit = 100): string => {
    if (!text) return '';
    return text.length > limit ? `${text.substring(0, limit)}...` : text;
  };

  const getDifficultyLabel = (difficulty: string): string => {
    const labels: Record<string, string> = {
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
      month: 'short',
      year: 'numeric'
    });
  };

  // Render recipe card (identique Vue template)
  const renderRecipeCard = ({ item: recipe }: { item: any }) => (
    <TouchableOpacity
      style={styles.recipeCard}
      onPress={() => handleRecipeClick(recipe)}
      activeOpacity={0.9}
    >
      <View style={styles.cardImage}>
        <View style={styles.imagePlaceholder}>
          <Text style={styles.placeholderText}>🍳</Text>
        </View>
        
        {/* Overlay avec badges */}
        <View style={styles.cardOverlay}>
          {recipe.total_time && (
            <View style={styles.timeBadge}>
              <Text style={styles.badgeText}>{recipe.total_time}min</Text>
            </View>
          )}
          {recipe.difficulty && (
            <View style={styles.difficultyBadge}>
              <Text style={styles.badgeText}>
                {getDifficultyLabel(recipe.difficulty)}
              </Text>
            </View>
          )}
        </View>
      </View>
      
      <View style={styles.cardContent}>
        <Text style={styles.cardTitle} numberOfLines={2}>
          {recipe.title}
        </Text>
        
        <Text style={styles.cardDescription} numberOfLines={3}>
          {getShortDescription(recipe.short_description)}
        </Text>
        
        <View style={styles.cardMeta}>
          <TouchableOpacity
            style={styles.likeButton}
            onPress={() => handleLike(recipe.id)}
            activeOpacity={0.7}
          >
            <DinorIcon
              name={recipe.is_liked ? 'favorite' : 'favorite_border'}
              size={20}
              color={recipe.is_liked ? COLORS.PRIMARY_RED : COLORS.MEDIUM_GRAY}
              filled={recipe.is_liked}
            />
            <Text style={[
              styles.likesText,
              recipe.is_liked && styles.likesTextActive
            ]}>
              {recipe.likes_count || 0}
            </Text>
          </TouchableOpacity>
          
          <Text style={styles.dateText}>
            {formatDate(recipe.created_at)}
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  // Render footer
  const renderFooter = () => {
    if (!loadingMore) return null;
    
    return (
      <View style={styles.footerLoader}>
        <ActivityIndicator size="small" color={COLORS.PRIMARY_RED} />
        <Text style={styles.footerText}>Chargement...</Text>
      </View>
    );
  };

  return (
    <View style={styles.container}>
      {/* Search bar (identique Vue) */}
      <View style={styles.searchContainer}>
        <View style={styles.searchInputContainer}>
          <DinorIcon name="search" size={20} color={COLORS.MEDIUM_GRAY} />
          <TextInput
            style={styles.searchInput}
            placeholder="Rechercher une recette..."
            placeholderTextColor={COLORS.MEDIUM_GRAY}
            value={searchQuery}
            onChangeText={handleSearch}
            autoCorrect={false}
            autoCapitalize="none"
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity onPress={() => handleSearch('')}>
              <DinorIcon name="close" size={20} color={COLORS.MEDIUM_GRAY} />
            </TouchableOpacity>
          )}
        </View>
      </View>

      {/* Liste des recettes */}
      <FlatList
        data={filteredRecipes}
        keyExtractor={(item) => `recipe-${item.id}`}
        renderItem={renderRecipeCard}
        contentContainerStyle={styles.listContent}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={handleRefresh}
            colors={[COLORS.PRIMARY_RED]}
            tintColor={COLORS.PRIMARY_RED}
          />
        }
        onEndReached={handleLoadMore}
        onEndReachedThreshold={0.5}
        ListFooterComponent={renderFooter}
        ListEmptyComponent={() => (
          <View style={styles.emptyContainer}>
            <DinorIcon name="restaurant" size={64} color={COLORS.MEDIUM_GRAY} />
            <Text style={styles.emptyTitle}>Aucune recette trouvée</Text>
            <Text style={styles.emptyText}>
              {searchQuery 
                ? `Aucune recette ne correspond à "${searchQuery}"`
                : "Aucune recette n'est disponible pour le moment"
              }
            </Text>
          </View>
        )}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
  },
  
  // Search container (identique Vue)
  searchContainer: {
    backgroundColor: COLORS.WHITE,
    paddingHorizontal: DIMENSIONS.SPACING_4,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(0, 0, 0, 0.05)',
  },
  
  searchInputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.BACKGROUND,
    borderRadius: 25,
    paddingHorizontal: 16,
    paddingVertical: 10,
    gap: 12,
  },
  
  searchInput: {
    flex: 1,
    fontSize: TYPOGRAPHY.fontSize.md,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    color: COLORS.DARK_GRAY,
  },
  
  // Liste content
  listContent: {
    padding: DIMENSIONS.SPACING_4,
    paddingBottom: DIMENSIONS.BOTTOM_NAV_HEIGHT + 20,
  },
  
  // Recipe card (identique Home mais pleine largeur)
  recipeCard: {
    backgroundColor: COLORS.WHITE,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    marginBottom: 16,
    shadowColor: COLORS.SHADOW,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  
  cardImage: {
    height: 200,
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
    fontSize: 64,
  },
  
  cardOverlay: {
    position: 'absolute',
    top: 12,
    right: 12,
    flexDirection: 'column',
    gap: 6,
  },
  
  timeBadge: {
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 15,
  },
  
  difficultyBadge: {
    backgroundColor: COLORS.ORANGE_ACCENT,
    paddingHorizontal: 10,
    paddingVertical: 5,
    borderRadius: 15,
  },
  
  badgeText: {
    color: COLORS.WHITE,
    fontSize: TYPOGRAPHY.fontSize.sm,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
  
  cardContent: {
    padding: DIMENSIONS.SPACING_4,
  },
  
  cardTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg, // 20px
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.heading,
    marginBottom: 8,
    lineHeight: 26,
  },
  
  cardDescription: {
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    lineHeight: 22,
    marginBottom: 16,
  },
  
  cardMeta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  
  likeButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingVertical: 4,
    paddingHorizontal: 8,
    borderRadius: 20,
  },
  
  likesText: {
    fontSize: TYPOGRAPHY.fontSize.sm + 1,
    color: COLORS.MEDIUM_GRAY,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
  
  likesTextActive: {
    color: COLORS.PRIMARY_RED,
  },
  
  dateText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
  
  // Footer loader
  footerLoader: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 20,
    gap: 8,
  },
  
  footerText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
  
  // Empty state
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 60,
    paddingHorizontal: 40,
  },
  
  emptyTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg + 2,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.heading,
    marginTop: 16,
    marginBottom: 8,
    textAlign: 'center',
  },
  
  emptyText: {
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    textAlign: 'center',
    lineHeight: 22,
  },
});

export default RecipesScreen;