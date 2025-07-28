import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  RefreshControl,
  FlatList,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '../styles/colors';
import { DinorIcon } from '../components/icons/DinorIcon';
import { useAuthStore } from '../stores/authStore';
import { apiService } from '../services/api';

interface LeaderboardUser {
  id: number;
  name: string;
  avatar?: string;
  total_points: number;
  total_predictions: number;
  accuracy_percentage: number;
  exact_scores: number;
  rank: number;
  rank_change?: number;
}

interface UserStats {
  total_points: number;
  total_predictions: number;
  accuracy_percentage: number;
  exact_scores: number;
  current_rank: number;
  rank_change: number;
}

export const PredictionsLeaderboardScreen: React.FC = () => {
  const { user, isAuthenticated } = useAuthStore();
  const [topUsers, setTopUsers] = useState<LeaderboardUser[]>([]);
  const [userStats, setUserStats] = useState<UserStats | null>(null);
  const [loading, setLoading] = useState(false);
  const [refreshing, setRefreshing] = useState(false);

  useEffect(() => {
    if (isAuthenticated) {
      loadLeaderboard();
      loadUserStats();
    }
  }, [isAuthenticated]);

  const loadLeaderboard = async () => {
    try {
      setLoading(true);
      const response = await apiService.get('/leaderboard/top?limit=10');
      if (response.success) {
        setTopUsers(response.data);
      }
    } catch (error) {
      console.error('Error loading leaderboard:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadUserStats = async () => {
    try {
      const response = await apiService.get('/leaderboard/my-stats');
      if (response.success) {
        setUserStats(response.data);
      }
    } catch (error) {
      console.error('Error loading user stats:', error);
    }
  };

  const refreshLeaderboard = async () => {
    try {
      setRefreshing(true);
      // Trigger server refresh
      await apiService.post('/leaderboard/refresh');
      // Reload data
      await Promise.all([loadLeaderboard(), loadUserStats()]);
    } catch (error) {
      console.error('Error refreshing leaderboard:', error);
    } finally {
      setRefreshing(false);
    }
  };

  const getRankIcon = (rank: number) => {
    switch (rank) {
      case 1:
        return { icon: 'crown', color: '#FFD700' };
      case 2:
        return { icon: 'award', color: '#C0C0C0' };
      case 3:
        return { icon: 'award', color: '#CD7F32' };
      default:
        return { icon: 'user', color: COLORS.MEDIUM_GRAY };
    }
  };

  const getRankChangeIcon = (change?: number) => {
    if (!change || change === 0) return null;
    
    return (
      <View style={[
        styles.rankChange,
        { backgroundColor: change > 0 ? '#10B981' : '#EF4444' }
      ]}>
        <DinorIcon 
          name={change > 0 ? 'arrow-up' : 'arrow-down'} 
          size={12} 
          color={COLORS.WHITE} 
        />
        <Text style={styles.rankChangeText}>
          {Math.abs(change)}
        </Text>
      </View>
    );
  };

  const renderTopUser = ({ item, index }: { item: LeaderboardUser; index: number }) => {
    const rankInfo = getRankIcon(item.rank);
    const isPodium = item.rank <= 3;

    return (
      <View style={[
        styles.userCard,
        isPodium && styles.podiumCard,
        item.rank === 1 && styles.goldCard,
      ]}>
        <View style={styles.userRank}>
          <DinorIcon 
            name={rankInfo.icon} 
            size={isPodium ? 28 : 24} 
            color={rankInfo.color} 
          />
          <Text style={[
            styles.rankNumber,
            isPodium && styles.podiumRankNumber,
          ]}>
            #{item.rank}
          </Text>
          {getRankChangeIcon(item.rank_change)}
        </View>

        <View style={styles.userInfo}>
          <Text style={[
            styles.userName,
            isPodium && styles.podiumUserName,
          ]}>
            {item.name}
          </Text>
          
          <View style={styles.userStats}>
            <View style={styles.statItem}>
              <DinorIcon name="target" size={16} color={COLORS.GOLDEN} />
              <Text style={styles.statValue}>{item.total_points}</Text>
              <Text style={styles.statLabel}>pts</Text>
            </View>
            
            <View style={styles.statItem}>
              <DinorIcon name="zap" size={16} color={COLORS.ORANGE_ACCENT} />
              <Text style={styles.statValue}>{item.accuracy_percentage}%</Text>
              <Text style={styles.statLabel}>précision</Text>
            </View>
            
            <View style={styles.statItem}>
              <DinorIcon name="bullseye" size={16} color={COLORS.PRIMARY_RED} />
              <Text style={styles.statValue}>{item.exact_scores}</Text>
              <Text style={styles.statLabel}>exact</Text>
            </View>
          </View>
        </View>
      </View>
    );
  };

  if (!isAuthenticated) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.authPrompt}>
          <DinorIcon name="trophy" size={64} color={COLORS.MEDIUM_GRAY} />
          <Text style={styles.authTitle}>Classement des pronostics</Text>
          <Text style={styles.authText}>
            Connectez-vous pour voir le classement et vos statistiques.
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Classement</Text>
        <TouchableOpacity
          style={styles.refreshButton}
          onPress={refreshLeaderboard}
          disabled={refreshing}
        >
          {refreshing ? (
            <ActivityIndicator size="small" color={COLORS.PRIMARY_RED} />
          ) : (
            <DinorIcon name="refresh-cw" size={20} color={COLORS.PRIMARY_RED} />
          )}
        </TouchableOpacity>
      </View>

      <ScrollView 
        style={styles.content}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={refreshLeaderboard}
            colors={[COLORS.PRIMARY_RED]}
          />
        }
      >
        {/* User Stats Card */}
        {userStats && (
          <View style={styles.userStatsCard}>
            <View style={styles.userStatsHeader}>
              <DinorIcon name="user" size={24} color={COLORS.PRIMARY_RED} />
              <Text style={styles.userStatsTitle}>Mes statistiques</Text>
            </View>
            
            <View style={styles.userStatsGrid}>
              <View style={styles.userStatItem}>
                <Text style={styles.userStatValue}>{userStats.total_points}</Text>
                <Text style={styles.userStatLabel}>Points totaux</Text>
              </View>
              
              <View style={styles.userStatItem}>
                <Text style={styles.userStatValue}>#{userStats.current_rank}</Text>
                <Text style={styles.userStatLabel}>Classement</Text>
                {getRankChangeIcon(userStats.rank_change)}
              </View>
              
              <View style={styles.userStatItem}>
                <Text style={styles.userStatValue}>{userStats.accuracy_percentage}%</Text>
                <Text style={styles.userStatLabel}>Précision</Text>
              </View>
              
              <View style={styles.userStatItem}>
                <Text style={styles.userStatValue}>{userStats.exact_scores}</Text>
                <Text style={styles.userStatLabel}>Scores exacts</Text>
              </View>
            </View>
          </View>
        )}

        {/* Top 10 Leaderboard */}
        <View style={styles.leaderboardSection}>
          <Text style={styles.sectionTitle}>Top 10</Text>
          
          {loading && topUsers.length === 0 ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={COLORS.PRIMARY_RED} />
              <Text style={styles.loadingText}>Chargement du classement...</Text>
            </View>
          ) : (
            <FlatList
              data={topUsers}
              renderItem={renderTopUser}
              keyExtractor={(item) => item.id.toString()}
              scrollEnabled={false}
              showsVerticalScrollIndicator={false}
            />
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
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
  refreshButton: {
    padding: 8,
  },
  content: {
    flex: 1,
    padding: DIMENSIONS.SPACING_4,
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
  userStatsCard: {
    backgroundColor: COLORS.WHITE,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    padding: DIMENSIONS.SPACING_4,
    marginBottom: DIMENSIONS.SPACING_4,
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  userStatsHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: DIMENSIONS.SPACING_4,
  },
  userStatsTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: 'bold',
    color: COLORS.DARK_GRAY,
    marginLeft: 8,
  },
  userStatsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
  },
  userStatItem: {
    width: '50%',
    alignItems: 'center',
    padding: 8,
    position: 'relative',
  },
  userStatValue: {
    fontSize: TYPOGRAPHY.fontSize.xl,
    fontWeight: 'bold',
    color: COLORS.PRIMARY_RED,
  },
  userStatLabel: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.MEDIUM_GRAY,
    marginTop: 4,
  },
  leaderboardSection: {
    marginTop: DIMENSIONS.SPACING_4,
  },
  sectionTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: 'bold',
    color: COLORS.DARK_GRAY,
    marginBottom: DIMENSIONS.SPACING_4,
  },
  userCard: {
    backgroundColor: COLORS.WHITE,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    padding: DIMENSIONS.SPACING_4,
    marginBottom: 8,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  podiumCard: {
    borderWidth: 2,
    borderColor: COLORS.GOLDEN,
    shadowColor: COLORS.GOLDEN,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  goldCard: {
    borderColor: '#FFD700',
    backgroundColor: '#FFFBF0',
  },
  userRank: {
    alignItems: 'center',
    marginRight: DIMENSIONS.SPACING_4,
    position: 'relative',
  },
  rankNumber: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    fontWeight: 'bold',
    color: COLORS.MEDIUM_GRAY,
    marginTop: 4,
  },
  podiumRankNumber: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.DARK_GRAY,
  },
  rankChange: {
    position: 'absolute',
    top: -6,
    right: -6,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 4,
    paddingVertical: 2,
    borderRadius: 10,
    minWidth: 20,
  },
  rankChangeText: {
    fontSize: 10,
    fontWeight: 'bold',
    color: COLORS.WHITE,
    marginLeft: 2,
  },
  userInfo: {
    flex: 1,
  },
  userName: {
    fontSize: TYPOGRAPHY.fontSize.md,
    fontWeight: '600',
    color: COLORS.DARK_GRAY,
    marginBottom: 8,
  },
  podiumUserName: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: 'bold',
  },
  userStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  statItem: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  statValue: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    fontWeight: 'bold',
    color: COLORS.DARK_GRAY,
    marginLeft: 4,
  },
  statLabel: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.MEDIUM_GRAY,
    marginLeft: 2,
  },
});