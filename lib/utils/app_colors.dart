import 'package:flutter/material.dart';

/// We're defining static const Color variables.
/// static means you can access them directly using AppColors.primaryOrange without creating an AppColors object. const means their values are fixed at compile time.

// A class to hold all your app's custom colors
class AppColors {
  // Primary Brand Colors (Orange & Yellow)
  static const Color primaryOrange = Color.fromARGB(
    255,
    246,
    87,
    25,
  ); // A fresh, vibrant orange
  static const Color accentYellow = Color(0xFFFFD700); // A bright, clear yellow
  static const Color goldenrod = Color.fromARGB(255, 255, 188, 18);

  // Neutral Colors (White & Black variants)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(
    0xFF333333,
  ); // For dark mode backgrounds, or bold text
  static const Color lightGrey = Color(
    0xFFF5F5F5,
  ); // For light mode backgrounds, or subtle elements
  static const Color mediumGrey = Color(0xFF757575); // For secondary text

  // Semantic Colors (Optional, but good practice)
  ///For crucial alerts, success messages, small notification badges,
  ///or as an alternative highlight for specific interactive elements if the gold is reserved for the absolute top priority.
  static const Color successGreen = Color(0xFF28a745);
  //For error messages, invalid input fields, or destructive actions (e.g., "Delete").
  static const Color errorRed = Color(0xFFCC0000);

  static const Color teal = Color(0xEE008080);
  static const Color darkEmerald = Color(0xFF006B3E);
  static const Color royalBlue = Color(0xEE4169E1);

  //Other palettes for the icons:
  // Palette 1: "Vaporwave Dream" (Nostalgic, Dreamy, Digital)
  static const Color electricViolet = Color(0xFF8A2BE2);
  static const Color cyanAqua = Color(0xFF00FFFF);
  static const Color hotPink = Color(0xFFFF69B4);
  static const Color aliceBlue = Color(0xFFF0F8FF);
  static const Color lightSeaGreen = Color(0xFF20B2AA);

  // Palette 2: "Urban Neon Pop" (Bold, Energetic, Street Art Inspired)
  static const Color neonMagenta = Color(0xFFFF00FF);
  static const Color electricLimeGreen = Color(0xFF39FF14);
  static const Color brightGold = Color(0xFFFFD700);
  static const Color deepSkyBlue = Color(0xFF00BFFF);
  static const Color nearBlack = Color(0xFF1A1A1A);

  // Palette 3: "Soft & Sweet Aesthetic" (Youthful, Whimsical, Cozy)
  static const Color softPink = Color(0xFFFFC0CB);
  static const Color softBlue = Color(0xFFADD8E6);
  static const Color softGreen = Color(0xFF90EE90);
  static const Color lemonChiffon = Color(0xFFFFFACD);
  static const Color softDarkGray = Color(0xFFA9A9A9);

  // Palette 4: "Dark Mode Edge" (Cool, Minimal, Sophisticated)
  static const Color darkModeBackground = Color(0xFF121212);
  static const Color darkModePrimaryAccent = Color(0xFF6C5CE7);
  static const Color darkModeSecondaryAccent = Color(0xFF00ADB5);
  static const Color darkModeHighlight = Color(0xFFFFD000);
  static const Color darkModeText = Color(0xFFE0E0E0);

  // You can add more specific shades if needed, e.g.:
  // static const Color darkOrange = Color(0xFFD37F00);
}
