<template>
  <div 
    class="badge"
    :class="[
      `badge--${variant}`,
      `badge--${size}`,
      { 'badge--clickable': clickable },
      { 'badge--outlined': outlined },
      { 'badge--active': active }
    ]"
    @click="handleClick"
  >
    <span v-if="icon" class="badge-icon material-symbols-outlined">{{ icon }}</span>
    <span class="badge-text">{{ text }}</span>
    <span v-if="count !== undefined" class="badge-count">{{ count }}</span>
  </div>
</template>

<script>
export default {
  name: 'Badge',
  props: {
    text: {
      type: String,
      required: true
    },
    icon: {
      type: String,
      default: null
    },
    count: {
      type: [Number, String],
      default: undefined
    },
    variant: {
      type: String,
      default: 'primary',
      validator: (value) => [
        'primary', 'secondary', 'success', 'warning', 'error', 'info', 'neutral'
      ].includes(value)
    },
    size: {
      type: String,
      default: 'medium',
      validator: (value) => ['small', 'medium', 'large'].includes(value)
    },
    outlined: {
      type: Boolean,
      default: false
    },
    clickable: {
      type: Boolean,
      default: false
    },
    active: {
      type: Boolean,
      default: false
    }
  },
  emits: ['click'],
  methods: {
    handleClick(event) {
      if (this.clickable) {
        this.$emit('click', event);
      }
    }
  }
};
</script>

<style scoped>
.badge {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  padding: 0.25rem 0.75rem;
  border-radius: 50px;
  font-weight: 500;
  font-size: 0.875rem;
  line-height: 1.2;
  transition: all 0.2s ease;
  white-space: nowrap;
  border: 1px solid transparent;
}

/* Sizes */
.badge--small {
  padding: 0.125rem 0.5rem;
  font-size: 0.75rem;
  gap: 0.125rem;
}

.badge--medium {
  padding: 0.25rem 0.75rem;
  font-size: 0.875rem;
  gap: 0.25rem;
}

.badge--large {
  padding: 0.375rem 1rem;
  font-size: 1rem;
  gap: 0.375rem;
}

/* Icon sizes */
.badge--small .badge-icon {
  font-size: 1rem;
}

.badge--medium .badge-icon {
  font-size: 1.125rem;
}

.badge--large .badge-icon {
  font-size: 1.25rem;
}

/* Variants */
.badge--primary {
  background-color: #E1251B;
  color: #FFFFFF;
}

.badge--primary.badge--outlined {
  background-color: transparent;
  color: #E1251B;
  border-color: #E1251B;
}

.badge--secondary {
  background-color: #F4D03F;
  color: #2D3748;
}

.badge--secondary.badge--outlined {
  background-color: transparent;
  color: #F4D03F;
  border-color: #F4D03F;
}

.badge--success {
  background-color: #48BB78;
  color: #FFFFFF;
}

.badge--success.badge--outlined {
  background-color: transparent;
  color: #48BB78;
  border-color: #48BB78;
}

.badge--warning {
  background-color: #ED8936;
  color: #FFFFFF;
}

.badge--warning.badge--outlined {
  background-color: transparent;
  color: #ED8936;
  border-color: #ED8936;
}

.badge--error {
  background-color: #F56565;
  color: #FFFFFF;
}

.badge--error.badge--outlined {
  background-color: transparent;
  color: #F56565;
  border-color: #F56565;
}

.badge--info {
  background-color: #4299E1;
  color: #FFFFFF;
}

.badge--info.badge--outlined {
  background-color: transparent;
  color: #4299E1;
  border-color: #4299E1;
}

.badge--neutral {
  background-color: #E2E8F0;
  color: #4A5568;
}

.badge--neutral.badge--outlined {
  background-color: transparent;
  color: #4A5568;
  border-color: #E2E8F0;
}

/* Clickable state */
.badge--clickable {
  cursor: pointer;
}

.badge--clickable:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.badge--clickable:active {
  transform: translateY(0);
}

/* Active state */
.badge--active {
  box-shadow: 0 0 0 2px rgba(225, 37, 27, 0.3);
}

.badge--clickable.badge--active:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15), 0 0 0 2px rgba(225, 37, 27, 0.3);
}

/* Count styling */
.badge-count {
  background-color: rgba(255, 255, 255, 0.2);
  color: inherit;
  padding: 0.125rem 0.375rem;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  min-width: 1.25rem;
  text-align: center;
}

.badge--outlined .badge-count {
  background-color: rgba(0, 0, 0, 0.05);
}

/* Responsive adjustments */
@media (max-width: 480px) {
  .badge--large {
    padding: 0.25rem 0.75rem;
    font-size: 0.875rem;
  }
  
  .badge--medium {
    padding: 0.1875rem 0.625rem;
    font-size: 0.8125rem;
  }
  
  .badge--small {
    padding: 0.125rem 0.5rem;
    font-size: 0.75rem;
  }
}

/* Material Design 3 inspired variants */
.badge.md3-style {
  border-radius: 8px;
  font-weight: 600;
}

.badge.md3-style.badge--primary {
  background-color: var(--md-sys-color-primary, #E1251B);
  color: var(--md-sys-color-on-primary, #FFFFFF);
}

.badge.md3-style.badge--secondary {
  background-color: var(--md-sys-color-secondary-container, #F4D03F);
  color: var(--md-sys-color-on-secondary-container, #2D3748);
}
</style>