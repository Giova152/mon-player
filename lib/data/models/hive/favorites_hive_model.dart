import 'package:hive/hive.dart';

part 'favorites_hive_model.g.dart';

/// Modèle Hive pour stocker les favoris.
@HiveType(typeId: 2)
class FavoritesHiveModel extends HiveObject {
  @HiveField(0)
  late List<String> favoriteSongIds;

  FavoritesHiveModel({required this.favoriteSongIds});
}
