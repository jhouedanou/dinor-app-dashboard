<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="modelValue" class="auth-modal-overlay" @click="handleOverlayClick">
        <div class="auth-modal" @click.stop>
          <div class="auth-modal-header">
            <h3>{{ isLogin ? 'Connexion' : 'Inscription' }}</h3>
            <button class="close-btn" @click="close" aria-label="Fermer">
              <LucideX :size="20" />
            </button>
          </div>
          
          <div class="auth-modal-content">
            <!-- Messages d'erreur et d'information -->
            <div v-if="errorMessage" class="error-message" :class="{ 'info-message': isInfoMessage }">
              {{ errorMessage }}
              <div v-if="showCreateAccountSuggestion" class="create-account-suggestion">
                <p>Ce compte n'existe pas encore.</p>
                <button @click="switchToRegister" class="create-account-btn">
                  Créer un compte maintenant
                </button>
              </div>
            </div>
            
            <!-- Formulaire de connexion -->
            <form v-if="isLogin" @submit.prevent="handleLogin" class="auth-form">
              <div class="form-group">
                <label for="email">Email</label>
                <input 
                  id="email"
                  v-model="loginForm.email" 
                  type="email" 
                  required
                  :disabled="authStore.loading"
                  class="form-input"
                  placeholder="votre@email.com"
                >
              </div>
              
              <div class="form-group">
                <label for="password">Mot de passe</label>
                <input 
                  id="password"
                  v-model="loginForm.password" 
                  type="password" 
                  required
                  :disabled="authStore.loading"
                  class="form-input"
                  placeholder="Votre mot de passe"
                >
              </div>
              
              <button 
                type="submit" 
                :disabled="authStore.loading"
                class="submit-btn"
              >
                {{ authStore.loading ? 'Connexion...' : 'Se connecter' }}
              </button>
            </form>
            
            <!-- Formulaire d'inscription -->
            <form v-else @submit.prevent="handleRegister" class="auth-form">
              <div class="form-group">
                <label for="name">Nom</label>
                <input 
                  id="name"
                  v-model="registerForm.name" 
                  type="text" 
                  required
                  :disabled="authStore.loading"
                  class="form-input"
                  placeholder="Votre nom"
                >
              </div>
              
              <div class="form-group">
                <label for="register-email">Email</label>
                <input 
                  id="register-email"
                  v-model="registerForm.email" 
                  type="email" 
                  required
                  :disabled="authStore.loading"
                  class="form-input"
                  placeholder="votre@email.com"
                >
              </div>
              
              <div class="form-group">
                <label for="register-password">Mot de passe</label>
                <input 
                  id="register-password"
                  v-model="registerForm.password" 
                  type="password" 
                  required
                  :disabled="authStore.loading"
                  class="form-input"
                  placeholder="Au moins 8 caractères"
                >
              </div>
              
              <div class="form-group">
                <label for="password-confirmation">Confirmer le mot de passe</label>
                <input 
                  id="password-confirmation"
                  v-model="registerForm.password_confirmation" 
                  type="password" 
                  required
                  :disabled="authStore.loading"
                  class="form-input"
                  placeholder="Confirmez votre mot de passe"
                >
              </div>
              
              <button 
                type="submit" 
                :disabled="authStore.loading"
                class="submit-btn"
              >
                {{ authStore.loading ? 'Inscription...' : 'S\'inscrire' }}
              </button>
            </form>
            
            <!-- Toggle entre connexion et inscription -->
            <div class="auth-toggle">
              <p v-if="isLogin">
                Pas encore de compte ? 
                <button @click="isLogin = false" class="toggle-btn">S'inscrire</button>
              </p>
              <p v-else>
                Déjà un compte ? 
                <button @click="isLogin = true" class="toggle-btn">Se connecter</button>
              </p>
            </div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { ref, reactive, computed, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  initialMessage: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'authenticated'])

const authStore = useAuthStore()
const isLogin = ref(true)
const showCreateAccountSuggestion = ref(false)
const userNotFoundEmail = ref('')

const loginForm = reactive({
  email: '',
  password: ''
})

const registerForm = reactive({
  name: '',
  email: '',
  password: '',
  password_confirmation: ''
})

// Message d'erreur intelligent avec suggestion de création de compte
const errorMessage = computed(() => {
  if (props.initialMessage) {
    return props.initialMessage
  }
  return authStore.error
})

const isInfoMessage = computed(() => {
  return props.initialMessage && !props.initialMessage.includes('erreur')
})

// Surveiller les erreurs pour détecter les utilisateurs inexistants
watch(() => authStore.error, (newError) => {
  if (newError && (
    newError.includes('utilisateur introuvable') ||
    newError.includes('email not found') ||
    newError.includes('Invalid credentials') ||
    newError.includes('compte n\'existe pas')
  )) {
    showCreateAccountSuggestion.value = true
    userNotFoundEmail.value = loginForm.email
  } else {
    showCreateAccountSuggestion.value = false
  }
})

const close = () => {
  emit('update:modelValue', false)
  resetForms()
}

const handleOverlayClick = (e) => {
  if (e.target === e.currentTarget) {
    close()
  }
}

const resetForms = () => {
  loginForm.email = ''
  loginForm.password = ''
  registerForm.name = ''
  registerForm.email = ''
  registerForm.password = ''
  registerForm.password_confirmation = ''
  authStore.error = null
  showCreateAccountSuggestion.value = false
  userNotFoundEmail.value = ''
}

const switchToRegister = () => {
  // Pré-remplir l'email si on vient d'une tentative de connexion échouée
  if (userNotFoundEmail.value) {
    registerForm.email = userNotFoundEmail.value
  }
  isLogin.value = false
  showCreateAccountSuggestion.value = false
  authStore.error = null
}

const handleLogin = async () => {
  // Vérifier si l'utilisateur est déjà connecté
  if (authStore.isAuthenticated) {
    console.log('✅ [Auth Modal] Utilisateur déjà connecté, fermeture du modal')
    emit('authenticated', authStore.user)
    close()
    return
  }
  
  showCreateAccountSuggestion.value = false
  const result = await authStore.login(loginForm)
  
  if (result.success) {
    emit('authenticated', result.user)
    close()
  }
}

const handleRegister = async () => {
  const result = await authStore.register(registerForm)
  
  if (result.success) {
    emit('authenticated', result.user)
    close()
  }
}
</script>

<style scoped>
.auth-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 1rem;
}

.auth-modal {
  background: white;
  border-radius: 16px;
  max-width: 400px;
  width: 100%;
  max-height: 90vh;
  overflow: hidden;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.auth-modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.5rem;
  border-bottom: 1px solid #e0e0e0;
  background: #f8f9fa;
}

.auth-modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
  color: #333;
}

.close-btn {
  background: none;
  border: none;
  padding: 0.5rem;
  cursor: pointer;
  border-radius: 50%;
  transition: background-color 0.2s;
  color: #666;
}

.close-btn:hover {
  background-color: #f5f5f5;
}

.auth-modal-content {
  padding: 2rem;
}

.error-message {
  background: #fee;
  color: #c33;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  font-size: 0.875rem;
  border: 1px solid #fcc;
}

.error-message.info-message {
  background: #e3f2fd;
  color: #1976d2;
  border: 1px solid #bbdefb;
}

.create-account-suggestion {
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #fcc;
}

.create-account-suggestion p {
  margin: 0 0 0.75rem 0;
  font-weight: 500;
}

.create-account-btn {
  background: #E53E3E;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.create-account-btn:hover {
  background: #c53030;
  transform: translateY(-1px);
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-weight: 500;
  color: #333;
  font-size: 0.875rem;
}

.form-input {
  padding: 0.75rem 1rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.form-input:focus {
  outline: none;
  border-color: #E53E3E;
  box-shadow: 0 0 0 2px rgba(229, 62, 62, 0.1);
}

.form-input:disabled {
  background: #f5f5f5;
  cursor: not-allowed;
}

.submit-btn {
  padding: 0.875rem 1.5rem;
  background: #E53E3E;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  margin-top: 0.5rem;
}

.submit-btn:hover:not(:disabled) {
  background: #c53030;
  transform: translateY(-1px);
}

.submit-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
  transform: none;
}

.auth-toggle {
  margin-top: 1.5rem;
  text-align: center;
  padding-top: 1.5rem;
  border-top: 1px solid #e0e0e0;
}

.auth-toggle p {
  margin: 0;
  color: #666;
  font-size: 0.875rem;
}

.toggle-btn {
  background: none;
  border: none;
  color: #E53E3E;
  font-weight: 600;
  cursor: pointer;
  text-decoration: underline;
}

.toggle-btn:hover {
  color: #c53030;
}

/* Animations */
.modal-enter-active,
.modal-leave-active {
  transition: all 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .auth-modal,
.modal-leave-to .auth-modal {
  transform: scale(0.9);
}

/* Mobile */
@media (max-width: 480px) {
  .auth-modal {
    margin: 0 1rem;
  }
  
  .auth-modal-content {
    padding: 1.5rem;
  }
}
</style> 