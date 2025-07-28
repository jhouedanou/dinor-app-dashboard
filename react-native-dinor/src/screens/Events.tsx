/**
 * ÉCRAN CONVERTI : Events (Événements)
 * Structure identique aux autres listes
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
} from 'react-native';
import { useFocusEffect, useNavigation } from '@react-navigation/native';

import DinorIcon from '@/components/icons/DinorIcon';
import { useDataStore } from '@/stores';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '@/styles';

const EventsScreen: React.FC = () => {
  const navigation = useNavigation();
  
  const {
    events,
    eventsLoading,
    eventsError,
    fetchEvents,
    toggleLike,
  } = useDataStore();

  const [searchQuery, setSearchQuery] = useState('');
  const [refreshing, setRefreshing] = useState(false);

  const filteredEvents = events.filter(event =>
    event.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    (event.description && event.description.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  useFocusEffect(
    React.useCallback(() => {
      if (events.length === 0) {
        loadEvents();
      }
    }, [])
  );

  const loadEvents = async () => {
    console.log('📅 [Events] Chargement événements');
    await fetchEvents({ limit: 50 });
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadEvents();
    setRefreshing(false);
  };

  const handleEventClick = (event: any) => {
    console.log('📅 [Events] Navigation vers événement:', event.title);
    navigation.navigate('EventDetail', { id: event.id, event });
  };

  const handleLike = async (id: number) => {
    await toggleLike('events', id);
  };

  const getShortDescription = (text: string, limit = 100): string => {
    if (!text) return '';
    return text.length > limit ? `${text.substring(0, limit)}...` : text;
  };

  const formatDate = (dateString: string): string => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('fr-FR', {
      day: 'numeric',
      month: 'long',
      year: 'numeric'
    });
  };

  const formatTime = (dateString: string): string => {
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleTimeString('fr-FR', {
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const renderEventCard = ({ item: event }: { item: any }) => (
    <TouchableOpacity
      style={styles.eventCard}
      onPress={() => handleEventClick(event)}
      activeOpacity={0.9}
    >
      <View style={styles.cardImage}>
        <View style={styles.imagePlaceholder}>
          <Text style={styles.placeholderText}>📅</Text>
        </View>
      </View>
      
      <View style={styles.cardContent}>
        <Text style={styles.cardTitle} numberOfLines={2}>
          {event.title}
        </Text>
        
        <Text style={styles.cardDescription} numberOfLines={3}>
          {getShortDescription(event.description)}
        </Text>
        
        <View style={styles.cardMeta}>
          <TouchableOpacity
            style={styles.likeButton}
            onPress={() => handleLike(event.id)}
            activeOpacity={0.7}
          >
            <DinorIcon
              name={event.is_liked ? 'favorite' : 'favorite_border'}
              size={18}
              color={event.is_liked ? COLORS.PRIMARY_RED : COLORS.MEDIUM_GRAY}
              filled={event.is_liked}
            />
            <Text style={[
              styles.likesText,
              event.is_liked && styles.likesTextActive
            ]}>
              {event.likes_count || 0}
            </Text>
          </TouchableOpacity>
          
          {event.date && (
            <Text style={styles.eventDateText}>
              📅 {formatDate(event.date)}
            </Text>
          )}
          
          {event.location && (
            <Text style={styles.locationText}>
              📍 {event.location}
            </Text>
          )}
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
            placeholder="Rechercher un événement..."
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

      {/* Liste des événements */}
      <FlatList
        data={filteredEvents}
        keyExtractor={(item) => `event-${item.id}`}
        renderItem={renderEventCard}
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
            <DinorIcon name="calendar" size={64} color={COLORS.MEDIUM_GRAY} />
            <Text style={styles.emptyTitle}>Aucun événement trouvé</Text>
            <Text style={styles.emptyText}>
              {searchQuery 
                ? `Aucun événement ne correspond à "${searchQuery}"`
                : "Aucun événement n'est disponible pour le moment"
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
  
  eventCard: {
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
    height: 160,
    borderTopLeftRadius: DIMENSIONS.BORDER_RADIUS,
    borderTopRightRadius: DIMENSIONS.BORDER_RADIUS,
    overflow: 'hidden',
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
  
  cardContent: {
    padding: DIMENSIONS.SPACING_4,
  },
  
  cardTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
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
    flexWrap: 'wrap',
    alignItems: 'center',
    gap: 8,
  },
  
  likeButton: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    paddingVertical: 4,
    paddingHorizontal: 8,
    borderRadius: 15,
  },
  
  likesText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
  },
  
  likesTextActive: {
    color: COLORS.PRIMARY_RED,
  },
  
  eventDateText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.PRIMARY_RED,
    fontWeight: TYPOGRAPHY.fontWeight.medium,
    backgroundColor: 'rgba(229, 62, 62, 0.1)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  
  locationText: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
    backgroundColor: COLORS.BACKGROUND,
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

export default EventsScreen;