/**
 * DATA STORE - GESTION DES DONNÉES APPLICATIVES
 * 
 * FIDÉLITÉ FONCTIONNELLE :
 * - Cache des données (recipes, tips, events)
 * - Gestion loading states
 * - Actions CRUD identiques Vue
 * - Persistance locale avec AsyncStorage
 */

import { create } from 'zustand';
import apiService from '@/services/api';

interface Recipe {
  id: number;
  title: string;
  description: string;
  short_description?: string;
  image?: string;
  likes_count: number;
  is_liked: boolean;
  total_time?: number;
  difficulty?: string;
  created_at: string;
}

interface Tip {
  id: number;
  title: string;
  content: string;
  image?: string;
  likes_count: number;
  is_liked: boolean;
  estimated_time?: number;
  difficulty_level?: string;
  created_at: string;
}

interface Event {
  id: number;
  title: string;
  description: string;
  date: string;
  location?: string;
  image?: string;
  likes_count: number;
  is_liked: boolean;
  created_at: string;
}

interface ApiResponse {
  success: boolean;
  data?: any;
  message?: string;
  is_liked?: boolean;
  likes_count?: number;
}

interface DataState {
  // État des données
  recipes: Recipe[];
  tips: Tip[];
  events: Event[];
  
  // États de chargement
  recipesLoading: boolean;
  tipsLoading: boolean;
  eventsLoading: boolean;
  
  // Erreurs
  recipesError: string | null;
  tipsError: string | null;
  eventsError: string | null;
  
  // Actions RECIPES
  fetchRecipes: (params?: any) => Promise<Recipe[]>;
  fetchRecipe: (id: number) => Promise<Recipe | null>;
  setRecipes: (recipes: Recipe[]) => void;
  updateRecipe: (id: number, updates: Partial<Recipe>) => void;
  
  // Actions TIPS
  fetchTips: (params?: any) => Promise<Tip[]>;
  fetchTip: (id: number) => Promise<Tip | null>;
  setTips: (tips: Tip[]) => void;
  updateTip: (id: number, updates: Partial<Tip>) => void;
  
  // Actions EVENTS
  fetchEvents: (params?: any) => Promise<Event[]>;
  fetchEvent: (id: number) => Promise<Event | null>;
  setEvents: (events: Event[]) => void;
  updateEvent: (id: number, updates: Partial<Event>) => void;
  
  // Actions communes
  toggleLike: (type: 'recipes' | 'tips' | 'events', id: number) => Promise<boolean>;
  clearData: () => void;
}

export const useDataStore = create<DataState>((set, get) => ({
  // État initial
  recipes: [],
  tips: [],
  events: [],
  
  recipesLoading: false,
  tipsLoading: false,
  eventsLoading: false,
  
  recipesError: null,
  tipsError: null,
  eventsError: null,

  // RECIPES Actions
  fetchRecipes: async (params = {}) => {
    set({ recipesLoading: true, recipesError: null });
    
    try {
      const data = await apiService.getRecipes(params);
      
      if (data.success) {
        const recipes = data.data || [];
        set({ recipes, recipesLoading: false });
        console.log('✅ [Data Store] Recettes chargées:', recipes.length);
        return recipes;
      } else {
        throw new Error(data.message || 'Erreur lors du chargement des recettes');
      }
    } catch (error: any) {
      console.error('❌ [Data Store] Erreur fetchRecipes:', error.message);
      set({ recipesError: error.message, recipesLoading: false });
      return [];
    }
  },

  fetchRecipe: async (id: number) => {
    try {
      const data = await apiService.getRecipe(id);
      
      if (data.success) {
        const recipe = data.data;
        
        // Mettre à jour la recette dans la liste si elle existe
        const state = get();
        const updatedRecipes = state.recipes.map(r => 
          r.id === id ? { ...r, ...recipe } : r
        );
        
        // Ajouter la recette si elle n'existe pas
        if (!state.recipes.find(r => r.id === id)) {
          updatedRecipes.push(recipe);
        }
        
        set({ recipes: updatedRecipes });
        console.log('✅ [Data Store] Recette chargée:', recipe.title);
        return recipe;
      } else {
        throw new Error(data.message || 'Erreur lors du chargement de la recette');
      }
    } catch (error: any) {
      console.error('❌ [Data Store] Erreur fetchRecipe:', error.message);
      return null;
    }
  },

  setRecipes: (recipes: Recipe[]) => {
    set({ recipes });
  },

  updateRecipe: (id: number, updates: Partial<Recipe>) => {
    const state = get();
    const updatedRecipes = state.recipes.map(recipe =>
      recipe.id === id ? { ...recipe, ...updates } : recipe
    );
    set({ recipes: updatedRecipes });
  },

  // TIPS Actions (structure identique)
  fetchTips: async (params = {}) => {
    set({ tipsLoading: true, tipsError: null });
    
    try {
      const data = await apiService.getTips(params);
      
      if (data.success) {
        const tips = data.data || [];
        set({ tips, tipsLoading: false });
        console.log('✅ [Data Store] Astuces chargées:', tips.length);
        return tips;
      } else {
        throw new Error(data.message || 'Erreur lors du chargement des astuces');
      }
    } catch (error: any) {
      console.error('❌ [Data Store] Erreur fetchTips:', error.message);
      set({ tipsError: error.message, tipsLoading: false });
      return [];
    }
  },

  fetchTip: async (id: number) => {
    try {
      const data = await apiService.getTip(id);
      
      if (data.success) {
        const tip = data.data;
        
        const state = get();
        const updatedTips = state.tips.map(t => 
          t.id === id ? { ...t, ...tip } : t
        );
        
        if (!state.tips.find(t => t.id === id)) {
          updatedTips.push(tip);
        }
        
        set({ tips: updatedTips });
        console.log('✅ [Data Store] Astuce chargée:', tip.title);
        return tip;
      } else {
        throw new Error(data.message || 'Erreur lors du chargement de l\'astuce');
      }
    } catch (error: any) {
      console.error('❌ [Data Store] Erreur fetchTip:', error.message);
      return null;
    }
  },

  setTips: (tips: Tip[]) => {
    set({ tips });
  },

  updateTip: (id: number, updates: Partial<Tip>) => {
    const state = get();
    const updatedTips = state.tips.map(tip =>
      tip.id === id ? { ...tip, ...updates } : tip
    );
    set({ tips: updatedTips });
  },

  // EVENTS Actions (structure identique)
  fetchEvents: async (params = {}) => {
    set({ eventsLoading: true, eventsError: null });
    
    try {
      const data = await apiService.getEvents(params);
      
      if (data.success) {
        const events = data.data || [];
        set({ events, eventsLoading: false });
        console.log('✅ [Data Store] Événements chargés:', events.length);
        return events;
      } else {
        throw new Error(data.message || 'Erreur lors du chargement des événements');
      }
    } catch (error: any) {
      console.error('❌ [Data Store] Erreur fetchEvents:', error.message);
      set({ eventsError: error.message, eventsLoading: false });
      return [];
    }
  },

  fetchEvent: async (id: number) => {
    try {
      const data = await apiService.getEvent(id);
      
      if (data.success) {
        const event = data.data;
        
        const state = get();
        const updatedEvents = state.events.map(e => 
          e.id === id ? { ...e, ...event } : e
        );
        
        if (!state.events.find(e => e.id === id)) {
          updatedEvents.push(event);
        }
        
        set({ events: updatedEvents });
        console.log('✅ [Data Store] Événement chargé:', event.title);
        return event;
      } else {
        throw new Error(data.message || 'Erreur lors du chargement de l\'événement');
      }
    } catch (error: any) {
      console.error('❌ [Data Store] Erreur fetchEvent:', error.message);
      return null;
    }
  },

  setEvents: (events: Event[]) => {
    set({ events });
  },

  updateEvent: (id: number, updates: Partial<Event>) => {
    const state = get();
    const updatedEvents = state.events.map(event =>
      event.id === id ? { ...event, ...updates } : event
    );
    set({ events: updatedEvents });
  },

  // Action commune TOGGLE LIKE (identique Vue)
  toggleLike: async (type: 'recipes' | 'tips' | 'events', id: number) => {
    try {
      // Type mapping pour l'API (identique Vue)
      const apiType = type === 'recipes' ? 'recipe' : type === 'tips' ? 'tip' : 'event';
      
      const data = await apiService.toggleLike(apiType, id) as ApiResponse;
      
      if (data.success) {
        // Mettre à jour l'état local (optimistic update)
        const state = get();
        const items = state[type];
        const updatedItems = items.map((item: any) =>
          item.id === id
            ? {
                ...item,
                is_liked: data.is_liked || false,
                likes_count: data.likes_count || item.likes_count + (data.is_liked ? 1 : -1)
              }
            : item
        );
        
        set({ [type]: updatedItems });
        
        console.log('🔄 [Data Store] Like togglé:', { type, id, liked: data.is_liked });
        return data.is_liked || false;
      } else {
        throw new Error(data.message || 'Erreur lors du toggle like');
      }
    } catch (error: any) {
      console.error('❌ [Data Store] Erreur toggleLike:', error.message);
      return false;
    }
  },

  // Clear toutes les données
  clearData: () => {
    set({
      recipes: [],
      tips: [],
      events: [],
      recipesError: null,
      tipsError: null,
      eventsError: null,
    });
    console.log('🗑️ [Data Store] Toutes les données effacées');
  },
}));