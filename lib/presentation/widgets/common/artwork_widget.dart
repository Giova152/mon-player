import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/utils/utils.dart';

/// Widget d'artwork de chanson — affiche la pochette ou un placeholder coloré.
class ArtworkWidget extends StatelessWidget {
  final String? artworkPath;
  final double size;
  final double borderRadius;
  final String title;
  final String artist;
  final BoxFit fit;

  const ArtworkWidget({
    super.key,
    this.artworkPath,
    this.size = 52,
    this.borderRadius = 8,
    required this.title,
    required this.artist,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: artworkPath != null
            ? _ArtworkImage(path: artworkPath!, size: size, fit: fit)
            : _ArtworkPlaceholder(title: title, artist: artist, size: size),
      ),
    );
  }
}

/// Image de la pochette depuis le système de fichiers.
class _ArtworkImage extends StatelessWidget {
  final String path;
  final double size;
  final BoxFit fit;

  const _ArtworkImage({
    required this.path,
    required this.size,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (_, __, ___) => _ArtworkPlaceholder(
        title: '',
        artist: '',
        size: size,
      ),
      frameBuilder: (_, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return AnimatedOpacity(
          opacity: frame != null ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: child,
        );
      },
    );
  }
}

/// Placeholder coloré avec initiales quand pas de pochette.
class _ArtworkPlaceholder extends StatelessWidget {
  final String title;
  final String artist;
  final double size;

  const _ArtworkPlaceholder({
    required this.title,
    required this.artist,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final text = title.isNotEmpty ? title : artist;
    final color = ColorUtils.fromText(text);
    final initials = StringUtils.initials(text);
    final fontSize = size * 0.3;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Version large de l'artwork pour l'écran du lecteur complet.
class LargeArtworkWidget extends StatelessWidget {
  final String? artworkPath;
  final String title;
  final String artist;
  final double size;

  const LargeArtworkWidget({
    super.key,
    this.artworkPath,
    required this.title,
    required this.artist,
    this.size = 300,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 5,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: artworkPath != null
            ? Image.file(
                File(artworkPath!),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _LargePlaceholder(
                  title: title,
                  artist: artist,
                  size: size,
                ),
              )
            : _LargePlaceholder(
                title: title,
                artist: artist,
                size: size,
              ),
      ),
    );
  }
}

class _LargePlaceholder extends StatelessWidget {
  final String title;
  final String artist;
  final double size;

  const _LargePlaceholder({
    required this.title,
    required this.artist,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final text = title.isNotEmpty ? title : artist;
    final color = ColorUtils.fromText(text);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.6),
            color.withOpacity(0.8),
          ],
          stops: const [0, 0.5, 1],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_rounded,
              size: size * 0.35,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size * 0.1),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.06,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
