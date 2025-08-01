// lib/main.dart - Use this code ONLY AFTER pub outdated confirms correct package versions
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart'; // Keep this import
import 'package:quran_tafseer_app/screens/home_screen.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/utils/app_constants.dart';

import 'package:quran_tafseer_app/services/central_audio_handler.dart';

// This `late` variable will be assigned by JustAudioBackground.init's internal AudioService.instance
late final CentralAudioHandler
globalAudioHandler; // Use late final as it's assigned once

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // // 1. Initialize JustAudioBackground (this only sets up the notification UI)
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.example.quran_tafseer_app.channel.audio',
  //   androidNotificationChannelName: 'Quran Recitation',
  //   androidNotificationOngoing: true,
  //   androidNotificationIcon: 'drawable/ic_stat_music_note',
  // );

  // // 2. Initialize AudioService separately, injecting your custom CentralAudioHandler
  // // This is the correct pattern for older just_audio_background versions
  // globalAudioHandler = await AudioService.init(
  //   builder: () => CentralAudioHandler(),
  //   config: const AudioServiceConfig(
  //     androidNotificationChannelId:
  //         'com.example.quran_tafseer_app.channel.audio',
  //     androidNotificationChannelName: 'Quran Recitation',
  //     androidNotificationOngoing: true,
  //     androidNotificationClickStartsActivity: true,
  //     androidStopForegroundOnPause: true,
  //   ),
  // );

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
      home: const HomeScreen(),
    );
  }
}
