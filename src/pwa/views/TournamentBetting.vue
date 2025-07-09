<template>
  <div class="tournament-betting">
    <main class="md3-main-content">
      <!-- Header -->
      <div class="page-header">
        <div class="header-content">
          <div class="breadcrumb">
            <router-link to="/predictions" class="breadcrumb-link">Prédictions</router-link>
            <DinorIcon name="chevron_right" :size="16" />
            <span class="current-page">Paris de Tournois</span>
          </div>
          <h1 class="md3-title-large dinor-text-primary">Interface de Paris</h1>
          <p class="md3-body-medium dinor-text-gray">
            Pariez intelligemment sur les tournois et maximisez vos gains
          </p>
        </div>
      </div>

      <!-- Tournament Selection -->
      <div class="tournament-selection">
        <h2 class="section-title">
          <DinorIcon name="emoji_events" :size="20" />
          Sélectionner un tournoi
        </h2>
        
        <div v-if="loadingTournaments" class="loading-state">
          <div class="md3-circular-progress"></div>
          <p>Chargement des tournois...</p>
        </div>
        
        <div v-else class="tournaments-grid">
          <div 
            v-for="tournament in availableTournaments" 
            :key="tournament.id"
            :class="['tournament-card', { 'selected': selectedTournament?.id === tournament.id }]"
            @click="selectTournament(tournament)"
          >
            <div class="tournament-header">
              <h3 class="tournament-name">{{ tournament.name }}</h3>
              <div class="tournament-badges">
                <span :class="['status-badge', tournament.status]">
                  {{ tournament.status_label }}
                </span>
                <span v-if="tournament.is_featured" class="featured-badge">
                  <DinorIcon name="star" :size="16" />
                  Vedette
                </span>
              </div>
            </div>
            
            <p class="tournament-description">{{ tournament.description }}</p>
            
            <div class="tournament-stats">
              <div class="stat">
                <DinorIcon name="group" :size="16" />
                <span>{{ tournament.participants_count }} participants</span>
              </div>
              <div class="stat" v-if="tournament.prize_pool > 0">
                <DinorIcon name="emoji_events" :size="16" />
                <span>{{ formatCurrency(tournament.prize_pool, tournament.currency) }}</span>
              </div>
              <div class="stat">
                <DinorIcon name="schedule" :size="16" />
                <span>{{ formatDate(tournament.end_date) }}</span>
              </div>
            </div>
            
            <div class="tournament-progress">
              <div class="progress-bar">
                <div 
                  class="progress-fill" 
                  :style="{ width: tournament.progress_percentage + '%' }"
                ></div>
              </div>
              <span class="progress-text">{{ tournament.progress_percentage }}% terminé</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Betting Interface -->
      <div v-if="selectedTournament" class="betting-interface">
        <div class="interface-header">
          <h2 class="section-title">
            <DinorIcon name="casino" :size="20" />
            Interface de Paris - {{ selectedTournament.name }}
          </h2>
          <div class="user-balance" v-if="authStore.isAuthenticated">
            <DinorIcon name="account_balance_wallet" :size="20" />
            <span>Solde: {{ userBalance }} points</span>
          </div>
        </div>

        <!-- Matches to Bet On -->
        <div class="matches-section">
          <h3 class="subsection-title">Matchs disponibles</h3>
          
          <div v-if="loadingMatches" class="loading-state">
            <div class="md3-circular-progress"></div>
            <p>Chargement des matchs...</p>
          </div>
          
          <div v-else-if="tournamentMatches.length === 0" class="no-matches">
            <DinorIcon name="sports_soccer" :size="48" />
            <h3>Aucun match disponible</h3>
            <p>Aucun match n'est actuellement ouvert aux paris pour ce tournoi.</p>
          </div>
          
          <div v-else class="matches-grid">
            <div 
              v-for="match in tournamentMatches" 
              :key="match.id"
              class="match-betting-card"
            >
              <div class="match-header">
                <div class="match-info">
                  <span class="round">{{ match.round || 'Match' }}</span>
                  <span class="match-date">{{ formatMatchDateTime(match.match_date) }}</span>
                </div>
                <div class="betting-status">
                  <span v-if="match.can_predict" class="status-open">
                    <DinorIcon name="lock_open" :size="16" />
                    Paris ouverts
                  </span>
                  <span v-else class="status-closed">
                    <DinorIcon name="lock" :size="16" />
                    Paris fermés
                  </span>
                </div>
              </div>

              <div class="teams-section">
                <div class="team home-team">
                  <img 
                    v-if="match.home_team.logo_url" 
                    :src="match.home_team.logo_url" 
                    :alt="match.home_team.name"
                    class="team-logo"
                  >
                  <div v-else class="team-logo-placeholder">
                    <DinorIcon name="shield" :size="32" />
                  </div>
                  <div class="team-info">
                    <h4 class="team-name">{{ match.home_team.name }}</h4>
                    <span class="team-country">{{ match.home_team.country }}</span>
                  </div>
                </div>
                
                <div class="vs-section">
                  <span class="vs-text">VS</span>
                  <div class="odds-display" v-if="match.odds">
                    <div class="odd-item">
                      <span class="odd-label">Dom.</span>
                      <span class="odd-value">{{ match.odds.home }}</span>
                    </div>
                    <div class="odd-item">
                      <span class="odd-label">Nul</span>
                      <span class="odd-value">{{ match.odds.draw }}</span>
                    </div>
                    <div class="odd-item">
                      <span class="odd-label">Ext.</span>
                      <span class="odd-value">{{ match.odds.away }}</span>
                    </div>
                  </div>
                </div>
                
                <div class="team away-team">
                  <img 
                    v-if="match.away_team.logo_url" 
                    :src="match.away_team.logo_url" 
                    :alt="match.away_team.name"
                    class="team-logo"
                  >
                  <div v-else class="team-logo-placeholder">
                    <DinorIcon name="shield" :size="32" />
                  </div>
                  <div class="team-info">
                    <h4 class="team-name">{{ match.away_team.name }}</h4>
                    <span class="team-country">{{ match.away_team.country }}</span>
                  </div>
                </div>
              </div>

              <!-- Betting Form -->
              <div v-if="match.can_predict && authStore.isAuthenticated" class="betting-form">
                <div class="bet-types">
                  <h4 class="form-title">Types de paris</h4>
                  
                  <!-- Score Prediction -->
                  <div class="bet-type score-prediction">
                    <label class="bet-label">
                      <DinorIcon name="sports_score" :size="16" />
                      Prédiction de score
                    </label>
                    <div class="score-inputs">
                      <div class="score-input">
                        <label>{{ match.home_team.short_name || 'DOM' }}</label>
                        <input 
                          v-model.number="getBetData(match.id).homeScore"
                          type="number" 
                          min="0" 
                          max="10"
                          class="score-field"
                        >
                      </div>
                      <span class="score-separator">-</span>
                      <div class="score-input">
                        <label>{{ match.away_team.short_name || 'EXT' }}</label>
                        <input 
                          v-model.number="getBetData(match.id).awayScore"
                          type="number" 
                          min="0" 
                          max="10"
                          class="score-field"
                        >
                      </div>
                    </div>
                  </div>

                  <!-- Winner Prediction -->
                  <div class="bet-type winner-prediction">
                    <label class="bet-label">
                      <DinorIcon name="emoji_events" :size="16" />
                      Vainqueur
                    </label>
                    <div class="winner-options">
                      <button 
                        :class="['winner-btn', { 'active': getBetData(match.id).winner === 'home' }]"
                        @click="setBetWinner(match.id, 'home')"
                      >
                        {{ match.home_team.short_name || 'Domicile' }}
                      </button>
                      <button 
                        :class="['winner-btn', { 'active': getBetData(match.id).winner === 'draw' }]"
                        @click="setBetWinner(match.id, 'draw')"
                      >
                        Match nul
                      </button>
                      <button 
                        :class="['winner-btn', { 'active': getBetData(match.id).winner === 'away' }]"
                        @click="setBetWinner(match.id, 'away')"
                      >
                        {{ match.away_team.short_name || 'Extérieur' }}
                      </button>
                    </div>
                  </div>

                  <!-- Bet Amount -->
                  <div class="bet-type bet-amount">
                    <label class="bet-label">
                      <DinorIcon name="payments" :size="16" />
                      Mise (points)
                    </label>
                    <div class="amount-input">
                      <input 
                        v-model.number="getBetData(match.id).amount"
                        type="number" 
                        min="1" 
                        :max="userBalance"
                        placeholder="Montant en points"
                        class="amount-field"
                      >
                      <div class="quick-amounts">
                        <button 
                          v-for="amount in quickAmounts" 
                          :key="amount"
                          @click="setQuickAmount(match.id, amount)"
                          class="quick-amount-btn"
                        >
                          {{ amount }}
                        </button>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Bet Summary -->
                <div class="bet-summary">
                  <div class="summary-item">
                    <span>Prédiction:</span>
                    <span>{{ getBetSummary(match.id) }}</span>
                  </div>
                  <div class="summary-item">
                    <span>Mise:</span>
                    <span>{{ getBetData(match.id).amount || 0 }} points</span>
                  </div>
                  <div class="summary-item">
                    <span>Gain potentiel:</span>
                    <span>{{ calculatePotentialWin(match.id) }} points</span>
                  </div>
                </div>

                <!-- Submit Bet -->
                <button 
                  @click="submitBet(match.id)"
                  :disabled="!canSubmitBet(match.id) || submitting"
                  class="btn-primary submit-bet"
                >
                  <span v-if="submitting" class="loading-spinner"></span>
                  <span v-else>
                    <DinorIcon name="casino" :size="16" />
                    Placer le pari
                  </span>
                </button>
              </div>

              <!-- Auth Required -->
              <div v-else-if="match.can_predict && !authStore.isAuthenticated" class="auth-required">
                <DinorIcon name="login" :size="32" />
                <p>Connectez-vous pour parier sur ce match</p>
                <button @click="showAuthModal = true" class="btn-primary">
                  Se connecter
                </button>
              </div>

              <!-- Existing Bet Display -->
              <div v-if="getExistingBet(match.id)" class="existing-bet">
                <h4 class="existing-bet-title">Votre pari actuel</h4>
                <div class="bet-details">
                  <div class="detail-item">
                    <DinorIcon name="sports_score" :size="16" />
                    <span>{{ getExistingBet(match.id).predicted_home_score }}-{{ getExistingBet(match.id).predicted_away_score }}</span>
                  </div>
                  <div class="detail-item">
                    <DinorIcon name="emoji_events" :size="16" />
                    <span>{{ getWinnerText(getExistingBet(match.id).predicted_winner) }}</span>
                  </div>
                  <div class="detail-item">
                    <DinorIcon name="payments" :size="16" />
                    <span>{{ getExistingBet(match.id).bet_amount || 0 }} points</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Betting Statistics -->
        <div class="betting-stats">
          <h3 class="subsection-title">
            <DinorIcon name="analytics" :size="20" />
            Vos statistiques de paris
          </h3>
          
          <div class="stats-grid">
            <div class="stat-card">
              <div class="stat-icon">
                <DinorIcon name="casino" :size="24" />
              </div>
              <div class="stat-content">
                <h4 class="stat-value">{{ userStats.totalBets || 0 }}</h4>
                <p class="stat-label">Paris placés</p>
              </div>
            </div>
            
            <div class="stat-card">
              <div class="stat-icon">
                <DinorIcon name="trending_up" :size="24" />
              </div>
              <div class="stat-content">
                <h4 class="stat-value">{{ userStats.winRate || 0 }}%</h4>
                <p class="stat-label">Taux de réussite</p>
              </div>
            </div>
            
            <div class="stat-card">
              <div class="stat-icon">
                <DinorIcon name="payments" :size="24" />
              </div>
              <div class="stat-content">
                <h4 class="stat-value">{{ userStats.totalWinnings || 0 }}</h4>
                <p class="stat-label">Gains totaux</p>
              </div>
            </div>
            
            <div class="stat-card">
              <div class="stat-icon">
                <DinorIcon name="leaderboard" :size="24" />
              </div>
              <div class="stat-content">
                <h4 class="stat-value">#{{ userStats.rank || 'N/A' }}</h4>
                <p class="stat-label">Classement</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- No Tournament Selected -->
      <div v-else class="no-tournament-selected">
        <div class="placeholder-content">
          <DinorIcon name="casino" :size="64" />
          <h3>Sélectionnez un tournoi</h3>
          <p>Choisissez un tournoi ci-dessus pour commencer à parier</p>
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
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'TournamentBetting',
  components: {
    AuthModal,
    DinorIcon
  },
  setup() {
    const apiStore = useApiStore()
    const authStore = useAuthStore()
    
    // State
    const availableTournaments = ref([])
    const selectedTournament = ref(null)
    const tournamentMatches = ref([])
    const userBets = ref({})
    const existingBets = ref({})
    const userStats = ref({})
    const userBalance = ref(1000) // Points de départ
    
    // Loading states
    const loadingTournaments = ref(true)
    const loadingMatches = ref(false)
    const submitting = ref(false)
    const showAuthModal = ref(false)
    
    // Betting data
    const bettingData = ref({})
    const quickAmounts = [10, 25, 50, 100, 250]

    // Initialize betting data for a match
    const getBetData = (matchId) => {
      if (!bettingData.value[matchId]) {
        bettingData.value[matchId] = {
          homeScore: 0,
          awayScore: 0,
          winner: null,
          amount: 10
        }
      }
      return bettingData.value[matchId]
    }

    // Set bet winner
    const setBetWinner = (matchId, winner) => {
      getBetData(matchId).winner = winner
    }

    // Set quick amount
    const setQuickAmount = (matchId, amount) => {
      getBetData(matchId).amount = Math.min(amount, userBalance.value)
    }

    // Get bet summary
    const getBetSummary = (matchId) => {
      const bet = getBetData(matchId)
      if (bet.homeScore !== null && bet.awayScore !== null && bet.winner) {
        return `${bet.homeScore}-${bet.awayScore}, ${getWinnerText(bet.winner)}`
      }
      return 'Aucune prédiction'
    }

    // Get winner text
    const getWinnerText = (winner) => {
      switch (winner) {
        case 'home': return 'Victoire domicile'
        case 'away': return 'Victoire extérieur'
        case 'draw': return 'Match nul'
        default: return 'Non défini'
      }
    }

    // Calculate potential win
    const calculatePotentialWin = (matchId) => {
      const bet = getBetData(matchId)
      const baseMultiplier = 2.0
      const scoreMultiplier = 1.5
      const amount = bet.amount || 0
      
      if (bet.winner && amount > 0) {
        return Math.round(amount * baseMultiplier * scoreMultiplier)
      }
      return 0
    }

    // Check if can submit bet
    const canSubmitBet = (matchId) => {
      const bet = getBetData(matchId)
      return bet.homeScore !== null && 
             bet.awayScore !== null && 
             bet.winner && 
             bet.amount > 0 && 
             bet.amount <= userBalance.value
    }

    // Get existing bet
    const getExistingBet = (matchId) => {
      return existingBets.value[matchId]
    }

    // Load tournaments
    const loadTournaments = async () => {
      try {
        loadingTournaments.value = true
        const response = await apiStore.get('/tournaments/betting-available')
        if (response.success) {
          availableTournaments.value = response.data
        }
      } catch (error) {
        console.error('Erreur chargement tournois:', error)
      } finally {
        loadingTournaments.value = false
      }
    }

    // Select tournament
    const selectTournament = async (tournament) => {
      selectedTournament.value = tournament
      await loadTournamentMatches(tournament.id)
      if (authStore.isAuthenticated) {
        await loadUserBets(tournament.id)
        await loadUserStats()
      }
    }

    // Load tournament matches
    const loadTournamentMatches = async (tournamentId) => {
      try {
        loadingMatches.value = true
        const response = await apiStore.get(`/tournaments/${tournamentId}/matches/betting`)
        if (response.success) {
          tournamentMatches.value = response.data
        }
      } catch (error) {
        console.error('Erreur chargement matchs:', error)
      } finally {
        loadingMatches.value = false
      }
    }

    // Load user bets
    const loadUserBets = async (tournamentId) => {
      try {
        const response = await apiStore.get(`/tournaments/${tournamentId}/my-bets`)
        if (response.success) {
          existingBets.value = response.data.reduce((acc, bet) => {
            acc[bet.football_match_id] = bet
            return acc
          }, {})
        }
      } catch (error) {
        console.error('Erreur chargement paris utilisateur:', error)
      }
    }

    // Load user stats
    const loadUserStats = async () => {
      try {
        const response = await apiStore.get('/betting/my-stats')
        if (response.success) {
          userStats.value = response.data
        }
      } catch (error) {
        console.error('Erreur chargement stats:', error)
      }
    }

    // Submit bet
    const submitBet = async (matchId) => {
      if (!canSubmitBet(matchId)) return
      
      try {
        submitting.value = true
        const bet = getBetData(matchId)
        
        const response = await apiStore.post(`/matches/${matchId}/bet`, {
          predicted_home_score: bet.homeScore,
          predicted_away_score: bet.awayScore,
          predicted_winner: bet.winner,
          bet_amount: bet.amount
        })
        
        if (response.success) {
          // Update balance
          userBalance.value -= bet.amount
          
          // Add to existing bets
          existingBets.value[matchId] = response.data
          
          // Clear betting form
          delete bettingData.value[matchId]
          
          // Show success message
          alert('Pari placé avec succès!')
          
          // Reload stats
          if (authStore.isAuthenticated) {
            await loadUserStats()
          }
        }
      } catch (error) {
        console.error('Erreur soumission pari:', error)
        alert('Erreur lors de la soumission du pari')
      } finally {
        submitting.value = false
      }
    }

    // Handle authentication
    const handleAuthenticated = () => {
      showAuthModal.value = false
      if (selectedTournament.value) {
        loadUserBets(selectedTournament.value.id)
        loadUserStats()
      }
    }

    // Format helpers
    const formatCurrency = (amount, currency = 'EUR') => {
      return new Intl.NumberFormat('fr-FR', { 
        style: 'currency', 
        currency: currency 
      }).format(amount)
    }

    const formatDate = (date) => {
      return new Date(date).toLocaleDateString('fr-FR', {
        day: 'numeric',
        month: 'short',
        year: 'numeric'
      })
    }

    const formatMatchDateTime = (date) => {
      return new Date(date).toLocaleString('fr-FR', {
        day: 'numeric',
        month: 'short',
        hour: '2-digit',
        minute: '2-digit'
      })
    }

    // Initialize
    onMounted(() => {
      loadTournaments()
    })

    return {
      // State
      availableTournaments,
      selectedTournament,
      tournamentMatches,
      userStats,
      userBalance,
      loadingTournaments,
      loadingMatches,
      submitting,
      showAuthModal,
      quickAmounts,
      
      // Stores
      apiStore,
      authStore,
      
      // Methods
      selectTournament,
      getBetData,
      setBetWinner,
      setQuickAmount,
      getBetSummary,
      getWinnerText,
      calculatePotentialWin,
      canSubmitBet,
      getExistingBet,
      submitBet,
      handleAuthenticated,
      formatCurrency,
      formatDate,
      formatMatchDateTime
    }
  }
}
</script>

<style scoped>
.tournament-betting {
  min-height: 100vh;
  background: var(--md-sys-color-surface, #fefbff);
}

.page-header {
  background: linear-gradient(135deg, var(--dinor-red) 0%, #c41e3a 100%);
  color: white;
  padding: 2rem 1rem;
  margin-bottom: 2rem;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
}

.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1rem;
  font-size: 0.875rem;
  opacity: 0.9;
}

.breadcrumb-link {
  color: inherit;
  text-decoration: none;
}

.breadcrumb-link:hover {
  text-decoration: underline;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
  color: var(--dinor-red);
  font-size: 1.25rem;
  font-weight: 600;
}

.tournament-selection {
  max-width: 1200px;
  margin: 0 auto 3rem;
  padding: 0 1rem;
}

.tournaments-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 1.5rem;
}

.tournament-card {
  background: white;
  border: 2px solid #e2e8f0;
  border-radius: 16px;
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tournament-card:hover {
  border-color: var(--dinor-red);
  box-shadow: 0 8px 32px rgba(225, 37, 27, 0.15);
  transform: translateY(-2px);
}

.tournament-card.selected {
  border-color: var(--dinor-red);
  background: rgba(225, 37, 27, 0.05);
}

.tournament-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.tournament-badges {
  display: flex;
  gap: 0.5rem;
  flex-direction: column;
  align-items: flex-end;
}

.status-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
}

.status-badge.active {
  background: #10b981;
  color: white;
}

.status-badge.registration_open {
  background: #3b82f6;
  color: white;
}

.featured-badge {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.25rem 0.5rem;
  background: #fbbf24;
  color: #92400e;
  border-radius: 8px;
  font-size: 0.75rem;
  font-weight: 600;
}

.tournament-stats {
  display: flex;
  gap: 1rem;
  margin: 1rem 0;
  flex-wrap: wrap;
}

.stat {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.875rem;
  color: #6b7280;
}

.tournament-progress {
  margin-top: 1rem;
}

.progress-bar {
  width: 100%;
  height: 6px;
  background: #e5e7eb;
  border-radius: 3px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: var(--dinor-red);
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 0.75rem;
  color: #6b7280;
  margin-top: 0.25rem;
}

.betting-interface {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
}

.interface-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
}

.user-balance {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: var(--dinor-red);
  color: white;
  padding: 0.75rem 1rem;
  border-radius: 12px;
  font-weight: 600;
}

.matches-grid {
  display: grid;
  gap: 2rem;
}

.match-betting-card {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 16px;
  padding: 1.5rem;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
}

.match-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.match-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.round {
  font-weight: 600;
  color: var(--dinor-red);
}

.match-date {
  font-size: 0.875rem;
  color: #6b7280;
}

.betting-status {
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-size: 0.875rem;
  font-weight: 600;
}

.status-open {
  background: #10b981;
  color: white;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.status-closed {
  background: #ef4444;
  color: white;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.teams-section {
  display: grid;
  grid-template-columns: 1fr auto 1fr;
  gap: 2rem;
  align-items: center;
  margin-bottom: 2rem;
}

.team {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.team.away-team {
  flex-direction: row-reverse;
}

.team-logo {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  object-fit: cover;
}

.team-logo-placeholder {
  width: 48px;
  height: 48px;
  background: #f3f4f6;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #6b7280;
}

.team-info {
  text-align: left;
}

.away-team .team-info {
  text-align: right;
}

.team-name {
  font-weight: 600;
  margin: 0;
}

.team-country {
  font-size: 0.875rem;
  color: #6b7280;
}

.vs-section {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.vs-text {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--dinor-red);
}

.odds-display {
  display: flex;
  gap: 0.5rem;
}

.odd-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0.5rem;
  background: #f8fafc;
  border-radius: 8px;
}

.odd-label {
  font-size: 0.75rem;
  color: #6b7280;
}

.odd-value {
  font-weight: 600;
  color: var(--dinor-red);
}

.betting-form {
  border-top: 1px solid #e5e7eb;
  padding-top: 1.5rem;
}

.bet-types {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.form-title {
  margin: 0 0 1rem;
  color: var(--dinor-red);
}

.bet-type {
  padding: 1rem;
  background: #f8fafc;
  border-radius: 12px;
}

.bet-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  margin-bottom: 1rem;
  color: #374151;
}

.score-inputs {
  display: flex;
  align-items: center;
  gap: 1rem;
  justify-content: center;
}

.score-input {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
}

.score-field {
  width: 60px;
  padding: 0.5rem;
  border: 2px solid #d1d5db;
  border-radius: 8px;
  text-align: center;
  font-weight: 600;
}

.score-field:focus {
  outline: none;
  border-color: var(--dinor-red);
}

.score-separator {
  font-size: 1.5rem;
  font-weight: 700;
  color: #6b7280;
}

.winner-options {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.winner-btn {
  flex: 1;
  padding: 0.75rem 1rem;
  border: 2px solid #d1d5db;
  background: white;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
  font-weight: 600;
}

.winner-btn:hover {
  border-color: var(--dinor-red);
}

.winner-btn.active {
  background: var(--dinor-red);
  color: white;
  border-color: var(--dinor-red);
}

.amount-input {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.amount-field {
  width: 100%;
  padding: 0.75rem;
  border: 2px solid #d1d5db;
  border-radius: 8px;
  font-size: 1rem;
}

.amount-field:focus {
  outline: none;
  border-color: var(--dinor-red);
}

.quick-amounts {
  display: flex;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.quick-amount-btn {
  padding: 0.5rem 1rem;
  border: 1px solid #d1d5db;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.875rem;
}

.quick-amount-btn:hover {
  background: var(--dinor-red);
  color: white;
  border-color: var(--dinor-red);
}

.bet-summary {
  background: #f0f9ff;
  border: 1px solid #0ea5e9;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1rem;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.25rem 0;
}

.submit-bet {
  width: 100%;
  padding: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  font-size: 1rem;
  font-weight: 600;
}

.auth-required {
  background: #fef3c7;
  border: 1px solid #f59e0b;
  border-radius: 8px;
  padding: 1.5rem;
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.existing-bet {
  background: #ecfdf5;
  border: 1px solid #10b981;
  border-radius: 8px;
  padding: 1rem;
  margin-top: 1rem;
}

.existing-bet-title {
  margin: 0 0 1rem;
  color: #065f46;
}

.bet-details {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.betting-stats {
  margin-top: 3rem;
  max-width: 1200px;
  margin: 3rem auto 0;
  padding: 0 1rem;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.stat-card {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

.stat-icon {
  width: 48px;
  height: 48px;
  background: var(--dinor-red);
  color: white;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--dinor-red);
  margin: 0;
}

.stat-label {
  font-size: 0.875rem;
  color: #6b7280;
  margin: 0;
}

.no-tournament-selected {
  max-width: 1200px;
  margin: 0 auto;
  padding: 4rem 1rem;
  text-align: center;
}

.placeholder-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  color: #6b7280;
}

.placeholder-content {
  opacity: 0.5;
}

.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 2rem;
  color: #6b7280;
}

.no-matches {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  padding: 3rem;
  color: #6b7280;
  text-align: center;
  opacity: 0.5;
}

/* Responsive */
@media (max-width: 768px) {
  .teams-section {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .vs-section {
    order: -1;
  }
  
  .team {
    justify-content: center;
  }
  
  .away-team {
    flex-direction: row;
  }
  
  .away-team .team-info {
    text-align: center;
  }
  
  .winner-options {
    flex-direction: column;
  }
  
  .interface-header {
    flex-direction: column;
    gap: 1rem;
    align-items: stretch;
  }
}

/* Animations */
.md3-circular-progress {
  width: 32px;
  height: 32px;
  border: 3px solid #e5e7eb;
  border-top-color: var(--dinor-red);
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.loading-spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

/* Button styles */
.btn-primary {
  background: var(--dinor-red);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 0.75rem 1.5rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary:hover:not(:disabled) {
  background: #c41e3a;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(225, 37, 27, 0.3);
}

.btn-primary:disabled {
  background: #9ca3af;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.btn-secondary {
  background: white;
  color: var(--dinor-red);
  border: 2px solid var(--dinor-red);
  border-radius: 8px;
  padding: 0.75rem 1.5rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-secondary:hover {
  background: var(--dinor-red);
  color: white;
}

.subsection-title {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 1.5rem;
  font-size: 1.125rem;
  font-weight: 600;
  color: #374151;
}
</style> 