import 'package:hive/hive.dart';

part 'app_settings_hive_model.g.dart';

/// Modèle Hive pour stocker les paramètres de l'application.
@HiveType(typeId: 3)
class AppSettingsHiveModel extends HiveObject {
  @HiveField(0)
  late bool isDarkMode;

  @HiveField(1)
  late double playbackSpeed;

  @HiveField(2)
  late bool isShuffleEnabled;

  @HiveField(3)
  late int repeatMode; // 0: off, 1: all, 2: one

  @HiveField(4)
  late String sortOrder;

  @HiveField(5)
  late String? lastPlayedSongId;

  @HiveField(6)
  late int lastPlayedPositionMs;

  @HiveField(7)
  late List<String> lastQueue; // IDs de la dernière queue

  @HiveField(8)
  late double volume;

  AppSettingsHiveModel({
    this.isDarkMode = true,
    this.playbackSpeed = 1.0,
    this.isShuffleEnabled = false,
    this.repeatMode = 0,
    this.sortOrder = 'titleAsc',
    this.lastPlayedSongId,
    this.lastPlayedPositionMs = 0,
    this.lastQueue = const [],
    this.volume = 1.0,
  });
}
