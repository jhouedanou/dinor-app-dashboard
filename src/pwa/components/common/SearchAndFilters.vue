<template>
  <div class="search-and-filters">
    <!-- Search Bar -->
    <div class="search-container">
      <div class="search-input-wrapper">
        <span class="material-icons search-icon">search</span>
        <span class="emoji-fallback search-icon">🔍</span>
        <input
          :value="searchQuery"
          @input="$emit('update:searchQuery', $event.target.value)"
          type="text"
          :placeholder="searchPlaceholder"
          class="search-input"
        />
        <button 
          v-if="searchQuery"
          @click="$emit('update:searchQuery', '')"
          class="clear-search"
          aria-label="Effacer la recherche"
        >
          <i class="material-icons">close</span>
          <span class="emoji-fallback">✖️</span>
        </button>
      </div>
    </div>

    <!-- All Filters in One Row -->
    <div v-if="categories?.length || additionalFilters?.length" class="all-filters">
      <div class="filters-row">
        <!-- Category Filter -->
        <div v-if="categories?.length" class="filter-dropdown-group">
          <label class="filter-label">
            <i class="material-icons">category</span>
            <span class="emoji-fallback">📂</span>
            Catégories
          </label>
          <div class="dropdown-wrapper">
            <select
              :value="selectedCategory || ''"
              @change="$emit('update:selectedCategory', $event.target.value ? parseInt($event.target.value) : null)"
              class="filter-dropdown"
            >
              <option value="">Toutes les catégories</option>
              <option
                v-for="category in categories"
                :key="category.id"
                :value="category.id"
              >
                {{ category.name }}
              </option>
            </select>
            <span class="dropdown-arrow material-icons">expand_more</span>
            <span class="dropdown-arrow emoji-fallback">▼</span>
          </div>
        </div>

        <!-- Additional Filters -->
        <div 
          v-for="filter in additionalFilters" 
          :key="filter.key"
          class="filter-dropdown-group"
        >
          <label class="filter-label">
            <i class="material-icons">{{ filter.icon || 'tune' }}</span>
            <span class="emoji-fallback">{{ filter.icon === 'schedule' ? '⏱️' : '⚙️' }}</span>
            {{ filter.label }}
          </label>
          <div class="dropdown-wrapper">
            <select
              :value="getFilterValue(filter.key) || ''"
              @change="$emit('update:additionalFilter', { key: filter.key, value: $event.target.value || null })"
              class="filter-dropdown"
            >
              <option value="">{{ filter.allLabel || 'Tous' }}</option>
              <option
                v-for="option in filter.options"
                :key="option.value"
                :value="option.value"
              >
                {{ option.label }}
              </option>
            </select>
            <span class="dropdown-arrow material-icons">expand_more</span>
            <span class="dropdown-arrow emoji-fallback">▼</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Results count -->
    <div v-if="resultsCount !== null" class="results-info">
      {{ resultsCount }} {{ itemType }}{{ resultsCount > 1 ? 's' : '' }}
      <span v-if="searchQuery"> pour "{{ searchQuery }}"</span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SearchAndFilters',
  emits: ['update:searchQuery', 'update:selectedCategory', 'update:additionalFilter'],
  props: {
    searchQuery: {
      type: String,
      default: ''
    },
    searchPlaceholder: {
      type: String,
      default: 'Rechercher...'
    },
    selectedCategory: {
      type: [Number, String],
      default: null
    },
    categories: {
      type: Array,
      default: () => []
    },
    additionalFilters: {
      type: Array,
      default: () => []
    },
    selectedFilters: {
      type: Object,
      default: () => ({})
    },
    resultsCount: {
      type: Number,
      default: null
    },
    itemType: {
      type: String,
      default: 'élément'
    }
  },
  methods: {
    getFilterValue(key) {
      return this.selectedFilters[key] || null
    }
  }
}
</script>

<style scoped>
.search-and-filters {
  padding: 1rem;
  background: #F4D03F; /* Fond doré comme demandé */
  border-radius: 12px;
  margin-bottom: 1rem;
  box-shadow: 0 4px 12px rgba(244, 208, 63, 0.3); /* Ombre dorée */
  border: 2px solid #E6C200; /* Bordure dorée plus foncée */
}

.search-container {
  margin-bottom: 1rem;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  background: #FFFFFF; /* Fond blanc pour contraster avec le doré */
  border-radius: 24px;
  padding: 0 1rem;
  transition: all 0.2s ease;
  border: 2px solid #E6C200; /* Bordure dorée */
}

.search-input-wrapper:focus-within {
  background: #FFFFFF;
  box-shadow: 0 0 0 3px rgba(244, 208, 63, 0.3); /* Focus doré */
  border-color: #B8860B; /* Bordure plus foncée au focus */
}

.search-icon {
  color: #8B7000; /* Icône dorée foncée */
  margin-right: 0.5rem;
}

.search-input {
  flex: 1;
  border: none;
  background: transparent;
  padding: 12px 0;
  font-size: 1rem;
  outline: none;
  color: #2D3748; /* Texte foncé pour contraste */
  font-weight: 500;
}

.search-input::placeholder {
  color: #8B7000; /* Placeholder doré foncé */
  font-weight: 400;
}

.clear-search {
  background: none;
  border: none;
  color: #8B7000; /* Couleur dorée foncée */
  cursor: pointer;
  padding: 4px;
  border-radius: 50%;
  transition: background-color 0.2s ease;
}

.clear-search:hover {
  background: rgba(244, 208, 63, 0.2); /* Hover doré léger */
}

.all-filters {
  margin-bottom: 1rem;
}

/* Styles pour les filtres déroulants */
.filters-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: flex-start;
}

.filter-dropdown-group {
  min-width: 200px;
  flex: 1;
}

.filter-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  font-weight: 700; /* Plus gras pour plus de lisibilité */
  color: #2D3748; /* Texte foncé sur fond doré */
  font-size: 0.9rem;
  cursor: pointer;
  text-shadow: 0 1px 2px rgba(255, 255, 255, 0.5); /* Ombre de texte pour lisibilité */
}

.filter-label .material-icons {
  font-size: 1.25rem;
  color: #8B7000; /* Icône dorée foncée */
  font-weight: 600;
}

.dropdown-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.filter-dropdown {
  width: 100%;
  appearance: none;
  background: #FFFFFF; /* Fond blanc pour contraster */
  border: 2px solid #E6C200; /* Bordure dorée */
  border-radius: 12px;
  padding: 12px 40px 12px 16px;
  font-size: 0.95rem;
  font-weight: 600; /* Plus gras pour lisibilité */
  color: #2D3748; /* Texte foncé */
  cursor: pointer;
  transition: all 0.3s ease;
  outline: none;
  box-shadow: 0 2px 6px rgba(244, 208, 63, 0.2); /* Ombre dorée */
}

.filter-dropdown:hover {
  border-color: #B8860B; /* Bordure plus foncée au hover */
  box-shadow: 0 4px 12px rgba(244, 208, 63, 0.4); /* Ombre plus prononcée */
  background: #FFFEF7; /* Fond légèrement jaunâtre */
}

.filter-dropdown:focus {
  border-color: #8B7000; /* Bordure foncée au focus */
  box-shadow: 0 0 0 3px rgba(244, 208, 63, 0.3); /* Focus doré */
  background: #FFFFFF;
}

.filter-dropdown option {
  padding: 8px 12px;
  background: #FFFFFF;
  color: #2D3748;
  font-weight: 500;
}

.dropdown-arrow {
  position: absolute;
  right: 12px;
  color: #8B7000; /* Flèche dorée foncée */
  pointer-events: none;
  transition: transform 0.2s ease;
  font-weight: 600;
}

.filter-dropdown:focus + .dropdown-arrow {
  transform: rotate(180deg);
  color: #8B7000;
}

/* Styles pour les anciennes chips de catégories */
.filter-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  overflow-x: auto;
  padding-bottom: 0.25rem;
}

.filter-chip {
  background: #FFFFFF; /* Fond blanc */
  border: 2px solid #E6C200; /* Bordure dorée */
  color: #2D3748; /* Texte foncé */
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 600; /* Plus gras */
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s ease;
  box-shadow: 0 2px 4px rgba(244, 208, 63, 0.2);
}

.filter-chip:hover {
  background: #FFFEF7; /* Fond légèrement jaunâtre */
  border-color: #B8860B;
  transform: translateY(-1px); /* Légère élévation */
  box-shadow: 0 4px 8px rgba(244, 208, 63, 0.3);
}

.filter-chip.active {
  background: #8B7000; /* Fond doré foncé pour l'actif */
  color: #FFFFFF; /* Texte blanc pour contraste */
  border-color: #8B7000;
  font-weight: 700;
  box-shadow: 0 4px 12px rgba(139, 112, 0, 0.4);
}

.results-info {
  padding: 0.75rem 1rem;
  background: #FFFFFF; /* Fond blanc pour contraster */
  color: #2D3748; /* Texte foncé */
  border-radius: 8px;
  font-weight: 600; /* Plus gras */
  font-size: 0.875rem;
  margin-bottom: 0;
  border: 2px solid #E6C200; /* Bordure dorée */
  box-shadow: 0 2px 6px rgba(244, 208, 63, 0.2);
}

/* Responsive */
@media (max-width: 768px) {
  .search-and-filters {
    padding: 0.75rem;
  }
  
  .filters-row {
    flex-direction: row;
    flex-wrap: wrap;
    gap: 0.75rem;
  }
  
  .filter-dropdown-group {
    min-width: 100%;
  }
  
  .filter-dropdown {
  
    font-size: 16px; /* Prevent zoom on iOS */
    padding: 14px 40px 14px 16px;
  }
  
  .filter-chips {
    -webkit-overflow-scrolling: touch;
  }
}

@media (max-width: 480px) {
  .filters-row {
    gap: 0.5rem;
  }
  
  .filter-label {
    font-size: 0.85rem;
  }
  
  .filter-dropdown {
    padding: 10px 35px 10px 12px;
    font-size: 14px;
  }
}

/* Système de fallback pour les icônes - logique simplifiée */
.emoji-fallback {
  display: none; /* Masqué par défaut */
}

.material-icons {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

/* UNIQUEMENT quand .force-emoji est présent sur html, afficher les emoji */
html.force-emoji .material-icons {
  display: none !important;
}

html.force-emoji .emoji-fallback {
  display: inline-block !important;
}
</style> 