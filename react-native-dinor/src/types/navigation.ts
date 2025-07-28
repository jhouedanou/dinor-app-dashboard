/**
 * Types de navigation pour React Navigation
 */

export type RootStackParamList = {
  Home: undefined;
  Recipes: undefined;
  Tips: undefined;
  Events: undefined;
  DinorTV: undefined;
  Profile: undefined;
  RecipeDetail: { id: number; recipe: any };
  TipDetail: { id: number; tip: any };
  EventDetail: { id: number; event: any };
};

export type TabParamList = {
  Home: undefined;
  Recipes: undefined;
  Tips: undefined;
  Events: undefined;
  DinorTV: undefined;
  Profile: undefined;
};

declare global {
  namespace ReactNavigation {
    interface RootParamList extends RootStackParamList {}
  }
} 