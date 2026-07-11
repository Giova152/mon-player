import 'package:equatable/equatable.dart';
import 'song.dart';

/// Entité représentant une playlist.
class Playlist extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<String> songIds; // IDs des chansons dans la playlist
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverArtSongId; // ID de la chanson utilisée pour la pochette

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverArtSongId,
  });

  /// Nombre de chansons dans la playlist.
  int get trackCount => songIds.length;

  /// Vérifie si la playlist contient une chanson.
  bool containsSong(String songId) => songIds.contains(songId);

  /// Durée totale de la playlist (calculée depuis les chansons).
  Duration totalDuration(List<Song> songs) {
    final playlistSongs = songs.where((s) => songIds.contains(s.id));
    return playlistSongs.fold(
      Duration.zero,
      (total, song) => total + song.duration,
    );
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverArtSongId,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverArtSongId: coverArtSongId ?? this.coverArtSongId,
    );
  }

  @override
  List<Object?> get props => [id, name, songIds, createdAt, updatedAt];

  @override
  String toString() => 'Playlist(id: $id, name: $name, count: $trackCount)';
}
