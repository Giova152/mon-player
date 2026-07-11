import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/playlist.dart';
import '../../../domain/repositories/playlist_repository.dart';
import '../models/hive/playlist_hive_model.dart';

/// Implémentation concrète du PlaylistRepository.
class PlaylistRepositoryImpl implements PlaylistRepository {
  final Box<PlaylistHiveModel> _playlistsBox;
  final _uuid = const Uuid();

  PlaylistRepositoryImpl({required Box<PlaylistHiveModel> playlistsBox})
      : _playlistsBox = playlistsBox;

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    final playlists = _playlistsBox.values.map(_hiveToEntity).toList();
    playlists.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return playlists;
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    final model = _playlistsBox.get(id);
    return model != null ? _hiveToEntity(model) : null;
  }

  @override
  Future<Playlist> createPlaylist({
    required String name,
    String? description,
  }) async {
    final now = DateTime.now();
    final id = _uuid.v4();
    final playlist = Playlist(
      id: id,
      name: name,
      description: description,
      songIds: [],
      createdAt: now,
      updatedAt: now,
    );
    await _saveToHive(playlist);
    return playlist;
  }

  @override
  Future<Playlist> renamePlaylist({
    required String id,
    required String newName,
  }) async {
    final model = _playlistsBox.get(id);
    if (model == null) throw Exception('Playlist introuvable : $id');
    model.name = newName;
    model.updatedAt = DateTime.now();
    await model.save();
    return _hiveToEntity(model);
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await _playlistsBox.delete(id);
  }

  @override
  Future<Playlist> addSongToPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    final model = _playlistsBox.get(playlistId);
    if (model == null) throw Exception('Playlist introuvable : $playlistId');
    if (!model.songIds.contains(songId)) {
      model.songIds = [...model.songIds, songId];
      model.updatedAt = DateTime.now();
      if (model.coverArtSongId == null && model.songIds.isNotEmpty) {
        model.coverArtSongId = model.songIds.first;
      }
      await model.save();
    }
    return _hiveToEntity(model);
  }

  @override
  Future<Playlist> addSongsToPlaylist({
    required String playlistId,
    required List<String> songIds,
  }) async {
    final model = _playlistsBox.get(playlistId);
    if (model == null) throw Exception('Playlist introuvable : $playlistId');
    final existingIds = Set<String>.from(model.songIds);
    final newIds = songIds.where((id) => !existingIds.contains(id)).toList();
    if (newIds.isNotEmpty) {
      model.songIds = [...model.songIds, ...newIds];
      model.updatedAt = DateTime.now();
      model.coverArtSongId ??= model.songIds.first;
      await model.save();
    }
    return _hiveToEntity(model);
  }

  @override
  Future<Playlist> removeSongFromPlaylist({
    required String playlistId,
    required String songId,
  }) async {
    final model = _playlistsBox.get(playlistId);
    if (model == null) throw Exception('Playlist introuvable : $playlistId');
    model.songIds = model.songIds.where((id) => id != songId).toList();
    model.updatedAt = DateTime.now();
    if (model.coverArtSongId == songId) {
      model.coverArtSongId = model.songIds.isNotEmpty ? model.songIds.first : null;
    }
    await model.save();
    return _hiveToEntity(model);
  }

  @override
  Future<Playlist> reorderSongs({
    required String playlistId,
    required int oldIndex,
    required int newIndex,
  }) async {
    final model = _playlistsBox.get(playlistId);
    if (model == null) throw Exception('Playlist introuvable : $playlistId');
    final ids = List<String>.from(model.songIds);
    final item = ids.removeAt(oldIndex);
    ids.insert(newIndex, item);
    model.songIds = ids;
    model.updatedAt = DateTime.now();
    await model.save();
    return _hiveToEntity(model);
  }

  // ─── Helpers privés ────────────────────────────────────────────────────────

  Future<void> _saveToHive(Playlist playlist) async {
    final model = PlaylistHiveModel(
      id: playlist.id,
      name: playlist.name,
      description: playlist.description,
      songIds: List<String>.from(playlist.songIds),
      createdAt: playlist.createdAt,
      updatedAt: playlist.updatedAt,
      coverArtSongId: playlist.coverArtSongId,
    );
    await _playlistsBox.put(playlist.id, model);
  }

  Playlist _hiveToEntity(PlaylistHiveModel model) {
    return Playlist(
      id: model.id,
      name: model.name,
      description: model.description,
      songIds: List<String>.from(model.songIds),
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      coverArtSongId: model.coverArtSongId,
    );
  }
}
