<template>
  <div class="video-modal" @click="closeModal">
    <div class="modal-content" @click.stop>
      <button @click="closeModal" class="close-button">
        <DinorIcon name="close" :size="24" />
      </button>
      <div class="video-player">
        <iframe
          v-if="embedUrl"
          :src="embedUrl"
          :title="video.title"
          frameborder="0"
          allowfullscreen
          @load="onVideoLoad"
          @error="onVideoError"
        ></iframe>
        <div v-else class="video-error">
          <DinorIcon name="error" :size="48" />
          <p>URL de vidéo non valide</p>
        </div>
      </div>
      <div class="video-details">
        <h3>{{ video.title }}</h3>
        <p v-if="video.description">{{ video.description }}</p>
        <div class="video-meta">
          <span v-if="video.views_count" class="views">
            <DinorIcon name="visibility" :size="16" />
            {{ video.views_count }} vues
          </span>
          <span v-if="video.created_at" class="date">
            {{ formatDate(video.created_at) }}
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'
import DinorIcon from '@/components/DinorIcon.vue'

export default {
  name: 'VideoModal',
  components: {
    DinorIcon
  },
  props: {
    video: {
      type: Object,
      required: true
    }
  },
  emits: ['close'],
  setup(props, { emit }) {
    const closeModal = () => {
      emit('close')
    }
    
    const embedUrl = computed(() => {
      return getEmbedUrl(props.video.video_url)
    })
    
    const getEmbedUrl = (videoUrl) => {
      if (!videoUrl) return ''
      
      // Convertir l'URL YouTube en URL d'embed
      const youtubeMatch = videoUrl.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([^&\n?#]+)/)
      if (youtubeMatch) {
        return `https://www.youtube.com/embed/${youtubeMatch[1]}?autoplay=1&rel=0`
      }
      
      return videoUrl
    }
    
    const formatDate = (dateString) => {
      if (!dateString) return ''
      return new Date(dateString).toLocaleDateString('fr-FR', {
        day: 'numeric',
        month: 'short',
        year: 'numeric'
      })
    }
    
    const onVideoLoad = () => {
      console.log('🎬 [VideoModal] Vidéo chargée avec succès')
    }
    
    const onVideoError = () => {
      console.error('❌ [VideoModal] Erreur lors du chargement de la vidéo')
    }
    
    return {
      closeModal,
      embedUrl,
      getEmbedUrl,
      formatDate,
      onVideoLoad,
      onVideoError
    }
  }
}
</script>

<style scoped>
.video-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 16px;
}

.modal-content {
  background: var(--md-sys-color-surface, #fefbff);
  border-radius: 16px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  overflow: auto;
  position: relative;
}

.close-button {
  position: absolute;
  top: 12px;
  right: 12px;
  background: rgba(0, 0, 0, 0.5);
  color: white;
  border: none;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  z-index: 1;
  transition: all 0.2s ease;
}

.close-button:hover {
  background: rgba(0, 0, 0, 0.7);
  transform: scale(1.1);
}

.video-player {
  aspect-ratio: 16/9;
  width: 100%;
}

.video-player iframe {
  width: 100%;
  height: 100%;
  border-radius: 16px 16px 0 0;
}

.video-error {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  background: #f5f5f5;
  border-radius: 16px 16px 0 0;
  color: #666;
}

.video-error p {
  margin: 16px 0 0 0;
  font-size: 14px;
}

.video-details {
  padding: 20px;
}

.video-details h3 {
  margin: 0 0 12px 0;
  font-size: 20px;
  font-weight: 600;
  color: var(--md-sys-color-on-surface, #1c1b1f);
}

.video-details p {
  margin: 0 0 16px 0;
  font-size: 14px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
  line-height: 1.5;
}

.video-meta {
  display: flex;
  gap: 16px;
  font-size: 12px;
  color: var(--md-sys-color-on-surface-variant, #49454f);
}

.views,
.date {
  display: flex;
  align-items: center;
  gap: 4px;
}

/* Responsive */
@media (max-width: 768px) {
  .modal-content {
    max-width: 95vw;
    max-height: 95vh;
  }
  
  .video-details {
    padding: 16px;
  }
  
  .video-details h3 {
    font-size: 18px;
  }
}
</style> 