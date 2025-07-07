<template>
  <div class="profile">
    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement du profil...</p>
    </div>

    <!-- Not Authenticated State -->
    <div v-else-if="!authStore.isAuthenticated" class="auth-required">
      <div class="auth-icon">
        <i class="material-icons">person</i>
      </div>
      <h2 class="md3-title-large">Profil utilisateur</h2>
      <p class="md3-body-large">Connectez-vous pour voir votre profil et vos favoris</p>
      <button @click="showAuthModal = true" class="btn-primary">
        Se connecter
      </button>
    </div>

    <!-- Authenticated Content -->
    <div v-else class="profile-content">
      <!-- User Info Section -->
      <div class="user-info-section">
        <div class="user-avatar">
          <i class="material-icons">person</i>
        </div>
        <div class="user-details">
          <h1 class="user-name">{{ authStore.userName }}</h1>
          <p class="user-email">{{ authStore.user?.email }}</p>
          <p class="member-since" v-if="authStore.user?.created_at">Membre depuis {{ formatMemberSince(authStore.user.created_at) }}</p>
        </div>
      </div>

      <!-- Profile Navigation -->
      <div class="profile-navigation">
        <button 
          v-for="section in profileSections" 
          :key="section.key"
          @click="activeSection = section.key"
          class="nav-button"
          :class="{ active: activeSection === section.key }"
        >
          <i class="material-icons">{{ section.icon }}</i>
          <span>{{ section.label }}</span>
        </button>
      </div>

      <!-- Profile Sections -->
      <div class="profile-sections">
        <!-- Favorites Section -->
        <div v-if="activeSection === 'favorites'" class="section-content">
        <div class="section-header">
          <h2 class="section-title">Mes Favoris</h2>
          <div class="filter-tabs">
            <button 
              v-for="tab in filterTabs" 
              :key="tab.key"
              @click="selectedFilter = tab.key"
              class="filter-tab"
              :class="{ active: selectedFilter === tab.key }"
            >
              <i class="material-icons">{{ tab.icon }}</i>
              <span>{{ tab.label }}</span>
            </button>
          </div>
        </div>

        <!-- Favorites List -->
        <div v-if="filteredFavorites.length" class="favorites-list">
          <div 
            v-for="favorite in filteredFavorites" 
            :key="favorite.id"
            @click="goToContent(favorite)"
            class="favorite-item"
          >
            <div class="favorite-image">
              <img 
                :src="favorite.content.image || getDefaultImage(favorite.type)" 
                :alt="favorite.content.title"
                @error="handleImageError"
              >
              <div class="favorite-type-badge">
                <i class="material-icons">{{ getTypeIcon(favorite.type) }}</i>
              </div>
            </div>
            <div class="favorite-info">
              <h3 class="favorite-title">{{ favorite.content.title }}</h3>
              <p class="favorite-description">
                {{ getShortDescription(favorite.content.description) }}
              </p>
              <div class="favorite-meta">
                <span class="favorite-date">
                  Ajouté {{ formatDate(favorite.favorited_at) }}
                </span>
                <div class="favorite-stats">
                  <span class="stat">
                    <i class="material-icons">favorite</i>
                    {{ favorite.content.likes_count || 0 }}
                  </span>
                  <span class="stat">
                    <i class="material-icons">comment</i>
                    {{ favorite.content.comments_count || 0 }}
                  </span>
                </div>
              </div>
            </div>
            <button 
              @click.stop="removeFavorite(favorite)"
              class="remove-favorite"
              title="Retirer des favoris"
            >
              <i class="material-icons">close</i>
            </button>
          </div>
        </div>

        <!-- Empty State -->
        <div v-else class="empty-favorites">
          <div class="empty-icon">
            <i class="material-icons">favorite_border</i>
          </div>
          <h3>{{ getEmptyMessage() }}</h3>
          <p>{{ getEmptyDescription() }}</p>
          <router-link :to="getExploreLink()" class="btn-secondary">
            Découvrir du contenu
          </router-link>
        </div>
        </div>

        <!-- Predictions Section -->
        <div v-if="activeSection === 'predictions'" class="section-content">
          <h2 class="section-title">Mes Pronostics</h2>
          
          <!-- Loading -->
          <div v-if="predictionsLoading" class="loading-container">
            <div class="md3-circular-progress"></div>
            <p>Chargement de vos statistiques...</p>
          </div>

          <!-- Predictions Tabs -->
          <div v-else-if="userPredictionsStats" class="predictions-section">
            <!-- Sub-navigation for predictions -->
            <div class="sub-tabs">
              <button
                v-for="tab in predictionsTabs"
                :key="tab.key"
                @click="switchPredictionsTab(tab.key)"
                :class="['sub-tab', { active: activePredictionsTab === tab.key }]"
              >
                <i class="material-icons">{{ tab.icon }}</i>
                <span>{{ tab.label }}</span>
              </button>
            </div>

            <!-- Mes prédictions Tab -->
            <div v-if="activePredictionsTab === 'my-predictions'" class="tab-content">
              <div class="predictions-header">
                <h3 class="tab-title">Mes prédictions</h3>
                <div class="predictions-stats">
                  <div class="stat-item">
                    <span class="stat-value">{{ userPredictionsStats.total_predictions }}</span>
                    <span class="stat-label">Total</span>
                  </div>
                  <div class="stat-item">
                    <span class="stat-value">{{ userPredictionsStats.total_points }}</span>
                    <span class="stat-label">Points</span>
                  </div>
                  <div class="stat-item">
                    <span class="stat-value">{{ userPredictionsStats.accuracy_percentage }}%</span>
                    <span class="stat-label">Précision</span>
                  </div>
                </div>
              </div>

              <!-- Liste complète des prédictions -->
              <div v-if="userAllPredictions.length" class="predictions-list">
                <div 
                  v-for="prediction in userAllPredictions" 
                  :key="prediction.id" 
                  class="prediction-card"
                  :class="{ calculated: prediction.is_calculated }"
                >
                  <div class="prediction-match">
                    <div class="teams">
                      <span class="team">{{ prediction.football_match.home_team.name }}</span>
                      <span class="vs">vs</span>
                      <span class="team">{{ prediction.football_match.away_team.name }}</span>
                    </div>
                    <div class="match-date">
                      {{ formatDate(prediction.football_match.match_date) }}
                    </div>
                  </div>
                  
                  <div class="prediction-details">
                    <div class="predicted-score">
                      {{ prediction.predicted_home_score }} - {{ prediction.predicted_away_score }}
                    </div>
                    <div v-if="prediction.football_match.is_finished" class="actual-score">
                      Résultat: {{ prediction.football_match.home_score }} - {{ prediction.football_match.away_score }}
                    </div>
                    <div class="prediction-status">
                      <span v-if="prediction.is_calculated" class="points-earned" :class="{ 'points-positive': prediction.points_earned > 0 }">
                        {{ prediction.points_earned }} point{{ prediction.points_earned > 1 ? 's' : '' }}
                      </span>
                      <span v-else class="pending">En attente</span>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- Récents pronostics si pas de liste complète -->
              <div v-else-if="recentPredictions.length" class="recent-predictions">
                <div class="predictions-list">
                  <div 
                    v-for="prediction in recentPredictions" 
                    :key="prediction.id" 
                    class="prediction-card"
                    :class="{ calculated: prediction.is_calculated }"
                  >
                    <div class="prediction-match">
                      <div class="teams">
                        <span class="team">{{ prediction.football_match.home_team.name }}</span>
                        <span class="vs">vs</span>
                        <span class="team">{{ prediction.football_match.away_team.name }}</span>
                      </div>
                      <div class="match-date">
                        {{ formatDate(prediction.football_match.match_date) }}
                      </div>
                    </div>
                    
                    <div class="prediction-details">
                      <div class="predicted-score">
                        {{ prediction.predicted_home_score }} - {{ prediction.predicted_away_score }}
                      </div>
                      <div class="prediction-status">
                        <span v-if="prediction.is_calculated" class="points-earned">
                          {{ prediction.points_earned }} point{{ prediction.points_earned > 1 ? 's' : '' }}
                        </span>
                        <span v-else class="pending">En attente</span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <button @click="loadAllUserPredictions" class="btn-secondary load-more-btn">
                  Charger toutes mes prédictions
                </button>
              </div>

              <!-- No Predictions -->
              <div v-else class="no-predictions">
                <div class="empty-icon">
                  <i class="material-icons">sports_soccer</i>
                </div>
                <h3>Aucun pronostic</h3>
                <p>Vous n'avez pas encore fait de pronostic. Commencez dès maintenant!</p>
                <router-link to="/predictions" class="btn-primary">
                  Faire mon premier pronostic
                </router-link>
              </div>
            </div>

            <!-- Mon classement Tab -->
            <div v-if="activePredictionsTab === 'my-ranking'" class="tab-content">
              <div class="ranking-header">
                <h3 class="tab-title">Mon classement</h3>
              </div>

              <!-- Stats globales -->
              <div class="global-ranking">
                <h4 class="subsection-title">Classement global</h4>
                <div class="ranking-card global">
                  <div class="ranking-info">
                    <div class="rank-badge" :class="getRankClass(userPredictionsStats.current_rank)">
                      <i class="material-icons">star</i>
                      <span>{{ userPredictionsStats.current_rank ? `#${userPredictionsStats.current_rank}` : 'Non classé' }}</span>
                    </div>
                    <div class="ranking-stats">
                      <div class="stat-item">
                        <span class="stat-value">{{ userPredictionsStats.total_points }}</span>
                        <span class="stat-label">Points totaux</span>
                      </div>
                      <div class="stat-item">
                        <span class="stat-value">{{ userPredictionsStats.accuracy_percentage }}%</span>
                        <span class="stat-label">Précision</span>
                      </div>
                      <div class="stat-item">
                        <span class="stat-value">{{ userPredictionsStats.correct_scores || 0 }}</span>
                        <span class="stat-label">Scores exacts</span>
                      </div>
                    </div>
                  </div>
                  <router-link to="/predictions/leaderboard" class="view-leaderboard-btn">
                    Voir le classement complet
                  </router-link>
                </div>
              </div>

              <!-- Classement par tournoi -->
              <div v-if="userTournaments.length" class="tournaments-ranking">
                <h4 class="subsection-title">Mes tournois</h4>
                <div class="tournaments-list">
                  <div 
                    v-for="tournamentData in userTournaments" 
                    :key="tournamentData.tournament.id" 
                    class="tournament-ranking-card"
                  >
                    <div class="tournament-header">
                      <h5 class="tournament-name">{{ tournamentData.tournament.name }}</h5>
                      <span :class="['tournament-status', tournamentData.tournament.status]">
                        {{ tournamentData.tournament.status_label }}
                      </span>
                    </div>
                    
                    <div class="tournament-ranking">
                      <div class="rank-badge" :class="getRankClass(tournamentData.user_rank)">
                        <span>{{ tournamentData.user_rank ? `#${tournamentData.user_rank}` : 'N/A' }}</span>
                      </div>
                      <div class="tournament-stats">
                        <div class="stat-item">
                          <span class="stat-value">{{ tournamentData.user_points }}</span>
                          <span class="stat-label">Points</span>
                        </div>
                        <div class="stat-item">
                          <span class="stat-value">{{ tournamentData.user_predictions }}</span>
                          <span class="stat-label">Prédictions</span>
                        </div>
                        <div class="stat-item">
                          <span class="stat-value">{{ tournamentData.user_accuracy }}%</span>
                          <span class="stat-label">Précision</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- No Tournaments -->
              <div v-else class="no-tournaments-ranking">
                <div class="empty-icon">
                  <i class="material-icons">emoji_events</i>
                </div>
                <h4>Aucun tournoi actif</h4>
                <p>Participez à des tournois pour voir votre classement.</p>
                <router-link to="/predictions/tournaments" class="btn-secondary">
                  Découvrir les tournois
                </router-link>
              </div>
            </div>

            <!-- En cours Tab -->
            <div v-if="activePredictionsTab === 'active-tournaments'" class="tab-content">
              <div class="active-tournaments-header">
                <h3 class="tab-title">Tournois en cours</h3>
                <p class="tab-description">Tournois où vous pouvez faire des prédictions</p>
              </div>

              <!-- Liste des tournois actifs -->
              <div v-if="activeTournaments.length" class="active-tournaments-list">
                <div 
                  v-for="tournament in activeTournaments" 
                  :key="tournament.id" 
                  class="active-tournament-card"
                  @click="openTournamentModal(tournament)"
                >
                  <div class="tournament-info">
                    <h4 class="tournament-name">{{ tournament.name }}</h4>
                    <p v-if="tournament.description" class="tournament-description">{{ tournament.description }}</p>
                    <div class="tournament-meta">
                      <span :class="['tournament-status', tournament.status]">
                        {{ tournament.status_label }}
                      </span>
                      <span v-if="tournament.participants_count" class="participants-count">
                        {{ tournament.participants_count }} participant{{ tournament.participants_count > 1 ? 's' : '' }}
                      </span>
                    </div>
                  </div>
                  
                  <div class="tournament-actions">
                    <div class="tournament-prize" v-if="tournament.prize_pool">
                      {{ formatPrize(tournament.prize_pool, tournament.currency) }}
                    </div>
                    <button 
                      v-if="tournament.can_register && !tournament.user_is_participant"
                      @click.stop="registerToTournament(tournament)" 
                      class="btn-primary tournament-action-btn"
                    >
                      S'inscrire
                    </button>
                    <button 
                      v-else-if="tournament.user_is_participant && tournament.can_predict"
                      @click.stop="goToPredictions(tournament)" 
                      class="btn-secondary tournament-action-btn"
                    >
                      Prédire
                    </button>
                    <span v-else class="tournament-status-text">
                      {{ tournament.user_is_participant ? 'Inscrit' : 'Complet' }}
                    </span>
                  </div>
                </div>
              </div>

              <!-- No Active Tournaments -->
              <div v-else class="no-active-tournaments">
                <div class="empty-icon">
                  <i class="material-icons">schedule</i>
                </div>
                <h4>Aucun tournoi ouvert</h4>
                <p>Il n'y a pas de tournoi ouvert aux prédictions pour le moment. Revenez bientôt!</p>
                <div class="suggestions">
                  <router-link to="/predictions" class="btn-secondary">
                    Faire des prédictions
                  </router-link>
                  <button @click="loadActiveTournaments" class="btn-outline">
                    Actualiser
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Error State -->
          <div v-else class="error-state">
            <div class="error-icon">
              <i class="material-icons">error_outline</i>
            </div>
            <h3>Erreur de chargement</h3>
            <p>Impossible de charger vos statistiques de pronostics.</p>
            <button @click="loadPredictionsData" class="btn-secondary">
              Réessayer
            </button>
          </div>
        </div>

        <!-- Account Section -->
        <div v-if="activeSection === 'account'" class="section-content">
          <h2 class="section-title">Mon Compte</h2>
          
          <!-- Username Update Form -->
          <div class="form-section">
            <h3 class="form-title">Nom d'utilisateur</h3>
            <form @submit.prevent="updateUsername" class="update-form">
              <div class="form-field">
                <label class="form-label">Nouveau nom d'utilisateur</label>
                <input 
                  v-model="usernameForm.name" 
                  type="text" 
                  class="form-input" 
                  placeholder="Votre nom d'utilisateur"
                  required
                  minlength="2"
                  maxlength="255"
                >
              </div>
              <div class="form-actions">
                <button type="submit" class="btn-primary" :disabled="usernameForm.loading">
                  <span v-if="usernameForm.loading">Mise à jour...</span>
                  <span v-else>Mettre à jour</span>
                </button>
              </div>
              <div v-if="usernameForm.message" class="form-message" :class="usernameForm.success ? 'success' : 'error'">
                {{ usernameForm.message }}
              </div>
            </form>
          </div>
        </div>

        <!-- Security Section -->
        <div v-if="activeSection === 'security'" class="section-content">
          <h2 class="section-title">Sécurité</h2>
          
          <!-- Password Change Form -->
          <div class="form-section">
            <h3 class="form-title">Changer le mot de passe</h3>
            <form @submit.prevent="updatePassword" class="update-form">
              <div class="form-field">
                <label class="form-label">Mot de passe actuel</label>
                <input 
                  v-model="passwordForm.currentPassword" 
                  type="password" 
                  class="form-input" 
                  placeholder="Votre mot de passe actuel"
                  required
                >
              </div>
              <div class="form-field">
                <label class="form-label">Nouveau mot de passe</label>
                <input 
                  v-model="passwordForm.newPassword" 
                  type="password" 
                  class="form-input" 
                  placeholder="Votre nouveau mot de passe"
                  required
                  minlength="8"
                >
                <small class="form-hint">Au moins 8 caractères avec lettres et chiffres</small>
              </div>
              <div class="form-field">
                <label class="form-label">Confirmer le nouveau mot de passe</label>
                <input 
                  v-model="passwordForm.confirmPassword" 
                  type="password" 
                  class="form-input" 
                  placeholder="Confirmer votre nouveau mot de passe"
                  required
                  minlength="8"
                >
              </div>
              <div class="form-actions">
                <button type="submit" class="btn-primary" :disabled="passwordForm.loading">
                  <span v-if="passwordForm.loading">Mise à jour...</span>
                  <span v-else>Changer le mot de passe</span>
                </button>
              </div>
              <div v-if="passwordForm.message" class="form-message" :class="passwordForm.success ? 'success' : 'error'">
                {{ passwordForm.message }}
              </div>
            </form>
          </div>

          <!-- Logout Section -->
          <div class="form-section logout-section">
            <h3 class="form-title">Déconnexion</h3>
            <p class="form-description">
              Vous serez déconnecté de votre compte sur cet appareil. Vos données seront conservées.
            </p>
            <button @click="handleLogout" class="btn-logout-main">
              <i class="material-icons">logout</i>
              <span>Se déconnecter</span>
            </button>
          </div>
        </div>

        <!-- Legal Section -->
        <div v-if="activeSection === 'legal'" class="section-content">
          <h2 class="section-title">Légal & Confidentialité</h2>
          
          <!-- Terms and Privacy Links -->
          <div class="legal-section">
            <h3 class="form-title">Conditions d'utilisation</h3>
            <div class="legal-links">
              <a href="/terms" class="legal-link">
                <i class="material-icons">description</i>
                <span>Conditions générales d'utilisation</span>
                <i class="material-icons">arrow_forward_ios</i>
              </a>
              <a href="/privacy" class="legal-link">
                <i class="material-icons">privacy_tip</i>
                <span>Politique de confidentialité</span>
                <i class="material-icons">arrow_forward_ios</i>
              </a>
              <a href="/cookies" class="legal-link">
                <i class="material-icons">cookie</i>
                <span>Politique des cookies</span>
                <i class="material-icons">arrow_forward_ios</i>
              </a>
            </div>
          </div>

          <!-- Data Deletion Request -->
          <div class="form-section danger-section">
            <h3 class="form-title danger-title">Suppression des données</h3>
            <p class="danger-description">
              Vous pouvez demander la suppression de toutes vos données personnelles conformément au RGPD. 
              Cette action est irréversible.
            </p>
            <form @submit.prevent="requestDataDeletion" class="update-form">
              <div class="form-field">
                <label class="form-label">Raison de la suppression (optionnel)</label>
                <textarea 
                  v-model="deletionForm.reason" 
                  class="form-textarea" 
                  placeholder="Expliquez pourquoi vous souhaitez supprimer vos données..."
                  rows="3"
                  maxlength="500"
                ></textarea>
              </div>
              <div class="form-field">
                <label class="checkbox-label">
                  <input 
                    v-model="deletionForm.confirm" 
                    type="checkbox" 
                    required
                  >
                  Je confirme vouloir supprimer définitivement toutes mes données
                </label>
              </div>
              <div class="form-actions">
                <button type="submit" class="btn-danger" :disabled="deletionForm.loading || !deletionForm.confirm">
                  <span v-if="deletionForm.loading">Demande en cours...</span>
                  <span v-else>Demander la suppression</span>
                </button>
              </div>
              <div v-if="deletionForm.message" class="form-message" :class="deletionForm.success ? 'success' : 'error'">
                {{ deletionForm.message }}
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Auth Modal -->
    <AuthModal v-model="showAuthModal" />
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useApiStore } from '@/stores/api'
import AuthModal from '@/components/common/AuthModal.vue'

export default {
  name: 'Profile',
  components: {
    AuthModal
  },
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()
    const apiStore = useApiStore()

    const loading = ref(false)
    const showAuthModal = ref(false)
    const favorites = ref([])
    const selectedFilter = ref('all')
    const activeSection = ref('favorites')
    
    // Predictions data
    const predictionsLoading = ref(false)
    const userPredictionsStats = ref(null)
    const recentPredictions = ref([])
    const userTournaments = ref([])
    const tournamentsLoading = ref(false)
    const activePredictionsTab = ref('my-predictions')
    const activeTournaments = ref([])
    const userAllPredictions = ref([])

    // Predictions sub-tabs
    const predictionsTabs = ref([
      { key: 'my-predictions', label: 'Mes prédictions', icon: 'sports_soccer' },
      { key: 'my-ranking', label: 'Mon classement', icon: 'leaderboard' },
      { key: 'active-tournaments', label: 'En cours', icon: 'emoji_events' }
    ])

    // Form states
    const usernameForm = ref({
      name: '',
      loading: false,
      message: '',
      success: false
    })

    const passwordForm = ref({
      currentPassword: '',
      newPassword: '',
      confirmPassword: '',
      loading: false,
      message: '',
      success: false
    })

    const deletionForm = ref({
      reason: '',
      confirm: false,
      loading: false,
      message: '',
      success: false
    })

    const profileSections = ref([
      { key: 'favorites', label: 'Favoris', icon: 'favorite' },
      { key: 'predictions', label: 'Pronostics', icon: 'sports_soccer' },
      { key: 'account', label: 'Compte', icon: 'person' },
      { key: 'security', label: 'Sécurité', icon: 'security' },
      { key: 'legal', label: 'Légal', icon: 'gavel' }
    ])

    const filterTabs = ref([
      { key: 'all', label: 'Tout', icon: 'apps' },
      { key: 'recipe', label: 'Recettes', icon: 'restaurant' },
      { key: 'tip', label: 'Astuces', icon: 'lightbulb' },
      { key: 'event', label: 'Événements', icon: 'event' },
      { key: 'dinor_tv', label: 'Vidéos', icon: 'play_circle' }
    ])

    const totalFavorites = computed(() => favorites.value.length)

    const favoritesStats = computed(() => {
      const stats = {}
      favorites.value.forEach(favorite => {
        const type = favorite.type === 'dinor_tv' ? 'videos' : `${favorite.type}s`
        stats[type] = (stats[type] || 0) + 1
      })
      return stats
    })

    const filteredFavorites = computed(() => {
      if (selectedFilter.value === 'all') {
        return favorites.value
      }
      return favorites.value.filter(favorite => favorite.type === selectedFilter.value)
    })

    const loadFavorites = async () => {
      if (!authStore.isAuthenticated) return

      loading.value = true
      try {
        console.log('🔍 [Profile] Chargement des favoris...')
        // Utiliser temporairement l'API de test qui retourne les vrais favoris
        const response = await fetch('/api/test-favorites', {
          method: 'GET',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          }
        })
        const data = await response.json()
        console.log('🔍 [Profile] Réponse API favoris:', data)
        if (data.success) {
          favorites.value = data.data
          console.log('🔍 [Profile] Favoris chargés:', favorites.value.length, 'éléments')
        }
      } catch (error) {
        console.error('❌ [Profile] Erreur lors du chargement des favoris:', error)
      } finally {
        loading.value = false
      }
    }

    const loadPredictionsData = async () => {
      if (!authStore.isAuthenticated) return

      predictionsLoading.value = true
      try {
        console.log('🏆 [Profile] Chargement des données de pronostics...')
        
        // Load user predictions stats, recent predictions and tournaments in parallel
        const [statsData, recentData, tournamentsData] = await Promise.all([
          apiStore.get('/v1/leaderboard/my-stats'),
          apiStore.get('/v1/predictions/my-recent?limit=5'),
          apiStore.get('/v1/tournaments/my-tournaments')
        ])
        
        if (statsData.success) {
          userPredictionsStats.value = statsData.data
          console.log('🏆 [Profile] Stats utilisateur chargées:', userPredictionsStats.value)
        }
        
        if (recentData.success) {
          recentPredictions.value = recentData.data
          console.log('🏆 [Profile] Pronostics récents chargés:', recentPredictions.value.length, 'éléments')
        }
        
        if (tournamentsData.success) {
          userTournaments.value = tournamentsData.data
          console.log('🏆 [Profile] Tournois utilisateur chargés:', userTournaments.value.length, 'éléments')
        }
      } catch (error) {
        console.error('❌ [Profile] Erreur lors du chargement des données de pronostics:', error)
        // If stats endpoint fails, reset to null to show error state
        userPredictionsStats.value = null
        recentPredictions.value = []
        userTournaments.value = []
      } finally {
        predictionsLoading.value = false
      }
    }

    const loadAllUserPredictions = async () => {
      if (!authStore.isAuthenticated) return

      try {
        const data = await apiStore.get('/v1/predictions')
        if (data.success) {
          userAllPredictions.value = data.data
        }
      } catch (error) {
        console.error('❌ [Profile] Erreur lors du chargement de toutes les prédictions:', error)
      }
    }

    const loadActiveTournaments = async () => {
      if (!authStore.isAuthenticated) return

      try {
        const data = await apiStore.get('/tournaments/featured')
        if (data.success) {
          // Filtrer seulement les tournois où on peut prédire
          activeTournaments.value = data.data.filter(tournament => 
            tournament.can_predict && 
            ['registration_open', 'registration_closed', 'active'].includes(tournament.status)
          )
        }
      } catch (error) {
        console.error('❌ [Profile] Erreur lors du chargement des tournois actifs:', error)
      }
    }

    const switchPredictionsTab = (tabKey) => {
      activePredictionsTab.value = tabKey
      
      // Charger les données spécifiques selon l'onglet
      if (tabKey === 'my-predictions' && userAllPredictions.value.length === 0) {
        loadAllUserPredictions()
      } else if (tabKey === 'active-tournaments' && activeTournaments.value.length === 0) {
        loadActiveTournaments()
      }
    }

    const removeFavorite = async (favorite) => {
      if (!confirm('Êtes-vous sûr de vouloir retirer cet élément de vos favoris ?')) {
        return
      }

      try {
        const data = await apiStore.request(`/favorites/${favorite.id}`, {
          method: 'DELETE'
        })
        
        if (data.success) {
          favorites.value = favorites.value.filter(f => f.id !== favorite.id)
        }
      } catch (error) {
        console.error('Erreur lors de la suppression du favori:', error)
        alert('Erreur lors de la suppression du favori')
      }
    }

    const goToContent = (favorite) => {
      const routes = {
        recipe: `/recipe/${favorite.content.id}`,
        tip: `/tip/${favorite.content.id}`,
        event: `/event/${favorite.content.id}`,
        dinor_tv: `/dinor-tv`
      }
      
      const route = routes[favorite.type]
      if (route) {
        router.push(route)
      }
    }

    const getTypeIcon = (type) => {
      const icons = {
        recipe: 'restaurant',
        tip: 'lightbulb',
        event: 'event',
        dinor_tv: 'play_circle'
      }
      return icons[type] || 'star'
    }

    const getDefaultImage = (type) => {
      const defaults = {
        recipe: '/images/default-recipe.jpg',
        tip: '/images/default-tip.jpg',
        event: '/images/default-event.jpg',
        dinor_tv: '/images/default-video.jpg'
      }
      return defaults[type] || '/images/default-content.jpg'
    }

    const getShortDescription = (description) => {
      if (!description) return ''
      
      // Supprimer les balises HTML
      const stripHtml = description.replace(/<[^>]*>/g, '')
      
      // Limiter la longueur
      return stripHtml.length > 100 ? stripHtml.substring(0, 100) + '...' : stripHtml
    }

    const getEmptyMessage = () => {
      const messages = {
        all: 'Aucun favori pour le moment',
        recipe: 'Aucune recette favorite',
        tip: 'Aucune astuce favorite',
        event: 'Aucun événement favori',
        dinor_tv: 'Aucune vidéo favorite'
      }
      return messages[selectedFilter.value] || 'Aucun favori'
    }

    const getEmptyDescription = () => {
      const descriptions = {
        all: 'Ajoutez du contenu à vos favoris en cliquant sur l\'icône cœur',
        recipe: 'Parcourez les recettes et ajoutez vos préférées à vos favoris',
        tip: 'Découvrez des astuces utiles et sauvegardez-les',
        event: 'Trouvez des événements intéressants et ajoutez-les à vos favoris',
        dinor_tv: 'Regardez des vidéos et ajoutez vos préférées à vos favoris'
      }
      return descriptions[selectedFilter.value] || ''
    }

    const getExploreLink = () => {
      const links = {
        all: '/',
        recipe: '/recipes',
        tip: '/tips',
        event: '/events',
        dinor_tv: '/dinor-tv'
      }
      return links[selectedFilter.value] || '/'
    }

    const formatDate = (date) => {
      if (!date) return ''
      
      try {
        const parsedDate = new Date(date)
        if (isNaN(parsedDate.getTime())) {
          return ''
        }
        
        return parsedDate.toLocaleDateString('fr-FR', {
          day: 'numeric',
          month: 'short'
        })
      } catch (error) {
        console.warn('Erreur lors du formatage de la date:', error)
        return ''
      }
    }

    const formatMemberSince = (date) => {
      if (!date) return 'Date inconnue'
      
      try {
        const parsedDate = new Date(date)
        if (isNaN(parsedDate.getTime())) {
          return 'Date inconnue'
        }
        
        return parsedDate.toLocaleDateString('fr-FR', {
          year: 'numeric',
          month: 'long'
        })
      } catch (error) {
        console.warn('Erreur lors du formatage de la date membre:', error)
        return 'Date inconnue'
      }
    }

    const handleImageError = (event) => {
      event.target.src = '/images/default-content.jpg'
    }

    // Form handlers
    const updateUsername = async () => {
      usernameForm.value.loading = true
      usernameForm.value.message = ''
      
      try {
        console.log('📝 [Profile] Mise à jour du nom:', { name: usernameForm.value.name })
        
        const data = await apiStore.put('/profile/name', {
          name: usernameForm.value.name
        })
        
        console.log('✅ [Profile] Réponse mise à jour nom:', data)
        
        if (data.success) {
          usernameForm.value.success = true
          usernameForm.value.message = 'Nom d\'utilisateur mis à jour avec succès'
          // Update auth store
          authStore.user.name = data.data.name
          usernameForm.value.name = ''
        }
      } catch (error) {
        console.error('❌ [Profile] Erreur mise à jour nom:', error)
        console.error('❌ [Profile] Données d\'erreur:', error.response?.data)
        
        usernameForm.value.success = false
        
        // Afficher les erreurs spécifiques si disponibles
        if (error.response?.data?.errors) {
          const errors = error.response.data.errors
          if (errors.name && errors.name.length > 0) {
            usernameForm.value.message = errors.name[0]
          } else {
            usernameForm.value.message = 'Erreur de validation: ' + Object.values(errors).flat().join(', ')
          }
        } else {
          usernameForm.value.message = error.response?.data?.message || error.message || 'Erreur lors de la mise à jour'
        }
      } finally {
        usernameForm.value.loading = false
      }
    }

    const updatePassword = async () => {
      if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
        passwordForm.value.success = false
        passwordForm.value.message = 'Les mots de passe ne correspondent pas'
        return
      }

      passwordForm.value.loading = true
      passwordForm.value.message = ''
      
      try {
        console.log('🔐 [Profile] Mise à jour du mot de passe')
        
        const data = await apiStore.put('/profile/password', {
          current_password: passwordForm.value.currentPassword,
          new_password: passwordForm.value.newPassword,
          new_password_confirmation: passwordForm.value.confirmPassword
        })
        
        console.log('✅ [Profile] Réponse mise à jour mdp:', data)
        
        if (data.success) {
          passwordForm.value.success = true
          passwordForm.value.message = 'Mot de passe mis à jour avec succès'
          // Clear form
          passwordForm.value.currentPassword = ''
          passwordForm.value.newPassword = ''
          passwordForm.value.confirmPassword = ''
        }
      } catch (error) {
        console.error('❌ [Profile] Erreur mise à jour mdp:', error)
        console.error('❌ [Profile] Données d\'erreur:', error.response?.data)
        
        passwordForm.value.success = false
        
        // Afficher les erreurs spécifiques si disponibles
        if (error.response?.data?.errors) {
          const errors = error.response.data.errors
          if (errors.current_password && errors.current_password.length > 0) {
            passwordForm.value.message = errors.current_password[0]
          } else if (errors.new_password && errors.new_password.length > 0) {
            passwordForm.value.message = errors.new_password[0]
          } else {
            passwordForm.value.message = 'Erreur de validation: ' + Object.values(errors).flat().join(', ')
          }
        } else {
          passwordForm.value.message = error.response?.data?.message || error.message || 'Erreur lors de la mise à jour'
        }
      } finally {
        passwordForm.value.loading = false
      }
    }

    const requestDataDeletion = async () => {
      if (!confirm('Êtes-vous absolument sûr de vouloir demander la suppression de toutes vos données ? Cette action est irréversible.')) {
        return
      }

      deletionForm.value.loading = true
      deletionForm.value.message = ''
      
      try {
        const data = await apiStore.request('/profile/request-deletion', {
          method: 'POST',
          body: {
            reason: deletionForm.value.reason,
            confirm: deletionForm.value.confirm
          }
        })
        
        if (data.success) {
          deletionForm.value.success = true
          deletionForm.value.message = data.message
          // Clear form
          deletionForm.value.reason = ''
          deletionForm.value.confirm = false
        }
      } catch (error) {
        deletionForm.value.success = false
        deletionForm.value.message = error.response?.data?.message || 'Erreur lors de la demande'
      } finally {
        deletionForm.value.loading = false
      }
    }

    const handleLogout = async () => {
      if (confirm('Êtes-vous sûr de vouloir vous déconnecter ?')) {
        console.log('👋 [Profile] Déconnexion utilisateur')
        try {
          await authStore.logout()
          // Rediriger vers la page d'accueil après déconnexion
          router.push('/')
        } catch (error) {
          console.error('❌ [Profile] Erreur lors de la déconnexion:', error)
        }
      }
    }

    const openTournament = (tournament) => {
      console.log('🏆 [Profile] Ouverture du tournoi:', tournament.name)
      router.push(`/predictions/tournaments`)
    }

    const openTournamentModal = (tournament) => {
      console.log('🏆 [Profile] Ouverture modale tournoi:', tournament.name)
      router.push(`/predictions/tournaments`)
    }

    const registerToTournament = async (tournament) => {
      console.log('🏆 [Profile] Inscription au tournoi:', tournament.name)
      try {
        const data = await apiStore.post(`/v1/tournaments/${tournament.id}/register`)
        if (data.success) {
          tournament.user_is_participant = true
          tournament.can_register = false
        }
      } catch (error) {
        console.error('❌ [Profile] Erreur inscription tournoi:', error)
      }
    }

    const goToPredictions = (tournament) => {
      console.log('🏆 [Profile] Aller aux prédictions:', tournament.name)
      router.push('/predictions')
    }

    const formatPrize = (amount, currency = 'XOF') => {
      return new Intl.NumberFormat('fr-FR', {
        style: 'currency',
        currency: currency,
        minimumFractionDigits: 0
      }).format(amount)
    }

    const getRankClass = (rank) => {
      if (!rank) return ''
      if (rank === 1) return 'rank-gold'
      if (rank === 2) return 'rank-silver'
      if (rank === 3) return 'rank-bronze'
      if (rank <= 10) return 'rank-top10'
      return ''
    }

    // Watch auth state changes
    watch(() => authStore.isAuthenticated, (isAuth) => {
      if (isAuth) {
        loadFavorites()
        loadPredictionsData()
      } else {
        favorites.value = []
        userPredictionsStats.value = null
        recentPredictions.value = []
      }
    }, { immediate: true })

    // Watch active section changes to load predictions data when needed
    watch(() => activeSection.value, (section) => {
      if (section === 'predictions' && authStore.isAuthenticated && !userPredictionsStats.value) {
        loadPredictionsData()
      }
    })

    onMounted(() => {
      if (authStore.isAuthenticated) {
        loadFavorites()
        loadPredictionsData()
        // Initialize username form with current name
        usernameForm.value.name = authStore.user?.name || ''
        
        // Debug user data
        console.log('🔍 [Profile] Données utilisateur:', authStore.user)
        console.log('🔍 [Profile] Date création:', authStore.user?.created_at)
      }
    })

    return {
      loading,
      showAuthModal,
      favorites,
      selectedFilter,
      activeSection,
      profileSections,
      filterTabs,
      totalFavorites,
      favoritesStats,
      filteredFavorites,
      authStore,
      usernameForm,
      passwordForm,
      deletionForm,
      // Predictions data
      predictionsLoading,
      userPredictionsStats,
      recentPredictions,
      loadPredictionsData,
      removeFavorite,
      goToContent,
      getTypeIcon,
      getDefaultImage,
      getShortDescription,
      getEmptyMessage,
      getEmptyDescription,
      getExploreLink,
      formatDate,
      formatMemberSince,
      handleImageError,
      updateUsername,
      updatePassword,
      requestDataDeletion,
      handleLogout,
      // Tournaments data
      userTournaments,
      tournamentsLoading,
      openTournament,
      // New predictions tabs data
      activePredictionsTab,
      predictionsTabs,
      userAllPredictions,
      activeTournaments,
      switchPredictionsTab,
      loadAllUserPredictions,
      loadActiveTournaments,
      openTournamentModal,
      registerToTournament,
      goToPredictions,
      formatPrize,
      getRankClass
    }
  }
}
</script>

<style scoped>
.profile {
  min-height: 100vh;
  background: #FFFFFF;
  padding: 16px;
  padding-bottom: 100px; /* Space for bottom nav */
  font-family: 'Roboto', sans-serif;
}

.loading-state,
.auth-required {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 60vh;
  text-align: center;
  padding: 32px;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #E2E8F0;
  border-top: 4px solid #E53E3E;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.auth-icon {
  width: 80px;
  height: 80px;
  background: #F4D03F;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 24px;
}

.auth-icon i {
  font-size: 40px;
  color: #E53E3E;
}

.btn-primary {
  padding: 12px 24px;
  background: #E53E3E;
  color: #FFFFFF;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 16px;
}

.btn-primary:hover {
  background: #C53030;
  transform: translateY(-1px);
}

.user-info-section {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 24px;
  background: #F4D03F;
  border-radius: 16px;
  margin-bottom: 24px;
  position: relative;
}

.user-avatar {
  width: 64px;
  height: 64px;
  background: rgba(229, 62, 62, 0.1);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-avatar i {
  font-size: 32px;
  color: #E53E3E;
}

.user-details {
  flex: 1;
}

.user-name {
  margin: 0 0 4px 0;
  font-size: 20px;
  font-weight: 600;
  color: #2D3748;
}

.user-email {
  margin: 0 0 4px 0;
  font-size: 14px;
  color: #4A5568;
}

.member-since {
  margin: 0;
  font-size: 12px;
  color: #4A5568;
}

.btn-logout {
  padding: 8px 16px;
  background: rgba(229, 62, 62, 0.1);
  color: #E53E3E;
  border: 1px solid #E53E3E;
  border-radius: 8px;
  font-size: 12px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.2s ease;
}

.btn-logout:hover {
  background: #E53E3E;
  color: #FFFFFF;
}

.user-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 32px;
}

.stat-card {
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 12px;
  padding: 16px;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.stat-number {
  font-size: 24px;
  font-weight: 700;
  color: #E53E3E;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #4A5568;
  font-weight: 500;
}

.section-header {
  margin-bottom: 24px;
}

.section-title {
  margin: 0 0 16px 0;
  font-size: 20px;
  font-weight: 600;
  color: #2D3748;
}

.filter-tabs {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding-bottom: 4px;
}

.filter-tab {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: #F7FAFC;
  border: 1px solid #E2E8F0;
  border-radius: 20px;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
  color: #4A5568;
}

.filter-tab:hover {
  background: #EDF2F7;
}

.filter-tab.active {
  background: #E53E3E;
  color: #FFFFFF;
  border-color: #E53E3E;
}

.filter-tab i {
  font-size: 16px;
}

.favorites-list {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.favorite-item {
  display: flex;
  gap: 12px;
  padding: 16px;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}

.favorite-item:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

.favorite-image {
  position: relative;
  width: 80px;
  height: 80px;
  border-radius: 8px;
  overflow: hidden;
  flex-shrink: 0;
}

.favorite-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.favorite-type-badge {
  position: absolute;
  top: 4px;
  left: 4px;
  width: 24px;
  height: 24px;
  background: rgba(229, 62, 62, 0.9);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.favorite-type-badge i {
  font-size: 12px;
  color: #FFFFFF;
}

.favorite-info {
  flex: 1;
  min-width: 0;
}

.favorite-title {
  margin: 0 0 4px 0;
  font-size: 16px;
  font-weight: 600;
  color: #2D3748;
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.favorite-description {
  margin: 0 0 8px 0;
  font-size: 14px;
  color: #4A5568;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.favorite-meta {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.favorite-date {
  font-size: 12px;
  color: #4A5568;
}

.favorite-stats {
  display: flex;
  gap: 12px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: #4A5568;
}

.stat i {
  font-size: 14px;
}

.remove-favorite {
  position: absolute;
  top: 8px;
  right: 8px;
  width: 32px;
  height: 32px;
  background: rgba(229, 62, 62, 0.1);
  color: #E53E3E;
  border: none;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.remove-favorite:hover {
  background: #E53E3E;
  color: #FFFFFF;
}

.remove-favorite i {
  font-size: 18px;
}

.empty-favorites {
  text-align: center;
  padding: 48px 24px;
}

.empty-icon {
  width: 80px;
  height: 80px;
  background: #F7FAFC;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 24px;
}

.empty-icon i {
  font-size: 40px;
  color: #CBD5E0;
}

.empty-favorites h3 {
  margin: 0 0 8px 0;
  font-size: 18px;
  color: #2D3748;
}

.empty-favorites p {
  margin: 0 0 24px 0;
  font-size: 14px;
  color: #4A5568;
}

.btn-secondary {
  padding: 12px 24px;
  background: #FFFFFF;
  color: #E53E3E;
  border: 1px solid #E53E3E;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  text-decoration: none;
  display: inline-block;
  transition: all 0.2s ease;
}

.btn-secondary:hover {
  background: #E53E3E;
  color: #FFFFFF;
}

/* Responsive */
@media (max-width: 768px) {
  .user-info-section {
    flex-direction: column;
    text-align: center;
    gap: 12px;
  }

  .user-stats {
    grid-template-columns: repeat(2, 1fr);
  }

  .filter-tabs {
    justify-content: flex-start;
  }
  
  .favorite-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}

@media (max-width: 480px) {
  .profile {
    padding: 12px;
  }
  
  .user-stats {
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
  }
  
  .stat-card {
    padding: 12px;
  }
  
  .favorite-item {
    padding: 12px;
  }
  
  .favorite-image {
    width: 60px;
    height: 60px;
  }
}

/* Profile Navigation */
.profile-navigation {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  overflow-x: auto;
  padding-bottom: 4px;
}

.nav-button {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;
  color: #4A5568;
  min-width: fit-content;
}

.nav-button:hover {
  background: #F7FAFC;
  border-color: #CBD5E0;
}

.nav-button.active {
  background: #E53E3E;
  color: #FFFFFF;
  border-color: #E53E3E;
}

.nav-button i {
  font-size: 20px;
}

/* Profile Sections */
.profile-sections {
  min-height: 400px;
}

.section-content {
  background: #FFFFFF;
  border-radius: 12px;
  padding: 24px;
  border: 1px solid #E2E8F0;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

/* Form Styles */
.form-section {
  margin-bottom: 32px;
  padding: 24px;
  background: #F8F9FA;
  border-radius: 12px;
  border: 1px solid #E2E8F0;
}

.form-title {
  margin: 0 0 16px 0;
  font-size: 18px;
  font-weight: 600;
  color: #2D3748;
}

.form-description {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: #4A5568;
  line-height: 1.5;
}

.update-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-label {
  font-size: 14px;
  font-weight: 600;
  color: #2D3748;
}

.form-input,
.form-textarea {
  padding: 12px;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  font-size: 14px;
  background: #FFFFFF;
  transition: all 0.2s ease;
  font-family: inherit;
}

.form-input:focus,
.form-textarea:focus {
  outline: none;
  border-color: #E53E3E;
  box-shadow: 0 0 0 3px rgba(229, 62, 62, 0.1);
}

.form-textarea {
  resize: vertical;
  min-height: 80px;
}

.form-hint {
  font-size: 12px;
  color: #4A5568;
  margin-top: 4px;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  color: #2D3748;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: 16px;
  height: 16px;
  accent-color: #E53E3E;
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-start;
}

.form-message {
  padding: 12px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
}

.form-message.success {
  background: #F0FDF4;
  color: #059669;
  border: 1px solid #10B981;
}

.form-message.error {
  background: #FEF2F2;
  color: #DC2626;
  border: 1px solid #EF4444;
}

/* Button Styles */
.btn-danger {
  padding: 12px 24px;
  background: #DC2626;
  color: #FFFFFF;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-danger:hover {
  background: #B91C1C;
}

.btn-danger:disabled {
  background: #9CA3AF;
  cursor: not-allowed;
}

.btn-logout-main {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 24px;
  background: #E53E3E;
  color: #FFFFFF;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-logout-main:hover {
  background: #C53030;
  transform: translateY(-1px);
}

.btn-logout-main i {
  font-size: 18px;
}

/* Legal Section */
.legal-section {
  margin-bottom: 32px;
}

.legal-links {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.legal-link {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  text-decoration: none;
  color: #2D3748;
  transition: all 0.2s ease;
}

.legal-link:hover {
  background: #F7FAFC;
  border-color: #CBD5E0;
  transform: translateX(4px);
}

.legal-link i:first-child {
  font-size: 20px;
  color: #E53E3E;
}

.legal-link span {
  flex: 1;
  font-size: 14px;
  font-weight: 500;
}

.legal-link i:last-child {
  font-size: 16px;
  color: #9CA3AF;
}

/* Danger Section */
.danger-section {
  border-color: #FCA5A5;
  background: #FEF2F2;
}

.danger-title {
  color: #DC2626;
}

.danger-description {
  color: #7F1D1D;
  font-size: 14px;
  line-height: 1.5;
  margin-bottom: 16px;
}

/* Predictions Section Styles */
.predictions-overview {
  padding: 0;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 12px;
  padding: 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  transition: all 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.stat-card.points {
  border-color: #F4D03F;
}

.stat-card.rank {
  border-color: #F39C12;
}

.stat-card.predictions {
  border-color: #3498DB;
}

.stat-card.accuracy {
  border-color: #27AE60;
}

.stat-icon {
  width: 40px;
  height: 40px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #FFFFFF;
}

.stat-card.points .stat-icon {
  background: #F4D03F;
}

.stat-card.rank .stat-icon {
  background: #F39C12;
}

.stat-card.predictions .stat-icon {
  background: #3498DB;
}

.stat-card.accuracy .stat-icon {
  background: #27AE60;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #2D3748;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #6B7280;
  font-weight: 500;
}

.predictions-actions {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}

.action-link {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px;
  background: #F4D03F;
  color: #2D3748;
  text-decoration: none;
  border-radius: 8px;
  font-weight: 600;
  font-size: 14px;
  transition: all 0.2s ease;
}

.action-link:hover {
  background: #F1C40F;
  transform: translateY(-2px);
}

.action-link i {
  font-size: 18px;
}

.recent-predictions {
  margin-top: 24px;
}

.subsection-title {
  font-size: 18px;
  font-weight: 600;
  color: #2D3748;
  margin-bottom: 16px;
}

.predictions-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 16px;
}

.prediction-item {
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  padding: 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  transition: all 0.2s ease;
}

.prediction-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.prediction-item.calculated {
  border-color: #10B981;
  background: #F0FDF4;
}

.prediction-match {
  flex: 1;
}

.teams {
  font-weight: 600;
  color: #2D3748;
  margin-bottom: 4px;
}

.vs {
  color: #F4D03F;
  margin: 0 8px;
}

.match-date {
  font-size: 12px;
  color: #6B7280;
}

.prediction-details {
  text-align: right;
}

.predicted-score {
  font-size: 18px;
  font-weight: 700;
  color: #F4D03F;
  margin-bottom: 4px;
}

.prediction-status {
  font-size: 12px;
}

.points-earned {
  color: #10B981;
  font-weight: 600;
}

.pending {
  color: #F59E0B;
  font-weight: 500;
}

.view-all-link {
  text-align: center;
}

.no-predictions {
  text-align: center;
  padding: 48px 24px;
}

.no-predictions .empty-icon {
  width: 80px;
  height: 80px;
  background: #F7FAFC;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
}

.no-predictions .empty-icon i {
  font-size: 32px;
  color: #9CA3AF;
}

.no-predictions h3 {
  font-size: 18px;
  font-weight: 600;
  color: #2D3748;
  margin-bottom: 8px;
}

.no-predictions p {
  font-size: 14px;
  color: #6B7280;
  margin-bottom: 24px;
}

.error-state {
  text-align: center;
  padding: 48px 24px;
}

.error-icon {
  width: 80px;
  height: 80px;
  background: #FEF2F2;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
}

.error-icon i {
  font-size: 32px;
  color: #EF4444;
}

.error-state h3 {
  font-size: 18px;
  font-weight: 600;
  color: #2D3748;
  margin-bottom: 8px;
}

.error-state p {
  font-size: 14px;
  color: #6B7280;
  margin-bottom: 24px;
}

.loading-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 48px 24px;
  text-align: center;
}

.loading-container .md3-circular-progress {
  margin-bottom: 16px;
}

/* Responsive Design for New Elements */
@media (max-width: 768px) {
  .profile-navigation {
    justify-content: flex-start;
  }
  
  .nav-button {
    padding: 10px 12px;
    font-size: 13px;
  }
  
  .section-content {
    padding: 16px;
  }
  
  .form-section {
    padding: 16px;
  }
  
  .legal-link {
    padding: 12px;
  }
  
  .stats-grid {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .predictions-actions {
    flex-direction: column;
    gap: 8px;
  }
  
  .prediction-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
  }
  
  .prediction-details {
    text-align: left;
    width: 100%;
  }
}

@media (max-width: 480px) {
  .nav-button {
    padding: 8px 10px;
    font-size: 12px;
  }
  
  .nav-button i {
    font-size: 18px;
  }
  
  .section-content {
    padding: 12px;
  }
  
  .form-section {
    padding: 12px;
  }
}

/* Tournaments Section Styles */
.my-tournaments-section {
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #E5E7EB;
}

.tournaments-list {
  display: grid;
  gap: 16px;
  margin-bottom: 24px;
}

.tournament-item {
  background: #F8F9FA;
  border-radius: 12px;
  padding: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
  border: 1px solid #E5E7EB;
}

.tournament-item:hover {
  background: #F1F5F9;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.tournament-info {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
}

.tournament-name {
  font-size: 16px;
  font-weight: 600;
  color: #2D3748;
  margin: 0;
  flex: 1;
  margin-right: 12px;
}

.tournament-status {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.5px;
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

.tournament-stats {
  display: flex;
  justify-content: space-between;
  gap: 16px;
}

.stat-item {
  text-align: center;
  flex: 1;
}

.stat-label {
  display: block;
  font-size: 12px;
  color: #9CA3AF;
  margin-bottom: 4px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.stat-value {
  display: block;
  font-size: 18px;
  font-weight: 700;
  color: #F4D03F;
}

.no-tournaments {
  text-align: center;
  padding: 48px 24px;
}

.no-tournaments .empty-icon {
  width: 80px;
  height: 80px;
  background: #FEF3C7;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 16px;
}

.no-tournaments .empty-icon i {
  font-size: 32px;
  color: #F59E0B;
}

.no-tournaments h4 {
  font-size: 18px;
  font-weight: 600;
  color: #2D3748;
  margin-bottom: 8px;
}

.no-tournaments p {
  font-size: 14px;
  color: #6B7280;
  margin-bottom: 24px;
}

.tournaments-actions {
  display: flex;
  justify-content: center;
  margin-top: 24px;
}

@media (max-width: 768px) {
  .tournament-stats {
    gap: 8px;
  }
  
  .stat-value {
    font-size: 16px;
  }
  
  .tournament-item {
    padding: 12px;
  }
  
  .tournament-info {
    flex-direction: column;
    gap: 8px;
    align-items: stretch;
  }
  
  .tournament-name {
    margin-right: 0;
    margin-bottom: 8px;
  }
}

/* New Predictions Tabs Styles */
.predictions-section {
  background: #FFFFFF;
}

.sub-tabs {
  display: flex;
  background: #F8F9FA;
  border-radius: 12px;
  padding: 4px;
  margin-bottom: 24px;
  gap: 4px;
}

.sub-tab {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 16px;
  border: none;
  background: transparent;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  color: #6B7280;
  cursor: pointer;
  transition: all 0.2s ease;
}

.sub-tab.active {
  background: #FFFFFF;
  color: #F4D03F;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.sub-tab:hover:not(.active) {
  background: rgba(244, 208, 63, 0.1);
  color: #F4D03F;
}

.sub-tab i {
  font-size: 18px;
}

.tab-content {
  min-height: 200px;
}

.tab-title {
  font-size: 20px;
  font-weight: 600;
  color: #2D3748;
  margin-bottom: 16px;
}

.tab-description {
  font-size: 14px;
  color: #6B7280;
  margin-bottom: 24px;
}

/* Predictions Tab Styles */
.predictions-header {
  margin-bottom: 24px;
}

.predictions-stats {
  display: flex;
  justify-content: space-around;
  background: #F8F9FA;
  border-radius: 12px;
  padding: 16px;
  margin-top: 16px;
}

.predictions-stats .stat-item {
  text-align: center;
}

.predictions-stats .stat-value {
  display: block;
  font-size: 20px;
  font-weight: 700;
  color: #F4D03F;
  margin-bottom: 4px;
}

.predictions-stats .stat-label {
  font-size: 12px;
  color: #6B7280;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.prediction-card {
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 12px;
  transition: all 0.2s ease;
}

.prediction-card:hover {
  border-color: #F4D03F;
  box-shadow: 0 2px 8px rgba(244, 208, 63, 0.2);
}

.prediction-card.calculated {
  border-left: 4px solid #10B981;
}

.prediction-match {
  margin-bottom: 12px;
}

.prediction-match .teams {
  font-weight: 600;
  color: #2D3748;
  margin-bottom: 4px;
}

.prediction-match .vs {
  color: #6B7280;
  margin: 0 8px;
}

.prediction-match .match-date {
  font-size: 12px;
  color: #9CA3AF;
}

.predicted-score {
  font-size: 18px;
  font-weight: 700;
  color: #F4D03F;
  margin-bottom: 4px;
}

.actual-score {
  font-size: 14px;
  color: #6B7280;
  margin-bottom: 8px;
}

.points-earned {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  background: #FEE2E2;
  color: #DC2626;
}

.points-earned.points-positive {
  background: #D1FAE5;
  color: #065F46;
}

.pending {
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  background: #FEF3C7;
  color: #92400E;
}

.load-more-btn {
  width: 100%;
  margin-top: 16px;
}

/* Ranking Tab Styles */
.ranking-header {
  margin-bottom: 24px;
}

.global-ranking {
  margin-bottom: 32px;
}

.ranking-card {
  background: linear-gradient(135deg, #F4D03F 0%, #F39C12 100%);
  border-radius: 16px;
  padding: 24px;
  color: white;
}

.ranking-info {
  margin-bottom: 20px;
}

.rank-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(255, 255, 255, 0.2);
  padding: 8px 16px;
  border-radius: 20px;
  font-weight: 700;
  margin-bottom: 16px;
}

.rank-badge.rank-gold {
  background: linear-gradient(135deg, #FFD700, #FFA500);
}

.rank-badge.rank-silver {
  background: linear-gradient(135deg, #C0C0C0, #A0A0A0);
}

.rank-badge.rank-bronze {
  background: linear-gradient(135deg, #CD7F32, #8B4513);
}

.rank-badge.rank-top10 {
  background: linear-gradient(135deg, #4F46E5, #7C3AED);
}

.ranking-stats {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.ranking-stats .stat-item {
  text-align: center;
  background: rgba(255, 255, 255, 0.1);
  padding: 12px;
  border-radius: 8px;
}

.ranking-stats .stat-value {
  display: block;
  font-size: 18px;
  font-weight: 700;
  margin-bottom: 4px;
}

.ranking-stats .stat-label {
  font-size: 12px;
  opacity: 0.9;
}

.view-leaderboard-btn {
  display: inline-block;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  text-decoration: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  transition: all 0.2s ease;
}

.view-leaderboard-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

.tournaments-ranking {
  margin-bottom: 24px;
}

.tournament-ranking-card {
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  border-radius: 12px;
  padding: 20px;
  margin-bottom: 16px;
}

.tournament-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}

.tournament-header .tournament-name {
  font-size: 16px;
  font-weight: 600;
  color: #2D3748;
  margin: 0;
}

.tournament-ranking {
  display: flex;
  align-items: center;
  gap: 20px;
}

.tournament-ranking .rank-badge {
  color: white;
  font-weight: 700;
  font-size: 14px;
}

.tournament-ranking .tournament-stats {
  display: flex;
  gap: 24px;
  flex: 1;
}

.no-tournaments-ranking {
  text-align: center;
  padding: 48px 24px;
}

/* Active Tournaments Tab Styles */
.active-tournaments-header {
  margin-bottom: 24px;
}

.active-tournaments-list {
  display: grid;
  gap: 16px;
}

.active-tournament-card {
  background: #FFFFFF;
  border: 1px solid #E5E7EB;
  border-radius: 12px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.active-tournament-card:hover {
  border-color: #F4D03F;
  box-shadow: 0 4px 12px rgba(244, 208, 63, 0.2);
  transform: translateY(-2px);
}

.tournament-info {
  margin-bottom: 16px;
}

.tournament-description {
  font-size: 14px;
  color: #6B7280;
  margin: 8px 0;
  line-height: 1.5;
}

.tournament-meta {
  display: flex;
  gap: 12px;
  margin-top: 12px;
}

.participants-count {
  font-size: 12px;
  color: #6B7280;
  background: #F3F4F6;
  padding: 4px 8px;
  border-radius: 6px;
}

.tournament-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tournament-prize {
  font-size: 16px;
  font-weight: 700;
  color: #10B981;
}

.tournament-action-btn {
  padding: 8px 16px;
  font-size: 14px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
}

.tournament-status-text {
  font-size: 14px;
  color: #6B7280;
  font-weight: 500;
}

.no-active-tournaments {
  text-align: center;
  padding: 48px 24px;
}

.suggestions {
  display: flex;
  gap: 12px;
  justify-content: center;
  margin-top: 24px;
}

.btn-outline {
  background: transparent;
  border: 1px solid #E5E7EB;
  color: #6B7280;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-outline:hover {
  border-color: #F4D03F;
  color: #F4D03F;
}

/* Mobile Responsive */
@media (max-width: 768px) {
  .sub-tabs {
    flex-direction: column;
    gap: 2px;
  }
  
  .sub-tab {
    padding: 10px 12px;
    font-size: 13px;
  }
  
  .predictions-stats {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
  
  .ranking-stats {
    grid-template-columns: 1fr;
    gap: 12px;
  }
  
  .tournament-ranking {
    flex-direction: column;
    gap: 12px;
    text-align: center;
  }
  
  .tournament-actions {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }
  
  .suggestions {
    flex-direction: column;
    gap: 8px;
  }
}
</style>