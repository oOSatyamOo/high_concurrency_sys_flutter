import 'package:flutter/material.dart';

// @AETHER: Centralized color palette for the cyber-mystic / dark fantasy aesthetic.
// All colors defined as const to ensure compile-time resolution and zero runtime cost.
// HSL-tuned for visual harmony across dark surfaces with high-contrast neon accents.

/// {@template color_palette}
/// Aether's unified color system.
///
/// Colors are organized into semantic groups:
/// - **Abyss**: Deep backgrounds and surfaces (dark purples/blacks)
/// - **Neon**: High-energy accents for interactive elements
/// - **Metallic**: Gold/silver for premium UI elements
/// - **Status**: Semantic colors for success/warning/error states
/// {@endtemplate}
abstract final class ColorPalette {
  // ──────────────────────────────────────────────
  // Abyss — Deep backgrounds & surfaces
  // ──────────────────────────────────────────────

  /// Primary void — deepest background.
  static const Color abyssCore = Color(0xFF0A0612);

  /// Surface layer — card backgrounds, panels.
  static const Color abyssSurface = Color(0xFF1A0A2E);

  /// Elevated surface — modals, dialogs, raised cards.
  static const Color abyssElevated = Color(0xFF251545);

  /// Subtle surface variant for hover/focus states.
  static const Color abyssHover = Color(0xFF2E1B52);

  // ──────────────────────────────────────────────
  // Neon — High-energy interactive accents
  // ──────────────────────────────────────────────

  /// Primary neon — cyan glow for active elements.
  static const Color neonCyan = Color(0xFF00F5D4);

  /// Secondary neon — electric purple for secondary actions.
  static const Color neonPurple = Color(0xFFB24BF3);

  /// Tertiary neon — magenta for highlights and badges.
  static const Color neonMagenta = Color(0xFFFF006E);

  /// Neon blue — used for chat bubbles and info elements.
  static const Color neonBlue = Color(0xFF3A86FF);

  // ──────────────────────────────────────────────
  // Metallic — Premium UI elements
  // ──────────────────────────────────────────────

  /// Gold — for boss timers, rare items, premium indicators.
  static const Color metallicGold = Color(0xFFFFD700);

  /// Silver — for secondary metallic accents.
  static const Color metallicSilver = Color(0xFFC0C0C0);

  /// Bronze — for tertiary/earned status.
  static const Color metallicBronze = Color(0xFFCD7F32);

  // ──────────────────────────────────────────────
  // Status — Semantic feedback colors
  // ──────────────────────────────────────────────

  /// Success — raid join confirmed, action complete.
  static const Color statusSuccess = Color(0xFF00E676);

  /// Warning — slots filling, timer low.
  static const Color statusWarning = Color(0xFFFFAB00);

  /// Error — raid full, action failed.
  static const Color statusError = Color(0xFFFF1744);

  // ──────────────────────────────────────────────
  // Text — Typography colors
  // ──────────────────────────────────────────────

  /// Primary text — high contrast on dark surfaces.
  static const Color textPrimary = Color(0xFFF0E6FF);

  /// Secondary text — muted labels and captions.
  static const Color textSecondary = Color(0xFFB8A9D4);

  /// Disabled text — inactive or placeholder text.
  static const Color textDisabled = Color(0xFF6B5B8A);

  // ──────────────────────────────────────────────
  // Dividers & Borders
  // ──────────────────────────────────────────────

  /// Subtle divider on dark surfaces.
  static const Color divider = Color(0xFF3D2A5C);

  /// Border for input fields and cards.
  static const Color border = Color(0xFF4A3570);
}
