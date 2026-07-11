import '../entities/playlist.dart';

/// Interface du repository des playlists.
abstract class PlaylistRepository {
  /// Retourne toutes les playlists.
  Future<List<Playlist>> getAllPlaylists();

  /// Retourne une playlist par son ID.
  Future<Playlist?> getPlaylistById(String id);

  /// Crée une nouvelle playlist.
  Future<Playlist> createPlaylist({
    required String name,
    String? description,
  });

  /// Renomme une playlist.
  Future<Playlist> renamePlaylist({
    required String id,
    required String newName,
  });

  /// Supprime une playlist.
  Future<void> deletePlaylist(String id);

  /// Ajoute une chanson à une playlist.
  Future<Playlist> addSongToPlaylist({
    required String playlistId,
    required String songId,
  });

  /// Ajoute plusieurs chansons à une playlist.
  Future<Playlist> addSongsToPlaylist({
    required String playlistId,
    required List<String> songIds,
  });

  /// Retire une chanson d'une playlist.
  Future<Playlist> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  });

  /// Réordonne les chansons dans une playlist.
  Future<Playlist> reorderSongs({
    required String playlistId,
    required int oldIndex,
    required int newIndex,
  });
}
