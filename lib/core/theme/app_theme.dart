import 'package:flutter/material.dart';

import 'color_palette.dart';

// @AETHER: Single-source-of-truth Material 3 theme for the entire application.
// Uses ColorScheme.fromSeed is intentionally AVOIDED — we use a hand-crafted
// ColorScheme for pixel-perfect control over the cyber-mystic aesthetic.
// This prevents Material's auto-tonal mapping from diluting our neon palette.

// @AETHER:CONTINUATION — Phase 2 will add custom TextButton, OutlinedButton,

/// {@template app_theme}
/// Industry-grade Material 3 dark theme for Aether.
///
/// Design language: Dark Fantasy / Cyber-Mystic
/// - Deep purple abyss backgrounds
/// - Neon cyan primary with purple secondary
/// - Metallic gold accents for boss/raid elements
/// - Glassmorphism-inspired elevated surfaces
/// {@endtemplate}
abstract final class AppTheme {
  /// The single, authoritative [ThemeData] for the Aether application.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: ColorPalette.abyssCore,
      fontFamily: 'Roboto',

      // ── App Bar ──────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ColorPalette.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        iconTheme: IconThemeData(color: ColorPalette.neonCyan),
      ),

      // ── Cards ────────────────────────────────────────
      // @AETHER: Cards use a subtle purple surface with neon border glow.
      // Elevation is kept at 0 — we use custom BoxShadow for neon glow effects
      // in widgets, which gives us more control than Material's built-in elevation.
      cardTheme: CardThemeData(
        color: ColorPalette.abyssSurface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColorPalette.border, width: 0.5),
        ),
      ),

      // ── Elevated Buttons ─────────────────────────────
      // @AETHER: Primary action buttons (Join Raid) — neon cyan with dark text
      // for maximum contrast and CTA visibility.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.neonCyan,
          foregroundColor: ColorPalette.abyssCore,
          disabledBackgroundColor: ColorPalette.textDisabled,
          disabledForegroundColor: ColorPalette.abyssSurface,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── Input Fields ─────────────────────────────────
      // @AETHER: Chat input fields — dark surface with subtle neon focus border.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorPalette.abyssElevated,
        hintStyle: const TextStyle(
          color: ColorPalette.textDisabled,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ColorPalette.neonCyan,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorPalette.statusError),
        ),
      ),

      // ── Divider ──────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: ColorPalette.divider,
        thickness: 0.5,
        space: 1,
      ),

      // ── Icon ─────────────────────────────────────────
      iconTheme: const IconThemeData(color: ColorPalette.neonCyan, size: 24),

      // ── Text ─────────────────────────────────────────
      textTheme: _textTheme,

      // ── Progress Indicator ───────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: ColorPalette.neonCyan,
        linearTrackColor: ColorPalette.abyssElevated,
      ),

      // ── Snackbar ─────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ColorPalette.abyssElevated,
        contentTextStyle: const TextStyle(color: ColorPalette.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Private: ColorScheme ────────────────────────────
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: ColorPalette.neonCyan,
    onPrimary: ColorPalette.abyssCore,
    secondary: ColorPalette.neonPurple,
    onSecondary: ColorPalette.textPrimary,
    tertiary: ColorPalette.metallicGold,
    onTertiary: ColorPalette.abyssCore,
    error: ColorPalette.statusError,
    onError: ColorPalette.textPrimary,
    surface: ColorPalette.abyssSurface,
    onSurface: ColorPalette.textPrimary,
    surfaceContainerHighest: ColorPalette.abyssElevated,
    outline: ColorPalette.border,
    outlineVariant: ColorPalette.divider,
  );

  // ── Private: TextTheme ──────────────────────────────
  // @AETHER: Using a curated type scale. Display styles use wide letter-spacing
  // for the epic/fantasy feel. Body styles are tighter for readability in chat.
  static const TextTheme _textTheme = TextTheme(
    // Display — World Boss name, epic headers
    displayLarge: TextStyle(
      color: ColorPalette.textPrimary,
      fontSize: 32,
      fontWeight: FontWeight.w800,
      letterSpacing: 2.0,
    ),
    displayMedium: TextStyle(
      color: ColorPalette.textPrimary,
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
    displaySmall: TextStyle(
      color: ColorPalette.textPrimary,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),

    // Headline — Section titles (Global Pulse, Geo-Raid, Chat)
    headlineMedium: TextStyle(
      color: ColorPalette.metallicGold,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 2.5,
    ),
    headlineSmall: TextStyle(
      color: ColorPalette.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
    ),

    // Title — Card titles, raid names
    titleLarge: TextStyle(
      color: ColorPalette.textPrimary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: TextStyle(
      color: ColorPalette.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),

    // Body — Chat messages, descriptions
    bodyLarge: TextStyle(
      color: ColorPalette.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      color: ColorPalette.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),

    // Label — Buttons, counters, timestamps
    labelLarge: TextStyle(
      color: ColorPalette.neonCyan,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
    labelMedium: TextStyle(
      color: ColorPalette.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      color: ColorPalette.textDisabled,
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
  );
}
