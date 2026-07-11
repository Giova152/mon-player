import 'dart:typed_data';
import 'package:equatable/equatable.dart';

/// Entité représentant une piste audio dans le domaine métier.
class Song extends Equatable {
  final String id;
  final String filePath;
  final String fileName;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final Duration duration;
  final int fileSize;
  final DateTime dateAdded;
  final Uint8List? artwork;
  final String? artworkPath;
  final int trackNumber;
  final int year;
  final bool isFavorite;
  final int playCount;
  final int? lastPlayedPosition; // en millisecondes

  const Song({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.duration,
    required this.fileSize,
    required this.dateAdded,
    this.artwork,
    this.artworkPath,
    this.trackNumber = 0,
    this.year = 0,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayedPosition,
  });

  /// Crée une copie de la chanson avec les champs modifiés.
  Song copyWith({
    String? id,
    String? filePath,
    String? fileName,
    String? title,
    String? artist,
    String? album,
    String? genre,
    Duration? duration,
    int? fileSize,
    DateTime? dateAdded,
    Uint8List? artwork,
    String? artworkPath,
    int? trackNumber,
    int? year,
    bool? isFavorite,
    int? playCount,
    int? lastPlayedPosition,
  }) {
    return Song(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      dateAdded: dateAdded ?? this.dateAdded,
      artwork: artwork ?? this.artwork,
      artworkPath: artworkPath ?? this.artworkPath,
      trackNumber: trackNumber ?? this.trackNumber,
      year: year ?? this.year,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayedPosition: lastPlayedPosition ?? this.lastPlayedPosition,
    );
  }

  @override
  List<Object?> get props => [
        id,
        filePath,
        fileName,
        title,
        artist,
        album,
        genre,
        duration,
        fileSize,
        dateAdded,
        isFavorite,
        playCount,
      ];

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}
