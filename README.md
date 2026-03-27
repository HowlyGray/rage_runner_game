# 🎮 Rage Runner - Jeu Godot 4.5

## Description
**Rage Runner** est un jeu 2D d'évitement où le joueur doit esquiver des commentaires rageux qui tombent du haut de l'écran. Chaque commentaire inflige un débuff différent au joueur, rendant le jeu progressivement plus difficile.

## 🎯 Concept du Jeu
- Vue de dessus en 2D
- Le joueur contrôle un personnage en bas de l'écran
- Des commentaires rageux tombent du haut vers le bas
- Chaque commentaire touché applique un effet négatif temporaire

## 🎮 Débuffs Disponibles
1. **Lent** (Bleu) - Réduit la vitesse de déplacement de 50%
2. **Nul** (Rouge) - Réduit la taille du personnage
3. **Fragile** (Orange) - Augmente la zone de collision
4. **Aveugle** (Gris) - Réduit la visibilité du personnage
5. **Confus** (Violet) - Inverse les contrôles

## 🕹️ Contrôles
- **A / Flèche Gauche** : Déplacer à gauche
- **D / Flèche Droite** : Déplacer à droite
- **Échap** : Pause

## 📁 Structure du Projet

```
rage_runner_game/
├── project.godot           # Configuration du projet
├── icon.svg               # Icône du jeu
├── README.md              # Ce fichier
├── scripts/
│   ├── game_manager.gd    # Gestionnaire global du jeu
│   ├── audio_manager.gd   # Gestionnaire audio
│   ├── player.gd          # Script du joueur
│   ├── comment.gd         # Script des commentaires
│   ├── comment_spawner.gd # Générateur de commentaires
│   ├── game_scene.gd      # Scène principale de jeu
│   └── ui/
│       ├── title_screen.gd
│       ├── main_menu.gd
│       ├── settings_menu.gd
│       ├── credits_screen.gd
│       ├── pause_menu.gd
│       ├── game_over_screen.gd
│       ├── victory_screen.gd
│       ├── level_select.gd
│       └── level_transition.gd
└── scenes/
    ├── game/
    │   ├── player.tscn
    │   ├── comment.tscn
    │   └── game_scene.tscn
    └── ui/
        ├── title_screen.tscn
        ├── main_menu.tscn
        ├── settings_menu.tscn
        ├── credits_screen.tscn
        ├── pause_menu.tscn
        ├── game_over_screen.tscn
        ├── victory_screen.tscn
        ├── level_select.tscn
        └── level_transition.tscn
```

## 🎨 Fonctionnalités

### Menus Complets
- ✅ Title Screen (Écran titre)
- ✅ Main Menu (Menu principal)
- ✅ Settings (Paramètres audio)
- ✅ Credits (Crédits)
- ✅ Pause Menu (Menu pause)
- ✅ Game Over (Écran de défaite)
- ✅ Victory (Écran de victoire)
- ✅ Level Selection (Sélection de niveau)
- ✅ Level Transition (Transition entre niveaux)

### Système de Jeu
- ✅ Système de débuffs temporaires
- ✅ Système de score
- ✅ 5 niveaux avec difficulté progressive
- ✅ Sauvegarde du meilleur score
- ✅ Gestion des paramètres audio

### Niveaux
Chaque niveau augmente en difficulté :
1. **Niveau 1** : 60s - Facile
2. **Niveau 2** : 75s - Moyen
3. **Niveau 3** : 90s - Difficile
4. **Niveau 4** : 105s - Très Difficile
5. **Niveau 5** : 120s - Extrême

## 🚀 Installation et Utilisation

### Prérequis
- Godot Engine 4.5 ou supérieur

### Étapes
1. Téléchargez Godot 4.5 : https://godotengine.org/
2. Ouvrez Godot
3. Cliquez sur "Importer"
4. Naviguez vers le dossier `rage_runner_game`
5. Sélectionnez le fichier `project.godot`
6. Cliquez sur "Importer et éditer"

### Lancer le Jeu
- Appuyez sur **F5** dans l'éditeur Godot
- Ou cliquez sur le bouton "Lecture" ▶️

## 🎨 Personnalisation

### Ajouter de Nouveaux Débuffs
1. Ouvrez `scripts/comment.gd`
2. Ajoutez votre nouveau type dans `COMMENT_TEXTS` et `DEBUFF_COLORS`
3. Ouvrez `scripts/player.gd`
4. Ajoutez la logique dans `apply_debuff()` et `_on_debuff_expired()`

### Modifier la Difficulté
Ouvrez `scripts/game_manager.gd` et modifiez `level_config` :
```gdscript
var level_config = {
    1: {"duration": 60, "spawn_rate": 2.0, "comment_speed": 200},
    # ...
}
```

### Changer les Contrôles
1. Ouvrez le projet dans Godot
2. Allez dans `Projet > Paramètres du projet > Carte des entrées`
3. Modifiez les touches assignées

## 📊 Système de Score
- Score de base pour la survie
- Bonus de temps pour chaque niveau complété
- Pénalité de -10 points par débuff reçu
- Sauvegarde automatique du meilleur score

## 🔧 Améliorations Futures Possibles
- [ ] Ajouter des power-ups positifs
- [ ] Système de vies
- [ ] Mode multijoueur
- [ ] Graphismes et animations améliorés
- [ ] Musique et effets sonores
- [ ] Système de succès/achievements
- [ ] Classement en ligne
- [ ] Boss de fin de niveau

## 📝 Notes Techniques
- Engine: Godot 4.5
- Langage: GDScript
- Résolution: 1280x720
- Mode: 2D

## 👨‍💻 Auteur
Stéphane (Mosaic Mind)

## 📜 Licence
Projet éducatif - Libre d'utilisation et de modification

## 🎯 Objectif Pédagogique
Ce projet est conçu pour apprendre :
- La structure d'un projet Godot complet
- Le système de scènes et de nœuds
- La gestion d'état avec des singletons (Autoload)
- Les systèmes de débuffs/buffs temporaires
- La navigation entre menus
- La sauvegarde de données
- La gestion audio

---

**Amusez-vous bien et restez positifs ! 💪**
