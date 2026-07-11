import 'package:hive/hive.dart';

part 'playlist_hive_model.g.dart';

/// Modèle Hive pour stocker une playlist localement.
@HiveType(typeId: 1)
class PlaylistHiveModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late List<String> songIds;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime updatedAt;

  @HiveField(6)
  String? coverArtSongId;

  PlaylistHiveModel({
    required this.id,
    required this.name,
    this.description,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverArtSongId,
  });
}
