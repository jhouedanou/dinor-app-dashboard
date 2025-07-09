<template>
  <div class="predictions">
    <main class="md3-main-content">
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="skeleton-loader">
          <div class="skeleton-header"></div>
          <div class="skeleton-tournaments">
            <div v-for="i in 3" :key="i" class="skeleton-tournament"></div>
          </div>
        </div>
      </div>

      <!-- Predictions Content -->
      <div v-else class="predictions-content">
        <!-- Header Section -->
        <div class="predictions-header">
          <h1 class="md3-title-large dinor-text-primary">Pronostics</h1>
          <p class="md3-body-medium dinor-text-gray">
            Participez aux tournois et gagnez des points en prédisant les résultats !
          </p>
        </div>

        <!-- Tournaments List -->
        <div class="tournaments-section">
          <div v-if="loadingTournaments" class="tournaments-loading">
            <div class="skeleton-tournaments">
              <div v-for="i in 4" :key="i" class="skeleton-tournament"></div>
            </div>
          </div>
          
          <div v-else-if="tournaments.length > 0" class="tournaments-grid">
            <div 
              v-for="tournament in tournaments" 
              :key="tournament.id" 
              class="tournament-card"
              @click="openTournamentMatches(tournament)"
            >
              <div class="tournament-status" :class="tournament.status">
                {{ tournament.status_label }}
              </div>
              
              <div class="tournament-header">
                <h3 class="tournament-name">{{ tournament.name }}</h3>
                <p class="tournament-description">{{ tournament.description }}</p>
              </div>

              <div class="tournament-info">
                <div class="info-item">
                  <span class="material-symbols-outlined">groups</span>
                  <span>{{ tournament.participants_count }} participants</span>
                </div>
                
                <div class="info-item" v-if="tournament.prize_pool">
                  <span class="material-symbols-outlined">emoji_events</span>
                  <span>{{ formatPrize(tournament.prize_pool, tournament.currency) }}</span>
                </div>
                
                <div class="info-item">
                  <span class="material-symbols-outlined">schedule</span>
                  <span>{{ formatTournamentDate(tournament.start_date) }}</span>
                </div>
              </div>

              <div class="tournament-actions">
                <span class="view-matches-btn">
                  <span class="material-symbols-outlined">sports_soccer</span>
                  Voir les matchs
                </span>
              </div>
            </div>
          </div>
          
          <div v-else class="no-tournaments">
            <div class="no-tournaments-icon">
              <span class="material-symbols-outlined">emoji_events</span>
            </div>
            <h3 class="md3-title-medium">Aucun tournoi disponible</h3>
            <p class="md3-body-medium dinor-text-gray">
              Les nouveaux tournois apparaîtront ici dès qu'ils seront disponibles.
            </p>
          </div>
        </div>

        <!-- Rules Footer -->
        <div class="rules-footer">
          <div class="rules-card">
            <h3 class="rules-title">
              <span class="material-symbols-outlined">info</span>
              Règles des pronostics
            </h3>
            <div class="rules-content">
              <div class="rule-item">
                <span class="points">3 pts</span>
                <span class="rule-text">Score exact</span>
              </div>
              <div class="rule-item">
                <span class="points">1 pt</span>
                <span class="rule-text">Bon vainqueur</span>
              </div>
              <div class="rule-item">
                <span class="points">0 pt</span>
                <span class="rule-text">Pronostic incorrect</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
    
    <!-- Tournament Matches Modal -->
    <div v-if="selectedTournament" class="tournament-modal-overlay" @click="closeTournamentModal">
      <div class="tournament-modal" @click.stop>
        <div class="modal-header">
          <h2 class="modal-title">{{ selectedTournament.name }}</h2>
          <button @click="closeTournamentModal" class="close-btn">
            <span class="material-symbols-outlined">close</span>
          </button>
        </div>
        
        <div class="modal-content">
          <div v-if="loadingMatches" class="matches-loading">
            <div class="skeleton-matches">
              <div v-for="i in 3" :key="i" class="skeleton-match"></div>
            </div>
          </div>
          
          <div v-else-if="tournamentMatches.length > 0" class="matches-list">
            <div 
              v-for="match in tournamentMatches" 
              :key="match.id" 
              class="match-card"
              :class="{ 'match-saved': savedMatches.includes(match.id) }"
            >
              <div class="match-header">
                <div class="match-teams">
                  <div class="team home-team">
                    <img v-if="match.home_team.logo_url" :src="match.home_team.logo_url" :alt="match.home_team.name" />
                    <span>{{ match.home_team.short_name || match.home_team.name }}</span>
                  </div>
                  <div class="vs">vs</div>
                  <div class="team away-team">
                    <img v-if="match.away_team.logo_url" :src="match.away_team.logo_url" :alt="match.away_team.name" />
                    <span>{{ match.away_team.short_name || match.away_team.name }}</span>
                  </div>
                </div>
                
                <div class="match-info">
                  <span class="match-date">{{ formatMatchDate(match.match_date) }}</span>
                  <span class="match-status" :class="match.can_predict ? 'open' : 'closed'">
                    {{ match.can_predict ? 'Pronostics ouverts' : 'Fermé' }}
                  </span>
                </div>
              </div>

              <!-- Prediction Form (if authenticated and can predict) -->
              <div v-if="authStore.isAuthenticated && match.can_predict" class="prediction-form">
                <div class="score-inputs">
                  <div class="score-input">
                    <label>{{ match.home_team.short_name || match.home_team.name }}</label>
                    <input 
                      v-model.number="predictions[match.id].homeScore"
                      @input="handlePredictionInput(match.id)"
                      type="number" 
                      min="0" 
                      max="20"
                      class="score-field"
                      :class="{ 'saving': savingMatches.includes(match.id), 'saved': savedMatches.includes(match.id) }"
                    >
                  </div>
                  <div class="score-separator">-</div>
                  <div class="score-input">
                    <label>{{ match.away_team.short_name || match.away_team.name }}</label>
                    <input 
                      v-model.number="predictions[match.id].awayScore"
                      @input="handlePredictionInput(match.id)"
                      type="number" 
                      min="0" 
                      max="20"
                      class="score-field"
                      :class="{ 'saving': savingMatches.includes(match.id), 'saved': savedMatches.includes(match.id) }"
                    >
                  </div>
                </div>
                
                <div class="prediction-status">
                  <span v-if="savingMatches.includes(match.id)" class="status-saving">
                    <span class="material-symbols-outlined">sync</span>
                    Sauvegarde...
                  </span>
                  <span v-else-if="savedMatches.includes(match.id)" class="status-saved">
                    <span class="material-symbols-outlined">check_circle</span>
                    Sauvegardé
                  </span>
                </div>
              </div>

              <!-- Predict Button (if not authenticated) -->
              <div v-else-if="!authStore.isAuthenticated && match.can_predict" class="prediction-auth-required">
                <button @click="showAuthModal = true" class="btn-predict">
                  <span class="material-symbols-outlined">person</span>
                  Pronostiquer
                </button>
              </div>

              <!-- Existing Prediction Display -->
              <div v-if="match.user_prediction" class="existing-prediction">
                <span class="prediction-label">Votre pronostic :</span>
                <span class="prediction-score">
                  {{ match.user_prediction.predicted_home_score }} - {{ match.user_prediction.predicted_away_score }}
                </span>
              </div>
            </div>
          </div>
          
          <div v-else class="no-matches">
            <span class="material-symbols-outlined">sports_soccer</span>
            <p>Aucun match disponible pour ce tournoi</p>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Auth Modal -->
    <AuthModal 
      v-model="showAuthModal"
      @authenticated="handleAuthenticated"
    />
  </div>
</template>

<script>
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useApiStore } from '@/stores/api'
import { useAuthStore } from '@/stores/auth'
import AuthModal from '@/components/common/AuthModal.vue'

export default {
  name: 'Predictions',
  emits: ['update-header'],
  components: {
    AuthModal
  },
  setup(_, { emit }) {
    const apiStore = useApiStore()
    const authStore = useAuthStore()
    
    // State
    const tournaments = ref([])
    const loading = ref(true)
    const loadingTournaments = ref(true)
    const showAuthModal = ref(false)
    
    // Tournament modal state
    const selectedTournament = ref(null)
    const tournamentMatches = ref([])
    const loadingMatches = ref(false)
    
    // Predictions state
    const predictions = ref({})
    const savingMatches = ref([])
    const savedMatches = ref([])
    const debounceTimers = ref({})

    // Load tournaments
    const loadTournaments = async () => {
      loadingTournaments.value = true
      try {
        const data = await apiStore.get('/tournaments/featured?limit=20')
        if (data.success) {
          tournaments.value = data.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement des tournois:', error)
      } finally {
        loadingTournaments.value = false
        loading.value = false
      }
    }

    // Open tournament matches modal
    const openTournamentMatches = async (tournament) => {
      selectedTournament.value = tournament
      loadingMatches.value = true
      
      try {
        const data = await apiStore.get(`/tournaments/${tournament.id}/matches`)
        if (data.success) {
          tournamentMatches.value = data.data
          
          // Initialize predictions for each match
          data.data.forEach(match => {
            predictions.value[match.id] = {
              homeScore: match.user_prediction?.predicted_home_score || 0,
              awayScore: match.user_prediction?.predicted_away_score || 0
            }
          })
        }
      } catch (error) {
        console.error('Erreur lors du chargement des matchs:', error)
      } finally {
        loadingMatches.value = false
      }
    }

    // Close tournament modal
    const closeTournamentModal = () => {
      selectedTournament.value = null
      tournamentMatches.value = []
      predictions.value = {}
      savingMatches.value = []
      savedMatches.value = []
    }

    // Handle prediction input with debounce
    const handlePredictionInput = (matchId) => {
      // Clear existing timer
      if (debounceTimers.value[matchId]) {
        clearTimeout(debounceTimers.value[matchId])
      }
      
      // Remove from saved matches
      savedMatches.value = savedMatches.value.filter(id => id !== matchId)
      
      // Set new timer
      debounceTimers.value[matchId] = setTimeout(() => {
        savePrediction(matchId)
      }, 1000)
    }

    // Save prediction
    const savePrediction = async (matchId) => {
      if (!authStore.isAuthenticated) return
      
      const prediction = predictions.value[matchId]
      if (!prediction || prediction.homeScore === null || prediction.awayScore === null) return
      
      savingMatches.value.push(matchId)
      
      try {
        const data = await apiStore.patch('/predictions/upsert', {
          football_match_id: matchId,
          predicted_home_score: prediction.homeScore,
          predicted_away_score: prediction.awayScore
        })
        
        if (data.success) {
          savedMatches.value.push(matchId)
          
          // Remove from saved after 3 seconds
          setTimeout(() => {
            savedMatches.value = savedMatches.value.filter(id => id !== matchId)
          }, 3000)
        }
      } catch (error) {
        console.error('Erreur lors de la sauvegarde:', error)
      } finally {
        savingMatches.value = savingMatches.value.filter(id => id !== matchId)
      }
    }

    // Format functions
    const formatTournamentDate = (dateString) => {
      const date = new Date(dateString)
      const now = new Date()
      const diffDays = Math.ceil((date - now) / (1000 * 60 * 60 * 24))
      
      if (diffDays < 0) {
        return 'Terminé'
      } else if (diffDays === 0) {
        return 'Aujourd\'hui'
      } else if (diffDays === 1) {
        return 'Demain'
      } else if (diffDays < 7) {
        return `Dans ${diffDays} jours`
      } else {
        return date.toLocaleDateString('fr-FR', { day: 'numeric', month: 'short' })
      }
    }

    const formatMatchDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('fr-FR', {
        weekday: 'short',
        day: 'numeric',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const formatPrize = (amount, currency) => {
      return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: currency || 'XOF',
        minimumFractionDigits: 0
      }).format(amount)
    }

    const handleAuthenticated = () => {
      showAuthModal.value = false
      // Reload current tournament matches if open
      if (selectedTournament.value) {
        openTournamentMatches(selectedTournament.value)
      }
    }

    onMounted(() => {
      loadTournaments()
      
      emit('update-header', {
        title: 'Pronostics',
        showBack: false
      })
    })

    return {
      tournaments,
      loading,
      loadingTournaments,
      showAuthModal,
      selectedTournament,
      tournamentMatches,
      loadingMatches,
      predictions,
      savingMatches,
      savedMatches,
      authStore,
      openTournamentMatches,
      closeTournamentModal,
      handlePredictionInput,
      formatTournamentDate,
      formatMatchDate,
      formatPrize,
      handleAuthenticated
    }
  }
}
</script>

<style scoped>
.predictions {
  min-height: 100vh;
  background: #FFFFFF;
  font-family: 'Roboto', sans-serif;
}

/* Loading States */
.loading-container {
  padding: 2rem;
}

.skeleton-loader {
  max-width: 600px;
  margin: 0 auto;
}

.skeleton-header {
  height: 60px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
  border-radius: 8px;
  margin-bottom: 2rem;
}

.skeleton-tournaments {
  display: grid;
  gap: 1rem;
}

.skeleton-tournament {
  height: 120px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
  border-radius: 12px;
}

.skeleton-matches {
  display: grid;
  gap: 1rem;
}

.skeleton-match {
  height: 80px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
  border-radius: 8px;
}

@keyframes loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}

/* Header */
.predictions-header {
  text-align: center;
  padding: 2rem 1rem;
  max-width: 600px;
  margin: 0 auto;
}

/* Tournaments */
.tournaments-section {
  padding: 0 1rem 2rem;
  max-width: 800px;
  margin: 0 auto;
}

.tournaments-grid {
  display: grid;
  gap: 1rem;
}

.tournament-card {
  background: white;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  border: 1px solid #e0e0e0;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}

.tournament-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0,0,0,0.15);
}

.tournament-status {
  position: absolute;
  top: 1rem;
  right: 1rem;
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 500;
}

.tournament-status.active {
  background: #e8f5e8;
  color: #2e7d32;
}

.tournament-status.registration_open {
  background: #e3f2fd;
  color: #1976d2;
}

.tournament-header {
  margin-bottom: 1rem;
}

.tournament-name {
  font-size: 1.25rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: #1a1a1a;
}

.tournament-description {
  color: #666;
  font-size: 0.9rem;
}

.tournament-info {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  color: #666;
}

.info-item .material-symbols-outlined {
  font-size: 1rem;
}

.tournament-actions {
  display: flex;
  justify-content: flex-end;
}

.view-matches-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  background: #f5f5f5;
  border-radius: 8px;
  font-size: 0.9rem;
  color: #333;
  font-weight: 500;
}

/* No Tournaments */
.no-tournaments {
  text-align: center;
  padding: 3rem 1rem;
}

.no-tournaments-icon .material-symbols-outlined {
  font-size: 4rem;
  color: #ccc;
  margin-bottom: 1rem;
}

/* Rules Footer */
.rules-footer {
  margin-top: 2rem;
  padding: 0 1rem 2rem;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

.rules-card {
  background: #f8f9fa;
  border-radius: 12px;
  padding: 1.5rem;
  border: 1px solid #e9ecef;
}

.rules-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
  color: #333;
}

.rules-content {
  display: grid;
  gap: 0.75rem;
}

.rule-item {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.points {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: #007bff;
  color: white;
  border-radius: 20px;
  font-weight: 600;
  font-size: 0.9rem;
}

.rule-text {
  color: #555;
  font-size: 0.95rem;
}

/* Tournament Modal */
.tournament-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  z-index: 1000;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}

.tournament-modal {
  background: white;
  border-radius: 16px;
  max-width: 600px;
  width: 100%;
  max-height: 80vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
}

.modal-title {
  font-size: 1.25rem;
  font-weight: 600;
  color: #1a1a1a;
}

.close-btn {
  background: none;
  border: none;
  padding: 0.5rem;
  cursor: pointer;
  border-radius: 8px;
  transition: background 0.2s;
}

.close-btn:hover {
  background: #f5f5f5;
}

.modal-content {
  flex: 1;
  overflow-y: auto;
  padding: 1rem;
}

/* Matches */
.matches-list {
  display: grid;
  gap: 1rem;
}

.match-card {
  background: white;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  padding: 1rem;
  transition: border-color 0.3s ease;
}

.match-card.match-saved {
  border-color: #4caf50;
  background: #f8fff8;
}

.match-header {
  margin-bottom: 1rem;
}

.match-teams {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 0.5rem;
}

.team {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 500;
}

.team img {
  width: 24px;
  height: 24px;
  border-radius: 50%;
}

.vs {
  color: #666;
  font-size: 0.9rem;
}

.match-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.85rem;
  color: #666;
}

.match-status.open {
  color: #4caf50;
  font-weight: 500;
}

.match-status.closed {
  color: #f44336;
}

/* Prediction Form */
.prediction-form {
  margin-top: 1rem;
}

.score-inputs {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 0.5rem;
}

.score-input {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
}

.score-input label {
  font-size: 0.8rem;
  color: #666;
}

.score-field {
  width: 60px;
  height: 40px;
  text-align: center;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  transition: all 0.3s ease;
}

.score-field:focus {
  outline: none;
  border-color: #007bff;
}

.score-field.saving {
  border-color: #ff9800;
  background: #fff8e1;
}

.score-field.saved {
  border-color: #4caf50;
  background: #f8fff8;
}

.score-separator {
  font-size: 1.2rem;
  font-weight: 600;
  color: #666;
}

.prediction-status {
  display: flex;
  justify-content: center;
  font-size: 0.85rem;
}

.status-saving {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  color: #ff9800;
}

.status-saved {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  color: #4caf50;
}

.status-saving .material-symbols-outlined {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

/* Auth Required */
.prediction-auth-required {
  display: flex;
  justify-content: center;
  margin-top: 1rem;
}

.btn-predict {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: background 0.2s;
}

.btn-predict:hover {
  background: #0056b3;
}

/* Existing Prediction */
.existing-prediction {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  margin-top: 1rem;
  padding: 0.5rem;
  background: #f0f8ff;
  border-radius: 8px;
  font-size: 0.9rem;
}

.prediction-label {
  color: #666;
}

.prediction-score {
  font-weight: 600;
  color: #007bff;
}

/* No Matches */
.no-matches {
  text-align: center;
  padding: 2rem;
  color: #666;
}

.no-matches .material-symbols-outlined {
  font-size: 3rem;
  margin-bottom: 1rem;
  opacity: 0.5;
}

/* Responsive */
@media (min-width: 768px) {
  .tournaments-grid {
    grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  }
  
  .tournament-info {
    flex-direction: row;
    flex-wrap: wrap;
    gap: 1rem;
  }
  
  .info-item {
    flex: 1;
    min-width: 120px;
  }
}
</style>