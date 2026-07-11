import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/song.dart';
import '../../providers/audio_handler_provider.dart';
import '../../widgets/common/artwork_widget.dart';

/// Tuile de chanson réutilisable dans la bibliothèque et les playlists.
class SongTile extends ConsumerWidget {
  final Song song;
  final bool showIndex;
  final int? index;
  final VoidCallback? onTap;
  final bool showFavoriteButton;
  final bool isCurrentlyPlaying;
  final VoidCallback? onMoreTap;

  const SongTile({
    super.key,
    required this.song,
    this.showIndex = false,
    this.index,
    this.onTap,
    this.showFavoriteButton = true,
    this.isCurrentlyPlaying = false,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isPlaying = playerAsync.whenOrNull(
          data: (state) => state.currentSong?.id == song.id,
        ) ??
        false;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Numéro ou artwork
            if (showIndex && index != null)
              SizedBox(
                width: 32,
                child: Text(
                  '${index! + 1}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isPlaying
                            ? const Color(0xFFFC3C44)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              // Artwork avec animation de lecture
              Stack(
                children: [
                  ArtworkWidget(
                    artworkPath: song.artworkPath,
                    size: 52,
                    borderRadius: 8,
                    title: song.title,
                    artist: song.artist,
                  ),
                  if (isPlaying)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: _PlayingIndicator(),
                        ),
                      ),
                    ),
                ],
              ),

            const SizedBox(width: 12),

            // Titre, artiste, album
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isPlaying
                              ? const Color(0xFFFC3C44)
                              : null,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (song.artist != 'Artiste inconnu') ...[
                        Flexible(
                          child: Text(
                            song.artist,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (song.album != 'Album inconnu')
                          Text(
                            ' • ',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                      if (song.album != 'Album inconnu')
                        Flexible(
                          child: Text(
                            song.album,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Durée
            Text(
              _formatDuration(song.duration),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),

            const SizedBox(width: 4),

            // Bouton favori
            if (showFavoriteButton)
              _FavoriteButton(song: song),

            // Bouton plus
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onPressed: onMoreTap ?? () => _showMoreSheet(context, ref),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _showMoreSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SongMoreSheet(song: song),
    );
  }
}

/// Bouton favori animé.
class _FavoriteButton extends ConsumerWidget {
  final Song song;
  const _FavoriteButton({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(musicLibraryProvider.notifier).toggleFavorite(song.id);
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => ScaleTransition(
          scale: anim,
          child: child,
        ),
        child: Icon(
          song.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(song.isFavorite),
          color: song.isFavorite ? const Color(0xFFFC3C44) : Colors.grey,
          size: 20,
        ),
      ),
    );
  }
}

/// Sheet d'options pour une chanson.
class _SongMoreSheet extends ConsumerWidget {
  final Song song;
  const _SongMoreSheet({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // En-tête avec artwork et titre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ArtworkWidget(
                    artworkPath: song.artworkPath,
                    size: 60,
                    borderRadius: 10,
                    title: song.title,
                    artist: song.artist,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text(song.artist,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),

            // Options
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  ListTile(
                    leading: Icon(
                      song.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: song.isFavorite
                          ? const Color(0xFFFC3C44)
                          : null,
                    ),
                    title: Text(song.isFavorite
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris'),
                    onTap: () {
                      ref
                          .read(musicLibraryProvider.notifier)
                          .toggleFavorite(song.id);
                      Navigator.pop(context);
                    },
                  ),

                  // Ajouter à une playlist
                  ...playlistsAsync.whenOrNull(
                        data: (playlists) => playlists.map(
                          (playlist) => ListTile(
                            leading: const Icon(Icons.playlist_add_rounded),
                            title: Text('Ajouter à "${playlist.name}"'),
                            onTap: () {
                              ref
                                  .read(playlistsProvider.notifier)
                                  .addSongToPlaylist(playlist.id, song.id);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Ajouté à "${playlist.name}"'),
                                ),
                              );
                            },
                          ),
                        ).toList(),
                      ) ??
                      [],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animation de lecteur en cours de lecture (barres qui oscillent).
class _PlayingIndicator extends StatefulWidget {
  const _PlayingIndicator();

  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 100),
      )..repeat(reverse: true),
    );
    _animations = _controllers
        .map((c) => Tween<double>(begin: 4, end: 16).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(_controllers),
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(
          3,
          (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 3,
            height: _animations[i].value,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
