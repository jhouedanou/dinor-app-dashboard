<template>
  <div class="analytics-widget">
    <!-- En-tête du widget -->
    <div class="widget-header">
      <h3 class="widget-title">
        <DinorIcon name="bar-chart" :size="20" />
        Statistiques d'utilisation
      </h3>
      <div class="widget-actions">
        <button @click="refreshData" :disabled="loading" class="refresh-btn">
          <DinorIcon name="refresh" :size="16" :class="{ 'spinning': loading }" />
        </button>
        <select v-model="selectedPeriod" @change="loadData" class="period-select">
          <option value="1d">24h</option>
          <option value="7d">7 jours</option>
          <option value="30d">30 jours</option>
        </select>
      </div>
    </div>

    <!-- État de chargement -->
    <div v-if="loading" class="loading-state">
      <div class="loader"></div>
      <p>Chargement des statistiques...</p>
    </div>

    <!-- État d'erreur -->
    <div v-else-if="error" class="error-state">
      <DinorIcon name="alert-circle" :size="24" />
      <p>{{ error }}</p>
      <button @click="loadData" class="retry-btn">Réessayer</button>
    </div>

    <!-- Contenu principal -->
    <div v-else class="widget-content">
      <!-- Métriques principales -->
      <div class="metrics-grid">
        <div class="metric-card">
          <div class="metric-icon users">
            <DinorIcon name="users" :size="24" />
          </div>
          <div class="metric-info">
            <span class="metric-value">{{ formatNumber(data.total_users || 0) }}</span>
            <span class="metric-label">Utilisateurs actifs</span>
          </div>
        </div>

        <div class="metric-card">
          <div class="metric-icon sessions">
            <DinorIcon name="activity" :size="24" />
          </div>
          <div class="metric-info">
            <span class="metric-value">{{ formatNumber(data.total_sessions || 0) }}</span>
            <span class="metric-label">Sessions</span>
          </div>
        </div>

        <div class="metric-card">
          <div class="metric-icon views">
            <DinorIcon name="eye" :size="24" />
          </div>
          <div class="metric-info">
            <span class="metric-value">{{ formatNumber(data.page_views || 0) }}</span>
            <span class="metric-label">Pages vues</span>
          </div>
        </div>

        <div class="metric-card">
          <div class="metric-icon engagement">
            <DinorIcon name="heart" :size="24" />
          </div>
          <div class="metric-info">
            <span class="metric-value">{{ formatDuration(data.avg_session_duration || 0) }}</span>
            <span class="metric-label">Durée moyenne</span>
          </div>
        </div>
      </div>

      <!-- Graphique d'activité -->
      <div class="activity-chart">
        <h4>Activité par heure</h4>
        <div class="chart-container">
          <div
            v-for="(hour, index) in hourlyActivity"
            :key="index"
            class="chart-bar"
            :style="{ height: `${(hour.events / maxHourlyActivity) * 100}%` }"
            :title="`${hour.hour}h: ${hour.events} événements`"
          >
            <span class="bar-value">{{ hour.events }}</span>
          </div>
        </div>
        <div class="chart-labels">
          <span v-for="hour in 24" :key="hour" class="hour-label">{{ hour - 1 }}</span>
        </div>
      </div>

      <!-- Top événements -->
      <div class="top-events">
        <h4>Événements populaires</h4>
        <div class="events-list">
          <div
            v-for="event in topEvents"
            :key="event.event_type"
            class="event-item"
          >
            <span class="event-name">{{ formatEventName(event.event_type) }}</span>
            <span class="event-count">{{ formatNumber(event.count) }}</span>
            <div
              class="event-bar"
              :style="{ width: `${(event.count / maxEventCount) * 100}%` }"
            ></div>
          </div>
        </div>
      </div>

      <!-- Pages populaires -->
      <div class="top-pages">
        <h4>Pages populaires</h4>
        <div class="pages-list">
          <div
            v-for="page in topPages"
            :key="page.page_path"
            class="page-item"
          >
            <span class="page-path">{{ page.page_path }}</span>
            <span class="page-views">{{ formatNumber(page.views) }} vues</span>
          </div>
        </div>
      </div>

      <!-- Répartition des appareils -->
      <div class="device-breakdown">
        <h4>Répartition des appareils</h4>
        <div class="device-chart">
          <div class="device-item" v-for="device in deviceBreakdown" :key="device.type">
            <div class="device-info">
              <DinorIcon :name="getDeviceIcon(device.type)" :size="16" />
              <span>{{ device.type }}</span>
            </div>
            <div class="device-percentage">{{ device.percentage }}%</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Pied du widget -->
    <div class="widget-footer">
      <span class="last-updated">
        Mis à jour: {{ formatDate(lastUpdated) }}
      </span>
      <button @click="exportData" class="export-btn">
        <DinorIcon name="download" :size="16" />
        Exporter
      </button>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import { useAnalytics } from '@/composables/useAnalytics'
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'AnalyticsWidget',
  components: {
    DinorIcon
  },
  setup() {
    const loading = ref(false)
    const error = ref(null)
    const data = ref({})
    const selectedPeriod = ref('7d')
    const lastUpdated = ref(null)
    const { trackClick } = useAnalytics()

    // Données calculées
    const hourlyActivity = computed(() => data.value.hourly_activity || [])
    const topEvents = computed(() => (data.value.top_events || []).slice(0, 5))
    const topPages = computed(() => (data.value.top_pages || []).slice(0, 5))
    const deviceBreakdown = computed(() => {
      const devices = data.value.device_breakdown || []
      return devices.map(device => ({
        type: device.is_mobile ? 'Mobile' : 'Desktop',
        count: device.count,
        percentage: Math.round((device.count / devices.reduce((sum, d) => sum + d.count, 0)) * 100)
      }))
    })

    const maxHourlyActivity = computed(() => {
      return Math.max(...hourlyActivity.value.map(h => h.events), 1)
    })

    const maxEventCount = computed(() => {
      return Math.max(...topEvents.value.map(e => e.count), 1)
    })

    // Charger les données
    const loadData = async () => {
      loading.value = true
      error.value = null

      try {
        const response = await fetch(`/api/analytics/metrics?period=${selectedPeriod.value}`, {
          headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest'
          }
        })

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}`)
        }

        const result = await response.json()
        if (result.success) {
          data.value = result.data
          lastUpdated.value = new Date()
        } else {
          throw new Error(result.message || 'Erreur de chargement')
        }
      } catch (err) {
        console.error('Erreur lors du chargement des analytics:', err)
        error.value = 'Impossible de charger les statistiques'
        
        // Utiliser des données simulées en fallback
        data.value = generateMockData()
        lastUpdated.value = new Date()
      } finally {
        loading.value = false
      }
    }

    // Actualiser les données
    const refreshData = () => {
      trackClick('analytics_refresh', 'analytics')
      loadData()
    }

    // Exporter les données
    const exportData = () => {
      trackClick('analytics_export', 'analytics')
      
      const csvContent = generateCSVContent()
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
      const link = document.createElement('a')
      
      if (link.download !== undefined) {
        const url = URL.createObjectURL(blob)
        link.setAttribute('href', url)
        link.setAttribute('download', `analytics_${selectedPeriod.value}_${new Date().toISOString().split('T')[0]}.csv`)
        link.style.visibility = 'hidden'
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
      }
    }

    // Fonctions utilitaires
    const formatNumber = (num) => {
      if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M'
      if (num >= 1000) return (num / 1000).toFixed(1) + 'k'
      return num.toString()
    }

    const formatDuration = (minutes) => {
      if (minutes < 1) return Math.round(minutes * 60) + 's'
      if (minutes < 60) return Math.round(minutes) + 'min'
      return Math.round(minutes / 60) + 'h'
    }

    const formatDate = (date) => {
      if (!date) return 'Jamais'
      return new Intl.DateTimeFormat('fr-FR', {
        day: '2-digit',
        month: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      }).format(date)
    }

    const formatEventName = (eventType) => {
      const names = {
        'page_view': 'Page vue',
        'content_interaction': 'Interaction contenu',
        'navigation': 'Navigation',
        'element_click': 'Clic élément',
        'form_submit': 'Soumission formulaire',
        'search': 'Recherche',
        'social_interaction': 'Partage social'
      }
      return names[eventType] || eventType
    }

    const getDeviceIcon = (deviceType) => {
      const icons = {
        'Mobile': 'smartphone',
        'Desktop': 'computer',
        'Tablet': 'tablet'
      }
      return icons[deviceType] || 'monitor'
    }

    const generateCSVContent = () => {
      let csv = 'Type,Valeur,Période\n'
      csv += `Utilisateurs actifs,${data.value.total_users || 0},${selectedPeriod.value}\n`
      csv += `Sessions,${data.value.total_sessions || 0},${selectedPeriod.value}\n`
      csv += `Pages vues,${data.value.page_views || 0},${selectedPeriod.value}\n`
      csv += `Durée moyenne session,${data.value.avg_session_duration || 0},${selectedPeriod.value}\n`
      return csv
    }

    const generateMockData = () => ({
      total_users: Math.floor(Math.random() * 1000) + 500,
      total_sessions: Math.floor(Math.random() * 2000) + 1000,
      page_views: Math.floor(Math.random() * 5000) + 2000,
      avg_session_duration: Math.random() * 10 + 3,
      hourly_activity: Array.from({ length: 24 }, (_, i) => ({
        hour: i,
        events: Math.floor(Math.random() * 100) + 10
      })),
      top_events: [
        { event_type: 'page_view', count: Math.floor(Math.random() * 500) + 200 },
        { event_type: 'element_click', count: Math.floor(Math.random() * 300) + 100 },
        { event_type: 'navigation', count: Math.floor(Math.random() * 200) + 80 },
        { event_type: 'content_interaction', count: Math.floor(Math.random() * 150) + 50 },
        { event_type: 'search', count: Math.floor(Math.random() * 100) + 30 }
      ],
      top_pages: [
        { page_path: '/', views: Math.floor(Math.random() * 500) + 200 },
        { page_path: '/recipes', views: Math.floor(Math.random() * 300) + 150 },
        { page_path: '/tips', views: Math.floor(Math.random() * 200) + 100 },
        { page_path: '/events', views: Math.floor(Math.random() * 150) + 75 },
        { page_path: '/profile', views: Math.floor(Math.random() * 100) + 50 }
      ],
      device_breakdown: [
        { is_mobile: true, count: Math.floor(Math.random() * 300) + 200 },
        { is_mobile: false, count: Math.floor(Math.random() * 200) + 100 }
      ]
    })

    // Watchers
    watch(selectedPeriod, loadData)

    // Lifecycle
    onMounted(() => {
      loadData()
      
      // Actualisation automatique toutes les 5 minutes
      setInterval(() => {
        if (!loading.value) {
          loadData()
        }
      }, 5 * 60 * 1000)
    })

    return {
      loading,
      error,
      data,
      selectedPeriod,
      lastUpdated,
      hourlyActivity,
      topEvents,
      topPages,
      deviceBreakdown,
      maxHourlyActivity,
      maxEventCount,
      loadData,
      refreshData,
      exportData,
      formatNumber,
      formatDuration,
      formatDate,
      formatEventName,
      getDeviceIcon
    }
  }
}
</script>

<style scoped>
.analytics-widget {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.widget-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.widget-title {
  font-size: 18px;
  font-weight: 600;
  color: #2c3e50;
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 0;
}

.widget-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.refresh-btn {
  padding: 8px;
  background: none;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
}

.refresh-btn:hover {
  background: #e9ecef;
}

.refresh-btn:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.spinning {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.period-select {
  padding: 8px 12px;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  background: white;
  cursor: pointer;
}

.loading-state, .error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px;
  text-align: center;
}

.loader {
  width: 32px;
  height: 32px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #FF6B35;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

.error-state {
  color: #dc3545;
}

.retry-btn {
  margin-top: 12px;
  padding: 8px 16px;
  background: #FF6B35;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}

.widget-content {
  padding: 20px;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.metric-card {
  display: flex;
  align-items: center;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
  gap: 12px;
}

.metric-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.metric-icon.users { background: #007bff; }
.metric-icon.sessions { background: #28a745; }
.metric-icon.views { background: #ffc107; color: #333; }
.metric-icon.engagement { background: #dc3545; }

.metric-info {
  display: flex;
  flex-direction: column;
}

.metric-value {
  font-size: 24px;
  font-weight: bold;
  color: #2c3e50;
}

.metric-label {
  font-size: 14px;
  color: #6c757d;
}

.activity-chart, .top-events, .top-pages, .device-breakdown {
  margin-bottom: 24px;
}

.activity-chart h4, .top-events h4, .top-pages h4, .device-breakdown h4 {
  margin: 0 0 12px 0;
  font-size: 16px;
  font-weight: 600;
  color: #2c3e50;
}

.chart-container {
  display: flex;
  align-items: end;
  height: 120px;
  gap: 2px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
  margin-bottom: 8px;
}

.chart-bar {
  flex: 1;
  background: #FF6B35;
  border-radius: 2px 2px 0 0;
  position: relative;
  min-height: 4px;
  display: flex;
  align-items: end;
  justify-content: center;
  cursor: pointer;
  transition: opacity 0.2s;
}

.chart-bar:hover {
  opacity: 0.8;
}

.bar-value {
  font-size: 10px;
  color: white;
  margin-bottom: 2px;
  font-weight: 500;
}

.chart-labels {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #6c757d;
  padding: 0 16px;
}

.events-list, .pages-list {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 16px;
}

.event-item, .page-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
  border-bottom: 1px solid #e9ecef;
  position: relative;
}

.event-item:last-child, .page-item:last-child {
  border-bottom: none;
}

.event-bar {
  position: absolute;
  left: 0;
  bottom: 0;
  height: 2px;
  background: #FF6B35;
  opacity: 0.6;
}

.event-name, .page-path {
  font-weight: 500;
  color: #2c3e50;
}

.event-count, .page-views {
  font-size: 14px;
  color: #6c757d;
}

.device-chart {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 16px;
}

.device-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 0;
}

.device-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.device-percentage {
  font-weight: 600;
  color: #FF6B35;
}

.widget-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.last-updated {
  font-size: 12px;
  color: #6c757d;
}

.export-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px;
  background: #FF6B35;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.2s;
}

.export-btn:hover {
  background: #e85d2a;
}

@media (max-width: 768px) {
  .widget-header {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
  }
  
  .widget-actions {
    justify-content: space-between;
  }
  
  .metrics-grid {
    grid-template-columns: 1fr;
  }
  
  .chart-labels {
    font-size: 10px;
  }
  
  .chart-labels .hour-label:nth-child(even) {
    display: none;
  }
}
</style>