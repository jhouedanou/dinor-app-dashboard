<template>
  <div class="predictions-teams">
    <main class="md3-main-content">
      <!-- Loading State -->
      <div v-if="loading" class="loading-container">
        <div class="md3-circular-progress"></div>
        <p class="md3-body-large">Chargement des équipes...</p>
      </div>

      <!-- Teams Content -->
      <div v-else-if="teams.length" class="teams-content">
        <div class="teams-header">
          <h1 class="md3-title-large dinor-text-primary">Équipes</h1>
          <p class="md3-body-medium dinor-text-gray">Découvrez toutes les équipes participantes</p>
        </div>

        <div class="teams-grid">
          <div 
            v-for="team in teams" 
            :key="team.id" 
            class="team-card"
            @click="goToTeamDetail(team)"
          >
            <div class="team-logo">
              <img 
                v-if="team.logo_url" 
                :src="team.logo_url" 
                :alt="team.name"
                @error="handleImageError"
              >
              <div v-else class="team-logo-placeholder">
                <span class="material-symbols-outlined">sports_soccer</span>
              </div>
            </div>
            
            <div class="team-info">
              <h3 class="team-name md3-title-medium">{{ team.name }}</h3>
              <p v-if="team.short_name" class="team-short-name md3-body-small">{{ team.short_name }}</p>
              <div v-if="team.country" class="team-country">
                <span class="country-badge">{{ team.country }}</span>
              </div>
            </div>
            
            <div 
              v-if="team.color_primary" 
              class="team-colors"
              :style="{ backgroundColor: team.color_primary }"
            ></div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else class="empty-state">
        <div class="empty-icon">
          <span class="material-symbols-outlined">sports_soccer</span>
        </div>
        <h2 class="md3-title-large">Aucune équipe</h2>
        <p class="md3-body-large dinor-text-gray">Les équipes seront bientôt disponibles.</p>
      </div>
    </main>
  </div>
</template>

<script>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApiStore } from '@/stores/api'

export default {
  name: 'PredictionsTeams',
  emits: ['update-header'],
  setup(_, { emit }) {
    const router = useRouter()
    const apiStore = useApiStore()
    
    const teams = ref([])
    const loading = ref(true)

    const loadTeams = async () => {
      try {
        const data = await apiStore.get('/teams')
        if (data.success) {
          teams.value = data.data
        }
      } catch (error) {
        console.error('Erreur lors du chargement des équipes:', error)
      } finally {
        loading.value = false
      }
    }

    const goToTeamDetail = (team) => {
      // Pour l'instant, on peut juste afficher les infos
      console.log('Équipe sélectionnée:', team)
    }

    const handleImageError = (event) => {
      event.target.style.display = 'none'
    }

    onMounted(() => {
      loadTeams()
      
      // Mettre à jour le header
      emit('update-header', {
        title: 'Équipes',
        showBack: true,
        backPath: '/predictions'
      })
    })

    return {
      teams,
      loading,
      goToTeamDetail,
      handleImageError
    }
  }
}
</script>

<style scoped>
.predictions-teams {
  min-height: 100vh;
  background: #FFFFFF;
  font-family: 'Roboto', sans-serif;
}

.teams-content {
  padding: 1rem;
}

.teams-header {
  margin-bottom: 2rem;
  text-align: center;
}

.teams-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1rem;
  max-width: 1200px;
  margin: 0 auto;
}

.team-card {
  background: #FFFFFF;
  border-radius: 12px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  overflow: hidden;
}

.team-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.team-logo {
  width: 80px;
  height: 80px;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.team-logo img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  border-radius: 8px;
}

.team-logo-placeholder {
  width: 100%;
  height: 100%;
  background: #F4F4F5;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #9CA3AF;
}

.team-logo-placeholder i {
  font-size: 2rem;
}

.team-info {
  flex: 1;
  margin-bottom: 1rem;
}

.team-name {
  color: #2D3748;
  margin-bottom: 0.5rem;
  font-weight: 600;
}

.team-short-name {
  color: #6B7280;
  margin-bottom: 0.5rem;
}

.country-badge {
  background: #F4D03F;
  color: #2D3748;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 500;
}

.team-colors {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 4px;
}

.loading-container,
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  padding: 2rem;
  text-align: center;
}

.empty-icon i {
  font-size: 4rem;
  color: #9CA3AF;
  margin-bottom: 1rem;
}

@media (max-width: 768px) {
  .teams-grid {
    grid-template-columns: 1fr;
    gap: 0.75rem;
  }
  
  .team-card {
    padding: 1rem;
  }
  
  .team-logo {
    width: 60px;
    height: 60px;
  }
}
</style>