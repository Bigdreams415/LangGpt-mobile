import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF2E8B57);       // Forest Green
  static const Color primaryLight = Color(0xFF4CAF7D);
  static const Color primaryDark = Color(0xFF1F6B40);
  static const Color primarySurface = Color(0xFFE8F5EE); // light green tint

  // Secondary
  static const Color secondary = Color(0xFFCC5C3B);     // Warm Terracotta Red
  static const Color secondaryLight = Color(0xFFE87B5A);
  static const Color secondaryDark = Color(0xFFA3432A);
  static const Color secondarySurface = Color(0xFFFAEDE8);

  // Accent
  static const Color accentBlue = Color(0xFF1B4F8A);    // Deep Blue
  static const Color accentYellow = Color(0xFFF5C518);  // Warm Yellow
  static const Color accentBlueSurface = Color(0xFFE8EEF7);
  static const Color accentYellowSurface = Color(0xFFFFF8E1);

  // Neutral — Light
  static const Color background = Color(0xFFFAF8F3);    // Off-white / Cream
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2EFE8);
  static const Color divider = Color(0xFFE5E0D5);

  // Neutral — Dark
  static const Color darkBackground = Color(0xFF0F1410);
  static const Color darkSurface = Color(0xFF1A1F1A);
  static const Color darkSurfaceVariant = Color(0xFF242924);
  static const Color darkDivider = Color(0xFF2E332E);

  // Text — Light
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6560);
  static const Color textHint = Color(0xFFABA49B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Text — Dark
  static const Color textPrimaryDark = Color(0xFFE8E4DD);
  static const Color textSecondaryDark = Color(0xFFA09B92);
  static const Color textHintDark = Color(0xFF6B665E);

  // Status
  static const Color success = Color(0xFF2E8B57);
  static const Color error = Color(0xFFCC5C3B);
  static const Color warning = Color(0xFFF5C518);
  static const Color info = Color(0xFF1B4F8A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E8B57), Color(0xFF1F6B40)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1F6B40), Color(0xFF2E8B57), Color(0xFF3DAB6F)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFAF8F3), Color(0xFFF2EDE3)],
  );

  static const LinearGradient terracottaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFCC5C3B), Color(0xFFA3432A)],
  );
}

