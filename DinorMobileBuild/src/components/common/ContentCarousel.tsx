/**
 * COMPOSANT CONVERTI : ContentCarousel
 * 
 * FIDÉLITÉ VISUELLE :
 * - Design carousel horizontal identique Vue
 * - En-tête avec titre et lien "Voir tout"
 * - Cards scrollables horizontalement
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Scroll horizontal avec snap
 * - Loading states identiques
 * - Gestion erreurs identique
 * - Actions clicks identiques
 */

import React from 'react';
import {
  View,
  Text,
  FlatList,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Dimensions,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';

import DinorIcon from '@/components/icons/DinorIcon';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

const { width: screenWidth } = Dimensions.get('window');

interface ContentCarouselProps {
  title: string;
  items: any[];
  loading: boolean;
  error: string | null;
  contentType: 'recipes' | 'tips' | 'events';
  viewAllLink: string;
  onItemClick: (item: any) => void;
  onLike?: (id: number) => void;
  renderItem: (item: any) => React.ReactNode;
}

const ContentCarousel: React.FC<ContentCarouselProps> = ({
  title,
  items,
  loading,
  error,
  contentType,
  viewAllLink,
  onItemClick,
  onLike,
  renderItem,
}) => {
  const navigation = useNavigation();

  const handleViewAll = () => {
    console.log('👀 [ContentCarousel] Voir tout:', viewAllLink);
    navigation.navigate(viewAllLink as never);
  };

  const handleItemPress = (item: any) => {
    console.log('📱 [ContentCarousel] Item cliqué:', item.title);
    onItemClick(item);
  };

  // Loading state (identique Vue)
  if (loading && items.length === 0) {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>{title}</Text>
        </View>
        
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={COLORS.PRIMARY_RED} />
          <Text style={styles.loadingText}>Chargement...</Text>
        </View>
      </View>
    );
  }

  // Error state (identique Vue)
  if (error && items.length === 0) {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>{title}</Text>
        </View>
        
        <View style={styles.errorContainer}>
          <DinorIcon name="error" size={48} color={COLORS.ERROR} />
          <Text style={styles.errorText}>{error}</Text>
        </View>
      </View>
    );
  }

  // Empty state (identique Vue)
  if (!loading && items.length === 0) {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <Text style={styles.title}>{title}</Text>
        </View>
        
        <View style={styles.emptyContainer}>
          <Text style={styles.emptyText}>
            Aucun contenu disponible pour le moment
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {/* Header avec titre et lien "Voir tout" (identique Vue) */}
      <View style={styles.header}>
        <Text style={styles.title}>{title}</Text>
        
        <TouchableOpacity 
          style={styles.viewAllButton}
          onPress={handleViewAll}
          activeOpacity={0.7}
        >
          <Text style={styles.viewAllText}>Voir tout</Text>
          <DinorIcon name="chevron_right" size={16} color={COLORS.PRIMARY_RED} />
        </TouchableOpacity>
      </View>

      {/* Carousel horizontal (identique Vue) */}
      <FlatList
        data={items}
        horizontal
        showsHorizontalScrollIndicator={false}
        keyExtractor={(item) => `${contentType}-${item.id}`}
        contentContainerStyle={styles.carouselContent}
        snapToInterval={288} // 280px + 8px margin
        decelerationRate="fast"
        snapToAlignment="start"
        renderItem={({ item }) => (
          <TouchableOpacity
            activeOpacity={0.9}
            onPress={() => handleItemPress(item)}
          >
            {renderItem(item)}
          </TouchableOpacity>
        )}
        ListFooterComponent={() => <View style={{ width: 16 }} />} // Espace final
      />

      {/* Loading overlay si refresh */}
      {loading && items.length > 0 && (
        <View style={styles.refreshOverlay}>
          <ActivityIndicator size="small" color={COLORS.PRIMARY_RED} />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 32, // Espacement entre sections (identique Vue)
  },
  
  // Header avec titre et "Voir tout" (identique Vue)
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: DIMENSIONS.SPACING_4, // 16px exact
    marginBottom: 16,
  },
  
  title: {
    fontSize: TYPOGRAPHY.fontSize.lg + 2, // 22px
    fontWeight: TYPOGRAPHY.fontWeight.semibold, // 600 exact
    color: COLORS.DARK_GRAY, // #2D3748 exact
    fontFamily: TYPOGRAPHY.fontFamily.heading, // Open Sans exact
  },
  
  viewAllButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 20,
    backgroundColor: 'rgba(229, 62, 62, 0.1)', // Rouge très léger
  },
  
  viewAllText: {
    fontSize: TYPOGRAPHY.fontSize.sm + 1, // 13px
    fontWeight: TYPOGRAPHY.fontWeight.medium, // 500 exact
    color: COLORS.PRIMARY_RED, // #E53E3E exact
    fontFamily: TYPOGRAPHY.fontFamily.primary, // Roboto exact
  },
  
  // Carousel content
  carouselContent: {
    paddingLeft: DIMENSIONS.SPACING_4, // 16px exact
  },
  
  // Loading states (identiques Vue)
  loadingContainer: {
    height: 200,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.BACKGROUND,
    marginHorizontal: DIMENSIONS.SPACING_4,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
  },
  
  loadingText: {
    marginTop: 12,
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
  },
  
  // Error state (identique Vue)
  errorContainer: {
    height: 200,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.BACKGROUND,
    marginHorizontal: DIMENSIONS.SPACING_4,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
  },
  
  errorText: {
    marginTop: 12,
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.ERROR,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  
  // Empty state (identique Vue)
  emptyContainer: {
    height: 120,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.BACKGROUND,
    marginHorizontal: DIMENSIONS.SPACING_4,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
  },
  
  emptyText: {
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.MEDIUM_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  
  // Refresh overlay
  refreshOverlay: {
    position: 'absolute',
    top: 60,
    right: 20,
    backgroundColor: COLORS.WHITE,
    padding: 8,
    borderRadius: 20,
    shadowColor: COLORS.SHADOW,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 4,
  },
});

export default ContentCarousel;