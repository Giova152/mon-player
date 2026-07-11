import 'dart:io';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_constants.dart';
import '../../../domain/entities/song.dart';
import '../../../domain/repositories/music_repository.dart';
import '../../models/hive/song_hive_model.dart';
import '../../models/hive/app_settings_hive_model.dart';
import '../audio_scanner_service.dart';

/// Implémentation concrète du MusicRepository.
/// Gère le scan des fichiers et la persistance Hive.
class MusicRepositoryImpl implements MusicRepository {
  final AudioScannerService _scanner;
  final Box<SongHiveModel> _songsBox;
  final Box<AppSettingsHiveModel> _settingsBox;

  MusicRepositoryImpl({
    required AudioScannerService scanner,
    required Box<SongHiveModel> songsBox,
    required Box<AppSettingsHiveModel> settingsBox,
  })  : _scanner = scanner,
        _songsBox = songsBox,
        _settingsBox = settingsBox;

  // ─── Scan ──────────────────────────────────────────────────────────────────

  @override
  Future<List<Song>> scanMusicFolder() async {
    final audioFiles = await _scanner.scanAudioFiles();
    final existingIds = _songsBox.keys.toSet();
    final scannedSongs = <Song>[];

    for (final file in audioFiles) {
      if (!await file.exists()) continue;

      final song = await _scanner.extractMetadata(file);

      // Mise à jour ou création dans Hive
      final existingModel = _songsBox.get(song.id);
      if (existingModel != null) {
        // Conserver les données utilisateur (favoris, playCount)
        scannedSongs.add(song.copyWith(
          isFavorite: existingModel.isFavorite,
          playCount: existingModel.playCount,
          lastPlayedPosition: existingModel.lastPlayedPosition,
          artworkPath: song.artworkPath ?? existingModel.artworkPath,
        ));
        // Mettre à jour les métadonnées dans Hive
        await _saveToHive(scannedSongs.last);
      } else {
        scannedSongs.add(song);
        await _saveToHive(song);
      }
    }

    // Supprimer les chansons dont le fichier n'existe plus
    final scannedIds = scannedSongs.map((s) => s.id).toSet();
    for (final id in existingIds) {
      if (!scannedIds.contains(id)) {
        await _songsBox.delete(id);
      }
    }

    return scannedSongs;
  }

  // ─── CRUD ──────────────────────────────────────────────────────────────────

  @override
  Future<List<Song>> getAllSongs() async {
    return _songsBox.values.map(_hiveToEntity).toList();
  }

  @override
  Future<List<Song>> getFavoriteSongs() async {
    return _songsBox.values
        .where((s) => s.isFavorite)
        .map(_hiveToEntity)
        .toList();
  }

  @override
  Future<void> toggleFavorite(String songId) async {
    final model = _songsBox.get(songId);
    if (model != null) {
      model.isFavorite = !model.isFavorite;
      await model.save();
    }
  }

  @override
  Future<void> updatePlayStats({
    required String songId,
    required int positionMs,
  }) async {
    final model = _songsBox.get(songId);
    if (model != null) {
      model.playCount = model.playCount + 1;
      model.lastPlayedPosition = positionMs;
      await model.save();
    }

    // Sauvegarder dans les settings
    final settings = _getOrCreateSettings();
    settings.lastPlayedSongId = songId;
    settings.lastPlayedPositionMs = positionMs;
    await _settingsBox.put(HiveConstants.settingsKey, settings);
  }

  @override
  Future<({String? songId, int positionMs})> getLastPlayed() async {
    final settings = _settingsBox.get(HiveConstants.settingsKey);
    return (
      songId: settings?.lastPlayedSongId,
      positionMs: settings?.lastPlayedPositionMs ?? 0,
    );
  }

  @override
  Future<Song?> getSongById(String id) async {
    final model = _songsBox.get(id);
    if (model == null) return null;
    return _hiveToEntity(model);
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    if (query.isEmpty) return getAllSongs();
    final q = query.toLowerCase();
    return _songsBox.values
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q) ||
            s.fileName.toLowerCase().contains(q))
        .map(_hiveToEntity)
        .toList();
  }

  @override
  Future<List<Song>> getSongsSorted(SongSortOrder order) async {
    final songs = _songsBox.values.map(_hiveToEntity).toList();
    switch (order) {
      case SongSortOrder.titleAsc:
        songs.sort((a, b) => a.title.compareTo(b.title));
      case SongSortOrder.titleDesc:
        songs.sort((a, b) => b.title.compareTo(a.title));
      case SongSortOrder.artistAsc:
        songs.sort((a, b) => a.artist.compareTo(b.artist));
      case SongSortOrder.artistDesc:
        songs.sort((a, b) => b.artist.compareTo(a.artist));
      case SongSortOrder.albumAsc:
        songs.sort((a, b) => a.album.compareTo(b.album));
      case SongSortOrder.dateAddedDesc:
        songs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case SongSortOrder.dateAddedAsc:
        songs.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
      case SongSortOrder.durationAsc:
        songs.sort((a, b) => a.duration.compareTo(b.duration));
      case SongSortOrder.durationDesc:
        songs.sort((a, b) => b.duration.compareTo(a.duration));
      case SongSortOrder.playCountDesc:
        songs.sort((a, b) => b.playCount.compareTo(a.playCount));
    }
    return songs;
  }

  // ─── Helpers privés ────────────────────────────────────────────────────────

  Future<void> _saveToHive(Song song) async {
    final model = SongHiveModel(
      id: song.id,
      filePath: song.filePath,
      fileName: song.fileName,
      title: song.title,
      artist: song.artist,
      album: song.album,
      genre: song.genre,
      durationMs: song.duration.inMilliseconds,
      fileSize: song.fileSize,
      dateAdded: song.dateAdded,
      artworkPath: song.artworkPath,
      trackNumber: song.trackNumber,
      year: song.year,
      isFavorite: song.isFavorite,
      playCount: song.playCount,
      lastPlayedPosition: song.lastPlayedPosition,
    );
    await _songsBox.put(song.id, model);
  }

  Song _hiveToEntity(SongHiveModel model) {
    return Song(
      id: model.id,
      filePath: model.filePath,
      fileName: model.fileName,
      title: model.title,
      artist: model.artist,
      album: model.album,
      genre: model.genre,
      duration: Duration(milliseconds: model.durationMs),
      fileSize: model.fileSize,
      dateAdded: model.dateAdded,
      artworkPath: model.artworkPath,
      trackNumber: model.trackNumber,
      year: model.year,
      isFavorite: model.isFavorite,
      playCount: model.playCount,
      lastPlayedPosition: model.lastPlayedPosition,
    );
  }

  AppSettingsHiveModel _getOrCreateSettings() {
    return _settingsBox.get(HiveConstants.settingsKey) ??
        AppSettingsHiveModel();
  }
}
