import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème de l'application MonPlayer — inspiré d'Apple Music.
/// Utilise Material 3 avec des couleurs personnalisées.
class AppTheme {
  AppTheme._();

  // ─── Couleurs principales ───────────────────────────────────────────────────
  static const Color _primaryRed = Color(0xFFFC3C44);
  static const Color _primaryRedLight = Color(0xFFFF6B6B);
  static const Color _accentPink = Color(0xFFFF2D55);

  // ─── Couleurs mode sombre ──────────────────────────────────────────────────
  static const Color _darkBackground = Color(0xFF0A0A0F);
  static const Color _darkSurface = Color(0xFF141419);
  static const Color _darkCard = Color(0xFF1C1C24);
  static const Color _darkBorder = Color(0xFF2C2C38);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFF98989F);

  // ─── Couleurs mode clair ───────────────────────────────────────────────────
  static const Color _lightBackground = Color(0xFFF2F2F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightBorder = Color(0xFFE5E5EA);
  static const Color _lightTextPrimary = Color(0xFF000000);
  static const Color _lightTextSecondary = Color(0xFF6D6D72);

  // ─── Color Scheme sombre ───────────────────────────────────────────────────
  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: _primaryRed,
    onPrimary: Colors.white,
    primaryContainer: _primaryRed.withOpacity(0.15),
    onPrimaryContainer: _primaryRedLight,
    secondary: _accentPink,
    onSecondary: Colors.white,
    secondaryContainer: _accentPink.withOpacity(0.15),
    onSecondaryContainer: _accentPink,
    tertiary: const Color(0xFF30D158),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFF30D158).withOpacity(0.15),
    onTertiaryContainer: const Color(0xFF30D158),
    error: const Color(0xFFFF453A),
    onError: Colors.white,
    errorContainer: const Color(0xFFFF453A).withOpacity(0.15),
    onErrorContainer: const Color(0xFFFF453A),
    surface: _darkSurface,
    onSurface: _darkTextPrimary,
    onSurfaceVariant: _darkTextSecondary,
    outline: _darkBorder,
    outlineVariant: _darkBorder.withOpacity(0.5),
    shadow: Colors.black,
    scrim: Colors.black87,
    inverseSurface: _lightSurface,
    onInverseSurface: _lightTextPrimary,
    inversePrimary: _primaryRed,
    surfaceTint: _primaryRed.withOpacity(0.05),
  );

  // ─── Color Scheme clair ────────────────────────────────────────────────────
  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: _primaryRed,
    onPrimary: Colors.white,
    primaryContainer: _primaryRed.withOpacity(0.10),
    onPrimaryContainer: _primaryRed,
    secondary: _accentPink,
    onSecondary: Colors.white,
    secondaryContainer: _accentPink.withOpacity(0.10),
    onSecondaryContainer: _accentPink,
    tertiary: const Color(0xFF30D158),
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFF30D158).withOpacity(0.10),
    onTertiaryContainer: const Color(0xFF34C759),
    error: const Color(0xFFFF3B30),
    onError: Colors.white,
    errorContainer: const Color(0xFFFF3B30).withOpacity(0.10),
    onErrorContainer: const Color(0xFFFF3B30),
    surface: _lightSurface,
    onSurface: _lightTextPrimary,
    onSurfaceVariant: _lightTextSecondary,
    outline: _lightBorder,
    outlineVariant: _lightBorder.withOpacity(0.5),
    shadow: Colors.black26,
    scrim: Colors.black54,
    inverseSurface: _darkSurface,
    onInverseSurface: _darkTextPrimary,
    inversePrimary: _primaryRedLight,
    surfaceTint: _primaryRed.withOpacity(0.03),
  );

  // ─── Thème sombre ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return _buildTheme(_darkColorScheme, Brightness.dark, _darkBackground);
  }

  // ─── Thème clair ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return _buildTheme(_lightColorScheme, Brightness.light, _lightBackground);
  }

  // ─── Constructeur de thème partagé ────────────────────────────────────────
  static ThemeData _buildTheme(
    ColorScheme colorScheme,
    Brightness brightness,
    Color scaffoldBackground,
  ) {
    final isDark = brightness == Brightness.dark;
    final textTheme = GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDark ? _darkTextSecondary : _lightTextSecondary,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: isDark ? _darkTextSecondary : _lightTextSecondary,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
          letterSpacing: 1.25,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? _darkTextSecondary : _lightTextSecondary,
          letterSpacing: 1.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: isDark ? _darkTextSecondary : _lightTextSecondary,
          letterSpacing: 1.5,
        ),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(
          color: isDark ? _darkTextPrimary : _lightTextPrimary,
        ),
        centerTitle: true,
      ),

      // BottomNavigationBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark
            ? _darkSurface.withOpacity(0.95)
            : _lightSurface.withOpacity(0.95),
        selectedItemColor: _primaryRed,
        unselectedItemColor: isDark ? _darkTextSecondary : _lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // NavigationBar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? _darkSurface.withOpacity(0.95)
            : _lightSurface.withOpacity(0.95),
        indicatorColor: _primaryRed.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(color: _primaryRed);
          }
          return textTheme.labelSmall;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryRed);
          }
          return IconThemeData(
            color: isDark ? _darkTextSecondary : _lightTextSecondary,
          );
        }),
      ),

      // Card
      cardTheme: CardThemeData(
        color: isDark ? _darkCard : _lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        tileColor: Colors.transparent,
        selectedTileColor: _primaryRed.withOpacity(0.1),
        iconColor: isDark ? _darkTextSecondary : _lightTextSecondary,
        textColor: isDark ? _darkTextPrimary : _lightTextPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // IconButton
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return (isDark ? _darkTextSecondary : _lightTextSecondary)
                  .withOpacity(0.4);
            }
            return isDark ? _darkTextPrimary : _lightTextPrimary;
          }),
        ),
      ),

      // FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryRed,
        inactiveTrackColor: isDark ? _darkBorder : _lightBorder,
        thumbColor: Colors.white,
        overlayColor: _primaryRed.withOpacity(0.1),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? _darkTextSecondary : _lightTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryRed;
          return isDark ? _darkBorder : _lightBorder;
        }),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? _darkCard : _lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: textTheme.bodyMedium,
        prefixIconColor: isDark ? _darkTextSecondary : _lightTextSecondary,
        suffixIconColor: isDark ? _darkTextSecondary : _lightTextSecondary,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? _darkBorder : _lightBorder,
        thickness: 0.5,
        space: 0,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? _darkCard : _lightTextPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? _darkTextPrimary : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? _darkCard : _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? _darkCard : _lightSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        elevation: 0,
        modalElevation: 0,
      ),

      // PopupMenu
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? _darkCard : _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),

      // ProgressIndicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryRed,
      ),
    );
  }
}

/// Extensions de couleur utiles dans l'application.
extension AppColors on ColorScheme {
  Color get cardBackground => brightness == Brightness.dark
      ? const Color(0xFF1C1C24)
      : const Color(0xFFFFFFFF);

  Color get cardBorder => brightness == Brightness.dark
      ? const Color(0xFF2C2C38)
      : const Color(0xFFE5E5EA);

  Color get backgroundSecondary => brightness == Brightness.dark
      ? const Color(0xFF141419)
      : const Color(0xFFF2F2F7);
}
