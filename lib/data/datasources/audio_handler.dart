import 'dart:async';
import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Handler audio principal — gère la lecture, la queue, les contrôles
/// de l'écran verrouillé et du Centre de contrôle iOS.
///
/// Étend [BaseAudioHandler] d'audio_service pour gérer la lecture
/// en arrière-plan nativement sur iOS.
class MonPlayerAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  /// Vitesse de lecture actuelle
  double _speed = 1.0;

  /// Mode repeat : 0 = off, 1 = all, 2 = one
  int _repeatMode = 0;

  /// Mode shuffle
  bool _shuffleEnabled = false;

  MonPlayerAudioHandler() {
    // Écouteur sur le changement de piste (lecture de la suivante)
    _player.currentIndexStream.listen((index) {
      if (index != null && queue.value.isNotEmpty) {
        mediaItem.add(queue.value[index]);
      }
    });

    // Écouteur sur l'état de lecture → mise à jour du PlaybackState
    _player.playbackEventStream.listen(_broadcastState);

    // Passage automatique à la suivante en mode repeat all
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleCompletion();
      }
    });
  }

  // ─── AudioPlayer accessors ─────────────────────────────────────────────────

  AudioPlayer get player => _player;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<double> get speedStream => _player.speedStream;

  double get currentSpeed => _speed;
  int get currentRepeatMode => _repeatMode;
  bool get isShuffleEnabled => _shuffleEnabled;

  // ─── Commandes de lecture ──────────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final q = queue.value;
    final currentIndex = _player.currentIndex ?? 0;
    if (currentIndex < q.length - 1) {
      await skipToQueueItem(currentIndex + 1);
    } else if (_repeatMode == 1) {
      // Repeat all → retour au début
      await skipToQueueItem(0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final pos = _player.position;
    if (pos.inSeconds > 3) {
      // Si on est à plus de 3 secondes, on revient au début
      await seek(Duration.zero);
    } else {
      final currentIndex = _player.currentIndex ?? 0;
      if (currentIndex > 0) {
        await skipToQueueItem(currentIndex - 1);
      } else if (_repeatMode == 1) {
        await skipToQueueItem(queue.value.length - 1);
      } else {
        await seek(Duration.zero);
      }
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    mediaItem.add(queue.value[index]);
    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  /// Charge une nouvelle liste de pistes et démarre la lecture à l'index donné.
  Future<void> loadQueue({
    required List<MediaItem> items,
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
  }) async {
    queue.add(items);
    if (items.isEmpty) return;

    final sources = items.map((item) => AudioSource.uri(
          Uri.parse(item.extras?['filePath'] ?? item.id),
          tag: item,
        )).toList();

    await _player.setAudioSources(
      sources,
      initialIndex: initialIndex,
      initialPosition: initialPosition,
    );

    mediaItem.add(items[initialIndex]);
  }

  // ─── Vitesse & shuffle & repeat ────────────────────────────────────────────

  Future<void> setSpeed(double speed) async {
    _speed = speed;
    await _player.setSpeed(speed);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
  }

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;
    await _player.setShuffleModeEnabled(_shuffleEnabled);
    if (_shuffleEnabled) {
      await _player.shuffle();
    }
    _broadcastState(_player.playbackEvent);
  }

  Future<void> cycleRepeatMode() async {
    _repeatMode = (_repeatMode + 1) % 3;
    switch (_repeatMode) {
      case 0:
        await _player.setLoopMode(LoopMode.off);
      case 1:
        await _player.setLoopMode(LoopMode.all);
      case 2:
        await _player.setLoopMode(LoopMode.one);
    }
    _broadcastState(_player.playbackEvent);
  }

  // ─── Gestion de la fin de piste ───────────────────────────────────────────

  void _handleCompletion() {
    switch (_repeatMode) {
      case 0: // no repeat
        final next = (_player.currentIndex ?? 0) + 1;
        if (next < queue.value.length) {
          skipToQueueItem(next);
        }
      case 1: // repeat all → géré par LoopMode.all
        break;
      case 2: // repeat one → géré par LoopMode.one
        break;
    }
  }

  // ─── Diffusion de l'état ──────────────────────────────────────────────────

  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
      shuffleMode: _shuffleEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: switch (_repeatMode) {
        0 => AudioServiceRepeatMode.none,
        1 => AudioServiceRepeatMode.all,
        2 => AudioServiceRepeatMode.one,
        _ => AudioServiceRepeatMode.none,
      },
    ));
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'setSpeed':
        await setSpeed((extras?['speed'] as num?)?.toDouble() ?? 1.0);
      case 'toggleShuffle':
        await toggleShuffle();
      case 'cycleRepeat':
        await cycleRepeatMode();
      case 'setVolume':
        await setVolume((extras?['volume'] as num?)?.toDouble() ?? 1.0);
    }
  }

  /// Dispose du player audio.
  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }
}

/// Convertit une [Song] en [MediaItem] pour audio_service.
MediaItem songToMediaItem({
  required String id,
  required String filePath,
  required String title,
  required String artist,
  required String album,
  required Duration duration,
  String? artworkPath,
  Map<String, dynamic>? extras,
}) {
  final Uri? artworkUri = artworkPath != null
      ? Uri.file(artworkPath)
      : null;

  return MediaItem(
    id: filePath,
    title: title,
    artist: artist,
    album: album,
    duration: duration,
    artUri: artworkUri,
    extras: {
      'songId': id,
      'filePath': filePath,
      ...?extras,
    },
  );
}
