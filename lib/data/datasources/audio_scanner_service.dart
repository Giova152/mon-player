import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/song.dart';

/// Service de scan du dossier MonPlayer et d'extraction des métadonnées.
class AudioScannerService {
  final _uuid = const Uuid();

  /// Retourne le chemin du dossier MonPlayer sur l'appareil.
  Future<Directory> getMonPlayerDirectory() async {
    // Sur iOS, on utilise les Documents accessibles depuis l'app Fichiers
    final docsDir = await getApplicationDocumentsDirectory();
    final monPlayerDir = Directory(p.join(docsDir.path, AppConstants.appFolderName));

    if (!await monPlayerDir.exists()) {
      await monPlayerDir.create(recursive: true);
    }

    return monPlayerDir;
  }

  /// Scanne le dossier MonPlayer et retourne la liste des fichiers audio.
  Future<List<File>> scanAudioFiles() async {
    final dir = await getMonPlayerDirectory();
    final audioFiles = <File>[];

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase().replaceFirst('.', '');
        if (AppConstants.supportedFormats.contains(ext)) {
          audioFiles.add(entity);
        }
      }
    }

    return audioFiles;
  }

  /// Extrait les métadonnées d'un fichier audio et crée une entité Song.
  Future<Song> extractMetadata(File file) async {
    try {
      final metadata = await MetadataRetriever.fromFile(file);
      final stat = await file.stat();
      final fileName = p.basename(file.path);

      // Extraction de l'artwork si disponible
      Uint8List? artwork;
      String? artworkPath;
      if (metadata.albumArt != null) {
        final artworkDir = await _getArtworkDirectory();
        final songId = _generateIdFromPath(file.path);
        final artworkFile = File(p.join(artworkDir.path, '$songId.jpg'));
        if (!await artworkFile.exists()) {
          await artworkFile.writeAsBytes(metadata.albumArt!);
        }
        artworkPath = artworkFile.path;
        artwork = metadata.albumArt;
      }

      return Song(
        id: _generateIdFromPath(file.path),
        filePath: file.path,
        fileName: fileName,
        title: metadata.trackName?.isNotEmpty == true
            ? metadata.trackName!
            : _titleFromFileName(fileName),
        artist: metadata.authorName ?? metadata.albumArtistName ?? 'Artiste inconnu',
        album: metadata.albumName ?? 'Album inconnu',
        genre: metadata.genre ?? '',
        duration: Duration(milliseconds: metadata.trackDuration ?? 0),
        fileSize: stat.size,
        dateAdded: stat.modified,
        artwork: artwork,
        artworkPath: artworkPath,
        trackNumber: metadata.trackNumber ?? 0,
        year: metadata.year ?? 0,
        isFavorite: false,
        playCount: 0,
      );
    } catch (_) {
      // En cas d'erreur de lecture des métadonnées, on crée une Song minimale
      final stat = await file.stat();
      final fileName = p.basename(file.path);
      return Song(
        id: _generateIdFromPath(file.path),
        filePath: file.path,
        fileName: fileName,
        title: _titleFromFileName(fileName),
        artist: 'Artiste inconnu',
        album: 'Album inconnu',
        genre: '',
        duration: Duration.zero,
        fileSize: stat.size,
        dateAdded: stat.modified,
      );
    }
  }

  /// Génère un ID déterministe depuis le chemin du fichier.
  String _generateIdFromPath(String path) {
    // On utilise un hash du chemin pour avoir un ID stable
    final hash = path.hashCode.abs().toRadixString(16).padLeft(8, '0');
    return 'song_$hash';
  }

  /// Extrait un titre lisible depuis le nom de fichier.
  String _titleFromFileName(String fileName) {
    final withoutExt = p.basenameWithoutExtension(fileName);
    // Remplace les tirets/underscores par des espaces
    return withoutExt.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
  }

  /// Retourne le dossier de cache des artworks.
  Future<Directory> _getArtworkDirectory() async {
    final cacheDir = await getTemporaryDirectory();
    final artworkDir = Directory(p.join(cacheDir.path, 'artworks'));
    if (!await artworkDir.exists()) {
      await artworkDir.create(recursive: true);
    }
    return artworkDir;
  }
}
