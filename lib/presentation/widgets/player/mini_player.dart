import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio_handler_provider.dart';
import '../../screens/player/player_screen.dart';
import '../common/artwork_widget.dart';

/// Mini-lecteur flottant affiché en bas de l'écran principal.
/// Affiche le titre, artiste, et contrôles basiques.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return playerAsync.whenOrNull(
          data: (state) {
            final song = state.currentSong;
            if (song == null) return const SizedBox.shrink();

            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, anim, __) => const PlayerScreen(),
                  transitionsBuilder: (_, anim, __, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: anim,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C1C24).withOpacity(0.95)
                      : Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.06),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Barre de progression ultra-fine en haut
                      StreamBuilder<Duration>(
                        stream: ref.watch(audioHandlerSyncProvider).positionStream,
                        builder: (_, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final duration = state.duration;
                          final progress = duration.inMilliseconds > 0
                              ? position.inMilliseconds /
                                  duration.inMilliseconds
                              : 0.0;
                          return LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor:
                                Colors.grey.withOpacity(0.2),
                            color: const Color(0xFFFC3C44),
                            minHeight: 2,
                          );
                        },
                      ),

                      // Contenu principal du mini-lecteur
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            // Artwork
                            ArtworkWidget(
                              artworkPath: song.artworkPath,
                              size: 44,
                              borderRadius: 8,
                              title: song.title,
                              artist: song.artist,
                            ),
                            const SizedBox(width: 12),

                            // Titre et artiste
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    song.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    song.artist,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Contrôles
                            _MiniControlButton(
                              icon: Icons.skip_previous_rounded,
                              size: 28,
                              onTap: () =>
                                  ref.read(playerProvider.notifier).previous(),
                            ),
                            const SizedBox(width: 4),
                            _PlayPauseButton(isPlaying: state.isPlaying),
                            const SizedBox(width: 4),
                            _MiniControlButton(
                              icon: Icons.skip_next_rounded,
                              size: 28,
                              onTap: () =>
                                  ref.read(playerProvider.notifier).next(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        const SizedBox.shrink();
  }
}

class _MiniControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  const _MiniControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: size),
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  final bool isPlaying;
  const _PlayPauseButton({required this.isPlaying});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(playerProvider.notifier).togglePlayPause(),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFFC3C44),
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying),
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
