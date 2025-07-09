<template>
  <div class="tournaments">
    <main class="md3-main-content">
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="md3-circular-progress"></div>
        <p class="md3-body-large">Chargement des tournois...</p>
      </div>

      <!-- Tournaments Content -->
      <div v-else class="tournaments-content">
        <!-- Header Section -->
        <div class="tournaments-header">
          <h1 class="md3-title-large dinor-text-primary">Tournois</h1>
          <p class="md3-body-medium dinor-text-gray">Participez aux tournois et gagnez des prix!</p>
        </div>

        <!-- Filters -->
        <div class="filters-section">
          <div class="filter-tabs">
            <button 
              v-for="filter in filters" 
              :key="filter.key"
              @click="selectedFilter = filter.key"
              :class="['filter-tab', { active: selectedFilter === filter.key }]"
            >
              {{ filter.label }}
            </button>
          </div>
        </div>

        <!-- Tournaments Grid -->
        <div v-if="filteredTournaments.length > 0" class="tournaments-grid">
          <div 
            v-for="tournament in filteredTournaments" 
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
              <div class="info-row">
                <div class="info-item">
                  <DinorIcon name="group" :size="16" />
                  <span>{{ tournament.participants_count }} participants</span>
                </div>
                <div class="info-item" v-if="tournament.prize_pool > 0">
                  <DinorIcon name="emoji_events" :size="16" />
                  <span>{{ formatPrize(tournament.prize_pool, tournament.currency) }}</span>
                </div>
              </div>
              
              <div class="info-row">
                <div class="info-item">
                  <DinorIcon name="schedule" :size="16" />
                  <span>Fin: {{ formatDate(tournament.end_date) }}</span>
                </div>
                <div class="info-item" v-if="tournament.entry_fee > 0">
                  <DinorIcon name="payments" :size="16" />
                  <span>{{ formatPrize(tournament.entry_fee, tournament.currency) }}</span>
                </div>
              </div>
            </div>

            <!-- Progress Bar -->
            <div v-if="tournament.status === 'active'" class="tournament-progress">
              <div class="progress-bar">
                <div 
                  class="progress-fill" 
                  :style="{ width: tournament.progress_percentage + '%' }"
                ></div>
              </div>
              <span class="progress-text">{{ tournament.progress_percentage }}% terminé</span>
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
                <DinorIcon name="leaderboard" :size="16" />
                Mon classement
              </button>
              
              <div v-else class="tournament-status-info">
                <span v-if="tournament.status === 'upcoming'" class="status-text">
                  <DinorIcon name="schedule" :size="16" />
                  À venir
                </span>
                <span v-else-if="tournament.status === 'finished'" class="status-text">
                  <DinorIcon name="flag" :size="16" />
                  Terminé
                </span>
                <span v-else class="status-text">
                  <DinorIcon name="block" :size="16" />
                  Inscriptions fermées
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- Empty State -->
        <div v-else class="empty-state">
          <DinorIcon name="emoji_events" :size="64" />
          <h3>Aucun tournoi disponible</h3>
          <p>Les tournois apparaîtront ici quand ils seront disponibles.</p>
        </div>

        <!-- My Tournaments Section -->
        <div v-if="authStore.isAuthenticated && myTournaments.length > 0" class="my-tournaments-section">
          <h2 class="md3-title-medium dinor-text-primary">Mes tournois</h2>
          
          <div class="my-tournaments-list">
            <div 
              v-for="tournamentData in myTournaments" 
              :key="tournamentData.tournament.id"
              class="my-tournament-item"
              @click="openTournament(tournamentData.tournament)"
            >
              <div class="tournament-info-left">
                <h4 class="tournament-name">{{ tournamentData.tournament.name }}</h4>
                <span :class="['tournament-status', tournamentData.tournament.status]">
                  {{ tournamentData.tournament.status_label }}
                </span>
              </div>
              
              <div class="tournament-stats">
                <div class="stat-item">
                  <span class="stat-label">Rang</span>
                  <span class="stat-value">#{{ tournamentData.user_rank || 'N/A' }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Points</span>
                  <span class="stat-value">{{ tournamentData.user_points }}</span>
                </div>
                <div class="stat-item">
                  <span class="stat-label">Précision</span>
                  <span class="stat-value">{{ tournamentData.user_accuracy }}%</span>
                </div>
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
import { ref, onMounted, computed } from 'vue'
import { useApiStore } from '@/stores/api'
import { useAuthStore } from '@/stores/auth'
import AuthModal from '@/components/common/AuthModal.vue'
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'Tournaments',
  emits: ['update-header'],
  components: {
    AuthModal,
    DinorIcon
  },
  setup(_, { emit }) {
    const apiStore = useApiStore()
    const authStore = useAuthStore()
    
    const tournaments = ref([])
    const myTournaments = ref([])
    const loading = ref(true)
    const registering = ref(null)
    const showAuthModal = ref(false)
    const selectedFilter = ref('all')

    const filters = [
      { key: 'all', label: 'Tous' },
      { key: 'registration_open', label: 'Inscriptions ouvertes' },
      { key: 'active', label: 'En cours' },
      { key: 'upcoming', label: 'À venir' },
      { key: 'finished', label: 'Terminés' }
    ]

    const filteredTournaments = computed(() => {
      if (selectedFilter.value === 'all') {
        return tournaments.value
      }
      return tournaments.value.filter(t => t.status === selectedFilter.value)
    })

    const loadTournaments = async () => {
      try {
        const data = await apiStore.get('/tournaments', {
          sort_by: 'start_date',
          sort_direction: 'asc'
        })
        if (data.success) {
          tournaments.value = data.data || []
        }
      } catch (error) {
        console.error('Erreur lors du chargement des tournois:', error)
      }
    }

    const loadMyTournaments = async () => {
      if (!authStore.isAuthenticated) return
      
      try {
        const data = await apiStore.get('/tournaments/my-tournaments')
        if (data.success) {
          myTournaments.value = data.data || []
        }
      } catch (error) {
        console.error('Erreur lors du chargement de mes tournois:', error)
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
          
          // Recharger mes tournois
          await loadMyTournaments()
          
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
      console.log('Ouverture du tournoi:', tournament.name)
      // TODO: Navigate to tournament detail page
    }

    const viewTournamentLeaderboard = (tournament) => {
      console.log('Classement du tournoi:', tournament.name)
      // TODO: Navigate to tournament leaderboard
    }

    const formatPrize = (amount, currency) => {
      if (amount === 0) return 'Gratuit'
      
      return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: currency || 'XOF',
        minimumFractionDigits: 0
      }).format(amount)
    }

    const formatDate = (dateString) => {
      const date = new Date(dateString)
      return date.toLocaleDateString('fr-FR', {
        day: 'numeric',
        month: 'short',
        year: 'numeric'
      })
    }

    const handleAuthenticated = () => {
      showAuthModal.value = false
      loadMyTournaments()
    }

    onMounted(async () => {
      loading.value = true
      
      await Promise.all([
        loadTournaments(),
        loadMyTournaments()
      ])
      
      loading.value = false
      
      emit('update-header', {
        title: 'Tournois',
        showBack: true
      })
    })

    return {
      tournaments,
      myTournaments,
      loading,
      registering,
      showAuthModal,
      selectedFilter,
      filters,
      filteredTournaments,
      authStore,
      registerToTournament,
      openTournament,
      viewTournamentLeaderboard,
      formatPrize,
      formatDate,
      handleAuthenticated
    }
  }
}
</script>

<style scoped>
.tournaments {
  min-height: 100vh;
  background: #FFFFFF;
  font-family: 'Roboto', sans-serif;
}

.tournaments-content {
  padding: 1rem;
  max-width: 800px;
  margin: 0 auto;
}

.tournaments-header {
  text-align: center;
  margin-bottom: 2rem;
}

.filters-section {
  margin-bottom: 2rem;
}

.filter-tabs {
  display: flex;
  gap: 0.5rem;
  overflow-x: auto;
  padding-bottom: 0.5rem;
}

.filter-tab {
  padding: 0.5rem 1rem;
  border: 1px solid #E2E8F0;
  border-radius: 20px;
  background: #FFFFFF;
  color: #6B7280;
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
}

.filter-tab:hover {
  border-color: #F4D03F;
  color: #2D3748;
}

.filter-tab.active {
  background: #F4D03F;
  border-color: #F4D03F;
  color: #2D3748;
}

.tournaments-grid {
  display: grid;
  gap: 1.5rem;
  margin-bottom: 2rem;
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
  margin-bottom: 1rem;
}

.info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  color: #6B7280;
}

.info-item {
  color: #F4D03F;
}

.tournament-progress {
  margin-bottom: 1rem;
}

.progress-bar {
  width: 100%;
  height: 6px;
  background: #F3F4F6;
  border-radius: 3px;
  overflow: hidden;
  margin-bottom: 0.5rem;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #F4D03F, #F59E0B);
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 0.8rem;
  color: #6B7280;
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
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.tournament-status-info {
  display: flex;
  align-items: center;
}

.status-text {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: #9CA3AF;
  font-size: 0.85rem;
}

/* Status text icons are now handled by DinorIcon component */

.empty-state {
  text-align: center;
  padding: 4rem 1rem;
  color: #9CA3AF;
}

.empty-state {
  margin-bottom: 1rem;
  color: #E5E7EB;
}

.empty-state h3 {
  margin-bottom: 0.5rem;
  color: #6B7280;
}

.my-tournaments-section {
  margin-top: 3rem;
  padding-top: 2rem;
  border-top: 1px solid #E2E8F0;
}

.my-tournaments-list {
  display: grid;
  gap: 1rem;
}

.my-tournament-item {
  background: #F8F9FA;
  border-radius: 8px;
  padding: 1rem;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.my-tournament-item:hover {
  background: #F1F5F9;
  transform: translateY(-1px);
}

.tournament-info-left h4 {
  margin: 0 0 0.25rem 0;
  font-size: 1rem;
  color: #2D3748;
}

.tournament-stats {
  display: flex;
  gap: 1rem;
}

.stat-item {
  text-align: center;
}

.stat-label {
  display: block;
  font-size: 0.75rem;
  color: #9CA3AF;
  margin-bottom: 0.25rem;
}

.stat-value {
  display: block;
  font-size: 0.9rem;
  font-weight: 600;
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
  .info-row {
    flex-direction: column;
    gap: 0.5rem;
  }
  
  .tournament-stats {
    gap: 0.5rem;
  }
  
  .my-tournament-item {
    flex-direction: column;
    align-items: stretch;
    gap: 1rem;
  }
  
  .tournament-stats {
    justify-content: space-around;
  }
}
</style>