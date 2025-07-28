/**
 * ÉCRAN CONVERTI : Tips (Astuces)
 * 
 * Structure identique à Recipes mais adaptée pour les astuces
 */

import React, { useState } from 'react';
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

const TipsScreen: React.FC = () => {
  const navigation = useNavigation();
  
  const {
    tips,
    tipsLoading,
    tipsError,
    fetchTips,
    toggleLike,
  } = useDataStore();

  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);

  const filteredTips = tips.filter(tip =>
    tip.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    (tip.content && tip.content.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  useFocusEffect(
    React.useCallback(() => {
      if (tips.length === 0) {
        loadTips();
      }
    }, [])
  );

  const loadTips = async () => {
    console.log('💡 [Tips] Chargement astuces');
    await fetchTips({ limit: 50 });
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadTips();
    setRefreshing(false);
  };

  const handleTipClick = (tip: any) => {
    console.log('💡 [Tips] Navigation vers astuce:', tip.title);
    navigation.navigate('TipDetail', { id: tip.id, tip });
  };

  const handleLike = async (id: number) => {
    await toggleLike('tips', id);
  };

  const getShortDescription = (text: string, limit = 120): string => {
    if (!text) return '';
    return text.length > limit ? `${text.substring(0, limit)}...` : text;
  };

  const getDifficultyLabel = (difficulty: string): string => {
    const labels = {
      'easy': 'Facile',
      'medium': 'Moyen', 
      'hard': 'Difficile'
    };
    return labels[difficulty as keyof typeof labels] || difficulty;
  };

  const formatDate = (dateString: string): string => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'short',
    });
  };

  const renderTipCard = ({ item: tip }: { item: any }) => (
    <TouchableOpacity
      style={styles.tipCard}
      onPress={() => handleTipClick(tip)}
      activeOpacity={0.9}
    >
      <View style={styles.tipIcon}>
        <Text style={styles.tipIconText}>💡</Text>
      </View>
      
      <View style={styles.cardContent}>
        <Text style={styles.cardTitle} numberOfLines={2}>
          {tip.title}
        </Text>
        
        <Text style={styles.cardDescription} numberOfLines={4}>
          {getShortDescription(tip.content)}
        </Text>
        
        <View style={styles.cardMeta}>
          <TouchableOpacity
            style={styles.likeButton}
            onPress={() => handleLike(tip.id)}
            activeOpacity={0.7}
          >
            <DinorIcon
              name={tip.is_liked ? 'favorite' : 'favorite_border'}
              size={18}
              color={tip.is_liked ? COLORS.PRIMARY_RED : COLORS.MEDIUM_GRAY}
              filled={tip.is_liked}
            />
            <Text style={[
              styles.likesText,
              tip.is_liked && styles.likesTextActive
            ]}>
              {tip.likes_count || 0}
            </Text>
          </TouchableOpacity>
          
          {tip.estimated_time && (
            <Text style={styles.timeText}>
              ⏱️ {tip.estimated_time}min
            </Text>
          )}
          
          <Text style={styles.difficultyText}>
            {getDifficultyLabel(tip.difficulty_level)}
          </Text>
          
          <Text style={styles.dateText}>
            {formatDate(tip.created_at)}
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  return (
    <View style={styles.container}>
      {/* Search bar */}
      <View style={styles.searchContainer}>
        <View style={styles.searchInputContainer}>
          <DinorIcon name="search" size={20} color={COLORS.MEDIUM_GRAY} />
          <TextInput
            style={styles.searchInput}
            placeholder="Rechercher une astuce..."
            placeholderTextColor={COLORS.MEDIUM_GRAY}
            value={searchQuery}
            onChangeText={setSearchQuery}
            autoCorrect={false}
            autoCapitalize="none"
          />
          {searchQuery.length > 0 && (
            <TouchableOpacity onPress={() => setSearchQuery('')}>
              <DinorIcon name="close" size={20} color={COLORS.MEDIUM_GRAY} />
            </TouchableOpacity>
          )}
        </View>
      </View>

      {/* Liste des astuces */}
      <FlatList
        data={filteredTips}
        keyExtractor={(item) => `tip-${item.id}`}
        renderItem={renderTipCard}
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
        ListEmptyComponent={() => (
          <View style={styles.emptyContainer}>
            <DinorIcon name="lightbulb" size={64} color={COLORS.MEDIUM_GRAY} />
            <Text style={styles.emptyTitle}>Aucune astuce trouvée</Text>
            <Text style={styles.emptyText}>
              {searchQuery 
                ? `Aucune astuce ne correspond à "${searchQuery}"`
                : "Aucune astuce n'est disponible pour le moment"
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
  
  listContent: {
    padding: DIMENSIONS.SPACING_4,
    paddingBottom: DIMENSIONS.BOTTOM_NAV_HEIGHT + 20,
  },
  
  // Tip card (fond doré comme Vue)
  tipCard: {
    backgroundColor: COLORS.GOLDEN, // #F4D03F exact
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    marginBottom: 16,
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
  
  cardContent: {
    flex: 1,
  },
  
  cardTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: TYPOGRAPHY.fontWeight.semibold,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.heading,
    marginBottom: 8,
    lineHeight: 26,
    textAlign: 'center',
  },
  
  cardDescription: {
    fontSize: TYPOGRAPHY.fontSize.md,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    lineHeight: 22,
    marginBottom: 16,
    textAlign: 'center',
  },
  
  cardMeta: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    flexWrap: 'wrap',
    gap: 8,
  },
  
  likeButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingVertical: 4,
    paddingHorizontal: 8,
    borderRadius: 15,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
  },
  
  likesText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.DARK_GRAY,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
  
  likesTextActive: {
    color: COLORS.PRIMARY_RED,
  },
  
  timeText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.DARK_GRAY,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  
  difficultyText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.DARK_GRAY,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  
  dateText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.DARK_GRAY,
    fontFamily: TYPOGRAPHY.fontFamily.primary,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  
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

export default TipsScreen;