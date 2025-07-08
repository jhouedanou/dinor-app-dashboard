<template>
  <div v-if="isOpen" class="lightbox-overlay" @click="closeLightbox">
    <div class="lightbox-container">
      <!-- Navigation arrows -->
      <button 
        v-if="images.length > 1" 
        class="lightbox-nav lightbox-nav-prev"
        @click.stop="previousImage"
        :disabled="currentIndex === 0"
      >
        <span class="material-symbols-outlined">chevron_left</span>
        <span class="emoji-fallback">◀</span>
      </button>
      
      <button 
        v-if="images.length > 1" 
        class="lightbox-nav lightbox-nav-next"
        @click.stop="nextImage"
        :disabled="currentIndex === images.length - 1"
      >
        <span class="material-symbols-outlined">chevron_right</span>
        <span class="emoji-fallback">▶</span>
      </button>
      
      <!-- Image -->
      <div class="lightbox-image-container" @click.stop="">
        <img 
          :src="currentImage"
          :alt="currentAlt"
          class="lightbox-image"
          @load="handleImageLoad"
          @error="handleImageError"
        />
        
        <!-- Loading spinner -->
        <div v-if="imageLoading" class="lightbox-loading">
          <div class="md3-circular-progress"></div>
        </div>
      </div>
      
      <!-- Info bar -->
      <div class="lightbox-info">
        <div class="lightbox-title">{{ title }}</div>
        <div v-if="images.length > 1" class="lightbox-counter">
          {{ currentIndex + 1 }} / {{ images.length }}
        </div>
        <button class="lightbox-close" @click="closeLightbox">
          <span class="material-symbols-outlined">close</span>
          <span class="emoji-fallback">✕</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed, watch, onMounted, onUnmounted } from 'vue'

export default {
  name: 'ImageLightbox',
  props: {
    images: {
      type: Array,
      required: true
    },
    title: {
      type: String,
      default: ''
    },
    initialIndex: {
      type: Number,
      default: 0
    },
    isOpen: {
      type: Boolean,
      default: false
    }
  },
  emits: ['close', 'change'],
  setup(props, { emit }) {
    const currentIndex = ref(props.initialIndex)
    const imageLoading = ref(false)
    
    const currentImage = computed(() => {
      return props.images[currentIndex.value] || ''
    })
    
    const currentAlt = computed(() => {
      return `${props.title} - Image ${currentIndex.value + 1}`
    })
    
    const nextImage = () => {
      if (currentIndex.value < props.images.length - 1) {
        currentIndex.value++
        emit('change', currentIndex.value)
      }
    }
    
    const previousImage = () => {
      if (currentIndex.value > 0) {
        currentIndex.value--
        emit('change', currentIndex.value)
      }
    }
    
    const closeLightbox = () => {
      emit('close')
    }
    
    const handleImageLoad = () => {
      imageLoading.value = false
    }
    
    const handleImageError = () => {
      imageLoading.value = false
    }
    
    const handleKeydown = (event) => {
      if (!props.isOpen) return
      
      switch (event.key) {
        case 'Escape':
          closeLightbox()
          break
        case 'ArrowLeft':
          previousImage()
          break
        case 'ArrowRight':
          nextImage()
          break
      }
    }
    
    // Watch for index changes to show loading
    watch(() => currentIndex.value, () => {
      imageLoading.value = true
    })
    
    // Watch for initialIndex changes
    watch(() => props.initialIndex, (newIndex) => {
      currentIndex.value = newIndex
    })
    
    // Watch for isOpen changes to handle body scroll
    watch(() => props.isOpen, (isOpen) => {
      if (isOpen) {
        document.body.style.overflow = 'hidden'
      } else {
        document.body.style.overflow = ''
      }
    })
    
    onMounted(() => {
      document.addEventListener('keydown', handleKeydown)
    })
    
    onUnmounted(() => {
      document.removeEventListener('keydown', handleKeydown)
      document.body.style.overflow = ''
    })
    
    return {
      currentIndex,
      currentImage,
      currentAlt,
      imageLoading,
      nextImage,
      previousImage,
      closeLightbox,
      handleImageLoad,
      handleImageError
    }
  }
}
</script>

<style scoped>
.lightbox-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  backdrop-filter: blur(3px);
}

.lightbox-container {
  position: relative;
  max-width: 90vw;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
}

.lightbox-image-container {
  position: relative;
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 200px;
}

.lightbox-image {
  max-width: 100%;
  max-height: 80vh;
  object-fit: contain;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.5);
}

.lightbox-loading {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.lightbox-nav {
  position: absolute;
  top: 50%;
  transform: translateY(-50%);
  background: rgba(0, 0, 0, 0.7);
  color: white;
  border: none;
  border-radius: 50%;
  width: 48px;
  height: 48px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
  z-index: 10;
}

.lightbox-nav:hover:not(:disabled) {
  background: rgba(0, 0, 0, 0.9);
  transform: translateY(-50%) scale(1.1);
}

.lightbox-nav:disabled {
  opacity: 0.3;
  cursor: not-allowed;
}

.lightbox-nav-prev {
  left: 20px;
}

.lightbox-nav-next {
  right: 20px;
}

.lightbox-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem;
  background: rgba(0, 0, 0, 0.8);
  color: white;
  border-radius: 0 0 8px 8px;
  margin-top: 1rem;
}

.lightbox-title {
  font-weight: 600;
  font-size: 1.1rem;
}

.lightbox-counter {
  font-size: 0.9rem;
  opacity: 0.8;
}

.lightbox-close {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 50%;
  transition: background 0.2s ease;
}

.lightbox-close:hover {
  background: rgba(255, 255, 255, 0.2);
}

.lightbox-close .material-symbols-outlined {
  font-size: 24px;
}

/* Mobile styles */
@media (max-width: 768px) {
  .lightbox-container {
    max-width: 95vw;
    max-height: 95vh;
  }
  
  .lightbox-nav {
    width: 40px;
    height: 40px;
  }
  
  .lightbox-nav-prev {
    left: 10px;
  }
  
  .lightbox-nav-next {
    right: 10px;
  }
  
  .lightbox-info {
    flex-direction: column;
    gap: 0.5rem;
    text-align: center;
  }
  
  .lightbox-title {
    font-size: 1rem;
  }
  
  .lightbox-counter {
    font-size: 0.8rem;
  }
}
</style>