import 'package:flutter/material.dart';

/// Utilitaires pour formater la durée d'une piste audio.
class DurationUtils {
  DurationUtils._();

  /// Formate une durée en format mm:ss ou h:mm:ss.
  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Retourne le temps restant (-mm:ss).
  static String remaining(Duration total, Duration current) {
    final remaining = total - current;
    return '-${format(remaining)}';
  }

  /// Convertit des millisecondes en Duration.
  static Duration fromMilliseconds(int ms) =>
      Duration(milliseconds: ms);

  /// Convertit des secondes en Duration.
  static Duration fromSeconds(double seconds) =>
      Duration(milliseconds: (seconds * 1000).round());
}

/// Utilitaires pour les chaînes de caractères.
class StringUtils {
  StringUtils._();

  /// Retourne le nom du fichier sans son extension.
  static String fileNameWithoutExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return fileName;
    return fileName.substring(0, lastDot);
  }

  /// Retourne l'extension d'un fichier en minuscules.
  static String fileExtension(String fileName) {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return '';
    return fileName.substring(lastDot + 1).toLowerCase();
  }

  /// Tronque une chaîne si elle dépasse maxLength.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}…';
  }

  /// Retourne les initiales d'un texte (ex: "The Beatles" → "TB").
  static String initials(String text) {
    if (text.isEmpty) return '?';
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

/// Utilitaires pour les couleurs.
class ColorUtils {
  ColorUtils._();

  /// Génère une couleur déterministe à partir d'un texte (pour les avatars).
  static Color fromText(String text) {
    const colors = [
      Color(0xFFFC3C44),
      Color(0xFF30D158),
      Color(0xFF0A84FF),
      Color(0xFFFF9F0A),
      Color(0xFFBF5AF2),
      Color(0xFF32ADE6),
      Color(0xFFFF375F),
      Color(0xFF34C759),
    ];
    final index = text.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }

  /// Vérifie si une couleur est sombre (pour adapter le texte).
  static bool isDark(Color color) {
    final luminance = color.computeLuminance();
    return luminance < 0.5;
  }

  /// Retourne blanc ou noir selon la luminance de la couleur de fond.
  static Color adaptiveText(Color background) {
    return isDark(background) ? Colors.white : Colors.black;
  }
}
