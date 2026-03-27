# 🚀 Guide de Démarrage Rapide - Rage Runner

## ⚡ Installation Express (5 minutes)

### 1. Télécharger Godot
- Allez sur https://godotengine.org/download
- Téléchargez **Godot 4.5** (Standard version)
- Extrayez l'archive et lancez l'exécutable

### 2. Ouvrir le Projet
1. Lancez Godot
2. Cliquez sur **"Importer"**
3. Cliquez sur **"Parcourir"**
4. Naviguez vers le dossier `rage_runner_game`
5. Sélectionnez le fichier `project.godot`
6. Cliquez sur **"Importer et Éditer"**

### 3. Lancer le Jeu
- Appuyez sur **F5** (ou cliquez sur le bouton ▶️ en haut à droite)
- Le jeu se lance !

## 🎮 Comment Jouer

### Contrôles
- **A** ou **←** : Aller à gauche
- **D** ou **→** : Aller à droite
- **Échap** : Mettre en pause

### Objectif
Évitez les commentaires rageux qui tombent ! Survivez jusqu'à la fin du timer pour gagner le niveau.

### Les Débuffs
Chaque commentaire qui vous touche applique un effet négatif :
- 🔵 **LENT** : Vous ralentit
- 🔴 **NUL** : Vous rétrécit
- 🟠 **FRAGILE** : Agrandit votre hitbox
- ⚫ **AVEUGLE** : Réduit votre visibilité
- 🟣 **CONFUS** : Inverse vos contrôles

## 🛠️ Personnalisation Rapide

### Changer la Difficulté
Ouvrez `scripts/game_manager.gd` (ligne 13) :

```gdscript
var level_config = {
    1: {"duration": 60, "spawn_rate": 2.0, "comment_speed": 200},
    #       ↑ Durée    ↑ Fréquence        ↑ Vitesse
}
```

- `duration` : Temps pour terminer le niveau (en secondes)
- `spawn_rate` : Temps entre chaque commentaire (plus petit = plus difficile)
- `comment_speed` : Vitesse de descente des commentaires

### Ajouter un Nouveau Commentaire
Dans `scripts/comment.gd` (ligne 11), ajoutez :

```gdscript
const COMMENT_TEXTS = {
    "lent": ["T'es trop LENT!", "Bouge plus vite!"],
    "nouveau": ["Votre texte ici!", "Autre texte!"],  # ← Nouveau type
}
```

Puis dans `scripts/player.gd` (ligne 73), ajoutez la logique :

```gdscript
match debuff_type:
    "lent":
        current_speed = BASE_SPEED * 0.5
    "nouveau":
        # Votre effet ici
        current_speed = BASE_SPEED * 0.3
```

## 📂 Structure Simple du Projet

```
rage_runner_game/
├── scripts/              # Tous les scripts GDScript
│   ├── game_manager.gd   # Gestion globale
│   ├── player.gd         # Contrôles du joueur
│   ├── comment.gd        # Logique des projectiles
│   └── ui/              # Scripts des menus
│
└── scenes/              # Toutes les scènes
    ├── game/            # Scènes de jeu
    └── ui/              # Interfaces utilisateur
```

## 🐛 Dépannage

### Le jeu ne se lance pas
✅ Vérifiez que vous avez Godot 4.5 (pas 3.x)
✅ Ouvrez bien le fichier `project.godot`

### Erreurs de script
✅ Vérifiez que tous les fichiers sont présents
✅ Regardez l'onglet "Sortie" en bas de l'éditeur

### Performance lente
✅ Fermez d'autres applications
✅ Réduisez `spawn_rate` dans la configuration des niveaux

## 🎯 Premiers Pas de Développement

### 1. Modifier un Menu
1. Dans Godot, allez dans `scenes/ui/`
2. Double-cliquez sur `main_menu.tscn`
3. Sélectionnez un Label ou Button
4. Modifiez les propriétés dans l'inspecteur à droite
5. Appuyez sur **Ctrl+S** pour sauvegarder
6. Testez avec **F5**

### 2. Changer les Couleurs
Dans `scripts/comment.gd` (ligne 28) :

```gdscript
const DEBUFF_COLORS = {
    "lent": Color(0.3, 0.3, 1.0),  # RVB de 0 à 1
    #            R    V    B
}
```

### 3. Modifier le Joueur
Ouvrez `scenes/game/player.tscn`, sélectionnez "Sprite2D", changez la couleur !

## 📚 Ressources Godot

- Documentation officielle : https://docs.godotengine.org/
- Tutoriels : https://godottutorials.com/
- Forum : https://forum.godotengine.org/
- Discord Godot FR : https://discord.gg/godotfr

## 💡 Idées d'Améliorations Simples

1. **Ajouter un compteur de vies** (modifiez `game_scene.gd`)
2. **Power-ups positifs** (dupliquez la logique des commentaires)
3. **Changez les formes** (remplacez ColorRect par Sprite2D avec images)
4. **Musique de fond** (ajoutez un AudioStreamPlayer)
5. **Animations** (utilisez AnimationPlayer sur le joueur)

## 🎨 Assets Gratuits Recommandés

- **Kenney.nl** : Sprites et sons gratuits
- **OpenGameArt.org** : Assets libres
- **Freesound.org** : Effets sonores

---

**Besoin d'aide ?** Consultez le README.md complet !

**Bon développement ! 🚀**
