import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio_handler_provider.dart';
import '../../widgets/common/song_tile.dart';
import '../player/player_screen.dart';

/// Onglet Favoris.
class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteSongs = ref.watch(favoriteSongsProvider);
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
                'Favoris',
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
          ),

          if (favoriteSongs.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 80,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aucun favori',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Appuyez sur ❤️ sur une chanson\npour l\'ajouter à vos favoris.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // En-tête avec bouton lecture
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Text(
                      '${favoriteSongs.length} titre${favoriteSongs.length > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () {
                        ref
                            .read(playerProvider.notifier)
                            .playSong(favoriteSongs.first, favoriteSongs);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlayerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Lire tout'),
                    ),
                  ],
                ),
              ),
            ),

            SliverList.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];
                return SongTile(
                  song: song,
                  onTap: () {
                    ref
                        .read(playerProvider.notifier)
                        .playSong(song, favoriteSongs);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlayerScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
