import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/playlist.dart';
import '../../providers/audio_handler_provider.dart';
import '../../widgets/common/song_tile.dart';
import '../player/player_screen.dart';

/// Écran de détail d'une playlist.
class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allSongs = ref.watch(musicLibraryProvider).valueOrNull ?? [];
    final playlistSongs = playlist.songIds
        .map((id) => allSongs.where((s) => s.id == id).firstOrNull)
        .where((s) => s != null)
        .map((s) => s!)
        .toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF2F2F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(playlist.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFC3C44).withOpacity(0.7),
                      isDark
                          ? const Color(0xFF0A0A0F)
                          : const Color(0xFFF2F2F7),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.queue_music_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (action) =>
                    _handleAction(context, ref, action),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'rename',
                    child: ListTile(
                      leading: Icon(Icons.edit_rounded),
                      title: Text('Renommer'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_rounded,
                          color: Colors.red),
                      title: Text('Supprimer',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Infos de la playlist
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${playlistSongs.length} titre${playlistSongs.length > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (playlistSongs.isNotEmpty)
                    FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(playerProvider.notifier)
                            .playSong(playlistSongs.first, playlistSongs);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlayerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Lire'),
                    ),
                ],
              ),
            ),
          ),

          // Liste des chansons
          SliverList.builder(
            itemCount: playlistSongs.length,
            itemBuilder: (context, index) {
              final song = playlistSongs[index];
              return Dismissible(
                key: Key('${playlist.id}_${song.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete_rounded,
                      color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(playlistsProvider.notifier).removeSongFromPlaylist(
                        playlist.id,
                        song.id,
                      );
                },
                child: SongTile(
                  song: song,
                  showIndex: true,
                  index: index,
                  showFavoriteButton: false,
                  onTap: () {
                    ref
                        .read(playerProvider.notifier)
                        .playSong(song, playlistSongs);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlayerScreen(),
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

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) {
    if (action == 'rename') {
      final controller = TextEditingController(text: playlist.name);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Renommer la playlist'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nouveau nom'),
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
                      .renamePlaylist(playlist.id, name);
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Renommer'),
            ),
          ],
        ),
      );
    } else if (action == 'delete') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Supprimer la playlist ?'),
          content: Text(
              'La playlist "${playlist.name}" sera définitivement supprimée.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await ref
                    .read(playlistsProvider.notifier)
                    .deletePlaylist(playlist.id);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        ),
      );
    }
  }
}
