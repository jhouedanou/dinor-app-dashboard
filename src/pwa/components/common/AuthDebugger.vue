<template>
  <div class="auth-debugger" v-if="showDebugger">
    <div class="debug-header">
      <h3>🔍 Auth Debugger</h3>
      <button @click="toggleDebugger" class="close-btn">✕</button>
    </div>
    
    <div class="debug-content">
      <div class="debug-section">
        <h4>🏪 Auth Store</h4>
        <div class="debug-item">
          <span class="label">isAuthenticated:</span>
          <span class="value" :class="{ success: authStore.isAuthenticated, error: !authStore.isAuthenticated }">
            {{ authStore.isAuthenticated }}
          </span>
        </div>
        <div class="debug-item">
          <span class="label">user:</span>
          <span class="value">{{ authStore.user ? authStore.user.name : 'null' }}</span>
        </div>
        <div class="debug-item">
          <span class="label">token:</span>
          <span class="value">{{ authStore.token ? '***existe***' : 'null' }}</span>
        </div>
      </div>

      <div class="debug-section">
        <h4>💾 LocalStorage</h4>
        <div class="debug-item">
          <span class="label">auth_token:</span>
          <span class="value">{{ localToken ? '***existe***' : 'null' }}</span>
        </div>
        <div class="debug-item">
          <span class="label">auth_user:</span>
          <span class="value">{{ localUser ? localUser.substring(0, 50) + '...' : 'null' }}</span>
        </div>
      </div>

      <div class="debug-section">
        <h4>🎯 Props AppHeader</h4>
        <div class="debug-item">
          <span class="label">showFavorite:</span>
          <span class="value">{{ showFavorite }}</span>
        </div>
        <div class="debug-item">
          <span class="label">favoriteType:</span>
          <span class="value">{{ favoriteType }}</span>
        </div>
        <div class="debug-item">
          <span class="label">favoriteItemId:</span>
          <span class="value">{{ favoriteItemId }}</span>
        </div>
      </div>

      <div class="debug-actions">
        <button @click="refreshAuth" class="debug-btn">🔄 Actualiser Auth</button>
        <button @click="testFavorite" class="debug-btn">🌟 Test Favori</button>
        <button @click="clearAuth" class="debug-btn danger">🗑️ Clear Auth</button>
      </div>
    </div>
  </div>
  
  <!-- Toggle Button -->
  <button v-else @click="toggleDebugger" class="debug-toggle">
    🔍 Debug Auth
  </button>
</template>

<script>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useAuthStore } from '@/stores/auth'

export default {
  name: 'AuthDebugger',
  props: {
    showFavorite: Boolean,
    favoriteType: String,
    favoriteItemId: [String, Number]
  },
  setup(props) {
    const authStore = useAuthStore()
    const showDebugger = ref(false)
    
    // Variables réactives pour localStorage
    const localToken = ref(localStorage.getItem('auth_token'))
    const localUser = ref(localStorage.getItem('auth_user'))
    
    // Mettre à jour localStorage régulièrement
    const updateLocalStorage = () => {
      localToken.value = localStorage.getItem('auth_token')
      localUser.value = localStorage.getItem('auth_user')
    }
    
    const toggleDebugger = () => {
      showDebugger.value = !showDebugger.value
      if (showDebugger.value) {
        updateLocalStorage()
      }
    }
    
    const refreshAuth = async () => {
      console.log('🔄 [AuthDebugger] Actualisation auth store...')
      authStore.initAuth()
      updateLocalStorage()
      
      // Essayer de récupérer le profil
      try {
        await authStore.getProfile()
        console.log('✅ [AuthDebugger] Profil récupéré')
      } catch (error) {
        console.error('❌ [AuthDebugger] Erreur profil:', error)
      }
    }
    
    const testFavorite = () => {
      console.log('🌟 [AuthDebugger] Test des conditions pour favoris:')
      console.log({
        isAuthenticated: authStore.isAuthenticated,
        favoriteType: props.favoriteType,
        favoriteItemId: props.favoriteItemId,
        canInteract: authStore.isAuthenticated && props.favoriteType && props.favoriteItemId
      })
    }
    
    const clearAuth = () => {
      if (confirm('Êtes-vous sûr de vouloir vider l\'authentification ?')) {
        authStore.clearAuth()
        updateLocalStorage()
        console.log('🗑️ [AuthDebugger] Auth vidée')
      }
    }
    
    // Intervalle pour mettre à jour localStorage
    let interval = null
    
    onMounted(() => {
      interval = setInterval(updateLocalStorage, 1000)
    })
    
    onUnmounted(() => {
      if (interval) {
        clearInterval(interval)
      }
    })
    
    return {
      authStore,
      showDebugger,
      localToken,
      localUser,
      toggleDebugger,
      refreshAuth,
      testFavorite,
      clearAuth
    }
  }
}
</script>

<style scoped>
.auth-debugger {
  position: fixed;
  top: 20px;
  right: 20px;
  width: 350px;
  background: white;
  border: 2px solid #E1251B;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  z-index: 9999;
  font-family: 'Courier New', monospace;
  font-size: 12px;
}

.debug-header {
  background: #E1251B;
  color: white;
  padding: 8px 12px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.debug-header h3 {
  margin: 0;
  font-size: 14px;
}

.close-btn {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  font-size: 16px;
  padding: 0;
  width: 20px;
  height: 20px;
}

.debug-content {
  padding: 12px;
  max-height: 400px;
  overflow-y: auto;
}

.debug-section {
  margin-bottom: 12px;
  border-bottom: 1px solid #eee;
  padding-bottom: 8px;
}

.debug-section h4 {
  margin: 0 0 6px 0;
  font-size: 12px;
  color: #E1251B;
}

.debug-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
  font-size: 11px;
}

.label {
  font-weight: bold;
  color: #666;
}

.value {
  color: #333;
  word-break: break-all;
  max-width: 200px;
}

.value.success {
  color: #28a745;
  font-weight: bold;
}

.value.error {
  color: #dc3545;
  font-weight: bold;
}

.debug-actions {
  display: flex;
  gap: 4px;
  flex-wrap: wrap;
}

.debug-btn {
  background: #E1251B;
  color: white;
  border: none;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 10px;
  transition: background 0.2s;
}

.debug-btn:hover {
  background: #c1201a;
}

.debug-btn.danger {
  background: #dc3545;
}

.debug-btn.danger:hover {
  background: #c82333;
}

.debug-toggle {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: #E1251B;
  color: white;
  border: none;
  padding: 8px 12px;
  border-radius: 20px;
  cursor: pointer;
  font-size: 12px;
  z-index: 9999;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.debug-toggle:hover {
  background: #c1201a;
}
</style> 