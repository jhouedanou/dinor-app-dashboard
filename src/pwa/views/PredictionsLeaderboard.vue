<template>
  <div class="predictions-leaderboard">
    <main class="md3-main-content">
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="md3-circular-progress"></div>
        <p class="md3-body-large">Chargement du classement...</p>
      </div>

      <!-- Leaderboard Content -->
      <div v-else class="leaderboard-content">
        <!-- Header -->
        <div class="leaderboard-header">
          <h1 class="md3-title-large dinor-text-primary">Classement</h1>
          <p class="md3-body-medium dinor-text-gray">Découvrez qui sont les meilleurs pronostiqueurs!</p>
        </div>

        <!-- User Stats (if authenticated) -->
        <div v-if="authStore.isAuthenticated && userStats" class="user-stats-card">
          <div class="user-stats-header">
            <h2 class="md3-title-medium">Vos statistiques</h2>
            <div class="user-rank-badge" :class="getRankClass(userStats.current_position)">
              <span class="material-symbols-outlined">star</span>
              <span>{{ userStats.current_position ? `#${userStats.current_position}` : 'Non classé' }}</span>
            </div>
          </div>
          
          <div class="stats-grid">
            <div class="stat-item">
              <div class="stat-value">{{ userStats.total_points }}</div>
              <div class="stat-label">Points</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ userStats.total_predictions }}</div>
              <div class="stat-label">Pronostics</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ userStats.accuracy_percentage }}%</div>
              <div class="stat-label">Précision</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ userStats.correct_scores }}</div>
              <div class="stat-label">Scores exacts</div>
            </div>
          </div>
          
          <div v-if="userStats.rank_change !== 0" class="rank-change">
            <span v-if="userStats.rank_change > 0" class="material-symbols-outlined rank-up">trending_up</span>
            <span v-else class="material-symbols-outlined rank-down">trending_down</span>
            <span>{{ Math.abs(userStats.rank_change) }} position{{ Math.abs(userStats.rank_change) > 1 ? 's' : '' }}</span>
          </div>
        </div>

        <!-- Auth Prompt -->
        <div v-else-if="!authStore.isAuthenticated" class="auth-prompt">
          <div class="auth-prompt-content">
            <span class="material-symbols-outlined">account_circle</span>
            <h3 class="md3-title-medium">Connectez-vous</h3>
            <p class="md3-body-medium">Connectez-vous pour voir vos statistiques et votre position dans le classement</p>
            <button @click="showAuthModal = true" class="btn-primary">
              Se connecter
            </button>
          </div>
        </div>

        <!-- Top Players -->
        <div class="top-players-section">
          <h2 class="md3-title-medium dinor-text-primary">Top 10</h2>
          
          <div v-if="topPlayers.length" class="podium">
            <!-- Podium Top 3 -->
            <div v-for="(player, index) in topPlayers.slice(0, 3)" :key="player.id" class="podium-item" :class="`rank-${index + 1}`">
              <div class="podium-rank">
                <span class="material-symbols-outlined">{{ getPodiumIcon(index + 1) }}</span>
              </div>
              <div class="podium-info">
                <div class="player-name">{{ player.user.name }}</div>
                <div class="player-points">{{ player.total_points }} pts</div>
                <div class="player-accuracy">{{ player.accuracy_percentage }}% précision</div>
              </div>
            </div>
          </div>

          <!-- Full Leaderboard -->
          <div v-if="leaderboard.length" class="leaderboard-list">
            <div v-for="(player, index) in leaderboard" :key="player.id" class="leaderboard-item" :class="{ 'current-user': isCurrentUser(player) }">
              <div class="rank-number">
                <span class="rank-badge" :class="getRankClass(index + 1)">{{ index + 1 }}</span>
              </div>
              
              <div class="player-info">
                <div class="player-name">
                  {{ player.user.name }}
                  <span v-if="isCurrentUser(player)" class="you-badge">Vous</span>
                </div>
                <div class="player-details">
                  <span class="detail-item">{{ player.total_predictions }} pronostics</span>
                  <span class="detail-item">{{ player.correct_scores }} scores exacts</span>
                </div>
              </div>
              
              <div class="player-stats">
                <div class="points">{{ player.total_points }} pts</div>
                <div class="accuracy">{{ player.accuracy_percentage }}%</div>
              </div>
              
              <div v-if="player.rank_change" class="rank-change-indicator">
                <span v-if="player.rank_change > 0" class="material-symbols-outlined rank-up">keyboard_arrow_up</span>
                <span v-else class="material-symbols-outlined rank-down">keyboard_arrow_down</span>
                <span>{{ Math.abs(player.rank_change) }}</span>
              </div>
            </div>
          </div>

          <!-- Empty State -->
          <div v-else class="empty-leaderboard">
            <div class="empty-icon">
              <span class="material-symbols-outlined">leaderboard</span>
            </div>
            <h3 class="md3-title-medium">Aucun classement</h3>
            <p class="md3-body-medium dinor-text-gray">Le classement apparaîtra dès que les premiers pronostics seront faits.</p>
          </div>
        </div>

        <!-- Refresh Button -->
        <div class="refresh-section">
          <button 
            @click="refreshLeaderboard" 
            :disabled="refreshing"
            class="btn-secondary refresh-btn"
          >
            <span class="material-symbols-outlined">refresh</span>
            <span v-if="refreshing">Mise à jour...</span>
            <span v-else>Actualiser le classement</span>
          </button>
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

export default {
  name: 'PredictionsLeaderboard',
  emits: ['update-header'],
  components: {
    AuthModal
  },
  setup(_, { emit }) {
    const apiStore = useApiStore()
    const authStore = useAuthStore()
    
    const leaderboard = ref([])
    const topPlayers = ref([])
    const userStats = ref(null)
    const loading = ref(true)
    const refreshing = ref(false)
    const showAuthModal = ref(false)

    const loadLeaderboard = async () => {
      try {
        const [leaderboardData, topData] = await Promise.all([
          apiStore.get('/leaderboard'),
          apiStore.get('/leaderboard/top?limit=10')
        ])
        
        if (leaderboardData.success) {
          leaderboard.value = leaderboardData.data
        }
        
        if (topData.success) {
          topPlayers.value = topData.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement du classement:', error)
      }
    }

    const loadUserStats = async () => {
      if (!authStore.isAuthenticated) return
      
      try {
        const data = await apiStore.get('/leaderboard/my-stats')
        if (data.success) {
          userStats.value = data.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement des stats utilisateur:', error)
      }
    }

    const refreshLeaderboard = async () => {
      refreshing.value = true
      try {
        const data = await apiStore.post('/leaderboard/refresh')
        if (data.success) {
          await loadData()
        }
      } catch (error) {
        console.error('Erreur lors de la mise à jour:', error)
      } finally {
        refreshing.value = false
      }
    }

    const loadData = async () => {
      loading.value = true
      await Promise.all([
        loadLeaderboard(),
        loadUserStats()
      ])
      loading.value = false
    }

    const isCurrentUser = (player) => {
      return authStore.isAuthenticated && player.user_id === authStore.userId
    }

    const getRankClass = (rank) => {
      if (rank === 1) return 'rank-gold'
      if (rank === 2) return 'rank-silver'
      if (rank === 3) return 'rank-bronze'
      if (rank <= 10) return 'rank-top10'
      return ''
    }

    const getPodiumIcon = (rank) => {
      switch (rank) {
        case 1: return 'emoji_events'
        case 2: return 'military_tech'
        case 3: return 'stars'
        default: return 'star'
      }
    }

    const handleAuthenticated = () => {
      showAuthModal.value = false
      loadUserStats()
    }

    onMounted(() => {
      loadData()
      
      emit('update-header', {
        title: 'Classement',
        showBack: true,
        backPath: '/predictions'
      })
    })

    return {
      leaderboard,
      topPlayers,
      userStats,
      loading,
      refreshing,
      showAuthModal,
      authStore,
      refreshLeaderboard,
      isCurrentUser,
      getRankClass,
      getPodiumIcon,
      handleAuthenticated
    }
  }
}
</script>

<style scoped>
.predictions-leaderboard {
  min-height: 100vh;
  background: #FFFFFF;
  font-family: 'Roboto', sans-serif;
}

.leaderboard-content {
  padding: 1rem;
  max-width: 800px;
  margin: 0 auto;
}

.leaderboard-header {
  text-align: center;
  margin-bottom: 2rem;
}

.user-stats-card {
  background: linear-gradient(135deg, #F4D03F 0%, #F39C12 100%);
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  color: white;
}

.user-stats-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
}

.user-rank-badge {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  background: rgba(255, 255, 255, 0.2);
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-weight: 600;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 1rem;
  margin-bottom: 1rem;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 0.8rem;
  opacity: 0.9;
}

.rank-change {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  justify-content: center;
  font-size: 0.9rem;
}

.rank-up {
  color: #10B981;
}

.rank-down {
  color: #EF4444;
}

.auth-prompt {
  background: #F8F9FA;
  border-radius: 12px;
  padding: 2rem;
  text-align: center;
  margin-bottom: 2rem;
}

.auth-prompt-content i {
  font-size: 3rem;
  color: #9CA3AF;
  margin-bottom: 1rem;
}

.podium {
  display: flex;
  justify-content: center;
  gap: 1rem;
  margin-bottom: 2rem;
}

.podium-item {
  background: #FFFFFF;
  border-radius: 12px;
  padding: 1rem;
  text-align: center;
  border: 2px solid transparent;
  min-width: 120px;
}

.podium-item.rank-1 {
  border-color: #FFD700;
  transform: scale(1.05);
}

.podium-item.rank-2 {
  border-color: #C0C0C0;
}

.podium-item.rank-3 {
  border-color: #CD7F32;
}

.podium-rank i {
  font-size: 2rem;
  margin-bottom: 0.5rem;
}

.podium-item.rank-1 .podium-rank i {
  color: #FFD700;
}

.podium-item.rank-2 .podium-rank i {
  color: #C0C0C0;
}

.podium-item.rank-3 .podium-rank i {
  color: #CD7F32;
}

.player-name {
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.player-points {
  color: #F4D03F;
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.player-accuracy {
  font-size: 0.8rem;
  color: #6B7280;
}

.leaderboard-list {
  background: #F8F9FA;
  border-radius: 12px;
  overflow: hidden;
}

.leaderboard-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  background: #FFFFFF;
  border-bottom: 1px solid #E2E8F0;
  transition: all 0.2s ease;
}

.leaderboard-item:last-child {
  border-bottom: none;
}

.leaderboard-item.current-user {
  background: #FEF3CD;
  border-left: 4px solid #F4D03F;
}

.rank-number {
  margin-right: 1rem;
}

.rank-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  font-weight: 600;
  font-size: 0.9rem;
  background: #E2E8F0;
  color: #6B7280;
}

.rank-badge.rank-gold {
  background: #FFD700;
  color: #FFFFFF;
}

.rank-badge.rank-silver {
  background: #C0C0C0;
  color: #FFFFFF;
}

.rank-badge.rank-bronze {
  background: #CD7F32;
  color: #FFFFFF;
}

.rank-badge.rank-top10 {
  background: #F4D03F;
  color: #2D3748;
}

.player-info {
  flex: 1;
  margin-right: 1rem;
}

.player-info .player-name {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 600;
  margin-bottom: 0.25rem;
}

.you-badge {
  background: #F4D03F;
  color: #2D3748;
  padding: 0.125rem 0.5rem;
  border-radius: 12px;
  font-size: 0.7rem;
  font-weight: 600;
}

.player-details {
  display: flex;
  gap: 1rem;
  font-size: 0.8rem;
  color: #6B7280;
}

.player-stats {
  text-align: right;
  margin-right: 1rem;
}

.points {
  font-weight: 600;
  color: #F4D03F;
  margin-bottom: 0.25rem;
}

.accuracy {
  font-size: 0.8rem;
  color: #6B7280;
}

.rank-change-indicator {
  display: flex;
  flex-direction: column;
  align-items: center;
  font-size: 0.7rem;
}

.refresh-section {
  text-align: center;
  margin-top: 2rem;
}

.refresh-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.empty-leaderboard {
  text-align: center;
  padding: 3rem 1rem;
}

.empty-icon i {
  font-size: 4rem;
  color: #9CA3AF;
  margin-bottom: 1rem;
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
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .podium {
    flex-direction: column;
    align-items: center;
  }
  
  .player-details {
    flex-direction: column;
    gap: 0.25rem;
    font-size: 0.75rem;
  }
  
  .player-details .detail-item {
    color: #4A5568;
    font-weight: 500;
  }
  
  .leaderboard-item {
    padding: 0.75rem;
  }
  
  .player-stats {
    min-width: 60px;
    margin-right: 0.5rem;
  }
  
  .points {
    font-size: 0.85rem;
  }
  
  .accuracy {
    font-size: 0.75rem;
    color: #4A5568;
  }
  
  .rank-change-indicator {
    flex-direction: row;
    gap: 0.25rem;
    font-size: 0.6rem;
    margin-left: 0.5rem;
  }
  
  .rank-change-indicator .material-symbols-outlined {
    font-size: 0.9rem;
  }
}
</style>