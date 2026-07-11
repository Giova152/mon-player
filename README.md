# MonPlayer — Lecteur de musique hors ligne pour iOS

<p align="center">
  <img src="assets/images/icon.png" width="100" alt="MonPlayer Icon" />
</p>

<p align="center">
  <strong>MonPlayer</strong> — Votre musique, hors ligne.<br>
  Application iOS de lecture musicale locale, construite avec Flutter.
</p>

---

## Fonctionnalités

- 📁 **Dossier automatique** — Crée `Sur mon iPhone/MonPlayer/` au premier lancement
- 🔍 **Scan automatique** — Détecte les fichiers mp3, m4a, wav, flac, aac, ogg
- 🎵 **Lecteur complet** — Lecture, pause, suivant, précédent, barre de progression
- 🌙 **Arrière-plan** — Lecture continue en arrière-plan + contrôles écran verrouillé
- ❤️ **Favoris** — Marquez vos morceaux préférés
- 📋 **Playlists** — Créez, renommez, supprimez, réordonnez
- 🔄 **Shuffle & Repeat** — Lecture aléatoire et modes de répétition
- ⚡ **Vitesse de lecture** — De 0.5x à 2x
- 🎨 **Thème Apple Music** — Mode clair / sombre, animations fluides, Material 3
- 💾 **Persistance** — Reprise à la dernière position au redémarrage (Hive)
- 🖼️ **Métadonnées ID3** — Pochette, artiste, album, titre extraits automatiquement

---

## Stack technique

| Composant | Package |
|-----------|---------|
| Audio | `just_audio` + `just_audio_background` |
| Arrière-plan | `audio_service` |
| État | `flutter_riverpod` |
| Stockage | `hive` + `hive_flutter` |
| Métadonnées | `flutter_media_metadata` |
| Système de fichiers | `path_provider` + `path` |
| Architecture | Clean Architecture (Domain / Data / Presentation) |

---

## Prérequis

- **Flutter SDK** ≥ 3.10 (stable)
- **Xcode** ≥ 14 (macOS requis)
- **iOS** ≥ 14.0
- **CocoaPods** installé (`sudo gem install cocoapods`)

---

## Installation & Lancement sous Xcode

### 1. Cloner / copier le projet

```bash
cd votre-dossier
# Le projet est déjà dans mon_player/
```

### 2. Installer les dépendances Flutter

```bash
cd mon_player
flutter pub get
```

### 3. Installer les pods iOS

```bash
cd ios
pod install
cd ..
```

### 4. Ouvrir dans Xcode

```bash
open ios/Runner.xcworkspace
```

> ⚠️ Ouvrez **Runner.xcworkspace** et non Runner.xcodeproj.

### 5. Configurer le Signing

Dans Xcode :
1. Sélectionnez la target **Runner**
2. Onglet **Signing & Capabilities**
3. Choisissez votre **Team** (compte développeur Apple)
4. Le Bundle Identifier est `com.monplayer.mon_player`

### 6. Lancer sur l'iPhone

- Branchez votre iPhone en USB
- Sélectionnez-le comme cible dans Xcode
- Appuyez sur **▶ Run** (⌘R)

---

## Ajouter de la musique

Une fois l'application installée et lancée :

1. Ouvrez l'application **Fichiers** sur votre iPhone
2. Naviguez vers **Sur mon iPhone > MonPlayer**
3. Copiez vos fichiers audio dans ce dossier

Vous pouvez aussi utiliser :
- **AirDrop** → envoyez le fichier depuis votre Mac/iPhone
- **Finder** (macOS Catalina+) → Onglet Fichiers dans Finder
- **iTunes File Sharing** (Windows)

Formats supportés : `mp3`, `m4a`, `wav`, `flac`, `aac`, `ogg`

---

## Structure du projet

```
lib/
├── core/
│   ├── constants/       # Constantes (Hive, App)
│   ├── theme/           # Thème Material 3 (clair/sombre)
│   └── utils/           # Utilitaires (durée, couleurs, chaînes)
├── data/
│   ├── datasources/     # AudioScannerService, AudioHandler
│   ├── models/hive/     # Modèles Hive (Song, Playlist, Settings)
│   └── repositories/    # Implémentations des repositories
├── domain/
│   ├── entities/        # Song, Playlist (entités pures)
│   └── repositories/    # Interfaces (contrats)
└── presentation/
    ├── providers/        # Riverpod providers
    ├── screens/          # Écrans (Home, Player, Playlist, Favorites, Settings)
    └── widgets/          # Composants réutilisables
```

---

## Commandes utiles

```bash
# Lancer en mode debug (simulateur ou device)
flutter run

# Construire l'IPA pour distribution
flutter build ipa

# Générer les adapters Hive (si modification des modèles)
flutter pub run build_runner build --delete-conflicting-outputs

# Nettoyer le build
flutter clean && flutter pub get
```

---

## Notes iOS importantes

- La lecture en arrière-plan est gérée par `just_audio_background` qui utilise `AVAudioSession` en mode `.playback`
- Les contrôles de l'écran verrouillé et du Centre de contrôle sont automatiquement configurés via `audio_service`
- Le dossier `MonPlayer` est créé dans le répertoire **Documents** de l'app (accessible depuis Fichiers iOS)
- `UIFileSharingEnabled` et `LSSupportsOpeningDocumentsInPlace` sont activés dans `Info.plist`

---

## Licence

MIT © MonPlayer
