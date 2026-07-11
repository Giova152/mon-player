import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/audio_handler_provider.dart';
import '../../widgets/common/song_tile.dart';
import '../player/player_screen.dart';

/// Onglet Bibliothèque — liste toutes les chansons du dossier MonPlayer.
class LibraryTab extends ConsumerStatefulWidget {
  const LibraryTab({super.key});

  @override
  ConsumerState<LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<LibraryTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(musicLibraryProvider);
    final filteredSongs = ref.watch(filteredSongsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          // AppBar flottante style iOS
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 120,
            backgroundColor: isDark
                ? const Color(0xFF0A0A0F)
                : const Color(0xFFF2F2F7),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 12),
              title: Text(
                'Bibliothèque',
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
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Rafraîchir la bibliothèque',
                onPressed: () async {
                  await ref.read(musicLibraryProvider.notifier).refresh();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bibliothèque mise à jour'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          // Barre de recherche sticky
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchBarDelegate(
              child: Container(
                color: isDark
                    ? const Color(0xFF0A0A0F)
                    : const Color(0xFFF2F2F7),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (q) =>
                      ref.read(searchQueryProvider.notifier).state = q,
                  decoration: InputDecoration(
                    hintText: 'Rechercher dans la bibliothèque…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // Contenu : état de chargement / erreur / liste
          songsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFC3C44)),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Erreur : $e'),
                  ],
                ),
              ),
            ),
            data: (_) {
              if (filteredSongs.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyLibrary(
                    isSearch: ref.watch(searchQueryProvider).isNotEmpty,
                  ),
                );
              }

              return SliverList.builder(
                itemCount: filteredSongs.length,
                itemBuilder: (context, index) {
                  final song = filteredSongs[index];
                  return SongTile(
                    song: song,
                    showIndex: false,
                    onTap: () {
                      ref
                          .read(playerProvider.notifier)
                          .playSong(song, filteredSongs);
                      Navigator.push(
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
                      );
                    },
                  );
                },
              );
            },
          ),

          // Padding pour le mini-lecteur
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

/// Widget affiché quand la bibliothèque est vide.
class _EmptyLibrary extends StatelessWidget {
  final bool isSearch;
  const _EmptyLibrary({required this.isSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearch ? Icons.search_off_rounded : Icons.music_off_rounded,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              isSearch ? 'Aucun résultat' : 'Aucune musique',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isSearch
                  ? 'Essayez d\'autres termes de recherche.'
                  : 'Déposez vos fichiers audio dans le dossier MonPlayer '
                      'via l\'application Fichiers, AirDrop ou Finder, '
                      'puis rafraîchissez la bibliothèque.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (!isSearch) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFC3C44).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFC3C44).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder_open_rounded,
                            color: Color(0xFFFC3C44), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Dossier : Sur mon iPhone > MonPlayer',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFFC3C44),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Formats supportés : mp3, m4a, wav, flac, aac, ogg',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Delegate pour le header de recherche persistant.
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  const _SearchBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 64;

  @override
  double get minExtent => 64;

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) => false;
}
