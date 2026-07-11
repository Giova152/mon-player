import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/audio_handler_provider.dart';
import '../screens/home/library_tab.dart';
import '../screens/playlist/playlists_tab.dart';
import '../screens/favorites/favorites_tab.dart';
import '../screens/settings/settings_tab.dart';
import '../widgets/player/mini_player.dart';

/// Écran principal avec BottomNavigationBar de style iOS.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    LibraryTab(),
    PlaylistsTab(),
    FavoritesTab(),
    SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final playerAsync = ref.watch(playerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Contenu principal avec tabs
          IndexedStack(
            index: _selectedIndex,
            children: _tabs,
          ),

          // Mini-lecteur flottant au bas de l'écran
          playerAsync.whenOrNull(
            data: (playerState) {
              if (playerState.currentSong == null) return const SizedBox.shrink();
              return Positioned(
                left: 8,
                right: 8,
                bottom: 80 + MediaQuery.of(context).padding.bottom,
                child: const MiniPlayer(),
              );
            },
          ) ?? const SizedBox.shrink(),
        ],
      ),

      // Barre de navigation inférieure style iOS
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF141419).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _NavItem(
                  index: 0,
                  icon: Icons.music_note_rounded,
                  activeIcon: Icons.music_note_rounded,
                  label: 'Bibliothèque',
                  selectedIndex: _selectedIndex,
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
                _NavItem(
                  index: 1,
                  icon: Icons.queue_music_outlined,
                  activeIcon: Icons.queue_music_rounded,
                  label: 'Playlists',
                  selectedIndex: _selectedIndex,
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
                _NavItem(
                  index: 2,
                  icon: Icons.favorite_border_rounded,
                  activeIcon: Icons.favorite_rounded,
                  label: 'Favoris',
                  selectedIndex: _selectedIndex,
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
                _NavItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Réglages',
                  selectedIndex: _selectedIndex,
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int selectedIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    final color = isSelected
        ? const Color(0xFFFC3C44)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 10,
                    ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
