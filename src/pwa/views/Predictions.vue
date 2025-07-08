<template>
  <div class="predictions">
    <main class="md3-main-content">
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="md3-circular-progress"></div>
        <p class="md3-body-large">Chargement des matchs...</p>
      </div>

      <!-- Predictions Content -->
      <div v-else class="predictions-content">
        <!-- Header Section -->
        <div class="predictions-header">
          <h1 class="md3-title-large dinor-text-primary">Pronostics</h1>
          <p class="md3-body-medium dinor-text-gray">Pariez sur vos matchs favoris et gagnez des points!</p>
        </div>

        <!-- Current Match Section -->
        <div v-if="currentMatch" class="current-match-section">
          <h2 class="md3-title-medium dinor-text-primary">Match en cours</h2>
          <div class="match-card featured">
            <div class="match-header">
              <div class="match-teams">
                <div class="team home-team">
                  <img 
                    v-if="currentMatch.home_team.logo_url" 
                    :src="currentMatch.home_team.logo_url" 
                    :alt="currentMatch.home_team.name"
                    class="team-logo"
                    @error="handleImageError"
                  >
                  <div v-else class="team-logo-placeholder">
                    <i class="material-icons">sports_soccer</i>
                  </div>
                  <span class="team-name">{{ currentMatch.home_team.name }}</span>
                </div>
                
                <div class="match-vs">
                  <span class="vs-text">VS</span>
                  <div class="match-date">
                    {{ formatMatchDate(currentMatch.match_date) }}
                  </div>
                </div>
                
                <div class="team away-team">
                  <img 
                    v-if="currentMatch.away_team.logo_url" 
                    :src="currentMatch.away_team.logo_url" 
                    :alt="currentMatch.away_team.name"
                    class="team-logo"
                    @error="handleImageError"
                  >
                  <div v-else class="team-logo-placeholder">
                    <i class="material-icons">sports_soccer</i>
                  </div>
                  <span class="team-name">{{ currentMatch.away_team.name }}</span>
                </div>
              </div>
              
              <div v-if="currentMatch.can_predict" class="prediction-status can-predict">
                <i class="material-icons">check_circle</i>
                <span>Prédictions ouvertes</span>
              </div>
              <div v-else class="prediction-status closed">
                <i class="material-icons">cancel</i>
                <span>Prédictions fermées</span>
              </div>
            </div>

            <!-- User Prediction Form -->
            <div v-if="currentMatch.can_predict && authStore.isAuthenticated" class="prediction-form">
              <h3 class="md3-title-small">Votre pronostic</h3>
              <div class="score-inputs">
                <div class="score-input">
                  <label class="md3-body-small">{{ currentMatch.home_team.short_name || currentMatch.home_team.name }}</label>
                  <input 
                    v-model.number="prediction.homeScore"
                    type="number" 
                    min="0" 
                    max="20"
                    class="score-field"
                  >
                </div>
                <div class="score-separator">-</div>
                <div class="score-input">
                  <label class="md3-body-small">{{ currentMatch.away_team.short_name || currentMatch.away_team.name }}</label>
                  <input 
                    v-model.number="prediction.awayScore"
                    type="number" 
                    min="0" 
                    max="20"
                    class="score-field"
                  >
                </div>
              </div>
              <button 
                @click="submitPrediction"
                :disabled="!canSubmitPrediction || submitting"
                class="btn-primary prediction-submit"
              >
                <span v-if="submitting">Envoi...</span>
                <span v-else>{{ userPrediction ? 'Modifier' : 'Valider' }} le pronostic</span>
              </button>
            </div>

            <!-- Auth Required Message -->
            <div v-else-if="currentMatch.can_predict && !authStore.isAuthenticated" class="auth-required">
              <p class="md3-body-medium">Connectez-vous pour faire votre pronostic</p>
              <button @click="showAuthModal = true" class="btn-primary">
                Se connecter
              </button>
            </div>

            <!-- Existing Prediction Display -->
            <div v-if="userPrediction" class="user-prediction">
              <h3 class="md3-title-small">Votre pronostic actuel</h3>
              <div class="prediction-display">
                <span class="prediction-score">
                  {{ userPrediction.predicted_home_score }} - {{ userPrediction.predicted_away_score }}
                </span>
                <span class="prediction-winner">
                  Gagnant prédit: {{ getPredictedWinnerText(userPrediction.predicted_winner) }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- No Current Match - Improved Fallback -->
        <div v-else class="no-match-section">
          <div class="no-match-card">
            <div class="no-match-icon">
              <i class="material-icons">sports_soccer</i>
            </div>
            <h2 class="md3-title-medium">Aucun match en cours</h2>
            <p class="md3-body-medium dinor-text-gray">
              Il n'y a pas de match disponible pour le moment, mais vous pouvez :
            </p>
            
            <div class="suggestions-grid">
              <div class="suggestion-card" @click="$router.push('/predictions/tournaments')">
                <div class="suggestion-icon">
                  <i class="material-icons">emoji_events</i>
                </div>
                <h3 class="suggestion-title">Explorer les tournois</h3>
                <p class="suggestion-desc">Rejoignez des tournois et participez aux compétitions</p>
              </div>
              
              <div class="suggestion-card" @click="$router.push('/predictions/leaderboard')">
                <div class="suggestion-icon">
                  <i class="material-icons">leaderboard</i>
                </div>
                <h3 class="suggestion-title">Voir le classement</h3>
                <p class="suggestion-desc">Consultez les performances des autres joueurs</p>
              </div>
              
              <div class="suggestion-card" @click="$router.push('/predictions/my-predictions')">
                <div class="suggestion-icon">
                  <i class="material-icons">history</i>
                </div>
                <h3 class="suggestion-title">Historique</h3>
                <p class="suggestion-desc">Revoyez vos anciens pronostics et statistiques</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Tournaments Section -->
        <div class="tournaments-section">
          <div class="section-header">
            <h2 class="md3-title-medium dinor-text-primary">Tournois en cours</h2>
            <router-link to="/predictions/tournaments" class="view-all-link">
              Voir tout
            </router-link>
          </div>
          
          <div v-if="loadingTournaments" class="tournaments-loading">
            <div class="md3-circular-progress"></div>
            <p class="md3-body-small">Chargement des tournois...</p>
          </div>
          
          <div v-else-if="featuredTournaments.length > 0" class="tournaments-grid">
            <div 
              v-for="tournament in featuredTournaments" 
              :key="tournament.id" 
              class="tournament-card"
              @click="openTournament(tournament)"
            >
              <div class="tournament-header">
                <h3 class="tournament-name">{{ tournament.name }}</h3>
                <span :class="['tournament-status', tournament.status]">{{ tournament.status_label }}</span>
              </div>
              
              <p class="tournament-description">{{ tournament.description }}</p>
              
              <div class="tournament-info">
                <div class="info-item">
                  <i class="material-icons">group</i>
                  <span>{{ tournament.participants_count }} participants</span>
                </div>
                <div class="info-item" v-if="tournament.prize_pool > 0">
                  <i class="material-icons">emoji_events</i>
                  <span>{{ formatPrize(tournament.prize_pool, tournament.currency) }}</span>
                </div>
                <div class="info-item">
                  <i class="material-icons">schedule</i>
                  <span>{{ formatTournamentDate(tournament.end_date) }}</span>
                </div>
              </div>
              
              <div class="tournament-actions">
                <button 
                  v-if="tournament.can_register" 
                  @click.stop="registerToTournament(tournament)"
                  :disabled="registering === tournament.id"
                  class="btn-primary btn-small"
                >
                  <span v-if="registering === tournament.id">Inscription...</span>
                  <span v-else>Participer</span>
                </button>
                <button 
                  v-else-if="tournament.user_is_participant" 
                  @click.stop="viewTournamentLeaderboard(tournament)"
                  class="btn-secondary btn-small"
                >
                  Mon classement
                </button>
                <span v-else class="tournament-closed">Inscriptions fermées</span>
              </div>
            </div>
          </div>
          
          <!-- Enhanced No Tournaments Fallback -->
          <div v-else class="no-tournaments-enhanced">
            <div class="no-tournaments-icon">
              <i class="material-icons">emoji_events</i>
            </div>
            <h3 class="md3-title-medium">Aucun tournoi disponible</h3>
            <p class="md3-body-medium dinor-text-gray">
              Les tournois apparaîtront ici dès qu'ils seront disponibles.
            </p>
            
            <div class="fallback-actions">
              <div class="fallback-info">
                <h4 class="md3-title-small">En attendant :</h4>
                <ul class="fallback-list">
                  <li>
                    <i class="material-icons">notifications</i>
                    <span>Activez les notifications pour être prévenu des nouveaux tournois</span>
                  </li>
                  <li>
                    <i class="material-icons">schedule</i>
                    <span>Revenez régulièrement pour ne manquer aucune compétition</span>
                  </li>
                  <li v-if="!authStore.isAuthenticated">
                    <i class="material-icons">person</i>
                    <span>Créez un compte pour participer aux prochains tournois</span>
                  </li>
                </ul>
              </div>
              
              <div class="fallback-cta">
                <button 
                  v-if="!authStore.isAuthenticated" 
                  @click="showAuthModal = true" 
                  class="btn-primary"
                >
                  <i class="material-icons">person_add</i>
                  <span>Créer un compte</span>
                </button>
                <button 
                  v-else
                  @click="loadFeaturedTournaments" 
                  class="btn-secondary"
                >
                  <i class="material-icons">refresh</i>
                  <span>Actualiser</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="quick-actions">
          <router-link to="/predictions/leaderboard" class="quick-action-card">
            <i class="material-icons">leaderboard</i>
            <div class="action-text">
              <h3 class="md3-title-small">Classement</h3>
              <p class="md3-body-small">Voir les meilleurs pronostiqueurs</p>
            </div>
          </router-link>
          
          <router-link to="/predictions/my-predictions" class="quick-action-card">
            <i class="material-icons">history</i>
            <div class="action-text">
              <h3 class="md3-title-small">Mes prédictions</h3>
              <p class="md3-body-small">Historique et statistiques</p>
            </div>
          </router-link>
        </div>
      </div>
    </main>
    
    <!-- Auth Modal -->
    <AuthModal 
      v-model="showAuthModal"
      @authenticated="handleAuthenticated"
    />
  </div>
</template>

<script>
import { ref, onMounted, computed, watch } from 'vue'
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
    
    const currentMatch = ref(null)
    const userPrediction = ref(null)
    const loading = ref(true)
    const submitting = ref(false)
    const showAuthModal = ref(false)
    
    // Tournois
    const featuredTournaments = ref([])
    const loadingTournaments = ref(true)
    const registering = ref(null)
    
    const prediction = ref({
      homeScore: 0,
      awayScore: 0
    })

    const canSubmitPrediction = computed(() => {
      return prediction.value.homeScore !== null && 
             prediction.value.awayScore !== null &&
             prediction.value.homeScore >= 0 && 
             prediction.value.awayScore >= 0
    })

    const loadCurrentMatch = async () => {
      try {
        const data = await apiStore.get('/matches/current/match')
        if (data.success && data.data) {
          currentMatch.value = data.data
          await loadUserPrediction()
        }
      } catch (error) {
        console.error('Erreur lors du chargement du match:', error)
      } finally {
        loading.value = false
      }
    }

    const loadUserPrediction = async () => {
      if (!authStore.isAuthenticated || !currentMatch.value) return
      
      try {
        const data = await apiStore.get(`/predictions/match/${currentMatch.value.id}`)
        if (data.success && data.data) {
          userPrediction.value = data.data
          prediction.value = {
            homeScore: data.data.predicted_home_score,
            awayScore: data.data.predicted_away_score
          }
        }
      } catch (error) {
        console.error('Erreur lors du chargement de la prédiction:', error)
      }
    }

    const submitPrediction = async () => {
      if (!canSubmitPrediction.value || submitting.value) return
      
      submitting.value = true
      
      try {
        const payload = {
          football_match_id: currentMatch.value.id,
          predicted_home_score: prediction.value.homeScore,
          predicted_away_score: prediction.value.awayScore
        }
        
        let data
        if (userPrediction.value) {
          data = await apiStore.put(`/predictions/${userPrediction.value.id}`, payload)
        } else {
          data = await apiStore.post('/predictions', payload)
        }
        
        if (data.success) {
          userPrediction.value = data.data
          // Afficher un message de succès
          console.log('Pronostic enregistré avec succès!')
        }
      } catch (error) {
        console.error('Erreur lors de l\'envoi du pronostic:', error)
        if (error.message?.includes('401')) {
          showAuthModal.value = true
        }
      } finally {
        submitting.value = false
      }
    }

    const formatMatchDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('fr-FR', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    const getPredictedWinnerText = (winner) => {
      switch (winner) {
        case 'home': return currentMatch.value?.home_team?.name || 'Domicile'
        case 'away': return currentMatch.value?.away_team?.name || 'Extérieur'
        case 'draw': return 'Match nul'
        default: return 'Inconnu'
      }
    }

    const handleImageError = (event) => {
      event.target.style.display = 'none'
    }

    const handleAuthenticated = () => {
      showAuthModal.value = false
      loadUserPrediction()
    }

    // Watch for auth changes
    watch(() => authStore.isAuthenticated, (isAuth) => {
      if (isAuth) {
        loadUserPrediction()
      } else {
        userPrediction.value = null
      }
    })

    const loadFeaturedTournaments = async () => {
      try {
        const data = await apiStore.get('/tournaments/featured')
        if (data.success) {
          featuredTournaments.value = data.data || []
        }
      } catch (error) {
        console.error('Erreur lors du chargement des tournois:', error)
      } finally {
        loadingTournaments.value = false
      }
    }

    const registerToTournament = async (tournament) => {
      if (!authStore.isAuthenticated) {
        showAuthModal.value = true
        return
      }
      
      registering.value = tournament.id
      
      try {
        const data = await apiStore.post(`/tournaments/${tournament.id}/register`, {})
        if (data.success) {
          tournament.user_is_participant = true
          tournament.can_register = false
          tournament.participants_count += 1
          console.log('Inscription réussie au tournoi!')
        }
      } catch (error) {
        console.error('Erreur lors de l\'inscription:', error)
        if (error.message?.includes('401')) {
          showAuthModal.value = true
        }
      } finally {
        registering.value = null
      }
    }

    const openTournament = (tournament) => {
      // Navigate to tournament detail page
      console.log('Ouverture du tournoi:', tournament.name)
    }

    const viewTournamentLeaderboard = (tournament) => {
      // Navigate to tournament leaderboard
      console.log('Classement du tournoi:', tournament.name)
    }

    const formatPrize = (amount, currency) => {
      return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: currency || 'XOF',
        minimumFractionDigits: 0
      }).format(amount)
    }

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

    onMounted(() => {
      loadCurrentMatch()
      loadFeaturedTournaments()
      
      emit('update-header', {
        title: 'Pronostics',
        showBack: false
      })
    })

    return {
      currentMatch,
      userPrediction,
      loading,
      submitting,
      showAuthModal,
      prediction,
      canSubmitPrediction,
      authStore,
      featuredTournaments,
      loadingTournaments,
      registering,
      submitPrediction,
      registerToTournament,
      openTournament,
      viewTournamentLeaderboard,
      formatMatchDate,
      formatTournamentDate,
      formatPrize,
      getPredictedWinnerText,
      handleImageError,
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

.predictions-content {
  padding: 1rem;
  max-width: 800px;
  margin: 0 auto;
}

.predictions-header {
  text-align: center;
  margin-bottom: 2rem;
}

.current-match-section {
  margin-bottom: 2rem;
}

.tournaments-section {
  margin-bottom: 2rem;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.view-all-link {
  color: #F4D03F;
  text-decoration: none;
  font-size: 0.9rem;
  font-weight: 500;
}

.view-all-link:hover {
  text-decoration: underline;
}

.tournaments-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 2rem;
  text-align: center;
}

.tournaments-grid {
  display: grid;
  gap: 1rem;
  margin-bottom: 1rem;
}

.tournament-card {
  background: #FFFFFF;
  border-radius: 12px;
  border: 1px solid #E2E8F0;
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.2s ease;
}

.tournament-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
  border-color: #F4D03F;
}

.tournament-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.tournament-name {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2D3748;
  margin: 0;
  flex: 1;
  margin-right: 1rem;
}

.tournament-status {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  white-space: nowrap;
}

.tournament-status.registration_open {
  background: #D1FAE5;
  color: #065F46;
}

.tournament-status.active {
  background: #DBEAFE;
  color: #1E40AF;
}

.tournament-status.upcoming {
  background: #FEF3C7;
  color: #92400E;
}

.tournament-status.finished {
  background: #F3F4F6;
  color: #6B7280;
}

.tournament-description {
  color: #6B7280;
  font-size: 0.9rem;
  margin-bottom: 1rem;
  line-height: 1.4;
}

.tournament-info {
  display: grid;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: #6B7280;
}

.info-item i {
  font-size: 1rem;
  color: #F4D03F;
}

.tournament-actions {
  display: flex;
  justify-content: flex-end;
  align-items: center;
}

.btn-small {
  padding: 0.5rem 1rem;
  font-size: 0.85rem;
  border-radius: 6px;
}

.tournament-closed {
  color: #9CA3AF;
  font-size: 0.85rem;
  font-style: italic;
}

.no-tournaments {
  text-align: center;
  padding: 3rem 1rem;
  color: #9CA3AF;
}

.no-tournaments i {
  font-size: 3rem;
  margin-bottom: 1rem;
  color: #E5E7EB;
}

.match-card {
  background: #FFFFFF;
  border-radius: 12px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
  margin-bottom: 1rem;
}

.match-card.featured {
  border-color: #F4D03F;
  box-shadow: 0 4px 16px rgba(244, 208, 63, 0.2);
}

.match-teams {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 1rem;
}

.team {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
}

.team-logo {
  width: 60px;
  height: 60px;
  object-fit: contain;
  margin-bottom: 0.5rem;
}

.team-logo-placeholder {
  width: 60px;
  height: 60px;
  background: #F4F4F5;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #9CA3AF;
  margin-bottom: 0.5rem;
}

.team-name {
  text-align: center;
  font-weight: 600;
  font-size: 0.9rem;
}

.match-vs {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 0 1rem;
}

.vs-text {
  font-weight: 700;
  font-size: 1.2rem;
  color: #F4D03F;
}

.match-date {
  font-size: 0.8rem;
  color: #6B7280;
  text-align: center;
  margin-top: 0.5rem;
}

.prediction-status {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 500;
}

.prediction-status.can-predict {
  background: #D1FAE5;
  color: #065F46;
}

.prediction-status.closed {
  background: #FEE2E2;
  color: #991B1B;
}

.prediction-form {
  border-top: 1px solid #E2E8F0;
  padding-top: 1rem;
  margin-top: 1rem;
}

.score-inputs {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  margin: 1rem 0;
}

.score-input {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.score-input label {
  margin-bottom: 0.5rem;
  color: #6B7280;
}

.score-field {
  width: 60px;
  height: 50px;
  text-align: center;
  border: 2px solid #E2E8F0;
  border-radius: 8px;
  font-size: 1.2rem;
  font-weight: 600;
}

.score-field:focus {
  outline: none;
  border-color: #F4D03F;
}

.score-separator {
  font-size: 1.5rem;
  font-weight: 600;
  color: #6B7280;
}

.prediction-submit {
  width: 100%;
  margin-top: 1rem;
}

.auth-required {
  text-align: center;
  padding: 1rem;
  border: 1px dashed #E2E8F0;
  border-radius: 8px;
  margin-top: 1rem;
}

.user-prediction {
  background: #F8F9FA;
  border-radius: 8px;
  padding: 1rem;
  margin-top: 1rem;
}

.prediction-display {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.prediction-score {
  font-size: 1.5rem;
  font-weight: 700;
  color: #F4D03F;
}

.prediction-winner {
  font-size: 0.9rem;
  color: #6B7280;
}

.quick-actions {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
  margin-bottom: 2rem;
}

.quick-action-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1rem;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  text-decoration: none;
  color: #2D3748;
  transition: all 0.2s ease;
}

.quick-action-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.quick-action-card i {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  color: #F4D03F;
}

.action-text {
  text-align: center;
}

.rules-section {
  background: #F8F9FA;
  border-radius: 12px;
  padding: 1.5rem;
}

.rules-grid {
  display: grid;
  gap: 1rem;
  margin-top: 1rem;
}

.rule-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: #FFFFFF;
  border-radius: 8px;
}

.rule-icon {
  width: 40px;
  height: 40px;
  background: #F4D03F;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #2D3748;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  padding: 2rem;
  text-align: center;
}

/* No Match Section Styles */
.no-match-section {
  margin-bottom: 2rem;
}

.no-match-card {
  background: #F8F9FA;
  border-radius: 16px;
  padding: 2rem;
  text-align: center;
}

.no-match-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: #E2E8F0;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1.5rem;
}

.no-match-icon i {
  font-size: 36px;
  color: #6B7280;
}

.suggestions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1rem;
  margin-top: 2rem;
}

.suggestion-card {
  background: #FFFFFF;
  border-radius: 12px;
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid #E2E8F0;
  text-align: center;
}

.suggestion-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-color: #F4D03F;
}

.suggestion-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: #FEF3C7;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1rem;
}

.suggestion-icon i {
  font-size: 24px;
  color: #F59E0B;
}

.suggestion-title {
  font-size: 1.1rem;
  font-weight: 600;
  color: #2D3748;
  margin: 0 0 0.5rem 0;
}

.suggestion-desc {
  font-size: 0.9rem;
  color: #6B7280;
  margin: 0;
  line-height: 1.4;
}

/* Enhanced No Tournaments Styles */
.no-tournaments-enhanced {
  background: #F8F9FA;
  border-radius: 16px;
  padding: 2rem;
  text-align: center;
}

.no-tournaments-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: #FEF3C7;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1.5rem;
}

.no-tournaments-icon i {
  font-size: 36px;
  color: #F59E0B;
}

.fallback-actions {
  margin-top: 2rem;
  text-align: left;
}

.fallback-info h4 {
  color: #2D3748;
  margin: 0 0 1rem 0;
}

.fallback-list {
  list-style: none;
  padding: 0;
  margin: 0 0 1.5rem 0;
}

.fallback-list li {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
  padding: 0.75rem 0;
  border-bottom: 1px solid #E2E8F0;
}

.fallback-list li:last-child {
  border-bottom: none;
}

.fallback-list i {
  color: #F4D03F;
  font-size: 20px;
  margin-top: 2px;
  flex-shrink: 0;
}

.fallback-list span {
  color: #6B7280;
  line-height: 1.4;
}

.fallback-cta {
  text-align: center;
  margin-top: 1.5rem;
}

.fallback-cta button {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

@media (max-width: 768px) {
  .quick-actions {
    grid-template-columns: 1fr;
  }
  
  .suggestions-grid {
    grid-template-columns: 1fr;
  }
  
  .match-teams {
    flex-direction: column;
    gap: 1rem;
  }
  
  .match-vs {
    order: -1;
    margin-bottom: 1rem;
  }
  
  .team-logo,
  .team-logo-placeholder {
    width: 50px;
    height: 50px;
  }
}
</style>