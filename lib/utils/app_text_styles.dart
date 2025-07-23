import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart'; // Import your colors

// Define your font family names here.
// Make sure these fonts are added to your pubspec.yaml and assets!
/// Crucial Step for Custom Fonts: For your Arabic font (like Uthman Taha Naskh or any other you licensed), you must add it
/// to your pubspec.yaml file under the flutter: assets: section and ensure the font file (.ttf or .otf) is placed
/// in a designated assets/fonts/ folder (or similar).
const String kArabicFontFamily =
    'UthmanTahaNaskh'; // Example: Replace with your actual Arabic font name
const String kLatinFontFamily =
    'Roboto'; // Example: Replace with your chosen Latin font (e.g., Poppins, Lexend)

class AppTextStyles {
  // --- Arabic Text Styles ---
  static const TextStyle arabicAyahStyle = TextStyle(
    fontFamily: kArabicFontFamily,
    fontSize: 28.0, // Large for readability
    fontWeight: FontWeight.normal,
    color: AppColors.black,
    height: 1.8, // Good line spacing for Arabic
  );

  static const TextStyle arabicSurahNameStyle = TextStyle(
    fontFamily: kArabicFontFamily,
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle arabicTextSmall = TextStyle(
    fontSize: 16, // Smaller size for displaying Arabic names
    fontWeight: FontWeight.normal,
    color: AppColors.black,
    fontFamily: 'NotoNaskhArabic',
    // Make sure this font family supports Arabic characters.
  );

  // --- Latin/UI Text Styles ---
  static const TextStyle heading1 = TextStyle(
    fontFamily: kLatinFontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGrey, // Or AppColors.black for bold headings
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: kLatinFontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w600, // Semi-bold
    color: AppColors.darkGrey,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: kLatinFontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600, // Semi-bold
    color: AppColors.darkGrey,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: kLatinFontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle translationText = TextStyle(
    fontFamily: kLatinFontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
    color: AppColors.mediumGrey, // Slightly lighter for translation
    height: 1.5, // Good line spacing for Latin
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontFamily: kLatinFontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w500, // Medium weight
    color: AppColors.white, // For buttons with colored backgrounds
  );

  static const TextStyle captionText = TextStyle(
    fontFamily: kLatinFontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.mediumGrey,
  );

  // --- Dark Mode Variations (example) ---
  static final TextStyle arabicAyahStyleDark = arabicAyahStyle.copyWith(
    color: AppColors.white,
  );
  static final TextStyle heading1Dark = heading1.copyWith(
    color: AppColors.white,
  );

  static final TextStyle appBarTitle = TextStyle(
    // Changed from GoogleFonts.poppins
    fontFamily: kLatinFontFamily, // <--- Set your custom font family name here
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  // You'd create .copyWith for all styles for your dark theme
}
