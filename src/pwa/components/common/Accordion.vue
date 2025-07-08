<template>
  <div class="accordion" :class="{ 'accordion--open': isOpen }">
    <button 
      class="accordion-header" 
      @click="toggle"
      :aria-expanded="isOpen"
      :aria-controls="contentId"
      :disabled="!toggleable"
    >
      <span class="accordion-title">{{ title }}</span>
      <span class="accordion-icon">
        <span class="material-symbols-outlined">{{ isOpen ? 'expand_less' : 'expand_more' }}</span>
        <span class="emoji-fallback">{{ isOpen ? '▲' : '▼' }}</span>
      </span>
    </button>
    
    <div 
      class="accordion-content" 
      :id="contentId"
      :aria-hidden="!isOpen"
      ref="contentRef"
    >
      <div class="accordion-body">
        <slot></slot>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch, nextTick, onMounted } from 'vue'

/**
 * Accordion Component
 * 
 * Usage:
 * <Accordion title="Section Title" :initial-open="true" :toggleable="true" @toggle="handleToggle">
 *   Content goes here
 * </Accordion>
 * 
 * Methods (via ref):
 * - toggle(): Toggle the accordion
 * - open(): Open the accordion
 * - close(): Close the accordion
 * - setOpen(boolean): Set accordion state
 * 
 * Props:
 * - title: Section title
 * - initialOpen: Initial state (default: false)
 * - toggleable: Whether accordion can be toggled (default: true)
 * - id: Optional unique identifier
 */
export default {
  name: 'Accordion',
  props: {
    title: {
      type: String,
      required: true
    },
    initialOpen: {
      type: Boolean,
      default: false
    },
    id: {
      type: String,
      default: null
    },
    toggleable: {
      type: Boolean,
      default: true
    }
  },
  emits: ['toggle'],
  setup(props, { emit }) {
    const isOpen = ref(props.initialOpen)
    const contentRef = ref(null)
    const isInitialized = ref(false)
    
    const contentId = computed(() => {
      return props.id || `accordion-${Math.random().toString(36).substr(2, 9)}`
    })
    
    const toggle = () => {
      if (props.toggleable) {
        isOpen.value = !isOpen.value
        emit('toggle', isOpen.value)
      }
    }
    
    // Smooth height animation - uniquement après l'initialisation
    watch(isOpen, async (newValue) => {
      if (!contentRef.value || !isInitialized.value) return
      
      const content = contentRef.value
      
      if (newValue) {
        // Opening
        content.style.height = '0px'
        content.style.overflow = 'hidden'
        
        await nextTick()
        
        const scrollHeight = content.scrollHeight
        content.style.height = scrollHeight + 'px'
        
        // Remove height after animation
        setTimeout(() => {
          content.style.height = 'auto'
          content.style.overflow = 'visible'
        }, 300)
      } else {
        // Closing
        const scrollHeight = content.scrollHeight
        content.style.height = scrollHeight + 'px'
        content.style.overflow = 'hidden'
        
        await nextTick()
        
        content.style.height = '0px'
        
        // Clean up after animation
        setTimeout(() => {
          if (!isOpen.value) {
            content.style.overflow = 'hidden'
          }
        }, 300)
      }
    })
    
    // Initialiser l'état correct au montage
    onMounted(() => {
      if (contentRef.value) {
        const content = contentRef.value
        if (props.initialOpen) {
          // Si ouvert par défaut, s'assurer que le contenu est visible
          content.style.height = 'auto'
          content.style.overflow = 'visible'
        } else {
          // Si fermé par défaut, s'assurer que le contenu est caché
          content.style.height = '0px'
          content.style.overflow = 'hidden'
        }
      }
      // Marquer comme initialisé pour permettre les animations futures
      isInitialized.value = true
    })
    
    // Expose methods for programmatic control
    const open = () => {
      if (props.toggleable) {
        isOpen.value = true
        emit('toggle', true)
      }
    }
    
    const close = () => {
      if (props.toggleable) {
        isOpen.value = false
        emit('toggle', false)
      }
    }
    
    const setOpen = (open) => {
      if (props.toggleable) {
        isOpen.value = open
        emit('toggle', open)
      }
    }
    
    return {
      isOpen,
      contentId,
      contentRef,
      toggle,
      open,
      close,
      setOpen
    }
  }
}
</script>

<style scoped>
.accordion {
  border: 1px solid #E2E8F0;
  border-radius: 8px;
  margin-bottom: 1rem;
  overflow: hidden;
  transition: all 0.2s ease;
}

.accordion:hover {
  border-color: #CBD5E0;
}

.accordion--open {
  border-color: #F4D03F;
}

.accordion-header {
  width: 100%;
  padding: 1rem;
  background: #FFFFFF;
  border: none;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  text-align: left;
  transition: all 0.2s ease;
  font-size: 1.1rem;
  font-weight: 600;
  color: #2D3748;
}

.accordion-header:hover:not(:disabled) {
  background: #F8F9FA;
}

.accordion-header:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.accordion--open .accordion-header {
  background: #FEF3CD;
  border-bottom: 1px solid #F4D03F;
}

.accordion-title {
  flex: 1;
  color: inherit;
}

.accordion-icon {
  display: flex;
  align-items: center;
  margin-left: 1rem;
  transition: transform 0.2s ease;
}

.accordion--open .accordion-icon {
  transform: rotate(180deg);
}

.accordion-content {
  height: 0;
  overflow: hidden;
  transition: height 0.3s ease;
  background: #FFFFFF;
}

.accordion-body {
  padding: 1rem;
}

/* Mobile styles */
@media (max-width: 768px) {
  .accordion-header {
    padding: 0.75rem;
    font-size: 1rem;
  }
  
  .accordion-body {
    padding: 0.75rem;
  }
}
</style>