import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/screens/home_screen.dart'; // Import your new screen
import 'package:quran_tafseer_app/utils/app_colors.dart'; // Import your colors
import 'package:quran_tafseer_app/utils/app_text_styles.dart'; // Import your text styles
import 'package:quran_tafseer_app/utils/app_constants.dart'; // Import your dimensions

void main() {
  // NEW: Ensure Flutter's widget binding is initialized.
  // This is crucial for plugins like shared_preferences to work correctly early in the app lifecycle.
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Tafseer',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryOrange,
          primary: AppColors.primaryOrange,
          onPrimary: AppColors.white,
          secondary: AppColors.accentYellow,
          onSecondary: AppColors.black,
          surface: AppColors.white,
          onSurface: AppColors.black,
          error: AppColors.errorRed,
          onError: AppColors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.lightGrey,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: AppColors.white,
          elevation: 0,
          titleTextStyle: AppTextStyles.heading2.copyWith(
            color: AppColors.white,
          ),
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.heading1,
          displayMedium: AppTextStyles.heading2,
          bodyLarge: AppTextStyles.bodyText,
          bodyMedium: AppTextStyles.bodyText,
          titleMedium: AppTextStyles.translationText,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.borderRadiusMedium),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingLarge,
              vertical: AppDimens.paddingMedium,
            ),
            textStyle: AppTextStyles.buttonTextStyle,
          ),
        ),
      ),
      home: const HomeScreen(), // Use your new screen here!
    );
  }
}
