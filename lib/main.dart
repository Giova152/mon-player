import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:metadata_god/metadata_god.dart';

import 'core/constants/hive_constants.dart';
import 'core/theme/app_theme.dart';
import 'data/models/hive/song_hive_model.dart';
import 'data/models/hive/playlist_hive_model.dart';
import 'data/models/hive/favorites_hive_model.dart';
import 'data/models/hive/app_settings_hive_model.dart';
import 'presentation/providers/audio_handler_provider.dart';
import 'presentation/screens/home/home_screen.dart';

/// Point d'entrée principal de l'application MonPlayer.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientation portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialisation de just_audio_background pour la lecture en arrière-plan
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.monplayer.audio',
    androidNotificationChannelName: 'MonPlayer Audio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // Initialisation du plugin de métadonnées audio
  MetadataGod.initialize();

  // Initialisation de Hive pour le stockage local
  await Hive.initFlutter();

  // Enregistrement des adaptateurs Hive
  Hive.registerAdapter(SongHiveModelAdapter());
  Hive.registerAdapter(PlaylistHiveModelAdapter());
  Hive.registerAdapter(FavoritesHiveModelAdapter());
  Hive.registerAdapter(AppSettingsHiveModelAdapter());

  // Ouverture des boîtes Hive
  await Future.wait([
    Hive.openBox<SongHiveModel>(HiveConstants.songsBox),
    Hive.openBox<PlaylistHiveModel>(HiveConstants.playlistsBox),
    Hive.openBox<FavoritesHiveModel>(HiveConstants.favoritesBox),
    Hive.openBox<AppSettingsHiveModel>(HiveConstants.settingsBox),
  ]);

  runApp(
    const ProviderScope(
      child: MonPlayerApp(),
    ),
  );
}

/// Widget racine de l'application.
class MonPlayerApp extends ConsumerWidget {
  const MonPlayerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.watch(audioHandlerProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp(
      title: 'MonPlayer',
      debugShowCheckedModeBanner: false,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: audioHandler.when(
        data: (_) => const HomeScreen(),
        loading: () => const SplashScreen(),
        error: (e, _) => ErrorScreen(error: e.toString()),
      ),
    );
  }
}

/// Écran de chargement pendant l'initialisation.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0F) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFFFC3C44), Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFC3C44).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MonPlayer',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0A0A0F),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Votre musique, hors ligne',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Color(0xFFFC3C44),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

/// Écran d'erreur si l'initialisation échoue.
class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur d\'initialisation', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(error, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}
