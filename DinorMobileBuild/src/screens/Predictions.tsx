import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Alert,
  ActivityIndicator,
  FlatList,
  Modal,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { COLORS, DIMENSIONS, TYPOGRAPHY } from '../styles/colors';
import { DinorIcon } from '../components/icons/DinorIcon';
import { useAuthStore } from '../stores/authStore';
import { apiService } from '../services/api';

interface Tournament {
  id: number;
  name: string;
  description: string;
  status: string;
  participant_count: number;
  prize_pool?: number;
  currency?: string;
  start_date: string;
  end_date: string;
  progress_percentage: number;
  is_betting_available: boolean;
}

interface Match {
  id: number;
  home_team: {
    id: number;
    name: string;
    logo?: string;
  };
  away_team: {
    id: number;
    name: string;
    logo?: string;
  };
  match_date: string;
  status: string;
  can_predict: boolean;
  user_prediction?: {
    home_score: number;
    away_score: number;
    predicted_winner: string;
  };
}

interface Prediction {
  match_id: number;
  home_score: string;
  away_score: string;
  predicted_winner: string;
}

export const PredictionsScreen: React.FC = () => {
  const { user, isAuthenticated } = useAuthStore();
  const [tournaments, setTournaments] = useState<Tournament[]>([]);
  const [selectedTournament, setSelectedTournament] = useState<Tournament | null>(null);
  const [matches, setMatches] = useState<Match[]>([]);
  const [predictions, setPredictions] = useState<{ [key: number]: Prediction }>({});
  const [loading, setLoading] = useState(false);
  const [modalVisible, setModalVisible] = useState(false);
  const [savingStates, setSavingStates] = useState<{ [key: number]: boolean }>({});

  useEffect(() => {
    loadFeaturedTournaments();
  }, []);

  const loadFeaturedTournaments = async () => {
    try {
      setLoading(true);
      const response = await apiService.get('/tournaments/featured?limit=20');
      if (response.success) {
        setTournaments(response.data);
      }
    } catch (error) {
      console.error('Error loading tournaments:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadTournamentMatches = async (tournamentId: number) => {
    try {
      setLoading(true);
      const response = await apiService.get(`/tournaments/${tournamentId}/matches`);
      if (response.success) {
        setMatches(response.data);
        
        // Initialize predictions from existing user predictions
        const predictionState: { [key: number]: Prediction } = {};
        response.data.forEach((match: Match) => {
          if (match.user_prediction) {
            predictionState[match.id] = {
              match_id: match.id,
              home_score: match.user_prediction.home_score.toString(),
              away_score: match.user_prediction.away_score.toString(),
              predicted_winner: match.user_prediction.predicted_winner,
            };
          }
        });
        setPredictions(predictionState);
      }
    } catch (error) {
      console.error('Error loading matches:', error);
    } finally {
      setLoading(false);
    }
  };

  const updatePrediction = (matchId: number, field: keyof Prediction, value: string) => {
    setPredictions(prev => ({
      ...prev,
      [matchId]: {
        ...prev[matchId],
        match_id: matchId,
        [field]: value,
        // Auto-determine winner based on scores
        predicted_winner: field === 'home_score' || field === 'away_score' 
          ? determinePredictedWinner(
              field === 'home_score' ? parseInt(value) || 0 : parseInt(prev[matchId]?.home_score) || 0,
              field === 'away_score' ? parseInt(value) || 0 : parseInt(prev[matchId]?.away_score) || 0
            )
          : prev[matchId]?.predicted_winner || 'draw',
      },
    }));

    // Debounced save after 1 second
    setTimeout(() => {
      savePrediction(matchId);
    }, 1000);
  };

  const determinePredictedWinner = (homeScore: number, awayScore: number): string => {
    if (homeScore > awayScore) return 'home';
    if (awayScore > homeScore) return 'away';
    return 'draw';
  };

  const savePrediction = async (matchId: number) => {
    if (!isAuthenticated) {
      Alert.alert('Authentification requise', 'Vous devez être connecté pour faire des pronostics.');
      return;
    }

    const prediction = predictions[matchId];
    if (!prediction) return;

    try {
      setSavingStates(prev => ({ ...prev, [matchId]: true }));
      
      const response = await apiService.patch('/predictions/upsert', {
        predictions: [{
          match_id: matchId,
          home_score: parseInt(prediction.home_score) || 0,
          away_score: parseInt(prediction.away_score) || 0,
          predicted_winner: prediction.predicted_winner,
        }],
      });

      if (response.success) {
        // Update local state with server response if needed
      }
    } catch (error) {
      console.error('Error saving prediction:', error);
      Alert.alert('Erreur', 'Impossible de sauvegarder le pronostic');
    } finally {
      setSavingStates(prev => ({ ...prev, [matchId]: false }));
    }
  };

  const openTournamentModal = (tournament: Tournament) => {
    setSelectedTournament(tournament);
    setModalVisible(true);
    loadTournamentMatches(tournament.id);
  };

  const renderTournamentCard = ({ item }: { item: Tournament }) => (
    <TouchableOpacity
      style={styles.tournamentCard}
      onPress={() => openTournamentModal(item)}
    >
      <View style={styles.tournamentHeader}>
        <Text style={styles.tournamentName}>{item.name}</Text>
        <View style={styles.progressContainer}>
          <View style={[styles.progressBar, { width: `${item.progress_percentage}%` }]} />
        </View>
      </View>
      
      <Text style={styles.tournamentDescription}>{item.description}</Text>
      
      <View style={styles.tournamentStats}>
        <View style={styles.statItem}>
          <DinorIcon name="users" size={16} color={COLORS.MEDIUM_GRAY} />
          <Text style={styles.statText}>{item.participant_count} participants</Text>
        </View>
        
        {item.prize_pool && (
          <View style={styles.statItem}>
            <DinorIcon name="trophy" size={16} color={COLORS.GOLDEN} />
            <Text style={styles.statText}>
              {item.prize_pool} {item.currency || 'pts'}
            </Text>
          </View>
        )}
        
        <View style={styles.statItem}>
          <DinorIcon name="calendar" size={16} color={COLORS.MEDIUM_GRAY} />
          <Text style={styles.statText}>
            {new Date(item.start_date).toLocaleDateString()}
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  );

  const renderMatch = ({ item }: { item: Match }) => {
    const prediction = predictions[item.id];
    const isSaving = savingStates[item.id];

    return (
      <View style={styles.matchCard}>
        <View style={styles.matchTeams}>
          <View style={styles.team}>
            <Text style={styles.teamName}>{item.home_team.name}</Text>
          </View>
          
          <View style={styles.scoreInputs}>
            <TextInput
              style={styles.scoreInput}
              value={prediction?.home_score || ''}
              onChangeText={(value) => updatePrediction(item.id, 'home_score', value)}
              keyboardType="numeric"
              placeholder="0"
              editable={item.can_predict && isAuthenticated}
            />
            <Text style={styles.scoreSeparator}>-</Text>
            <TextInput
              style={styles.scoreInput}
              value={prediction?.away_score || ''}
              onChangeText={(value) => updatePrediction(item.id, 'away_score', value)}
              keyboardType="numeric"
              placeholder="0"
              editable={item.can_predict && isAuthenticated}
            />
          </View>
          
          <View style={styles.team}>
            <Text style={styles.teamName}>{item.away_team.name}</Text>
          </View>
        </View>
        
        <View style={styles.matchInfo}>
          <Text style={styles.matchDate}>
            {new Date(item.match_date).toLocaleDateString('fr-FR', {
              day: '2-digit',
              month: '2-digit',
              hour: '2-digit',
              minute: '2-digit',
            })}
          </Text>
          
          {isSaving && (
            <View style={styles.savingIndicator}>
              <ActivityIndicator size="small" color={COLORS.PRIMARY_RED} />
              <Text style={styles.savingText}>Sauvegarde...</Text>
            </View>
          )}
          
          {prediction && !isSaving && (
            <Text style={styles.savedText}>✓ Sauvegardé</Text>
          )}
        </View>
      </View>
    );
  };

  if (!isAuthenticated) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.authPrompt}>
          <DinorIcon name="lock" size={64} color={COLORS.MEDIUM_GRAY} />
          <Text style={styles.authTitle}>Authentification requise</Text>
          <Text style={styles.authText}>
            Connectez-vous pour accéder aux pronostics et participer aux tournois.
          </Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Pronostics</Text>
        <Text style={styles.subtitle}>Participez aux tournois et gagnez des points</Text>
      </View>

      <ScrollView style={styles.content}>
        {loading && tournaments.length === 0 ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color={COLORS.PRIMARY_RED} />
            <Text style={styles.loadingText}>Chargement des tournois...</Text>
          </View>
        ) : (
          <FlatList
            data={tournaments}
            renderItem={renderTournamentCard}
            keyExtractor={(item) => item.id.toString()}
            scrollEnabled={false}
            showsVerticalScrollIndicator={false}
          />
        )}
      </ScrollView>

      <Modal
        visible={modalVisible}
        animationType="slide"
        presentationStyle="pageSheet"
        onRequestClose={() => setModalVisible(false)}
      >
        <SafeAreaView style={styles.modalContainer}>
          <View style={styles.modalHeader}>
            <TouchableOpacity
              style={styles.closeButton}
              onPress={() => setModalVisible(false)}
            >
              <DinorIcon name="x" size={24} color={COLORS.DARK_GRAY} />
            </TouchableOpacity>
            <Text style={styles.modalTitle}>
              {selectedTournament?.name}
            </Text>
          </View>

          {loading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={COLORS.PRIMARY_RED} />
              <Text style={styles.loadingText}>Chargement des matchs...</Text>
            </View>
          ) : (
            <FlatList
              data={matches}
              renderItem={renderMatch}
              keyExtractor={(item) => item.id.toString()}
              showsVerticalScrollIndicator={false}
              contentContainerStyle={styles.matchesList}
            />
          )}
        </SafeAreaView>
      </Modal>
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
  tournamentCard: {
    backgroundColor: COLORS.WHITE,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    padding: DIMENSIONS.SPACING_4,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  tournamentHeader: {
    marginBottom: 8,
  },
  tournamentName: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: 'bold',
    color: COLORS.DARK_GRAY,
    marginBottom: 8,
  },
  progressContainer: {
    height: 4,
    backgroundColor: '#E2E8F0',
    borderRadius: 2,
    overflow: 'hidden',
  },
  progressBar: {
    height: '100%',
    backgroundColor: COLORS.GOLDEN,
  },
  tournamentDescription: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
    marginBottom: 12,
    lineHeight: 18,
  },
  tournamentStats: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  statItem: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  statText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.MEDIUM_GRAY,
    marginLeft: 4,
  },
  modalContainer: {
    flex: 1,
    backgroundColor: COLORS.BACKGROUND,
  },
  modalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: DIMENSIONS.SPACING_4,
    backgroundColor: COLORS.WHITE,
    borderBottomWidth: 1,
    borderBottomColor: '#E2E8F0',
  },
  closeButton: {
    marginRight: 12,
  },
  modalTitle: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: 'bold',
    color: COLORS.DARK_GRAY,
    flex: 1,
  },
  matchesList: {
    padding: DIMENSIONS.SPACING_4,
  },
  matchCard: {
    backgroundColor: COLORS.WHITE,
    borderRadius: DIMENSIONS.BORDER_RADIUS,
    padding: DIMENSIONS.SPACING_4,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  matchTeams: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  team: {
    flex: 1,
  },
  teamName: {
    fontSize: TYPOGRAPHY.fontSize.md,
    fontWeight: '600',
    color: COLORS.DARK_GRAY,
    textAlign: 'center',
  },
  scoreInputs: {
    flexDirection: 'row',
    alignItems: 'center',
    marginHorizontal: DIMENSIONS.SPACING_4,
  },
  scoreInput: {
    width: 50,
    height: 40,
    borderWidth: 1,
    borderColor: '#E2E8F0',
    borderRadius: 6,
    textAlign: 'center',
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: 'bold',
    backgroundColor: COLORS.WHITE,
  },
  scoreSeparator: {
    fontSize: TYPOGRAPHY.fontSize.lg,
    fontWeight: 'bold',
    color: COLORS.MEDIUM_GRAY,
    marginHorizontal: 8,
  },
  matchInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  matchDate: {
    fontSize: TYPOGRAPHY.fontSize.sm,
    color: COLORS.MEDIUM_GRAY,
  },
  savingIndicator: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  savingText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: COLORS.PRIMARY_RED,
    marginLeft: 4,
  },
  savedText: {
    fontSize: TYPOGRAPHY.fontSize.xs,
    color: '#10B981',
    fontWeight: '600',
  },
});