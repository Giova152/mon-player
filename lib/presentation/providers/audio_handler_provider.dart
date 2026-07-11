import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/constants/hive_constants.dart';
import '../../data/datasources/audio_handler.dart';
import '../../data/datasources/audio_scanner_service.dart';
import '../../data/models/hive/app_settings_hive_model.dart';
import '../../data/models/hive/playlist_hive_model.dart';
import '../../data/models/hive/song_hive_model.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../../data/repositories/playlist_repository_impl.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/repositories/music_repository.dart';
import '../../domain/repositories/playlist_repository.dart';

// ─── Infrastructure providers ─────────────────────────────────────────────────

/// Fournit la boîte Hive des chansons.
final songsBoxProvider = Provider<Box<SongHiveModel>>((ref) {
  return Hive.box<SongHiveModel>(HiveConstants.songsBox);
});

/// Fournit la boîte Hive des playlists.
final playlistsBoxProvider = Provider<Box<PlaylistHiveModel>>((ref) {
  return Hive.box<PlaylistHiveModel>(HiveConstants.playlistsBox);
});

/// Fournit la boîte Hive des paramètres.
final settingsBoxProvider = Provider<Box<AppSettingsHiveModel>>((ref) {
  return Hive.box<AppSettingsHiveModel>(HiveConstants.settingsBox);
});

/// Service de scan audio.
final audioScannerProvider = Provider<AudioScannerService>((ref) {
  return AudioScannerService();
});

// ─── Repository providers ─────────────────────────────────────────────────────

/// Fournit l'implémentation du MusicRepository.
final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return MusicRepositoryImpl(
    scanner: ref.watch(audioScannerProvider),
    songsBox: ref.watch(songsBoxProvider),
    settingsBox: ref.watch(settingsBoxProvider),
  );
});

/// Fournit l'implémentation du PlaylistRepository.
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  return PlaylistRepositoryImpl(
    playlistsBox: ref.watch(playlistsBoxProvider),
  );
});

// ─── Audio Handler provider ───────────────────────────────────────────────────

/// Initialise et fournit le MonPlayerAudioHandler.
/// Utilise un FutureProvider pour l'initialisation asynchrone.
final audioHandlerProvider = FutureProvider<MonPlayerAudioHandler>((ref) async {
  final handler = await AudioService.init(
    builder: () => MonPlayerAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.monplayer.audio',
      androidNotificationChannelName: 'MonPlayer',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      notificationColor: 0xFFFC3C44,
    ),
  );
  return handler;
});

/// Fournit l'audio handler de manière synchrone (après initialisation).
final audioHandlerSyncProvider = Provider<MonPlayerAudioHandler>((ref) {
  return ref.watch(audioHandlerProvider).requireValue;
});

// ─── Settings provider ────────────────────────────────────────────────────────

/// State des paramètres de l'application.
class AppSettings {
  final bool isDarkMode;
  final double playbackSpeed;
  final bool isShuffleEnabled;
  final int repeatMode;
  final String sortOrder;
  final double volume;

  const AppSettings({
    this.isDarkMode = true,
    this.playbackSpeed = 1.0,
    this.isShuffleEnabled = false,
    this.repeatMode = 0,
    this.sortOrder = 'titleAsc',
    this.volume = 1.0,
  });

  AppSettings copyWith({
    bool? isDarkMode,
    double? playbackSpeed,
    bool? isShuffleEnabled,
    int? repeatMode,
    String? sortOrder,
    double? volume,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      sortOrder: sortOrder ?? this.sortOrder,
      volume: volume ?? this.volume,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final box = ref.watch(settingsBoxProvider);
    final model = box.get(HiveConstants.settingsKey);
    if (model == null) return const AppSettings();
    return AppSettings(
      isDarkMode: model.isDarkMode,
      playbackSpeed: model.playbackSpeed,
      isShuffleEnabled: model.isShuffleEnabled,
      repeatMode: model.repeatMode,
      sortOrder: model.sortOrder,
      volume: model.volume,
    );
  }

  Future<void> toggleDarkMode() async {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    await _persist();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    state = state.copyWith(playbackSpeed: speed);
    await _persist();
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _persist();
  }

  Future<void> _persist() async {
    final box = ref.read(settingsBoxProvider);
    final model = box.get(HiveConstants.settingsKey) ?? AppSettingsHiveModel();
    model.isDarkMode = state.isDarkMode;
    model.playbackSpeed = state.playbackSpeed;
    model.isShuffleEnabled = state.isShuffleEnabled;
    model.repeatMode = state.repeatMode;
    model.sortOrder = state.sortOrder;
    model.volume = state.volume;
    await box.put(HiveConstants.settingsKey, model);
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

// ─── Music library provider ───────────────────────────────────────────────────

/// Fournit la liste complète des chansons après scan.
final musicLibraryProvider =
    AsyncNotifierProvider<MusicLibraryNotifier, List<Song>>(
  MusicLibraryNotifier.new,
);

class MusicLibraryNotifier extends AsyncNotifier<List<Song>> {
  @override
  Future<List<Song>> build() async {
    final repo = ref.watch(musicRepositoryProvider);
    // D'abord on charge depuis le cache Hive
    final cached = await repo.getAllSongs();
    // Puis on scanne les nouveaux fichiers en arrière-plan
    Future.microtask(() async {
      try {
        final scanned = await repo.scanMusicFolder();
        state = AsyncData(scanned);
      } catch (_) {}
    });
    return cached;
  }

  /// Rafraîchit la bibliothèque en rescannant le dossier.
  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.read(musicRepositoryProvider);
    try {
      final songs = await repo.scanMusicFolder();
      state = AsyncData(songs);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Bascule le favori d'une chanson.
  Future<void> toggleFavorite(String songId) async {
    final repo = ref.read(musicRepositoryProvider);
    await repo.toggleFavorite(songId);
    // Mise à jour locale de la liste
    state = state.whenData((songs) => songs.map((s) {
          if (s.id == songId) return s.copyWith(isFavorite: !s.isFavorite);
          return s;
        }).toList());
  }
}

/// Recherche dans la bibliothèque.
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredSongsProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(musicLibraryProvider).valueOrNull ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) return songs;
  return songs.where((s) {
    return s.title.toLowerCase().contains(query) ||
        s.artist.toLowerCase().contains(query) ||
        s.album.toLowerCase().contains(query);
  }).toList();
});

// ─── Favorites provider ───────────────────────────────────────────────────────

final favoriteSongsProvider = Provider<List<Song>>((ref) {
  final songs = ref.watch(musicLibraryProvider).valueOrNull ?? [];
  return songs.where((s) => s.isFavorite).toList();
});

// ─── Playlists provider ───────────────────────────────────────────────────────

final playlistsProvider =
    AsyncNotifierProvider<PlaylistsNotifier, List<Playlist>>(
  PlaylistsNotifier.new,
);

class PlaylistsNotifier extends AsyncNotifier<List<Playlist>> {
  @override
  Future<List<Playlist>> build() async {
    final repo = ref.watch(playlistRepositoryProvider);
    return repo.getAllPlaylists();
  }

  Future<Playlist> createPlaylist(String name) async {
    final repo = ref.read(playlistRepositoryProvider);
    final playlist = await repo.createPlaylist(name: name);
    state = state.whenData((list) => [playlist, ...list]);
    return playlist;
  }

  Future<void> deletePlaylist(String id) async {
    final repo = ref.read(playlistRepositoryProvider);
    await repo.deletePlaylist(id);
    state = state.whenData((list) => list.where((p) => p.id != id).toList());
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final repo = ref.read(playlistRepositoryProvider);
    final updated = await repo.renamePlaylist(id: id, newName: newName);
    state = state.whenData((list) =>
        list.map((p) => p.id == id ? updated : p).toList());
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final repo = ref.read(playlistRepositoryProvider);
    final updated = await repo.addSongToPlaylist(
      playlistId: playlistId,
      songId: songId,
    );
    state = state.whenData((list) =>
        list.map((p) => p.id == playlistId ? updated : p).toList());
  }

  Future<void> addSongsToPlaylist(
      String playlistId, List<String> songIds) async {
    final repo = ref.read(playlistRepositoryProvider);
    final updated = await repo.addSongsToPlaylist(
      playlistId: playlistId,
      songIds: songIds,
    );
    state = state.whenData((list) =>
        list.map((p) => p.id == playlistId ? updated : p).toList());
  }

  Future<void> removeSongFromPlaylist(
      String playlistId, String songId) async {
    final repo = ref.read(playlistRepositoryProvider);
    final updated = await repo.removeSongFromPlaylist(
      playlistId: playlistId,
      songId: songId,
    );
    state = state.whenData((list) =>
        list.map((p) => p.id == playlistId ? updated : p).toList());
  }
}

// ─── Player state provider ────────────────────────────────────────────────────

/// État du lecteur audio.
class PlayerState {
  final Song? currentSong;
  final List<Song> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isShuffleEnabled;
  final int repeatMode; // 0: off, 1: all, 2: one
  final double playbackSpeed;
  final double volume;
  final Duration position;
  final Duration duration;

  const PlayerState({
    this.currentSong,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isShuffleEnabled = false,
    this.repeatMode = 0,
    this.playbackSpeed = 1.0,
    this.volume = 1.0,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  PlayerState copyWith({
    Song? currentSong,
    List<Song>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isShuffleEnabled,
    int? repeatMode,
    double? playbackSpeed,
    double? volume,
    Duration? position,
    Duration? duration,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class PlayerNotifier extends AsyncNotifier<PlayerState> {
  MonPlayerAudioHandler? _handler;

  @override
  Future<PlayerState> build() async {
    _handler = ref.watch(audioHandlerSyncProvider);

    final settings = ref.watch(appSettingsProvider);

    // Écouter la position
    _handler!.positionStream.listen((pos) {
      state = state.whenData((s) => s.copyWith(position: pos));
    });

    // Écouter la durée
    _handler!.durationStream.listen((dur) {
      if (dur != null) {
        state = state.whenData((s) => s.copyWith(duration: dur));
      }
    });

    // Écouter l'état de lecture
    _handler!.playingStream.listen((playing) {
      state = state.whenData((s) => s.copyWith(isPlaying: playing));
    });

    // Écouter le mediaItem courant
    _handler!.mediaItem.listen((item) {
      if (item != null) {
        final songId = item.extras?['songId'] as String?;
        if (songId != null) {
          final songs = ref.read(musicLibraryProvider).valueOrNull ?? [];
          final song = songs.where((s) => s.id == songId).firstOrNull;
          if (song != null) {
            state = state.whenData((s) => s.copyWith(currentSong: song));
          }
        }
      }
    });

    // Restaurer la dernière lecture
    await _restoreLastPlayed();

    return PlayerState(
      playbackSpeed: settings.playbackSpeed,
      volume: settings.volume,
      isShuffleEnabled: settings.isShuffleEnabled,
      repeatMode: settings.repeatMode,
    );
  }

  /// Démarre la lecture d'une chanson dans le contexte d'une liste.
  Future<void> playSong(Song song, List<Song> queue) async {
    final handler = _handler;
    if (handler == null) return;

    final index = queue.indexWhere((s) => s.id == song.id);
    final actualIndex = index == -1 ? 0 : index;
    final actualQueue = index == -1 ? [song, ...queue] : queue;

    final mediaItems = actualQueue
        .map((s) => songToMediaItem(
              id: s.id,
              filePath: s.filePath,
              title: s.title,
              artist: s.artist,
              album: s.album,
              duration: s.duration,
              artworkPath: s.artworkPath,
            ))
        .toList();

    await handler.loadQueue(
      items: mediaItems,
      initialIndex: actualIndex,
    );

    state = state.whenData((s) => s.copyWith(
          currentSong: song,
          queue: actualQueue,
          currentIndex: actualIndex,
        ));

    // Sauvegarder les stats
    final repo = ref.read(musicRepositoryProvider);
    await repo.updatePlayStats(songId: song.id, positionMs: 0);
  }

  Future<void> togglePlayPause() async {
    final handler = _handler;
    if (handler == null) return;
    if (handler.player.playing) {
      await handler.pause();
    } else {
      await handler.play();
    }
  }

  Future<void> next() => _handler?.skipToNext() ?? Future.value();
  Future<void> previous() => _handler?.skipToPrevious() ?? Future.value();

  Future<void> seek(Duration position) => _handler?.seek(position) ?? Future.value();

  Future<void> setSpeed(double speed) async {
    await _handler?.setSpeed(speed);
    state = state.whenData((s) => s.copyWith(playbackSpeed: speed));
    await ref.read(appSettingsProvider.notifier).setPlaybackSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _handler?.setVolume(volume);
    state = state.whenData((s) => s.copyWith(volume: volume));
    await ref.read(appSettingsProvider.notifier).setVolume(volume);
  }

  Future<void> toggleShuffle() async {
    await _handler?.toggleShuffle();
    final newShuffle = _handler?.isShuffleEnabled ?? false;
    state = state.whenData((s) => s.copyWith(isShuffleEnabled: newShuffle));
  }

  Future<void> cycleRepeat() async {
    await _handler?.cycleRepeatMode();
    final newRepeat = _handler?.currentRepeatMode ?? 0;
    state = state.whenData((s) => s.copyWith(repeatMode: newRepeat));
  }

  /// Restaure la dernière chanson et position lues.
  Future<void> _restoreLastPlayed() async {
    try {
      final repo = ref.read(musicRepositoryProvider);
      final lastPlayed = await repo.getLastPlayed();
      if (lastPlayed.songId == null) return;

      final song = await repo.getSongById(lastPlayed.songId!);
      if (song == null) return;

      final handler = _handler;
      if (handler == null) return;

      final mediaItems = [
        songToMediaItem(
          id: song.id,
          filePath: song.filePath,
          title: song.title,
          artist: song.artist,
          album: song.album,
          duration: song.duration,
          artworkPath: song.artworkPath,
        ),
      ];

      await handler.loadQueue(
        items: mediaItems,
        initialIndex: 0,
        initialPosition: Duration(milliseconds: lastPlayed.positionMs),
      );

      state = state.whenData((s) => s.copyWith(currentSong: song));
    } catch (_) {}
  }
}

final playerProvider =
    AsyncNotifierProvider<PlayerNotifier, PlayerState>(PlayerNotifier.new);
