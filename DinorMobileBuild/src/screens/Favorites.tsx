import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  FlatList,
  Image,
  Alert,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '../styles/colors';
import { DinorIcon } from '../components/icons/DinorIcon';
import { LikeButton } from '../components/common/LikeButton';
import { FavoriteButton } from '../components/common/FavoriteButton';
import { useAuthStore } from '../stores/authStore';
import { apiService } from '../services/api';
import { ContentType } from '../hooks/useLikes';

interface FavoriteItem {
  id: number;
  favoritable_id: number;
  favoritable_type: ContentType;
  created_at: string;
  content: {
    id: number;
    title: string;
    description?: string;
    image?: string;
    author?: {
      name: string;
    };
    likes_count?: number;
    is_liked?: boolean;
    category?: {
      name: string;
    };
    // Recipe specific
    prep_time?: number;
    cook_time?: number;
    difficulty_level?: string;
    // Event specific
    event_date?: string;
    location?: string;
  };
}

type FilterType = 'all' | 'recipe' | 'tip' | 'event' | 'dinor_tv';

const FILTER_OPTIONS = [
  { key: 'all', label: 'Tout', icon: 'grid-3x3' },
  { key: 'recipe', label: 'Recettes', icon: 'chef-hat' },
  { key: 'tip', label: 'Astuces', icon: 'lightbulb' },
  { key: 'event', label: 'Événements', icon: 'calendar' },
  { key: 'dinor_tv', label: 'Vidéos', icon: 'tv' },
] as const;

export const FavoritesScreen: React.FC = () => {
  const { user, isAuthenticated } = useAuthStore();
  const [favorites, setFavorites] = useState<FavoriteItem[]>([]);
  const [filteredFavorites, setFilteredFavorites] = useState<FavoriteItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [activeFilter, setActiveFilter] = useState<FilterType>('all');

  useEffect(() => {
    if (isAuthenticated) {
      loadFavorites();
    }
  }, [isAuthenticated]);

  useEffect(() => {
    applyFilter();
  }, [favorites, activeFilter]);

  const loadFavorites = async () => {
    try {
      setLoading(true);
      const response = await apiService.get('/favorites', {
        include: 'content,content.author,content.category',
        per_page: 50,
      });
      
      if (response.success) {
        setFavorites(response.data.data || response.data);
      }
    } catch (error) {
      console.error('Error loading favorites:', error);
    } finally {
      setLoading(false);
    }
  };

  const applyFilter = () => {
    if (activeFilter === 'all') {
      setFilteredFavorites(favorites);
    } else {
      setFilteredFavorites(
        favorites.filter(item => item.favoritable_type === activeFilter)
      );
    }
  };

  const removeFavorite = async (favoriteId: number) => {
    try {
      const response = await apiService.delete(`/favorites/${favoriteId}`);
      if (response.success) {
        setFavorites(prev => prev.filter(item => item.id !== favoriteId));
      }
    } catch (error) {
      console.error('Error removing favorite:', error);
      Alert.alert('Erreur', 'Impossible de supprimer le favori');
    }
  };

  const getContentTypeLabel = (type: ContentType) => {
    const option = FILTER_OPTIONS.find(opt => opt.key === type);
    return option?.label || type;
  };

  const getContentTypeIcon = (type: ContentType) => {
    const option = FILTER_OPTIONS.find(opt => opt.key === type);
    return option?.icon || 'file';
  };

  const renderFilterButton = (option: typeof FILTER_OPTIONS[0]) => {
    const isActive = activeFilter === option.key;
    
    return (
      <TouchableOpacity
        key={option.key}
        style={[
          styles.filterButton,
          isActive && styles.activeFilterButton,
        ]}
        onPress={() => setActiveFilter(option.key)}
      >
        <DinorIcon 
          name={option.icon} 
          size={16} 
          color={isActive ? COLORS.WHITE : COLORS.MEDIUM_GRAY} 
        />
        <Text style={[
          styles.filterButtonText,
          isActive && styles.activeFilterButtonText,
        ]}>
          {option.label}
        </Text>
      </TouchableOpacity>
    );
  };

  const renderFavoriteItem = ({ item }: { item: FavoriteItem }) => {
    const { content } = item;
    
    return (
      <View style={styles.favoriteCard}>
        {/* Content Image */}
        <View style={styles.cardHeader}>
          {content.image ? (
            <Image
              source={{ uri: content.image }}
              style={styles.contentImage}
              resizeMode="cover"
            />
          ) : (
            <View style={styles.placeholderImage}>
              <DinorIcon 
                name={getContentTypeIcon(item.favoritable_type)} 
                size={32} 
                color={COLORS.MEDIUM_GRAY} 
              />
            </View>
          )}
          
          {/* Content Type Badge */}
          <View style={styles.typeBadge}>
            <Text style={styles.typeBadgeText}>
              {getContentTypeLabel(item.favoritable_type)}
            </Text>
          </View>
        </View>

        {/* Content Info */}
        <View style={styles.cardContent}>
          <Text style={styles.contentTitle} numberOfLines={2}>
            {content.title}
          </Text>
          
          {content.description && (
            <Text style={styles.contentDescription} numberOfLines={2}>
              {content.description}
            </Text>
          )}

          {/* Metadata */}
          <View style={styles.metadata}>
            {content.author && (
              <View style={styles.metadataItem}>
                <DinorIcon name="user" size={14} color={COLORS.MEDIUM_GRAY} />
                <Text style={styles.metadataText}>{content.author.name}</Text>
              </View>
            )}
            
            {content.category && (
              <View style={styles.metadataItem}>
                <DinorIcon name="tag" size={14} color={COLORS.MEDIUM_GRAY} />
                <Text style={styles.metadataText}>{content.category.name}</Text>
              </View>
            )}

            {/* Recipe specific metadata */}
            {item.favoritable_type === 'recipe' && content.prep_time && (
              <View style={styles.metadataItem}>
                <DinorIcon name="clock" size={14} color={COLORS.MEDIUM_GRAY} />
                <Text style={styles.metadataText}>
                  {content.prep_time + (content.cook_time || 0)} min
                </Text>
              </View>
            )}

            {/* Event specific metadata */}
            {item.favoritable_type === 'event' && content.event_date && (
              <View style={styles.metadataItem}>
                <DinorIcon name="calendar" size={14} color={COLORS.MEDIUM_GRAY} />
                <Text style={styles.metadataText}>
                  {new Date(content.event_date).toLocaleDateString()}
                </Text>
              </View>
            )}
          </View>

          {/* Actions */}
          <View style={styles.cardActions}>
            <View style={styles.actionsLeft}>
              <LikeButton
                contentType={item.favoritable_type}
                contentId={content.id}
                initialIsLiked={content.is_liked}
                initialLikesCount={content.likes_count}
                size="small"
                variant="compact"
              />
              
              <FavoriteButton
                contentType={item.favoritable_type}
                contentId={content.id}
                initialIsFavorited={true}
                size="small"
                variant="minimal"
              />
            </View>

            <TouchableOpacity
              style={styles.removeButton}
              onPress={() => {
                Alert.alert(
                  'Supprimer des favoris',
                  'Êtes-vous sûr de vouloir supprimer ce contenu de vos favoris ?',
                  [
                    { text: 'Annuler', style: 'cancel' },
                    { 
                      text: 'Supprimer', 
                      style: 'destructive',
                      onPress: () => removeFavorite(item.id),
                    },
                  ]
                );
              }}
            >
              <DinorIcon name="trash-2" size={16} color={COLORS.PRIMARY_RED} />
            </TouchableOpacity>
          </View>
        </View>
      </View>
    );
  };

  if (!isAuthenticated) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.authPrompt}>
          <DinorIcon name="bookmark" size={64} color={COLORS.MEDIUM_GRAY} />
          <Text style={styles.authTitle}>Mes favoris</Text>
          <Text style={styles.authText}>
            Connectez-vous pour voir vos contenus favoris.
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Mes favoris</Text>
        <Text style={styles.subtitle}>
          {filteredFavorites.length} contenu{filteredFavorites.length > 1 ? 's' : ''}
        </Text>
      </View>

      {/* Filter Tabs */}
      <ScrollView 
        horizontal 
        showsHorizontalScrollIndicator={false}
        style={styles.filtersContainer}
        contentContainerStyle={styles.filtersContent}
      >
        {FILTER_OPTIONS.map(renderFilterButton)}
      </ScrollView>

      {/* Content */}
      <View style={styles.content}>
        {loading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color={COLORS.PRIMARY_RED} />
            <Text style={styles.loadingText}>Chargement de vos favoris...</Text>
          </View>
        ) : filteredFavorites.length === 0 ? (
          <View style={styles.emptyState}>
            <DinorIcon name="bookmark" size={64} color={COLORS.MEDIUM_GRAY} />
            <Text style={styles.emptyTitle}>
              {activeFilter === 'all' 
                ? 'Aucun favori' 
                : `Aucun favori ${getContentTypeLabel(activeFilter).toLowerCase()}`}
            </Text>
            <Text style={styles.emptyText}>
              Explorez l'application et ajoutez des contenus à vos favoris pour les retrouver ici.
            </Text>
          </View>
        ) : (
          <FlatList
            data={filteredFavorites}
            renderItem={renderFavoriteItem}
            keyExtractor={(item) => `${item.favoritable_type}-${item.id}`}
            showsVerticalScrollIndicator={false}
            contentContainerStyle={styles.favoritesList}
          />
        )}
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
  },
  header: {
    padding: DIMENSIONS.SPACING_4,
    backgroundColor: COLORS.WHITE,
    borderBottomWidth: 1,
    borderBottomColor: '#E2E8F0',
  },
  title: {
    fontSize: TYPOGRAPHY.fontSize.xl,
    fontWeight: 'bold',
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.heading,
  },
  subtitle: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
    marginTop: 4,
  },
  filtersContainer: {
    backgroundColor: COLORS.WHITE,
    borderBottomWidth: 1,
    borderBottomColor: '#E2E8F0',
  },
  filtersContent: {
    paddingHorizontal: DIMENSIONS.SPACING_4,
    paddingVertical: 12,
  },
  filterButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: COLORS.MEDIUM_GRAY,
    marginRight: 8,
    backgroundColor: COLORS.WHITE,
  },
  activeFilterButton: {
    backgroundColor: COLORS.PRIMARY_RED,
    borderColor: COLORS.PRIMARY_RED,
  },
  filterButtonText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
    marginLeft: 6,
    fontWeight: '500',
  },
  activeFilterButtonText: {
    color: COLORS.WHITE,
  },
  content: {
    flex: 1,
  },
  authPrompt: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: DIMENSIONS.SPACING_4 * 2,
  },
  authTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: 'bold',
    color: COLORS.DARK_GRAY,
    marginTop: DIMENSIONS.SPACING_4,
    marginBottom: 8,
  },
  authText: {
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.MEDIUM_GRAY,
    textAlign: 'center',
    lineHeight: 22,
  },
  loadingContainer: {
    alignItems: 'center',
    padding: DIMENSIONS.SPACING_4 * 2,
  },
  loadingText: {
    marginTop: 12,
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.MEDIUM_GRAY,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: DIMENSIONS.SPACING_4 * 2,
  },
  emptyTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: 'bold',
    color: COLORS.DARK_GRAY,
    marginTop: DIMENSIONS.SPACING_4,
    marginBottom: 8,
  },
  emptyText: {
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.MEDIUM_GRAY,
    textAlign: 'center',
    lineHeight: 22,
  },
  favoritesList: {
    padding: DIMENSIONS.SPACING_4,
  },
  favoriteCard: {
    backgroundColor: COLORS.WHITE,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    marginBottom: 12,
    overflow: 'hidden',
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  cardHeader: {
    position: 'relative',
  },
  contentImage: {
    width: '100%',
    height: 120,
  },
  placeholderImage: {
    width: '100%',
    height: 120,
    backgroundColor: '#F7FAFC',
    justifyContent: 'center',
    alignItems: 'center',
  },
  typeBadge: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: COLORS.PRIMARY_RED,
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  typeBadgeText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.WHITE,
    fontWeight: '600',
  },
  cardContent: {
    padding: DIMENSIONS.SPACING_4,
  },
  contentTitle: {
    fontSize: TYPOGRAPHY.fontSize.md,
    fontWeight: 'bold',
    color: COLORS.DARK_GRAY,
    marginBottom: 6,
    lineHeight: 20,
  },
  contentDescription: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
    marginBottom: 12,
    lineHeight: 18,
  },
  metadata: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 12,
  },
  metadataItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginRight: 16,
    marginBottom: 4,
  },
  metadataText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.MEDIUM_GRAY,
    marginLeft: 4,
  },
  cardActions: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  actionsLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  removeButton: {
    padding: 8,
  },
});