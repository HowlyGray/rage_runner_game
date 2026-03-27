# ⭐ Système de Confiance en Soi - Version 1.3

## 🎯 Concept

Le **système de confiance en soi** est une barre dynamique qui représente le moral et la détermination du joueur. Elle commence à 50% et évolue en fonction de vos performances, créant un système de **momentum** qui récompense les joueurs habiles.

---

## 📊 La Barre de Confiance

### Affichage
```
Position: Coin inférieur droit (en dessous de la barre d'affliction)

┌────────────────┐
│ 😎 CONFIANT    │  ← État actuel
│ Confiance: 85% │  ← Pourcentage
│ [████████    ] │  ← Barre de progression
└────────────────┘
```

### Valeurs
- **Minimum** : 0% (paniqué)
- **Départ** : 50% (serein)
- **Maximum** : 100% (immunité émotionnelle)

---

## 🎨 Les 5 États de Confiance

### 1️⃣ PANIQUÉ (0-24%)
```
┌────────────────┐
│ 😰 PANIQUÉ     │  ← Rouge
│ Confiance: 15% │
│ [███         ] │
└────────────────┘
```
**Effet** : Moral très bas
**Cause** : Prendre beaucoup de coups
**Comportement** : Jouez prudemment

### 2️⃣ INQUIET (25-49%)
```
┌────────────────┐
│ 😟 INQUIET     │  ← Orange
│ Confiance: 38% │
│ [█████       ] │
└────────────────┘
```
**Effet** : Moral faible
**Cause** : Quelques erreurs
**Comportement** : Récupérez la confiance

### 3️⃣ SEREIN (50-74%)
```
┌────────────────┐
│ 😊 SEREIN      │  ← Bleu clair
│ Confiance: 62% │
│ [███████     ] │
└────────────────┘
```
**Effet** : Moral normal
**Cause** : État d'équilibre
**Comportement** : État initial

### 4️⃣ CONFIANT (75-99%)
```
┌────────────────┐
│ 😎 CONFIANT    │  ← Vert
│ Confiance: 87% │
│ [█████████   ] │
└────────────────┘
```
**Effet** : Moral élevé
**Cause** : Bonnes performances
**Comportement** : Continuez !

### 5️⃣ IMMUNITÉ ÉMOTIONNELLE (100%) ⭐
```
┌─────────────────────┐
│ ⭐ IMMUNITÉ ÉMOTIONNELLE ⭐ │  ← Doré brillant
│ Confiance: MAXIMUM! │
│ [████████████]      │
│ 6.3s restantes      │  ← Timer
└─────────────────────┘
```
**Effet** : INVINCIBLE aux débuffs !
**Durée** : 5-8 secondes (aléatoire)
**Teinte** : Joueur devient doré
**Après** : Retour à 50%

---

## 📈 Comment Gagner de la Confiance

### 🎯 Esquiver des Commentaires Rageux
**Gain** : +5% par esquive

**Système de Combo :**
- 1 esquive : +5%
- 2 esquives : +5% + (2×2%) = +9%
- 3 esquives : +5% + (3×2%) = +11%
- 4 esquives : +5% + (4×2%) = +13%
- ...

**Timeout** : 3 secondes entre esquives pour maintenir le combo

**Comment esquiver ?**
- Un commentaire passe à côté sans vous toucher
- Plus vous esquivez de suite, plus le bonus augmente !

### ⚔️ Éliminer des Ennemis
**Gain** : +10% par ennemi tué

**Stratégie** :
- Tuer un WALL (5 PV) = Beaucoup de tirs = Satisfaisant = +10%
- Tuer un SHOOTER (3 PV) = Rapide = +10%
- Tuer 10 ennemis = 100% = Immunité !

### 🌟 Ramasser des Compliments
**Gain** : +8% par compliment

**Double avantage** :
- +8% de confiance
- Réduit l'affliction de 1.5-3s
- +20 points de score

---

## 📉 Comment Perdre de la Confiance

### 💬 Touché par un Commentaire Rageux
**Perte** : -15%

**Impact** :
- Débuff appliqué (sauf si immunité)
- Confiance réduite
- Peut tomber en INQUIET

### 💔 Prendre des Dégâts (Ennemi/Projectile)
**Perte** : -20%

**Impact** :
- Perte de 1 PV
- Grosse réduction de confiance
- Peut tomber en PANIQUÉ

**Note** : Prendre des dégâts fait PLUS mal à la confiance que les commentaires !

---

## ⭐ Immunité Émotionnelle

### Activation
**Condition** : Atteindre 100% de confiance

**Déclenchement automatique** :
1. La barre atteint 100%
2. L'immunité s'active immédiatement
3. Timer démarre (5-8 secondes aléatoire)

### Effets

**1. Immunité aux Débuffs**
```
Commentaire rageux touché → Flash doré → AUCUN DÉBUFF !
```
- Les commentaires ne font RIEN
- L'affliction n'augmente pas
- Vous pouvez foncer dessus sans crainte

**2. Teinte Dorée**
```
Joueur normal:  🟢 Vert (ou blanc)
Joueur immunisé: ✨ Doré brillant ✨
```

**3. Timer Visible**
```
⭐ IMMUNITÉ ÉMOTIONNELLE ⭐
6.3s restantes  ← Compte à rebours
```

### Fin de l'Immunité
**Quand le timer atteint 0 :**
1. Retour à la couleur normale
2. Confiance retombe à 50%
3. Vulnérable à nouveau aux débuffs

**Dégâts et Compliments :**
- Prendre des dégâts → Perd 20% de confiance MÊME en immunité
- Ramasser compliments → Peut prolonger l'immunité !
- Tuer ennemis → Peut prolonger l'immunité !

**Exemple prolongation** :
```
100% → Immunité (7s)
↓
Tuer ennemi (+10%) → Nouvelle immunité (6s)
↓
Ramasser compliment (+8%) → Nouvelle immunité (8s)
↓
Etc...
```

---

## 🎮 Stratégies de Jeu

### 🏆 Stratégie "Momentum Star" (Maximum Score)
```
1. Esquiver 5-6 commentaires de suite (combo)
   → Confiance ~80%
2. Ramasser 2-3 compliments
   → Confiance = 100% → IMMUNITÉ !
3. Foncer à travers les commentaires
4. Tuer tous les ennemis
5. Ramasser plus de compliments
   → Prolonger l'immunité !
6. Repeat = Score massif
```

**Avantages** :
- ✅ Score maximal
- ✅ Sensation de puissance
- ✅ Immunité quasi-permanente

**Difficultés** :
- ❌ Requiert du skill
- ❌ Une erreur = perte du momentum

### 🛡️ Stratégie "Stable" (Débutant)
```
1. Maintenir 50-75% de confiance
2. Jouer prudemment
3. Éviter les dégâts
4. Ne pas viser l'immunité
5. Focus survie
```

**Avantages** :
- ✅ Peu de risque
- ✅ Confiance stable
- ✅ Bon pour apprendre

**Inconvénients** :
- ❌ Pas d'immunité
- ❌ Score moyen

### ⚡ Stratégie "Combo Master" (Intermédiaire)
```
1. Focus sur les COMBOS d'esquive
2. Éviter 8-10 commentaires de suite
   → +5% + (10×2%) = +25% par esquive !
3. Atteindre 100% rapidement
4. Utiliser immunité pour ramasser compliments
```

**Avantages** :
- ✅ Immunité fréquente
- ✅ Très satisfaisant
- ✅ Bon équilibre risque/récompense

---

## 💡 Tips & Tricks

### Tip #1 : Le Combo d'Esquive
> Maintenez un combo d'esquive pour des gains exponentiels !
> 10 esquives = +25% par esquive = +250% au total !

### Tip #2 : Priorité Confiance vs Survie
> Si confiance < 25%, PRIORITÉ = Confiance
> Cherchez compliments et ennemis faciles
> Si confiance > 75%, PRIORITÉ = Score
> Visez l'immunité !

### Tip #3 : Gestion de l'Immunité
> Pendant l'immunité :
> 1. Ramassez TOUS les compliments
> 2. Tuez TOUS les ennemis visibles
> 3. Ignorez les commentaires
> → Prolongez au maximum !

### Tip #4 : Esquive Calculée
> Ne pas esquiver au hasard !
> Prévoyez votre trajectoire 2-3 secondes à l'avance
> Maximisez les esquives volontaires

### Tip #5 : Récupération Rapide
> Si confiance < 25% (PANIQUÉ) :
> → Cherchez 3 compliments (+24%)
> → Tuez 1 ennemi (+10%)
> → Total = +34% → Retour SEREIN

### Tip #6 : Le Buff + Immunité
> BUFF (+30% vitesse) + IMMUNITÉ = SURPUISSANCE
> Vous êtes :
> - Plus rapide
> - Immunisé aux débuffs
> - Teinte dorée
> = Mode Dieu !

---

## 📊 Tableaux de Gains/Pertes

### Gains de Confiance
| Action | Gain | Notes |
|--------|------|-------|
| Esquive simple | +5% | Base |
| Esquive combo x2 | +9% | +4% bonus |
| Esquive combo x3 | +11% | +6% bonus |
| Esquive combo x5 | +15% | +10% bonus |
| Esquive combo x10 | +25% | +20% bonus ! |
| Tuer ennemi | +10% | Tout type |
| Ramasser compliment | +8% | + autres avantages |

### Pertes de Confiance
| Action | Perte | Notes |
|--------|-------|-------|
| Touché par commentaire | -15% | + Débuff |
| Prendre dégât (ennemi) | -20% | + Perte 1 PV |
| Prendre dégât (projectile) | -20% | + Perte 1 PV |

### Temps pour Atteindre 100%
| Méthode | Actions Requises |
|---------|------------------|
| Compliments seuls | 7 compliments (50→100) |
| Ennemis seuls | 5 ennemis (50→100) |
| Esquives simples | 10 esquives (50→100) |
| Combo x5 | 4 esquives (50→100) |
| Mixte (optimal) | 2 compliments + 3 ennemis |

---

## 🎨 Codes Couleur Visuels

### Barre de Confiance
```
0-24%   → 🔴 Rouge     (PANIQUÉ)
25-49%  → 🟠 Orange    (INQUIET)
50-74%  → 🔵 Bleu      (SEREIN)
75-99%  → 🟢 Vert      (CONFIANT)
100%    → ⭐ Doré      (IMMUNITÉ)
```

### Joueur
```
Normal       → ⚪ Blanc
Buff         → 🟢 Vert (vitesse +30%)
Immunité     → ✨ Doré (débuffs ignorés)
Buff+Immunité→ 🌟 Doré brillant (MODE DIEU)
```

---

## 🔧 Configuration Technique

### Constantes (dans player.gd)
```gdscript
# Gains
CONFIDENCE_DODGE_GAIN = 5.0      # Par esquive
CONFIDENCE_COMBO_BONUS = 2.0     # Par niveau de combo
CONFIDENCE_KILL_GAIN = 10.0      # Par ennemi
CONFIDENCE_COMPLIMENT_GAIN = 8.0 # Par compliment

# Pertes
CONFIDENCE_HIT_LOSS = 15.0       # Commentaire rageux
CONFIDENCE_DAMAGE_LOSS = 20.0    # Dégât ennemi

# Immunité
IMMUNITY_MIN_DURATION = 5.0      # 5 secondes min
IMMUNITY_MAX_DURATION = 8.0      # 8 secondes max

# Combo
DODGE_COMBO_TIMEOUT = 3.0        # 3s entre esquives
```

### Modifier les Valeurs
Pour un jeu plus facile :
```gdscript
CONFIDENCE_DODGE_GAIN = 8.0      # Esquives plus rewarding
CONFIDENCE_HIT_LOSS = 10.0       # Erreurs moins punissantes
```

Pour un jeu plus difficile :
```gdscript
CONFIDENCE_DODGE_GAIN = 3.0      # Esquives moins rewarding
CONFIDENCE_HIT_LOSS = 25.0       # Erreurs très punissantes
IMMUNITY_MAX_DURATION = 5.0      # Immunité plus courte
```

---

## 🎯 Objectifs de Design

### Pourquoi ce Système ?

**Problème v1.2 :**
- Gameplay pouvait être monotone
- Pas de récompense pour les bonnes performances
- Débuffs trop punitifs sans compensation

**Solution v1.3 :**
- **Momentum** : Bonnes performances = Récompenses
- **Immunité** : État de puissance temporaire
- **Combos** : Skill rewarded exponentiellement
- **Dynamisme** : Gameplay plus varié et satisfaisant

### Boucle de Gameplay Complète
```
Esquiver + Tuer + Ramasser
        ↓
Confiance augmente
        ↓
Atteindre 100%
        ↓
IMMUNITÉ ÉMOTIONNELLE ⭐
        ↓
Ignorer débuffs + Tuer + Ramasser
        ↓
Prolonger immunité
        ↓
Score massif + Satisfaction
        ↓
Immunité termine → 50%
        ↓
Recommencer le cycle
```

---

## 📚 Intégration avec Autres Systèmes

### Confiance + Affliction
```
Haute confiance + Basse affliction = OPTIMAL
Haute confiance + Haute affliction = Gérable
Basse confiance + Basse affliction = OK
Basse confiance + Haute affliction = CRITIQUE
```

### Confiance + Buff
```
BUFF seul           → +30% vitesse
IMMUNITÉ seule      → Ignore débuffs
BUFF + IMMUNITÉ     → MODE SURPUISSANCE
```

### Confiance + Vie
```
3 PV + 100% confiance = Excellent
1 PV + 100% confiance = Dangereux mais powerful
3 PV + 0% confiance   = Safe mais lent
1 PV + 0% confiance   = CRITIQUE
```

---

## 🏁 Récapitulatif Ultra-Rapide

**CONFIANCE = MOMENTUM**

```
Gagner :
✅ Esquive (+5% + combo bonus)
✅ Tuer ennemi (+10%)
✅ Ramasser compliment (+8%)

Perdre :
❌ Touché commentaire (-15%)
❌ Prendre dégât (-20%)

100% = ⭐ IMMUNITÉ (5-8s)
  → Débuffs ignorés
  → Joueur doré
  → MODE POWER

États :
😰 0-24%   PANIQUÉ
😟 25-49%  INQUIET
😊 50-74%  SEREIN
😎 75-99%  CONFIANT
⭐ 100%    IMMUNITÉ
```

---

**Maîtrisez votre confiance, devenez invincible ! ⭐💪**
