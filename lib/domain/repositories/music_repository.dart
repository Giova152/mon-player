import '../entities/song.dart';

/// Interface du repository de la bibliothèque musicale.
/// Définit le contrat entre le domaine et la couche data.
abstract class MusicRepository {
  /// Scanne le dossier MonPlayer et retourne les chansons trouvées.
  Future<List<Song>> scanMusicFolder();

  /// Retourne toutes les chansons de la bibliothèque.
  Future<List<Song>> getAllSongs();

  /// Retourne les chansons favorites.
  Future<List<Song>> getFavoriteSongs();

  /// Met à jour le statut favori d'une chanson.
  Future<void> toggleFavorite(String songId);

  /// Incrémente le compteur de lectures et met à jour la position.
  Future<void> updatePlayStats({
    required String songId,
    required int positionMs,
  });

  /// Retourne la dernière chanson lue et sa position.
  Future<({String? songId, int positionMs})> getLastPlayed();

  /// Retourne une chanson par son ID.
  Future<Song?> getSongById(String id);

  /// Recherche des chansons par titre, artiste ou album.
  Future<List<Song>> searchSongs(String query);

  /// Retourne les chansons triées par un critère donné.
  Future<List<Song>> getSongsSorted(SongSortOrder order);
}

/// Ordre de tri des chansons.
enum SongSortOrder {
  titleAsc,
  titleDesc,
  artistAsc,
  artistDesc,
  albumAsc,
  dateAddedDesc,
  dateAddedAsc,
  durationAsc,
  durationDesc,
  playCountDesc,
}
