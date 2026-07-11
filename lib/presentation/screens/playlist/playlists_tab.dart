import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio_handler_provider.dart';
import '../../widgets/common/song_tile.dart';
import '../../widgets/common/artwork_widget.dart';
import '../player/player_screen.dart';
import 'playlist_detail_screen.dart';

/// Onglet Playlists.
class PlaylistsTab extends ConsumerWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: isDark
                ? const Color(0xFF0A0A0F)
                : const Color(0xFFF2F2F7),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
              title: Text(
                'Playlists',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              background: Container(
                color: isDark
                    ? const Color(0xFF0A0A0F)
                    : const Color(0xFFF2F2F7),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                tooltip: 'Nouvelle playlist',
                onPressed: () => _showCreatePlaylistDialog(context, ref),
              ),
            ],
          ),

          playlistsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFC3C44)),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Erreur : $e')),
            ),
            data: (playlists) {
              if (playlists.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.queue_music_rounded,
                            size: 80,
                            color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 20),
                        Text(
                          'Aucune playlist',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () =>
                              _showCreatePlaylistDialog(context, ref),
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Créer une playlist'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                sliver: SliverGrid.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    final songs =
                        ref.watch(musicLibraryProvider).valueOrNull ?? [];
                    final coverSong = songs
                        .where((s) => s.id == playlist.coverArtSongId)
                        .firstOrNull;

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaylistDetailScreen(
                            playlist: playlist,
                          ),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C24)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Artwork
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: ArtworkWidget(
                                artworkPath: coverSong?.artworkPath,
                                size: double.infinity,
                                borderRadius: 0,
                                title: playlist.name,
                                artist: '',
                                fit: BoxFit.cover,
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playlist.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${playlist.trackCount} titre${playlist.trackCount > 1 ? 's' : ''}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nom de la playlist',
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (name) async {
            if (name.trim().isNotEmpty) {
              await ref
                  .read(playlistsProvider.notifier)
                  .createPlaylist(name.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(playlistsProvider.notifier)
                    .createPlaylist(name);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
