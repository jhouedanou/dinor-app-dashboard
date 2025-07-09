<template>
  <div class="profile">
    <!-- Loading State -->
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p>Chargement du profil...</p>
    </div>

    <!-- Not Authenticated State -->
    <div v-else-if="!authStore?.isAuthenticated" class="auth-required">
      <div class="auth-icon">
        <span class="material-symbols-outlined">person</span>
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
          <span class="material-symbols-outlined">person</span>
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
          <span class="material-symbols-outlined">{{ section.icon }}</span>
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
              <span class="material-symbols-outlined">{{ tab.icon }}</span>
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
                <span class="material-symbols-outlined">{{ getTypeIcon(favorite.type) }}</span>
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
                    <span class="material-symbols-outlined">favorite</span>
                    {{ favorite.content.likes_count || 0 }}
                  </span>
                  <span class="stat">
                    <span class="material-symbols-outlined">comment</span>
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
              <span class="material-symbols-outlined">close</span>
            </button>
          </div>
        </div>

        <!-- Empty State -->
        <div v-else class="empty-favorites">
          <div class="empty-icon">
            <span class="material-symbols-outlined">favorite_border</span>
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

          <!-- Main Predictions Dashboard -->
          <div v-else-if="userPredictionsStats" class="predictions-dashboard">
            
            <!-- Quick Stats & Actions -->
            <div class="predictions-overview">
              <div class="stats-grid">
                <div class="stat-card total-predictions">
                  <div class="stat-icon">
                    <span class="material-symbols-outlined">sports_soccer</span>
                  </div>
                  <div class="stat-content">
                    <span class="stat-value">{{ userPredictionsStats.total_predictions }}</span>
                    <span class="stat-label">Total prédictions</span>
                  </div>
                </div>
                
                <div class="stat-card total-points">
                  <div class="stat-icon">
                    <span class="material-symbols-outlined">emoji_events</span>
                  </div>
                  <div class="stat-content">
                    <span class="stat-value">{{ userPredictionsStats.total_points }}</span>
                    <span class="stat-label">Points gagnés</span>
                  </div>
                </div>
                
                <div class="stat-card accuracy">
                  <div class="stat-icon">
                    <span class="material-symbols-outlined">target</span>
                  </div>
                  <div class="stat-content">
                    <span class="stat-value">{{ userPredictionsStats.accuracy_percentage }}%</span>
                    <span class="stat-label">Précision</span>
                  </div>
                </div>
                
                <div class="stat-card ranking" v-if="userPredictionsStats.current_rank">
                  <div class="stat-icon">
                    <span class="material-symbols-outlined">leaderboard</span>
                  </div>
                  <div class="stat-content">
                    <span class="stat-value">#{{ userPredictionsStats.current_rank }}</span>
                    <span class="stat-label">Classement</span>
                  </div>
                </div>
              </div>

              <!-- Quick Actions -->
              <div class="quick-actions">
                <button @click="goToPredictions" class="action-button primary">
                  <span class="material-symbols-outlined">add_circle</span>
                  <span>Faire un pronostic</span>
                </button>
                
                <button @click="switchPredictionsTab('my-ranking')" class="action-button secondary">
                  <span class="material-symbols-outlined">leaderboard</span>
                  <span>Voir le classement</span>
                </button>
                
                <button @click="switchPredictionsTab('active-tournaments')" class="action-button secondary">
                  <span class="material-symbols-outlined">emoji_events</span>
                  <span>Tournois actifs</span>
                </button>
              </div>
            </div>

            <!-- Sub-navigation for detailed views -->
            <div class="sub-tabs">
              <button
                v-for="tab in predictionsTabs"
                :key="tab.key"
                @click="switchPredictionsTab(tab.key)"
                :class="['sub-tab', { active: activePredictionsTab === tab.key }]"
              >
                <span class="material-symbols-outlined">{{ tab.icon }}</span>
                <span>{{ tab.label }}</span>
              </button>
            </div>

            <!-- My Predictions Tab -->
            <div v-if="activePredictionsTab === 'my-predictions'" class="tab-content">
              <!-- Predictions Stats Overview -->
              <div v-if="userPredictionsStats" class="predictions-stats-overview">
                <div class="stats-grid">
                  <div class="stat-card">
                    <div class="stat-icon">
                      <span class="material-symbols-outlined">sports_soccer</span>
                    </div>
                    <div class="stat-info">
                      <span class="stat-value">{{ userPredictionsStats.total_predictions || 0 }}</span>
                      <span class="stat-label">Pronostics</span>
                    </div>
                  </div>
                  <div class="stat-card">
                    <div class="stat-icon accuracy">
                      <span class="material-symbols-outlined">target</span>
                    </div>
                    <div class="stat-info">
                      <span class="stat-value">{{ userPredictionsStats.accuracy_percentage || 0 }}%</span>
                      <span class="stat-label">Précision</span>
                    </div>
                  </div>
                  <div class="stat-card">
                    <div class="stat-icon points">
                      <span class="material-symbols-outlined">emoji_events</span>
                    </div>
                    <div class="stat-info">
                      <span class="stat-value">{{ userPredictionsStats.total_points || 0 }}</span>
                      <span class="stat-label">Points</span>
                    </div>
                  </div>
                  <div class="stat-card" v-if="userPredictionsStats.current_rank">
                    <div class="stat-icon ranking">
                      <span class="material-symbols-outlined">leaderboard</span>
                    </div>
                    <div class="stat-info">
                      <span class="stat-value">#{{ userPredictionsStats.current_rank }}</span>
                      <span class="stat-label">Classement</span>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Recent Predictions Preview -->
              <div v-if="recentPredictions.length" class="recent-predictions-preview">
                <div class="section-header-with-action">
                  <h3 class="subsection-title">
                    <span class="material-symbols-outlined">history</span>
                    Pronostics récents
                  </h3>
                  <div class="predictions-filter-mini">
                    <button 
                      @click="predictionsFilterMini = 'all'"
                      :class="['filter-btn', { active: predictionsFilterMini === 'all' }]"
                    >
                      Tous
                    </button>
                    <button 
                      @click="predictionsFilterMini = 'pending'"
                      :class="['filter-btn', { active: predictionsFilterMini === 'pending' }]"
                    >
                      En attente
                    </button>
                    <button 
                      @click="predictionsFilterMini = 'calculated'"
                      :class="['filter-btn', { active: predictionsFilterMini === 'calculated' }]"
                    >
                      Terminés
                    </button>
                  </div>
                </div>
                <div class="predictions-list compact">
                  <div 
                    v-for="prediction in getFilteredRecentPredictions()" 
                    :key="prediction.id" 
                    class="prediction-card compact"
                    :class="{ 
                      calculated: prediction.is_calculated,
                      'positive-result': prediction.is_calculated && prediction.points_earned > 0,
                      'negative-result': prediction.is_calculated && prediction.points_earned === 0
                    }"
                  >
                    <div class="prediction-status-indicator">
                      <span v-if="prediction.is_calculated" class="material-symbols-outlined">
                        {{ prediction.points_earned > 0 ? 'check_circle' : 'cancel' }}
                      </span>
                      <span v-else class="material-symbols-outlined pending-icon">schedule</span>
                    </div>
                    <div class="prediction-match">
                      <div class="teams">
                        <span class="team">{{ prediction.football_match.home_team.short_name || prediction.football_match.home_team.name }}</span>
                        <span class="vs">vs</span>
                        <span class="team">{{ prediction.football_match.away_team.short_name || prediction.football_match.away_team.name }}</span>
                      </div>
                      <div class="match-info">
                        <span class="predicted-score">{{ prediction.predicted_home_score }} - {{ prediction.predicted_away_score }}</span>
                        <span v-if="prediction.is_calculated" class="points-earned" :class="{ 'points-positive': prediction.points_earned > 0 }">
                          {{ prediction.points_earned > 0 ? '+' : '' }}{{ prediction.points_earned }} pt{{ prediction.points_earned > 1 ? 's' : '' }}
                        </span>
                        <span v-else class="pending">En attente</span>
                      </div>
                    </div>
                    <div class="prediction-date">
                      {{ formatRelativeTime(prediction.created_at) }}
                    </div>
                  </div>
                </div>
                
                <button @click="loadAllUserPredictions" class="btn-secondary show-all-btn">
                  <span class="material-symbols-outlined">visibility</span>
                  Voir tous mes pronostics ({{ userPredictionsStats.total_predictions }})
                </button>
              </div>

              <!-- Complete Predictions List (when loaded) -->
              <div v-if="userAllPredictions.length" class="all-predictions">
                <div class="predictions-header">
                  <h3 class="subsection-title">
                    <span class="material-symbols-outlined">list</span>
                    Tous mes pronostics
                  </h3>
                  <div class="predictions-filters">
                    <div class="filter-chips">
                      <button 
                        @click="predictionsFilter = 'all'"
                        :class="['filter-chip', { active: predictionsFilter === 'all' }]"
                      >
                        <span class="material-symbols-outlined">select_all</span>
                        Tous ({{ userAllPredictions.length }})
                      </button>
                      <button 
                        @click="predictionsFilter = 'pending'"
                        :class="['filter-chip', { active: predictionsFilter === 'pending' }]"
                      >
                        <span class="material-symbols-outlined">schedule</span>
                        En attente ({{ getPredictionsCountByStatus('pending') }})
                      </button>
                      <button 
                        @click="predictionsFilter = 'calculated'"
                        :class="['filter-chip', { active: predictionsFilter === 'calculated' }]"
                      >
                        <span class="material-symbols-outlined">check_circle</span>
                        Terminés ({{ getPredictionsCountByStatus('calculated') }})
                      </button>
                      <button 
                        @click="predictionsFilter = 'won'"
                        :class="['filter-chip', { active: predictionsFilter === 'won' }]"
                      >
                        <span class="material-symbols-outlined">emoji_events</span>
                        Gagnants ({{ getPredictionsCountByStatus('won') }})
                      </button>
                    </div>
                  </div>
                </div>
                
                <div class="predictions-list grouped">
                  <div v-for="group in groupedPredictions" :key="group.date" class="predictions-group">
                    <div class="group-header">
                      <span class="group-date">{{ group.date }}</span>
                      <span class="group-count">{{ group.predictions.length }} pronostic{{ group.predictions.length > 1 ? 's' : '' }}</span>
                    </div>
                    <div class="group-predictions">
                      <div 
                        v-for="prediction in group.predictions" 
                        :key="prediction.id" 
                        class="prediction-card detailed"
                        :class="{ 
                          calculated: prediction.is_calculated,
                          'positive-result': prediction.is_calculated && prediction.points_earned > 0,
                          'negative-result': prediction.is_calculated && prediction.points_earned === 0
                        }"
                      >
                        <div class="prediction-status-indicator">
                          <DinorIcon v-if="prediction.is_calculated" :name="prediction.points_earned > 0 ? 'check_circle' : 'cancel'" :size="20" />
                          <DinorIcon v-else name="schedule" :size="20" class="pending-icon" />
                        </div>
                        
                        <div class="prediction-match">
                          <div class="teams">
                            <span class="team">{{ prediction.football_match.home_team.name }}</span>
                            <span class="vs">vs</span>
                            <span class="team">{{ prediction.football_match.away_team.name }}</span>
                          </div>
                          <div class="match-date">
                            {{ formatTime(prediction.football_match.match_date) }}
                          </div>
                        </div>
                        
                        <div class="prediction-details">
                          <div class="prediction-scores">
                            <div class="predicted">
                              <span class="label">Mon pronostic</span>
                              <span class="score highlight">{{ prediction.predicted_home_score }} - {{ prediction.predicted_away_score }}</span>
                            </div>
                            <div v-if="prediction.football_match.is_finished" class="actual">
                              <span class="label">Résultat final</span>
                              <span class="score">{{ prediction.football_match.home_score }} - {{ prediction.football_match.away_score }}</span>
                            </div>
                          </div>
                          <div class="prediction-result">
                            <span v-if="prediction.is_calculated" class="points-earned" :class="getPointsClass(prediction.points_earned)">
                              <span class="material-symbols-outlined">{{ prediction.points_earned > 0 ? 'add' : 'remove' }}</span>
                              {{ prediction.points_earned }} point{{ prediction.points_earned > 1 ? 's' : '' }}
                            </span>
                            <span v-else class="pending">
                              <span class="material-symbols-outlined">schedule</span>
                              En attente du résultat
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- No Predictions State -->
              <div v-if="!recentPredictions.length && !userAllPredictions.length" class="empty-predictions">
                <div class="empty-illustration">
                  <div class="empty-icon">
                    <span class="material-symbols-outlined">sports_soccer</span>
                  </div>
                  <div class="empty-pattern"></div>
                </div>
                <h3>Aucun pronostic pour le moment</h3>
                <p>Commencez à faire des pronostics pour gagner des points et grimper dans le classement !</p>
                <div class="empty-actions">
                  <button @click="goToPredictions" class="btn-primary">
                    <span class="material-symbols-outlined">add</span>
                    Faire mon premier pronostic
                  </button>
                  <button @click="switchPredictionsTab('active-tournaments')" class="btn-secondary">
                    <span class="material-symbols-outlined">emoji_events</span>
                    Voir les tournois
                  </button>
                </div>
              </div>
            </div>

            <!-- My Ranking Tab -->
            <div v-if="activePredictionsTab === 'my-ranking'" class="tab-content">
              <div class="ranking-section">
                <h3 class="subsection-title">
                  <span class="material-symbols-outlined">leaderboard</span>
                  Mon classement
                </h3>
                
                <!-- Personal Ranking Card -->
                <div v-if="userPredictionsStats.current_rank" class="my-rank-card enhanced">
                  <div class="rank-badge" :class="getRankClass(userPredictionsStats.current_rank)">
                    <span class="material-symbols-outlined">emoji_events</span>
                    <span class="rank-number">#{{ userPredictionsStats.current_rank }}</span>
                  </div>
                  <div class="rank-info">
                    <h4>{{ authStore.user?.name || 'Vous' }}</h4>
                    <div class="rank-stats">
                      <div class="stat-item">
                        <span class="material-symbols-outlined">star</span>
                        <span>{{ userPredictionsStats.total_points }} points</span>
                      </div>
                      <div class="stat-item">
                        <span class="material-symbols-outlined">target</span>
                        <span>{{ userPredictionsStats.accuracy_percentage }}% de réussite</span>
                      </div>
                    </div>
                    <div v-if="userPredictionsStats.rank_change" class="rank-change" :class="{ positive: userPredictionsStats.rank_change > 0, negative: userPredictionsStats.rank_change < 0 }">
                      <span class="material-symbols-outlined">
                        {{ userPredictionsStats.rank_change > 0 ? 'trending_up' : 'trending_down' }}
                      </span>
                      {{ userPredictionsStats.rank_change > 0 ? '+' : '' }}{{ userPredictionsStats.rank_change }} place{{ Math.abs(userPredictionsStats.rank_change) > 1 ? 's' : '' }}
                    </div>
                  </div>
                </div>
                
                <!-- Progress to next rank -->
                <div v-if="userPredictionsStats.points_to_next_rank" class="progress-card">
                  <h4>Progression</h4>
                  <div class="progress-info">
                    <span>{{ userPredictionsStats.points_to_next_rank }} points pour le prochain rang</span>
                    <div class="progress-bar">
                      <div class="progress-fill" :style="{ width: getProgressPercentage() + '%' }"></div>
                    </div>
                  </div>
                </div>
                
                <div class="ranking-actions">
                  <button @click="goToLeaderboard" class="btn-primary">
                    <span class="material-symbols-outlined">leaderboard</span>
                    Voir le classement complet
                  </button>
                  <button @click="switchPredictionsTab('active-tournaments')" class="btn-secondary">
                    <span class="material-symbols-outlined">emoji_events</span>
                    Rejoindre un tournoi
                  </button>
                </div>
              </div>
            </div>

            <!-- Active Tournaments Tab -->
            <div v-if="activePredictionsTab === 'active-tournaments'" class="tab-content">
              <div class="tournaments-section">
                <h3 class="subsection-title">Tournois en cours</h3>
                
                <div v-if="activeTournaments.length" class="tournaments-list">
                  <div 
                    v-for="tournament in activeTournaments" 
                    :key="tournament.id" 
                    class="tournament-card"
                  >
                    <div class="tournament-header">
                      <h4>{{ tournament.name }}</h4>
                      <span class="tournament-status" :class="tournament.status">
                        {{ getTournamentStatusLabel(tournament.status) }}
                      </span>
                    </div>
                    
                    <div class="tournament-info">
                      <div v-if="tournament.total_prize" class="prize">
                        <span class="material-symbols-outlined">emoji_events</span>
                        <span>{{ formatPrize(tournament.total_prize) }}</span>
                      </div>
                      <div class="participants">
                        <span class="material-symbols-outlined">group</span>
                        <span>{{ tournament.participants_count || 0 }} participant{{ (tournament.participants_count || 0) > 1 ? 's' : '' }}</span>
                      </div>
                    </div>
                    
                    <div class="tournament-actions">
                      <button 
                        v-if="tournament.can_register && !tournament.user_is_participant"
                        @click="registerToTournament(tournament)"
                        :disabled="registering === tournament.id"
                        class="btn-secondary"
                      >
                        {{ registering === tournament.id ? 'Inscription...' : 'S\'inscrire' }}
                      </button>
                      
                      <button 
                        v-if="tournament.user_is_participant"
                        @click="goToPredictions(tournament)"
                        class="btn-primary"
                      >
                        Faire mes pronostics
                      </button>
                    </div>
                  </div>
                </div>
                
                <div v-else class="empty-tournaments">
                  <div class="empty-icon">
                    <span class="material-symbols-outlined">emoji_events</span>
                  </div>
                  <h4>Aucun tournoi actif</h4>
                  <p>Les nouveaux tournois apparaîtront ici dès qu'ils seront disponibles.</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Error State -->
          <div v-else class="error-state">
            <div class="error-icon">
              <span class="material-symbols-outlined">error</span>
            </div>
            <h3>Impossible de charger vos pronostics</h3>
            <p>Vérifiez votre connexion et réessayez.</p>
            <button @click="loadPredictionsData" class="btn-secondary">Réessayer</button>
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
              <span class="material-symbols-outlined">logout</span>
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
                <span class="material-symbols-outlined">description</span>
                <span>Conditions générales d'utilisation</span>
                <span class="material-symbols-outlined">arrow_forward_ios</span>
              </a>
              <a href="/privacy" class="legal-link">
                <span class="material-symbols-outlined">privacy_tip</span>
                <span>Politique de confidentialité</span>
                <span class="material-symbols-outlined">arrow_forward_ios</span>
              </a>
              <a href="/cookies" class="legal-link">
                <span class="material-symbols-outlined">cookie</span>
                <span>Politique des cookies</span>
                <span class="material-symbols-outlined">arrow_forward_ios</span>
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
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'Profile',
  components: {
    AuthModal,
    DinorIcon
  },
  setup() {
    const router = useRouter()
    const authStore = useAuthStore()
    const apiStore = useApiStore()

    // S'assurer que authStore est correctement initialisé
    if (!authStore) {
      console.error('❌ [Profile] AuthStore non initialisé')
      return {}
    }

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
    const predictionsFilter = ref('all')
    const predictionsFilterMini = ref('all')

    // Predictions sub-tabs
    const predictionsTabs = ref([
      { key: 'my-predictions', label: 'Mes prédictions', icon: 'sports_soccer' },
      { key: 'my-ranking', label: 'Mon classement', icon: 'leaderboard' },
      { key: 'active-tournaments', label: 'Tournois actifs', icon: 'emoji_events' }
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
      if (!authStore?.isAuthenticated) return

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
      if (!authStore?.isAuthenticated) return

      predictionsLoading.value = true
      try {
        console.log('🏆 [Profile] Chargement des données de pronostics...')
        
        // Check cache first
        const cacheKey = `dinor_predictions_${authStore.user?.id}`
        const cachedData = localStorage.getItem(cacheKey)
        
        if (cachedData) {
          try {
            const parsed = JSON.parse(cachedData)
            const now = Date.now()
            
            // Use cache if less than 5 minutes old
            if (now - parsed.timestamp < 5 * 60 * 1000) {
              userPredictionsStats.value = parsed.stats
              recentPredictions.value = parsed.recent
              userTournaments.value = parsed.tournaments
              predictionsLoading.value = false
              console.log('🏆 [Profile] Données chargées depuis le cache')
              return
            }
          } catch (e) {
            localStorage.removeItem(cacheKey)
          }
        }
        
        // Load user predictions stats, recent predictions and tournaments in parallel
        const [statsData, recentData, tournamentsData] = await Promise.all([
          apiStore.get('/leaderboard/my-stats'),
          apiStore.get('/predictions/my-recent?limit=5'),
          apiStore.get('/tournaments/my-tournaments')
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
        
        // Cache the data
        const cacheData = {
          timestamp: Date.now(),
          stats: userPredictionsStats.value,
          recent: recentPredictions.value,
          tournaments: userTournaments.value
        }
        localStorage.setItem(cacheKey, JSON.stringify(cacheData))
        
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
      if (!authStore?.isAuthenticated) return
      if (userAllPredictions.value.length > 0) return

      try {
        // Check cache first
        const cacheKey = `dinor_all_predictions_${authStore.user?.id}`
        const cachedData = localStorage.getItem(cacheKey)
        
        if (cachedData) {
          try {
            const parsed = JSON.parse(cachedData)
            const now = Date.now()
            
            // Use cache if less than 10 minutes old
            if (now - parsed.timestamp < 10 * 60 * 1000) {
              userAllPredictions.value = parsed.data
              console.log('🏆 [Profile] Toutes les prédictions chargées depuis le cache')
              return
            }
          } catch (e) {
            localStorage.removeItem(cacheKey)
          }
        }
        
        const data = await apiStore.get('/predictions')
        if (data.success) {
          userAllPredictions.value = data.data
          
          // Cache the data
          const cacheData = {
            timestamp: Date.now(),
            data: data.data
          }
          localStorage.setItem(cacheKey, JSON.stringify(cacheData))
        }
      } catch (error) {
        console.error('❌ [Profile] Erreur lors du chargement de toutes les prédictions:', error)
      }
    }

    const loadActiveTournaments = async () => {
      if (!authStore?.isAuthenticated) return

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
          // Update auth store with the new user data
          const updatedUser = { ...authStore.user, name: data.data.name }
          authStore.setUser(updatedUser)
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
        const data = await apiStore.post(`/tournaments/${tournament.id}/register`)
        if (data.success) {
          tournament.user_is_participant = true
          tournament.can_register = false
        }
      } catch (error) {
        console.error('❌ [Profile] Erreur inscription tournoi:', error)
      }
    }

    const goToPredictions = (tournament) => {
      console.log('🏆 [Profile] Aller aux prédictions:', tournament?.name || 'global')
      router.push('/predictions')
    }

    const goToLeaderboard = () => {
      console.log('🏆 [Profile] Aller au classement')
      // Pour l'instant, garder dans l'onglet ranking
      switchPredictionsTab('my-ranking')
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

    const getPointsClass = (points) => {
      if (points > 0) return 'points-positive'
      if (points === 0) return 'points-neutral'
      return 'points-negative'
    }

    const getTournamentStatusLabel = (status) => {
      const labels = {
        'registration_open': 'Inscriptions ouvertes',
        'registration_closed': 'Inscriptions fermées',
        'active': 'En cours',
        'finished': 'Terminé',
        'cancelled': 'Annulé'
      }
      return labels[status] || status
    }

    // Helper functions for predictions
    const formatRelativeTime = (date) => {
      const now = new Date()
      const predictionDate = new Date(date)
      const diffInHours = Math.floor((now - predictionDate) / (1000 * 60 * 60))
      
      if (diffInHours < 1) return 'Il y a moins d\'une heure'
      if (diffInHours < 24) return `Il y a ${diffInHours}h`
      if (diffInHours < 48) return 'Hier'
      
      const diffInDays = Math.floor(diffInHours / 24)
      if (diffInDays < 7) return `Il y a ${diffInDays} jour${diffInDays > 1 ? 's' : ''}`
      
      return formatDate(date)
    }
    
    const formatTime = (date) => {
      return new Date(date).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
    }
    
    const getFilteredRecentPredictions = () => {
      const predictions = recentPredictions.value.slice(0, 5)
      if (predictionsFilterMini.value === 'all') return predictions
      if (predictionsFilterMini.value === 'pending') return predictions.filter(p => !p.is_calculated)
      if (predictionsFilterMini.value === 'calculated') return predictions.filter(p => p.is_calculated)
      return predictions
    }
    
    const getPredictionsCountByStatus = (status) => {
      if (status === 'pending') return userAllPredictions.value.filter(p => !p.is_calculated).length
      if (status === 'calculated') return userAllPredictions.value.filter(p => p.is_calculated).length
      if (status === 'won') return userAllPredictions.value.filter(p => p.is_calculated && p.points_earned > 0).length
      return userAllPredictions.value.length
    }
    
    const getProgressPercentage = () => {
      if (!userPredictionsStats.value?.points_to_next_rank) return 0
      const currentPoints = userPredictionsStats.value.total_points || 0
      const pointsToNext = userPredictionsStats.value.points_to_next_rank || 100
      return Math.min(100, (currentPoints / (currentPoints + pointsToNext)) * 100)
    }
    
    // Computed for filtered predictions
    const filteredPredictions = computed(() => {
      if (!userAllPredictions.value.length) return []
      
      switch (predictionsFilter.value) {
        case 'calculated':
          return userAllPredictions.value.filter(p => p.is_calculated)
        case 'pending':
          return userAllPredictions.value.filter(p => !p.is_calculated)
        case 'won':
          return userAllPredictions.value.filter(p => p.is_calculated && p.points_earned > 0)
        default:
          return userAllPredictions.value
      }
    })
    
    const groupedPredictions = computed(() => {
      const groups = {}
      
      filteredPredictions.value.forEach(prediction => {
        const date = new Date(prediction.football_match.match_date)
        const dateKey = date.toLocaleDateString('fr-FR', { 
          weekday: 'long', 
          year: 'numeric', 
          month: 'long', 
          day: 'numeric' 
        })
        
        if (!groups[dateKey]) {
          groups[dateKey] = {
            date: dateKey,
            predictions: []
          }
        }
        
        groups[dateKey].predictions.push(prediction)
      })
      
      return Object.values(groups).sort((a, b) => {
        const dateA = new Date(a.predictions[0].football_match.match_date)
        const dateB = new Date(b.predictions[0].football_match.match_date)
        return dateB - dateA
      })
    })

    // Watch auth state changes
    watch(() => authStore?.isAuthenticated, (isAuth) => {
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
      if (section === 'predictions' && authStore?.isAuthenticated && !userPredictionsStats.value) {
        loadPredictionsData()
      }
    })

    onMounted(() => {
      if (authStore?.isAuthenticated) {
        loadFavorites()
        loadPredictionsData()
        // Initialize username form with current name
        usernameForm.value.name = authStore.user?.name || ''
        
        // Debug user data
        console.log('🔍 [Profile] Données utilisateur:', authStore.user)
        console.log('🔍 [Profile] Date création:', authStore.user?.created_at)
      }
      
      // Restore user preferences
      const savedFilter = localStorage.getItem('dinor_predictions_filter')
      const savedMiniFilter = localStorage.getItem('dinor_predictions_filter_mini')
      
      if (savedFilter) {
        predictionsFilter.value = savedFilter
      }
      
      if (savedMiniFilter) {
        predictionsFilterMini.value = savedMiniFilter
      }
    })

    return {
      authStore,
      
      // Main state
      loading,
      activeSection,
      showAuthModal,
      
      // Favorites
      favorites,
      selectedFilter,
      favoriteOptions: filterTabs, // Fix pour favoriteOptions manquant
      filteredFavorites,
      loadFavorites,
      removeFavorite,
      goToContent,
      profileSections,
      filterTabs,
      totalFavorites,
      favoritesStats,
      formatMemberSince,
      handleImageError,
      
      // Forms
      usernameForm,
      passwordForm,
      deletionForm,
      updateUsername,
      updatePassword,
      requestDataDeletion,
      handleLogout,
      openTournament,
      openTournamentModal,
      
      // Predictions
      predictionsLoading,
      userPredictionsStats,
      recentPredictions,
      userTournaments,
      predictionsTabs,
      activePredictionsTab,
      activeTournaments,
      userAllPredictions,
      predictionsFilter,
      predictionsFilterMini,
      formatRelativeTime,
      formatTime,
      getFilteredRecentPredictions,
      getPredictionsCountByStatus,
      getProgressPercentage,
      groupedPredictions,
      filteredPredictions,
      loadPredictionsData,
      loadAllUserPredictions,
      loadActiveTournaments,
      switchPredictionsTab,
      registerToTournament,
      goToPredictions,
      goToLeaderboard,
      getPointsClass,
      getTournamentStatusLabel,
      formatPrize,
      getRankClass,
      
      // Utilities
      formatDate,
      getTypeIcon,
      getDefaultImage,
      getShortDescription,
      getEmptyMessage,
      getEmptyDescription,
      getExploreLink
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
  background: #F1F5F9;
  border-radius: 16px;
  padding: 6px;
  margin-bottom: 32px;
  gap: 6px;
  border: 2px solid #E2E8F0;
}

.sub-tab {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  padding: 14px 20px;
  border: none;
  background: transparent;
  border-radius: 12px;
  font-size: 0.95rem;
  font-weight: 600;
  color: #64748B;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
}

.sub-tab.active {
  background: #FFFFFF;
  color: #E53E3E;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border: 2px solid #FCA5A5;
  transform: translateY(-1px);
}

.sub-tab:hover:not(.active) {
  background: rgba(229, 62, 62, 0.1);
  color: #E53E3E;
  transform: translateY(-1px);
}

.sub-tab .material-symbols-outlined {
  font-size: 20px;
  font-weight: 600;
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

.prediction-card.calculated:not(.positive-result):not(.negative-result) {
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

/* Predictions Dashboard Styles - Improved Readability */
.predictions-dashboard {
  .predictions-overview {
    margin-bottom: 2rem;

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
      gap: 1.25rem;
      margin-bottom: 1.5rem;

      .stat-card {
        background: #FFFFFF;
        border: 2px solid #E2E8F0;
        border-radius: 16px;
        padding: 1.25rem;
        display: flex;
        align-items: center;
        gap: 1rem;
        transition: all 0.3s ease;
        position: relative;

        &:hover {
          transform: translateY(-3px);
          box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
          border-color: #F4D03F;
        }

        &.total-predictions {
          .stat-icon {
            background: linear-gradient(135deg, #3B82F6, #2563EB);
            color: #FFFFFF;
          }
        }

        &.total-points {
          .stat-icon {
            background: linear-gradient(135deg, #F59E0B, #D97706);
            color: #FFFFFF;
          }
        }

        &.accuracy {
          .stat-icon {
            background: linear-gradient(135deg, #10B981, #059669);
            color: #FFFFFF;
          }
        }

        &.ranking {
          .stat-icon {
            background: linear-gradient(135deg, #8B5CF6, #7C3AED);
            color: #FFFFFF;
          }
        }

        .stat-icon {
          width: 48px;
          height: 48px;
          border-radius: 12px;
          display: flex;
          align-items: center;
          justify-content: center;
          flex-shrink: 0;

          .material-symbols-outlined {
            font-size: 24px;
            font-weight: 600;
          }
        }

        .stat-content {
          display: flex;
          flex-direction: column;
          min-width: 0;

          .stat-value {
            font-size: 1.75rem;
            font-weight: 700;
            color: #1F2937;
            line-height: 1.2;
            margin-bottom: 2px;
          }

          .stat-label {
            font-size: 0.875rem;
            color: #6B7280;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }
        }
      }
    }

    .quick-actions {
      display: flex;
      gap: 1rem;
      flex-wrap: wrap;

      .action-button {
        display: flex;
        align-items: center;
        gap: 0.75rem;
        padding: 1rem 1.5rem;
        border-radius: 12px;
        border: none;
        font-weight: 600;
        font-size: 0.9rem;
        cursor: pointer;
        transition: all 0.2s ease;
        flex: 1;
        min-width: 150px;
        justify-content: center;

        &.primary {
          background: linear-gradient(135deg, #E53E3E, #C53030);
          color: #FFFFFF;
          box-shadow: 0 4px 12px rgba(229, 62, 62, 0.3);

          &:hover {
            background: linear-gradient(135deg, #C53030, #9C1D1D);
            transform: translateY(-2px);
            box-shadow: 0 6px 16px rgba(229, 62, 62, 0.4);
          }
        }

        &.secondary {
          background: #F7FAFC;
          color: #2D3748;
          border: 2px solid #E2E8F0;

          &:hover {
            background: #EDF2F7;
            border-color: #CBD5E0;
            transform: translateY(-2px);
          }
        }

        .material-symbols-outlined {
          font-size: 1.25rem;
        }
      }
    }
  }

  .predictions-list {
    .prediction-card {
      background: #FFFFFF;
      border: 2px solid #E2E8F0;
      border-radius: 12px;
      padding: 1.25rem;
      margin-bottom: 1rem;
      transition: all 0.3s ease;
      position: relative;

      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.12);
        border-color: #CBD5E0;
      }

      &.calculated {
        background: linear-gradient(to right, #F0FDF4 0%, #FFFFFF 8%);
        
        &:not(.positive-result):not(.negative-result) {
          border-left: 4px solid #10B981;
        }
      }

      &.positive-result {
        border-left: 4px solid #10B981;
        background: linear-gradient(to right, #ECFDF5 0%, #FFFFFF 10%);
        
        .prediction-status-indicator {
          background: #D1FAE5;
          color: #065F46;
        }
      }

      &.negative-result {
        border-left: 4px solid #EF4444;
        background: linear-gradient(to right, #FEF2F2 0%, #FFFFFF 10%);
        
        .prediction-status-indicator {
          background: #FEE2E2;
          color: #DC2626;
        }
      }

      &.compact {
        padding: 1rem;

        .prediction-match {
          .teams {
            font-size: 0.95rem;
            font-weight: 600;
            color: #1F2937;
          }

          .match-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 0.9rem;
            margin-top: 0.5rem;

            .predicted-score {
              font-weight: 700;
              color: #E53E3E;
              font-size: 1rem;
            }

            .pending {
              color: #F59E0B;
              font-weight: 500;
              font-style: italic;
            }

            .points-earned {
              font-weight: 600;
              
              &.points-positive {
                color: #059669;
              }
            }
          }
        }

        .prediction-date {
          font-size: 0.8rem;
          color: #9CA3AF;
          margin-top: 0.5rem;
          text-align: right;
        }
      }

      &.detailed {
        .prediction-scores {
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
          margin-bottom: 1rem;

          .predicted, .actual {
            display: flex;
            align-items: center;
            gap: 0.75rem;

            .label {
              font-size: 0.875rem;
              color: #6B7280;
              font-weight: 500;
              min-width: 100px;
            }

            .score {
              font-weight: 700;
              color: #1F2937;
              font-size: 1.1rem;
              
              &.highlight {
                color: #E53E3E;
              }
            }
          }
        }
      }

      .prediction-match {
        .teams {
          display: flex;
          align-items: center;
          gap: 0.75rem;
          margin-bottom: 0.5rem;

          .team {
            font-weight: 600;
            font-size: 1rem;
            color: #1F2937;
            background: #F8FAFC;
            padding: 0.25rem 0.5rem;
            border-radius: 6px;
            border: 1px solid #E2E8F0;
          }

          .vs {
            color: #9CA3AF;
            font-size: 0.875rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }
        }

        .match-date {
          font-size: 0.875rem;
          color: #6B7280;
          font-weight: 500;
        }

        .match-info {
          display: flex;
          align-items: center;
          gap: 1rem;
          margin-top: 0.5rem;

          .predicted-score {
            font-size: 1.1rem;
            font-weight: 700;
            color: #E53E3E;
            background: #FEF2F2;
            padding: 0.25rem 0.5rem;
            border-radius: 6px;
            border: 1px solid #FCA5A5;
          }
        }
      }

      .prediction-status-indicator {
        position: absolute;
        top: 1rem;
        right: 1rem;
        width: 32px;
        height: 32px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #F3F4F6;
        border: 2px solid #E5E7EB;

        .material-symbols-outlined {
          font-size: 18px;
        }

        .pending-icon {
          color: #F59E0B;
        }
      }

      .points-earned {
        font-weight: 700;
        padding: 0.25rem 0.5rem;
        border-radius: 6px;
        font-size: 0.875rem;
        display: inline-flex;
        align-items: center;
        gap: 0.25rem;

        &.points-positive {
          color: #065F46;
          background: #D1FAE5;
          border: 1px solid #6EE7B7;
        }

        &.points-neutral {
          color: #6B7280;
          background: #F3F4F6;
          border: 1px solid #D1D5DB;
        }

        &.points-negative {
          color: #DC2626;
          background: #FEE2E2;
          border: 1px solid #FCA5A5;
        }

        .material-symbols-outlined {
          font-size: 16px;
        }
      }

      .pending {
        color: #F59E0B;
        font-style: italic;
        font-weight: 500;
        background: #FEF3C7;
        padding: 0.25rem 0.5rem;
        border-radius: 6px;
        border: 1px solid #FCD34D;
        font-size: 0.875rem;
        display: inline-flex;
        align-items: center;
        gap: 0.25rem;

        .material-symbols-outlined {
          font-size: 16px;
        }
      }
    }
  }

  .recent-predictions-preview {
    margin-bottom: 1.5rem;

    .show-all-btn {
      width: 100%;
      margin-top: 1rem;
    }
  }

  .predictions-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;

    .predictions-filters {
      .filter-select {
        padding: 0.5rem;
        border: 1px solid var(--md-sys-color-outline-variant);
        border-radius: 6px;
        background: var(--md-sys-color-surface);
        color: var(--md-sys-color-on-surface);
      }
    }
  }

  .my-rank-card {
    background: var(--md-sys-color-primary-container);
    border-radius: 12px;
    padding: 1.5rem;
    display: flex;
    align-items: center;
    gap: 1rem;
    margin-bottom: 1rem;

    .rank-badge {
      background: var(--md-sys-color-primary);
      color: var(--md-sys-color-on-primary);
      border-radius: 50%;
      width: 60px;
      height: 60px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.25rem;
      font-weight: 700;

      &.rank-gold {
        background: #FFD700;
        color: #1a1a1a;
      }

      &.rank-silver {
        background: #C0C0C0;
        color: #1a1a1a;
      }

      &.rank-bronze {
        background: #CD7F32;
        color: white;
      }
    }

    .rank-info {
      flex: 1;

      h4 {
        margin: 0 0 0.25rem 0;
        color: var(--md-sys-color-on-primary-container);
      }

      p {
        margin: 0 0 0.5rem 0;
        color: var(--md-sys-color-on-primary-container);
        opacity: 0.8;
      }

      .rank-change {
        display: flex;
        align-items: center;
        gap: 0.25rem;
        font-size: 0.875rem;

        &.positive {
          color: var(--md-sys-color-tertiary);
        }

        &.negative {
          color: var(--md-sys-color-error);
        }
      }
    }
  }

  .tournament-card {
    background: var(--md-sys-color-surface-variant);
    border-radius: 12px;
    padding: 1rem;
    margin-bottom: 1rem;

    .tournament-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 0.75rem;

      h4 {
        margin: 0;
        color: var(--md-sys-color-on-surface);
      }

      .tournament-status {
        padding: 0.25rem 0.5rem;
        border-radius: 6px;
        font-size: 0.75rem;
        font-weight: 500;

        &.registration_open {
          background: var(--md-sys-color-tertiary-container);
          color: var(--md-sys-color-on-tertiary-container);
        }

        &.active {
          background: var(--md-sys-color-primary-container);
          color: var(--md-sys-color-on-primary-container);
        }
      }
    }

    .tournament-info {
      display: flex;
      gap: 1rem;
      margin-bottom: 1rem;

      .prize, .participants {
        display: flex;
        align-items: center;
        gap: 0.25rem;
        font-size: 0.875rem;
        color: var(--md-sys-color-on-surface-variant);

        .material-symbols-outlined {
          font-size: 1rem;
        }
      }
    }

    .tournament-actions {
      display: flex;
      gap: 0.5rem;
    }
  }

  .empty-predictions, .empty-tournaments {
    text-align: center;
    padding: 2rem;

    .empty-icon {
      .material-symbols-outlined {
        font-size: 3rem;
        color: var(--md-sys-color-on-surface-variant);
        opacity: 0.5;
      }
    }

    h3, h4 {
      margin: 1rem 0 0.5rem 0;
      color: var(--md-sys-color-on-surface);
    }

    p {
      color: var(--md-sys-color-on-surface-variant);
      margin-bottom: 1.5rem;
    }
  }

  .subsection-title {
    font-size: 1.125rem;
    font-weight: 600;
    color: var(--md-sys-color-on-surface);
    margin: 0 0 1rem 0;
  }
}

/* === PREDICTIONS ENHANCEMENTS === */

/* Predictions Statistics Overview */
.predictions-stats-overview {
  margin-bottom: 32px;
  background: #FAFBFC;
  border-radius: 16px;
  padding: 24px;
  border: 2px solid #F1F5F9;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 16px;
  margin-bottom: 20px;
}

.stat-card {
  background: #FFFFFF;
  border: 2px solid #E2E8F0;
  border-radius: 16px;
  padding: 20px;
  text-align: center;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, #E53E3E, #F56565);
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: #F4D03F;
}

.stat-card:hover::before {
  transform: scaleX(1);
}

.stat-icon {
  width: 48px;
  height: 48px;
  background: #F7FAFC;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 12px auto;
  color: #4A5568;
  border: 2px solid #E2E8F0;
}

.stat-icon.accuracy {
  background: linear-gradient(135deg, #D1FAE5, #A7F3D0);
  color: #059669;
  border-color: #6EE7B7;
}

.stat-icon.points {
  background: linear-gradient(135deg, #FEF3C7, #FDE68A);
  color: #D97706;
  border-color: #FCD34D;
}

.stat-icon.ranking {
  background: linear-gradient(135deg, #E0E7FF, #C7D2FE);
  color: #7C3AED;
  border-color: #A5B4FC;
}

.stat-value {
  display: block;
  font-size: 1.75rem;
  font-weight: 800;
  color: #1F2937;
  margin-bottom: 4px;
  line-height: 1.2;
}

.stat-label {
  font-size: 0.875rem;
  color: #6B7280;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* Section Headers with Actions */
.section-header-with-action {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 2px solid #F1F5F9;
}

.subsection-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 1.25rem;
  font-weight: 700;
  color: #1F2937;
  margin: 0;
}

.subsection-title .material-symbols-outlined {
  font-size: 24px;
  color: #E53E3E;
  background: #FEF2F2;
  padding: 4px;
  border-radius: 8px;
}

/* Mini Filter Buttons */
.predictions-filter-mini {
  display: flex;
  gap: 6px;
}

.filter-btn {
  padding: 8px 16px;
  background: #FFFFFF;
  border: 2px solid #E2E8F0;
  border-radius: 24px;
  font-size: 0.875rem;
  font-weight: 600;
  color: #64748B;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  text-transform: capitalize;
}

.filter-btn.active {
  background: #E53E3E;
  color: #FFFFFF;
  border-color: #E53E3E;
  box-shadow: 0 4px 12px rgba(229, 62, 62, 0.3);
  transform: translateY(-1px);
}

.filter-btn:hover:not(.active) {
  background: #F8FAFC;
  border-color: #CBD5E0;
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

/* Enhanced Prediction Cards */
.prediction-card {
  position: relative;
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 12px;
  transition: all 0.2s ease;
}

.prediction-card:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.prediction-card.positive-result {
  border-left: 4px solid #38A169;
  background: linear-gradient(to right, #F0FFF4, #FFFFFF);
}

.prediction-card.negative-result {
  border-left: 4px solid #E53E3E;
  background: linear-gradient(to right, #FFF5F5, #FFFFFF);
}

.prediction-status-indicator {
  position: absolute;
  top: 12px;
  right: 12px;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.prediction-status-indicator .material-symbols-outlined {
  font-size: 16px;
}

.prediction-card.positive-result .prediction-status-indicator .material-symbols-outlined {
  color: #38A169;
}

.prediction-card.negative-result .prediction-status-indicator .material-symbols-outlined {
  color: #E53E3E;
}

.pending-icon {
  color: #F6AD55 !important;
}

.prediction-date {
  font-size: 11px;
  color: #718096;
  margin-top: 8px;
  text-align: right;
}

/* Filter Chips */
.filter-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.filter-chip {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  background: #F7FAFC;
  border: 1px solid #E2E8F0;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
  color: #4A5568;
  cursor: pointer;
  transition: all 0.2s ease;
}

.filter-chip.active {
  background: #E53E3E;
  color: #FFFFFF;
  border-color: #E53E3E;
}

.filter-chip:hover:not(.active) {
  background: #EDF2F7;
}

.filter-chip .material-symbols-outlined {
  font-size: 14px;
}

/* Grouped Predictions */
.predictions-list.grouped {
  margin-top: 16px;
}

.predictions-group {
  margin-bottom: 24px;
}

.group-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
  background: #F7FAFC;
  border-radius: 8px;
  margin-bottom: 8px;
}

.group-date {
  font-size: 14px;
  font-weight: 600;
  color: #1A202C;
  text-transform: capitalize;
}

.group-count {
  font-size: 12px;
  color: #718096;
}

.group-predictions {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

/* Enhanced Ranking Card */
.my-rank-card.enhanced {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #FFFFFF;
  border: none;
  padding: 24px;
  border-radius: 16px;
  margin-bottom: 24px;
}

.my-rank-card.enhanced .rank-badge {
  background: rgba(255, 255, 255, 0.2);
  border: 2px solid rgba(255, 255, 255, 0.3);
  color: #FFFFFF;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border-radius: 12px;
}

.rank-number {
  font-size: 20px;
  font-weight: 700;
}

.rank-stats {
  display: flex;
  gap: 16px;
  margin: 12px 0;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 14px;
}

.stat-item .material-symbols-outlined {
  font-size: 16px;
}

/* Progress Card */
.progress-card {
  background: #FFFFFF;
  border: 1px solid #E2E8F0;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
}

.progress-card h4 {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: 600;
  color: #1A202C;
}

.progress-info {
  font-size: 14px;
  color: #4A5568;
  margin-bottom: 8px;
}

.progress-bar {
  height: 8px;
  background: #E2E8F0;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #38A169, #48BB78);
  transition: width 0.3s ease;
}

/* Ranking Actions */
.ranking-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
}

.ranking-actions .btn-primary,
.ranking-actions .btn-secondary {
  flex: 1;
  min-width: 140px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
}

/* Enhanced Empty State */
.empty-predictions {
  text-align: center;
  padding: 48px 16px;
}

.empty-illustration {
  position: relative;
  display: inline-block;
  margin-bottom: 24px;
}

.empty-icon {
  width: 80px;
  height: 80px;
  background: #F7FAFC;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
}

.empty-icon .material-symbols-outlined {
  font-size: 40px;
  color: #A0AEC0;
}

.empty-pattern {
  position: absolute;
  top: -10px;
  right: -10px;
  width: 20px;
  height: 20px;
  background: #E53E3E;
  border-radius: 50%;
  opacity: 0.3;
}

.empty-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
  margin-top: 24px;
}

.empty-actions .btn-primary,
.empty-actions .btn-secondary {
  display: flex;
  align-items: center;
  gap: 6px;
}

/* Show All Button */
.show-all-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 24px;
  padding: 12px 24px;
  background: #F8FAFC;
  border: 2px solid #E2E8F0;
  border-radius: 12px;
  font-size: 0.95rem;
  font-weight: 600;
  color: #475569;
  cursor: pointer;
  transition: all 0.3s ease;
}

.show-all-btn:hover {
  background: #FFFFFF;
  border-color: #E53E3E;
  color: #E53E3E;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.show-all-btn .material-symbols-outlined {
  font-size: 20px;
}

/* Responsive Design */
@media (max-width: 768px) {
  .predictions-dashboard {
    .predictions-overview {
      .stats-grid {
        grid-template-columns: 1fr;
        gap: 12px;
      }
      
      .stat-card {
        padding: 16px;
        
        .stat-icon {
          width: 40px;
          height: 40px;
        }
        
        .stat-value {
          font-size: 1.5rem;
        }
      }
      
      .quick-actions {
        flex-direction: column;
        gap: 12px;
        
        .action-button {
          min-width: unset;
          padding: 12px 16px;
        }
      }
    }
  }
  
  .sub-tabs {
    flex-direction: column;
    gap: 4px;
    
    .sub-tab {
      padding: 12px 16px;
      font-size: 0.9rem;
    }
  }
  
  .section-header-with-action {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;
    
    .subsection-title {
      font-size: 1.125rem;
    }
    
    .predictions-filter-mini {
      width: 100%;
      justify-content: flex-start;
    }
  }
  
  .predictions-stats-overview {
    padding: 16px;
    
    .stats-grid {
      grid-template-columns: repeat(2, 1fr);
      gap: 12px;
    }
  }
  
  .prediction-card {
    &.compact {
      padding: 12px;
      
      .prediction-match {
        .teams {
          font-size: 0.9rem;
          flex-wrap: wrap;
          
          .team {
            padding: 0.2rem 0.4rem;
            font-size: 0.85rem;
          }
        }
        
        .match-info {
          margin-top: 8px;
          
          .predicted-score {
            font-size: 0.95rem;
            padding: 0.2rem 0.4rem;
          }
        }
      }
      
      .prediction-status-indicator {
        width: 28px;
        height: 28px;
        top: 8px;
        right: 8px;
        
        .material-symbols-outlined {
          font-size: 16px;
        }
      }
    }
  }
  
  .show-all-btn {
    padding: 10px 20px;
    font-size: 0.9rem;
  }
  
  .filter-chips {
    flex-wrap: wrap;
  }
  
  .rank-stats {
    flex-direction: column;
    gap: 8px;
  }
  
  .ranking-actions {
    flex-direction: column;
  }
  
  .empty-actions {
    flex-direction: column;
  }
}

@media (max-width: 480px) {
  .predictions-dashboard {
    .predictions-overview {
      .stats-grid {
        grid-template-columns: 1fr;
      }
    }
  }
  
  .predictions-stats-overview {
    .stats-grid {
      grid-template-columns: 1fr;
    }
  }
  
  .prediction-card {
    &.compact {
      .prediction-match {
        .teams {
          .team {
            font-size: 0.8rem;
          }
          
          .vs {
            font-size: 0.75rem;
          }
        }
      }
    }
  }
}

</style>