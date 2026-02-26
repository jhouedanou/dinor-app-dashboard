# Estimation des Temps de Développement – Dinor App (Public peu alphabétisé)

> **Note :** Ce document présente uniquement les estimations de temps de développement. Aucune fonctionnalité n'est implémentée ici.

---

## Hypothèses de base

- Stack actuelle : Laravel (back-end) + PWA / Flutter (mobile)
- Équipe estimée : 1 chef de projet, 2–3 développeurs full-stack, 1 designer UX/UI, 1 testeur QA
- Les estimations incluent : conception, développement, tests unitaires et intégration, recette QA
- **S** = Semaine(s) | **J** = Jour(s)

---

## 1. Fonctionnalités ultra pratiques (vie quotidienne)

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 1.1 | 🎛️ Mode "Cuisine guidée pas à pas" | L'app parle, attend le "Suivant", peut répéter l'étape, minuteur vocal intégré | **3–4 S** |
| 1.2 | ⏲️ Minuteur intelligent intégré | Timer auto selon recette, sonnerie + voix, fonctionne écran éteint (background service) | **1–2 S** |
| 1.3 | 📶 Mode hors connexion (Offline) | Téléchargement de recettes en Wi-Fi, fonctionne sans internet | **2–3 S** |
| 1.4 | 🔋 Mode faible consommation | Version légère, vidéos compressées, optimisée anciens téléphones | **1–2 S** |

**Sous-total : 7–11 semaines**

---

## 2. Fonctionnalités adaptées au marché local

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 2.1 | 🛒 Mode "Marché" | Images ingrédients à montrer au vendeur, liste visuelle cochable, estimation budget | **2–3 S** |
| 2.2 | 💰 Calculateur de budget simple | "Tu as 2000 FCFA ? Voici ce que tu peux cuisiner." Sélection visuelle par montant | **1–2 S** |
| 2.3 | 📦 Suggestions selon produits disponibles | L'utilisateur clique sur des icônes d'ingrédients → recettes proposées | **1–2 S** |

**Sous-total : 4–7 semaines**

---

## 3. Fonctionnalités sociales simples

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 3.1 | 🎤 Partage de recette en audio | Enregistrement vocal, partage sans écrire | **2–3 S** |
| 3.2 | 📸 Partage photo ultra simple | Bouton appareil, publication sans texte, réactions en icônes | **1 S** |
| 3.3 | 🏆 Défis communautaires simples | Défi thématique, envoi de photo, badges récompenses | **2–3 S** |

**Sous-total : 5–7 semaines**

---

## 4. Fonctionnalités éducatives utiles

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 4.1 | 👶 Mode "Maman" | Section recettes bébé, hygiène, conservation, portions enfants (audio + visuel) | **2–3 S** |
| 4.2 | 🧼 Conseils hygiène illustrés | Animations lavage des mains, conservation huile, cuisson sécurisée | **1–2 S** |

**Sous-total : 3–5 semaines**

---

## 5. Fonctionnalités différenciantes fortes

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 5.1 | 🎙️ Assistant vocal local | Commande vocale type "Dinor, comment faire le riz ?" | **4–6 S** |
| 5.2 | 🧑🏾‍🍳 Mode "Apprendre à cuisiner" | Niveaux débutant / intermédiaire / expert avec progression vocale | **3–4 S** |
| 5.3 | 🧭 Mode ultra simplifié (Senior) | Très grosses icônes, très peu d'options, navigation minimaliste | **1–2 S** |

**Sous-total : 8–12 semaines**

---

## 6. Fonctionnalités commerciales intelligentes

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 6.1 | 🎁 Coupons visuels | Coupon Dinor en image / QR code à montrer au commerçant | **1–2 S** |
| 6.2 | 🏪 Carte des points de vente | Carte simplifiée avec icônes magasins (intégration maps) | **1–2 S** |
| 6.3 | 📢 Messages promotionnels audio | Publicité vocale courte au lieu de texte publicitaire | **1 S** |

**Sous-total : 3–5 semaines**

---

## 7. Fonctionnalités émotionnelles

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 7.1 | ❤️ "Cuisine de ma région" | Sélection de région, recettes locales adaptées | **1–2 S** |
| 7.2 | 👵 "Recette de grand-mère" | Voix de femme âgée, narration authentique | **1–2 S** |
| 7.3 | 🎉 Mode événement | Contenus adaptés selon saison : Ramadan, Noël, Mariage, Baptême | **2–3 S** |

**Sous-total : 4–7 semaines**

---

## 8. Fonctionnalités d'accessibilité renforcée

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 8.1 | Texte optionnel agrandi | Taille de police ajustable dans les paramètres | **0,5 S** |
| 8.2 | Commandes vocales | Navigation entière par commande vocale | **3–4 S** |
| 8.3 | Bouton SOS répétition | Répétition de l'étape en cours d'un seul toucher | **0,5 S** |
| 8.4 | Interface à contraste élevé | Mode contraste élevé activable | **0,5 S** |

**Sous-total : 4,5–5,5 semaines**

---

## 9. Fonctionnalités terrain (innovation)

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 9.1 | 📲 Partage Bluetooth / Wi-Fi direct | Envoi de recette sans internet (Nearby Share / NFC / BLE) | **3–5 S** |
| 9.2 | 🏫 Mode formation collective | Mode projection écran, utilisable en atelier cuisine / ONG | **2–3 S** |

**Sous-total : 5–8 semaines**

---

## 10. Socle UX – Navigation 100% icônes et multilangue

| # | Fonctionnalité | Description courte | Estimation |
|---|----------------|--------------------|-----------|
| 10.1 | Navigation par icônes (riz, poulet, poisson…) | Refonte totale de la navigation sans texte | **2–3 S** |
| 10.2 | Support multilangue (Dioula, Baoulé, Wolof, Bambara) | Internationalisation + enregistrements audio | **3–5 S** |
| 10.3 | Voix off locale intégrée à toutes les recettes | Production audio + intégration dans le player | **3–4 S** |
| 10.4 | Système de réactions simplifié (👍 ❤️ ⭐) | Remplace les commentaires textuels | **0,5 S** |
| 10.5 | Partage WhatsApp simplifié (vidéo + audio) | Deep link WhatsApp avec vidéo et message pré-rempli | **0,5–1 S** |
| 10.6 | Gamification (badges "Bonne cuisinière", "Reine du riz"…) | Système de badges avec encouragements vocaux | **1–2 S** |

**Sous-total : 10–16 semaines**

---

## Récapitulatif global

| Catégorie | Min | Max |
|-----------|-----|-----|
| 1. Vie quotidienne | 7 S | 11 S |
| 2. Marché local | 4 S | 7 S |
| 3. Social simple | 5 S | 7 S |
| 4. Éducatif | 3 S | 5 S |
| 5. Différenciant fort | 8 S | 12 S |
| 6. Commercial | 3 S | 5 S |
| 7. Émotionnel | 4 S | 7 S |
| 8. Accessibilité | 4,5 S | 5,5 S |
| 9. Terrain / Innovation | 5 S | 8 S |
| 10. Socle UX / Langue | 10 S | 16 S |
| **TOTAL** | **~53,5 S** | **~83,5 S** |

---

## Estimation par priorité stratégique

Selon les 6 priorités identifiées :

| Priorité | Fonctionnalité | Estimation |
|----------|----------------|-----------|
| 🥇 1 | Mode audio complet (voix off, TTS, commandes vocales) | **5–8 S** |
| 🥈 2 | Navigation 100% icônes (refonte UX) | **2–3 S** |
| 🥉 3 | Mode offline (téléchargement recettes) | **2–3 S** |
| 4 | Recettes économiques (contenu + format) | **1–2 S** |
| 5 | Budget intelligent (calculateur visuel) | **1–2 S** |
| 6 | Partage WhatsApp simplifié | **0,5–1 S** |

**Total priorités hautes : ~12–19 semaines** (MVP accessible)

---

## Recommandation de phasage

### Phase 1 – MVP Accessible (3–4 mois)
- Navigation 100% icônes
- Voix off sur toutes les recettes existantes
- Mode offline de base
- Partage WhatsApp
- Réactions icônes

### Phase 2 – Engagement (2–3 mois)
- Mode "Cuisine guidée pas à pas"
- Minuteur vocal
- Calculateur de budget
- Mode "Marché"
- Gamification badges

### Phase 3 – Différenciation (3–4 mois)
- Assistant vocal local
- Mode "Apprendre à cuisiner"
- Défis communautaires
- Mode événement (Ramadan, fêtes…)
- Mode Maman

### Phase 4 – Innovation (3–4 mois)
- Partage Bluetooth / Wi-Fi direct
- Mode formation collective
- Support multilangue complet (Dioula, Baoulé, Wolof, Bambara)
- Mode ultra simplifié Senior

---

*Document généré le 20/02/2026 – Estimations à valider avec l'équipe technique.*
