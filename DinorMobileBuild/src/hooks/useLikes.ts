import { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { useAuthStore } from '../stores/authStore';
import { EventEmitter } from 'events';

// Global event emitter for synchronizing likes across components
const likesEventEmitter = new EventEmitter();

export type ContentType = 'recipe' | 'tip' | 'event' | 'dinor_tv';

interface LikeState {
  isLiked: boolean;
  isFavorited: boolean;
  likesCount: number;
  loading: boolean;
}

interface UseLikesReturn extends LikeState {
  toggleLike: () => Promise<void>;
  toggleFavorite: () => Promise<void>;
  refresh: () => Promise<void>;
}

export const useLikes = (
  contentType: ContentType,
  contentId: number,
  initialState?: Partial<LikeState>
): UseLikesReturn => {
  const { isAuthenticated } = useAuthStore();
  
  const [state, setState] = useState<LikeState>({
    isLiked: initialState?.isLiked || false,
    isFavorited: initialState?.isFavorited || false,
    likesCount: initialState?.likesCount || 0,
    loading: false,
  });

  // Check initial like and favorite status
  useEffect(() => {
    if (isAuthenticated && contentId) {
      checkStatus();
    }
  }, [isAuthenticated, contentId, contentType]);

  // Listen for global like updates
  useEffect(() => {
    const handleContentUpdate = (data: any) => {
      if (data.type === contentType && data.id === contentId) {
        setState(prev => ({
          ...prev,
          isLiked: data.isLiked,
          isFavorited: data.isFavorited,
          likesCount: data.likesCount,
        }));
      }
    };

    likesEventEmitter.on('content-interaction-updated', handleContentUpdate);
    
    return () => {
      likesEventEmitter.off('content-interaction-updated', handleContentUpdate);
    };
  }, [contentType, contentId]);

  const checkStatus = async () => {
    try {
      setState(prev => ({ ...prev, loading: true }));

      const [likeResponse, favoriteResponse] = await Promise.all([
        apiService.get(`/likes/check?type=${contentType}&id=${contentId}`),
        apiService.get(`/favorites/check?type=${contentType}&id=${contentId}`)
      ]);

      if (likeResponse.success && favoriteResponse.success) {
        setState(prev => ({
          ...prev,
          isLiked: likeResponse.data.isLiked || false,
          isFavorited: favoriteResponse.data.isFavorited || false,
          likesCount: likeResponse.data.likesCount || 0,
          loading: false,
        }));
      }
    } catch (error) {
      console.error('Error checking like/favorite status:', error);
      setState(prev => ({ ...prev, loading: false }));
    }
  };

  const toggleLike = async () => {
    if (!isAuthenticated) {
      // Could emit an event to show auth modal
      return;
    }

    const wasLiked = state.isLiked;
    const newLikesCount = wasLiked ? state.likesCount - 1 : state.likesCount + 1;
    const wasFavorited = state.isFavorited;

    // Optimistic update
    setState(prev => ({
      ...prev,
      isLiked: !wasLiked,
      isFavorited: !wasLiked ? true : wasFavorited, // Auto-favorite when liking
      likesCount: newLikesCount,
      loading: true,
    }));

    try {
      const response = await apiService.post('/likes/toggle', {
        likeable_type: contentType,
        likeable_id: contentId,
      });

      if (response.success) {
        const finalState = {
          isLiked: response.data.isLiked,
          isFavorited: response.data.isFavorited || (!wasLiked ? true : wasFavorited),
          likesCount: response.data.likesCount || newLikesCount,
          loading: false,
        };

        setState(prev => ({ ...prev, ...finalState }));

        // Emit global update event
        likesEventEmitter.emit('content-interaction-updated', {
          type: contentType,
          id: contentId,
          ...finalState,
        });
      } else {
        // Rollback on error
        setState(prev => ({
          ...prev,
          isLiked: wasLiked,
          isFavorited: wasFavorited,
          likesCount: state.likesCount,
          loading: false,
        }));
      }
    } catch (error) {
      console.error('Error toggling like:', error);
      
      // Rollback on error
      setState(prev => ({
        ...prev,
        isLiked: wasLiked,
        isFavorited: wasFavorited,
        likesCount: state.likesCount,
        loading: false,
      }));
    }
  };

  const toggleFavorite = async () => {
    if (!isAuthenticated) {
      return;
    }

    const wasFavorited = state.isFavorited;

    // Optimistic update
    setState(prev => ({
      ...prev,
      isFavorited: !wasFavorited,
      loading: true,
    }));

    try {
      const response = await apiService.post('/favorites/toggle', {
        favoritable_type: contentType,
        favoritable_id: contentId,
      });

      if (response.success) {
        const finalState = {
          isFavorited: response.data.isFavorited,
          loading: false,
        };

        setState(prev => ({ ...prev, ...finalState }));

        // Emit global update event
        likesEventEmitter.emit('content-interaction-updated', {
          type: contentType,
          id: contentId,
          isLiked: state.isLiked,
          isFavorited: finalState.isFavorited,
          likesCount: state.likesCount,
        });
      } else {
        // Rollback on error
        setState(prev => ({
          ...prev,
          isFavorited: wasFavorited,
          loading: false,
        }));
      }
    } catch (error) {
      console.error('Error toggling favorite:', error);
      
      // Rollback on error
      setState(prev => ({
        ...prev,
        isFavorited: wasFavorited,
        loading: false,
      }));
    }
  };

  const refresh = async () => {
    if (isAuthenticated && contentId) {
      await checkStatus();
    }
  };

  return {
    ...state,
    toggleLike,
    toggleFavorite,
    refresh,
  };
};

// Utility function to format like counts
export const formatLikeCount = (count: number): string => {
  if (count < 1000) return count.toString();
  if (count < 1000000) return `${(count / 1000).toFixed(1)}k`;
  return `${(count / 1000000).toFixed(1)}M`;
};

// Global function to emit content updates from outside components
export const emitContentUpdate = (
  type: ContentType,
  id: number,
  data: Partial<LikeState>
) => {
  likesEventEmitter.emit('content-interaction-updated', {
    type,
    id,
    ...data,
  });
};