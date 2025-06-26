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

    <!-- Category Filters -->
    <div v-if="categories?.length" class="filters">
      <div class="filter-header">
        <span class="material-symbols-outlined">filter_list</span>
        <span>Catégories</span>
      </div>
      <div class="filter-chips">
        <button
          @click="$emit('update:selectedCategory', null)"
          class="filter-chip"
          :class="{ active: !selectedCategory }"
        >
          Toutes
        </button>
        <button
          v-for="category in categories"
          :key="category.id"
          @click="$emit('update:selectedCategory', category.id)"
          class="filter-chip"
          :class="{ active: selectedCategory === category.id }"
        >
          {{ category.name }}
        </button>
      </div>
    </div>

    <!-- Additional Filters -->
    <div v-if="additionalFilters?.length" class="additional-filters">
      <div 
        v-for="filter in additionalFilters" 
        :key="filter.key"
        class="filter-group"
      >
        <div class="filter-header">
          <span class="material-symbols-outlined">{{ filter.icon || 'tune' }}</span>
          <span>{{ filter.label }}</span>
        </div>
        <div class="filter-chips">
          <button
            @click="$emit('update:additionalFilter', { key: filter.key, value: null })"
            class="filter-chip"
            :class="{ active: !getFilterValue(filter.key) }"
          >
            {{ filter.allLabel || 'Tous' }}
          </button>
          <button
            v-for="option in filter.options"
            :key="option.value"
            @click="$emit('update:additionalFilter', { key: filter.key, value: option.value })"
            class="filter-chip"
            :class="{ active: getFilterValue(filter.key) === option.value }"
          >
            {{ option.label }}
          </button>
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

.filters,
.additional-filters {
  margin-bottom: 1rem;
}

.filter-group {
  margin-bottom: 1rem;
}

.filter-group:last-child {
  margin-bottom: 0;
}

.filter-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: var(--on-surface-color, #1f2937);
  font-size: 0.875rem;
}

.filter-header .material-symbols-outlined {
  font-size: 1.125rem;
  color: var(--primary-color, #9F7C20);
}

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
  
  .filter-chips {
    -webkit-overflow-scrolling: touch;
  }
}
</style> 