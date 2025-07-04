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

        <!-- Quick Actions -->
        <div class="quick-actions">
          <router-link to="/predictions/teams" class="action-card">
            <i class="material-icons">groups</i>
            <span>Équipes</span>
          </router-link>
          
          <router-link to="/predictions/matches" class="action-card">
            <i class="material-icons">sports_soccer</i>
            <span>Tous les matchs</span>
          </router-link>
          
          <router-link to="/predictions/leaderboard" class="action-card">
            <i class="material-icons">trophy</i>
            <span>Classement</span>
          </router-link>
          
          <router-link to="/predictions/my-predictions" class="action-card">
            <i class="material-icons">history</i>
            <span>Mes pronostics</span>
          </router-link>
        </div>

        <!-- Rules Section -->
        <div class="rules-section">
          <h2 class="md3-title-medium dinor-text-primary">Règles du jeu</h2>
          <div class="rules-grid">
            <div class="rule-item">
              <div class="rule-icon">
                <i class="material-icons">star</i>
              </div>
              <div class="rule-content">
                <h3 class="md3-title-small">Score exact</h3>
                <p class="md3-body-small">3 points pour un score exact</p>
              </div>
            </div>
            
            <div class="rule-item">
              <div class="rule-icon">
                <i class="material-icons">thumb_up</i>
              </div>
              <div class="rule-content">
                <h3 class="md3-title-small">Bon gagnant</h3>
                <p class="md3-body-small">1 point pour le bon gagnant uniquement</p>
              </div>
            </div>
            
            <div class="rule-item">
              <div class="rule-icon">
                <i class="material-icons">emoji_events</i>
              </div>
              <div class="rule-content">
                <h3 class="md3-title-small">Score + Gagnant</h3>
                <p class="md3-body-small">3 points au total (même règle)</p>
              </div>
            </div>
          </div>
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
        const data = await apiStore.get(`/v1/predictions/match/${currentMatch.value.id}`)
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
          data = await apiStore.put(`/v1/predictions/${userPrediction.value.id}`, payload)
        } else {
          data = await apiStore.post('/v1/predictions', payload)
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

    onMounted(() => {
      loadCurrentMatch()
      
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
      submitPrediction,
      formatMatchDate,
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

.action-card {
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

.action-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.action-card i {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  color: #F4D03F;
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

@media (max-width: 768px) {
  .quick-actions {
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