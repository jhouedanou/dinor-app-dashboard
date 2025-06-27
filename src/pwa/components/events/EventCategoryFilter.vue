<template>
  <div class="event-category-filter">
    <h3 class="filter-title">Catégories d'événements</h3>
    
    <div v-if="loading" class="loading">
      Chargement des catégories...
    </div>

    <div v-else-if="error" class="error">
      Erreur lors du chargement des catégories
    </div>

    <div v-else class="categories-grid">
      <button
        :class="['category-btn', { active: !selectedCategoryId }]"
        @click="selectCategory(null)"
      >
        <span class="category-icon">📅</span>
        <span class="category-name">Tous les événements</span>
      </button>

      <button
        v-for="category in activeCategories"
        :key="category.id"
        :class="['category-btn', { active: selectedCategoryId === category.id }]"
        :style="{ '--category-color': category.color }"
        @click="selectCategory(category.id)"
      >
        <span class="category-icon" v-if="category.icon">
          <!-- Ici vous pouvez afficher l'icône selon votre système d'icônes -->
          {{ getCategoryEmoji(category.name) }}
        </span>
        <span class="category-name">{{ category.name }}</span>
        <span v-if="category.events_count" class="category-count">
          ({{ category.events_count }})
        </span>
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed, defineEmits } from 'vue'
import { useEventCategories } from '../../composables/useEventCategories'

const props = defineProps({
  selectedCategoryId: {
    type: [Number, String, null],
    default: null
  }
})

const emit = defineEmits(['category-selected'])

const { categories, activeCategories, loading, error } = useEventCategories()

const selectCategory = (categoryId) => {
  emit('category-selected', categoryId)
}

const getCategoryEmoji = (categoryName) => {
  const emojiMap = {
    'Séminaire': '🎓',
    'Conférence': '🎤',
    'Atelier': '🔧',
    'Cours de cuisine': '📚',
    'Dégustation': '❤️',
    'Festival': '✨',
    'Concours': '🏆',
    'Networking': '👥',
    'Exposition': '🏪',
    'Fête': '🎁'
  }
  return emojiMap[categoryName] || '📅'
}
</script>

<style scoped>
.event-category-filter {
  padding: 1rem;
}

.filter-title {
  font-size: 1.125rem;
  font-weight: 600;
  color: #1f2937;
  margin-bottom: 1rem;
}

.loading, .error {
  padding: 1rem;
  text-align: center;
  color: #6b7280;
}

.error {
  color: #dc2626;
}

.categories-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 0.75rem;
}

.category-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 0.5rem;
  background: white;
  cursor: pointer;
  transition: all 0.2s ease;
  text-align: left;
}

.category-btn:hover {
  border-color: var(--category-color, #3b82f6);
  background: #f9fafb;
}

.category-btn.active {
  border-color: var(--category-color, #3b82f6);
  background: var(--category-color, #3b82f6);
  color: white;
}

.category-icon {
  font-size: 1.25rem;
  flex-shrink: 0;
}

.category-name {
  font-weight: 500;
  flex-grow: 1;
}

.category-count {
  font-size: 0.875rem;
  opacity: 0.7;
}

@media (max-width: 640px) {
  .categories-grid {
    grid-template-columns: 1fr;
  }
}
</style> 