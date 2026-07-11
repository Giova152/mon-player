/// Constantes de l'application MonPlayer.
class AppConstants {
  AppConstants._();

  /// Nom du dossier créé dans "Sur mon iPhone"
  static const String appFolderName = 'MonPlayer';

  /// Formats audio supportés
  static const List<String> supportedFormats = [
    'mp3',
    'm4a',
    'wav',
    'flac',
    'aac',
    'ogg',
    'opus',
    'wma',
    'aiff',
  ];

  /// Durée des animations en ms
  static const int animationDuration = 300;
  static const int fastAnimationDuration = 150;

  /// Vitesses de lecture disponibles
  static const List<double> playbackSpeeds = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  /// URL par défaut pour la couleur d'accent
  static const String defaultAccentColor = '#FC3C44';

  /// Nombre maximal de musiques dans la queue récente
  static const int maxRecentlyPlayed = 50;
}
