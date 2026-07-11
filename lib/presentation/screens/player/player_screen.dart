import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/utils.dart';
import '../../providers/audio_handler_provider.dart';
import '../../widgets/common/artwork_widget.dart';

/// Écran lecteur complet — style Apple Music.
/// Affiche la pochette, les contrôles, la barre de progression,
/// la vitesse, le volume, le shuffle, et le repeat.
class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _artworkController;
  late Animation<double> _artworkScale;
  bool _showSpeedPicker = false;

  @override
  void initState() {
    super.initState();
    _artworkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _artworkScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _artworkController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _artworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF2F2F7),
      body: playerAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFC3C44)),
        ),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (state) {
          final song = state.currentSong;
          if (song == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_off_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Aucune musique sélectionnée',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            );
          }

          // Animation de l'artwork selon l'état de lecture
          if (state.isPlaying) {
            _artworkController.forward();
          } else {
            _artworkController.reverse(from: 0.95);
          }

          return SafeArea(
            child: Column(
              children: [
                // Header avec chevron bas et titre de l'onglet
                _PlayerHeader(onClose: () => Navigator.pop(context)),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),

                        // ── Artwork animé ─────────────────────────────────────
                        ScaleTransition(
                          scale: _artworkScale,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: LargeArtworkWidget(
                              artworkPath: song.artworkPath,
                              title: song.title,
                              artist: song.artist,
                              size: size.width - 80,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── Titre, artiste, favori ────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      song.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      song.artist != 'Artiste inconnu'
                                          ? song.artist
                                          : song.album != 'Album inconnu'
                                              ? song.album
                                              : '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(fontSize: 15),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              _FavoriteButton(song: song),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Barre de progression ──────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: _ProgressBar(state: state),
                        ),

                        const SizedBox(height: 20),

                        // ── Contrôles principaux ──────────────────────────────
                        _MainControls(state: state),

                        const SizedBox(height: 24),

                        // ── Volume ────────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: _VolumeControl(volume: state.volume),
                        ),

                        const SizedBox(height: 16),

                        // ── Vitesse de lecture ────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: _SpeedControl(speed: state.playbackSpeed),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Sub-widgets du lecteur ───────────────────────────────────────────────────

class _PlayerHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _PlayerHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
            onPressed: onClose,
          ),
          Expanded(
            child: Text(
              'En écoute',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// Barre de progression avec slider, temps actuel et temps restant.
class _ProgressBar extends ConsumerWidget {
  final PlayerState state;
  const _ProgressBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(audioHandlerSyncProvider);

    return StreamBuilder<Duration>(
      stream: handler.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final duration = state.duration;
        final progress = duration.inMilliseconds > 0
            ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: const Color(0xFFFC3C44),
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
                thumbColor: Colors.white,
                overlayColor: const Color(0xFFFC3C44).withOpacity(0.2),
              ),
              child: Slider(
                value: progress,
                onChanged: (v) {
                  final newPosition = Duration(
                    milliseconds:
                        (v * duration.inMilliseconds).round(),
                  );
                  ref.read(playerProvider.notifier).seek(newPosition);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DurationUtils.format(position),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    duration > Duration.zero
                        ? DurationUtils.remaining(duration, position)
                        : '--:--',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Contrôles principaux : shuffle, previous, play/pause, next, repeat.
class _MainControls extends ConsumerWidget {
  final PlayerState state;
  const _MainControls({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          _ControlButton(
            icon: Icons.shuffle_rounded,
            size: 26,
            isActive: state.isShuffleEnabled,
            onTap: () => ref.read(playerProvider.notifier).toggleShuffle(),
          ),

          // Précédent
          _ControlButton(
            icon: Icons.skip_previous_rounded,
            size: 44,
            onTap: () => ref.read(playerProvider.notifier).previous(),
          ),

          // Play / Pause
          GestureDetector(
            onTap: () => ref.read(playerProvider.notifier).togglePlayPause(),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFC3C44),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFC3C44).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: anim,
                  child: child,
                ),
                child: Icon(
                  state.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  key: ValueKey(state.isPlaying),
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
          ),

          // Suivant
          _ControlButton(
            icon: Icons.skip_next_rounded,
            size: 44,
            onTap: () => ref.read(playerProvider.notifier).next(),
          ),

          // Repeat
          _RepeatButton(repeatMode: state.repeatMode),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Icon(
              icon,
              size: size,
              color: isActive
                  ? const Color(0xFFFC3C44)
                  : Theme.of(context).colorScheme.onSurface,
            ),
            if (isActive)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFC3C44),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RepeatButton extends ConsumerWidget {
  final int repeatMode;
  const _RepeatButton({required this.repeatMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = switch (repeatMode) {
      0 => Icons.repeat_rounded,
      1 => Icons.repeat_rounded,
      2 => Icons.repeat_one_rounded,
      _ => Icons.repeat_rounded,
    };

    return GestureDetector(
      onTap: () => ref.read(playerProvider.notifier).cycleRepeat(),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 26,
              color: repeatMode > 0
                  ? const Color(0xFFFC3C44)
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (repeatMode > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFFC3C44),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Contrôle du volume avec slider et icônes.
class _VolumeControl extends ConsumerWidget {
  final double volume;
  const _VolumeControl({required this.volume});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Icon(
          Icons.volume_down_rounded,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
              thumbColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: Slider(
              value: volume,
              onChanged: (v) =>
                  ref.read(playerProvider.notifier).setVolume(v),
            ),
          ),
        ),
        Icon(
          Icons.volume_up_rounded,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

/// Sélecteur de vitesse de lecture.
class _SpeedControl extends ConsumerWidget {
  final double speed;
  const _SpeedControl({required this.speed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.speed_rounded, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        ...AppConstants.playbackSpeeds.map((s) {
          final isSelected = (speed - s).abs() < 0.01;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => ref.read(playerProvider.notifier).setSpeed(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFC3C44)
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${s}x',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Bouton favori dans le lecteur.
class _FavoriteButton extends ConsumerWidget {
  final dynamic song; // Song entity
  const _FavoriteButton({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(musicLibraryProvider.notifier).toggleFavorite(song.id),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: child,
        ),
        child: Icon(
          song.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(song.isFavorite),
          color: song.isFavorite ? const Color(0xFFFC3C44) : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}
