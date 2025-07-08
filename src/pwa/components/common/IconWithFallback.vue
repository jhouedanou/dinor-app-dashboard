<template>
  <span class="icon-with-fallback" :class="{ 'force-emoji': forceEmoji }">
    <span 
      class="material-symbols-outlined" 
      :style="{ fontSize: size + 'px' }"
      ref="iconRef"
    >
      {{ icon }}
    </span>
    <span 
      class="emoji-fallback" 
      :style="{ fontSize: (size * 0.85) + 'px' }"
    >
      {{ emoji }}
    </span>
  </span>
</template>

<script>
import { ref, onMounted, nextTick } from 'vue'

export default {
  name: 'IconWithFallback',
  props: {
    icon: {
      type: String,
      required: true
    },
    emoji: {
      type: String,
      required: true
    },
    size: {
      type: Number,
      default: 24
    }
  },
  setup(props) {
    const iconRef = ref(null)
    const forceEmoji = ref(false)
    
    const checkIcon = () => {
      if (iconRef.value) {
        const rect = iconRef.value.getBoundingClientRect()
        // Si l'icône n'a pas de dimensions, elle ne s'affiche probablement pas
        if (rect.width === 0 || rect.height === 0) {
          forceEmoji.value = true
        }
      }
    }
    
    onMounted(() => {
      nextTick(() => {
        // Attendre que les fonts soient chargées
        setTimeout(checkIcon, 100)
        // Vérifier à nouveau après un délai plus long
        setTimeout(checkIcon, 1000)
      })
    })
    
    return {
      iconRef,
      forceEmoji
    }
  }
}
</script>

<style scoped>
.icon-with-fallback {
  position: relative;
  display: inline-block;
}

.material-symbols-outlined {
  font-family: 'Material Symbols Outlined';
  font-weight: normal;
  font-style: normal;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
  font-feature-settings: 'liga';
  -webkit-font-feature-settings: 'liga';
  -webkit-font-smoothing: antialiased;
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

.emoji-fallback {
  display: none;
  line-height: 1;
}

/* Afficher emoji si Material Symbols ne charge pas */
.material-symbols-outlined:empty + .emoji-fallback,
.force-emoji .emoji-fallback {
  display: inline-block !important;
}

/* Masquer l'icône Material si elle est vide ou forcée */
.material-symbols-outlined:empty,
.force-emoji .material-symbols-outlined {
  display: none !important;
}
</style>