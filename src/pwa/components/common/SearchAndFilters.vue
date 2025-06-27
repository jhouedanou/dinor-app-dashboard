<template>
  <div class="search-and-filters">
    <!-- Search Bar -->
    <div class="search-container">
      <div class="search-input-wrapper">
        <span class="material-symbols-outlined search-icon">search</span>
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
          <span class="material-symbols-outlined">close</span>
        </button>
      </div>
    </div>

    <!-- All Filters in One Row -->
    <div v-if="categories?.length || additionalFilters?.length" class="all-filters">
      <div class="filters-row">
        <!-- Category Filter -->
        <div v-if="categories?.length" class="filter-dropdown-group">
          <label class="filter-label">
            <span class="material-symbols-outlined">category</span>
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
            <span class="dropdown-arrow material-symbols-outlined">expand_more</span>
          </div>
        </div>

        <!-- Additional Filters -->
        <div 
          v-for="filter in additionalFilters" 
          :key="filter.key"
          class="filter-dropdown-group"
        >
          <label class="filter-label">
            <span class="material-symbols-outlined">{{ filter.icon || 'tune' }}</span>
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
            <span class="dropdown-arrow material-symbols-outlined">expand_more</span>
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
  background: var(--surface-color, #ffffff);
  border-radius: 12px;
  margin-bottom: 1rem;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.search-container {
  margin-bottom: 1rem;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  background: var(--surface-variant-color, #f5f5f5);
  border-radius: 24px;
  padding: 0 1rem;
  transition: all 0.2s ease;
}

.search-input-wrapper:focus-within {
  background: var(--surface-color, #ffffff);
  box-shadow: 0 0 0 2px var(--primary-color, #9F7C20);
}

.search-icon {
  color: var(--on-surface-variant-color, #6b7280);
  margin-right: 0.5rem;
}

.search-input {
  flex: 1;
  border: none;
  background: transparent;
  padding: 12px 0;
  font-size: 1rem;
  outline: none;
  color: var(--on-surface-color, #1f2937);
}

.search-input::placeholder {
  color: var(--on-surface-variant-color, #6b7280);
}

.clear-search {
  background: none;
  border: none;
  color: var(--on-surface-variant-color, #6b7280);
  cursor: pointer;
  padding: 4px;
  border-radius: 50%;
  transition: background-color 0.2s ease;
}

.clear-search:hover {
  background: var(--surface-variant-color, #f5f5f5);
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
  font-weight: 600;
  color: var(--on-surface-color, #1f2937);
  font-size: 0.875rem;
  cursor: pointer;
}

.filter-label .material-symbols-outlined {
  font-size: 1.125rem;
  color: var(--primary-color, #9F7C20);
}

.dropdown-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.filter-dropdown {
  width: 100%;
  appearance: none;
  background: var(--surface-color, #ffffff);
  border: 2px solid var(--outline-variant-color, #e5e7eb);
  border-radius: 12px;
  padding: 12px 40px 12px 16px;
  font-size: 0.95rem;
  font-weight: 500;
  color: var(--on-surface-color, #1f2937);
  cursor: pointer;
  transition: all 0.3s ease;
  outline: none;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.filter-dropdown:hover {
  border-color: var(--primary-color, #9F7C20);
  box-shadow: 0 2px 8px rgba(159, 124, 32, 0.15);
}

.filter-dropdown:focus {
  border-color: var(--primary-color, #9F7C20);
  box-shadow: 0 0 0 3px rgba(159, 124, 32, 0.1);
  background: var(--surface-color, #ffffff);
}

.filter-dropdown option {
  padding: 8px 12px;
  background: var(--surface-color, #ffffff);
  color: var(--on-surface-color, #1f2937);
}

.dropdown-arrow {
  position: absolute;
  right: 12px;
  color: var(--on-surface-variant-color, #6b7280);
  pointer-events: none;
  transition: transform 0.2s ease;
}

.filter-dropdown:focus + .dropdown-arrow {
  transform: rotate(180deg);
  color: var(--primary-color, #9F7C20);
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
  background: var(--surface-variant-color, #f5f5f5);
  border: 1px solid var(--outline-variant-color, #e5e7eb);
  color: var(--on-surface-variant-color, #6b7280);
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: 500;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s ease;
}

.filter-chip:hover {
  background: var(--primary-container-color, #f3e8d3);
  border-color: var(--primary-color, #9F7C20);
}

.filter-chip.active {
  background: var(--primary-color, #9F7C20);
  color: var(--on-primary-color, #ffffff);
  border-color: var(--primary-color, #9F7C20);
}

.results-info {
  padding: 0.75rem 1rem;
  background: var(--primary-container-color, #f3e8d3);
  color: var(--on-primary-container-color, #5d4e00);
  border-radius: 8px;
  font-weight: 500;
  font-size: 0.875rem;
  margin-bottom: 0;
}

/* Responsive */
@media (max-width: 768px) {
  .search-and-filters {
    padding: 0.75rem;
  }
  
  .filters-row {
    flex-direction: column;
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
    font-size: 0.8rem;
  }
  
  .filter-dropdown {
    padding: 10px 35px 10px 12px;
    font-size: 14px;
  }
}
</style> 