import 'package:hive/hive.dart';

part 'song_hive_model.g.dart';

/// Modèle Hive pour stocker une chanson localement.
@HiveType(typeId: 0)
class SongHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String filePath;

  @HiveField(2)
  late String fileName;

  @HiveField(3)
  late String title;

  @HiveField(4)
  late String artist;

  @HiveField(5)
  late String album;

  @HiveField(6)
  late String genre;

  @HiveField(7)
  late int durationMs; // durée en millisecondes

  @HiveField(8)
  late int fileSize;

  @HiveField(9)
  late DateTime dateAdded;

  @HiveField(10)
  String? artworkPath;

  @HiveField(11)
  late int trackNumber;

  @HiveField(12)
  late int year;

  @HiveField(13)
  late bool isFavorite;

  @HiveField(14)
  late int playCount;

  @HiveField(15)
  int? lastPlayedPosition;

  SongHiveModel({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.durationMs,
    required this.fileSize,
    required this.dateAdded,
    this.artworkPath,
    this.trackNumber = 0,
    this.year = 0,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayedPosition,
  });
}
