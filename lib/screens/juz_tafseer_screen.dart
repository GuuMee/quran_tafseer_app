import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';

class JuzTafseerScreen extends StatelessWidget {
  const JuzTafseerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Juz 30 Tafseer', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.goldenrod,
      ),
      body: Center(
        child: Text(
          'Tafseer content for Juz 30 will be displayed here!',
          style: AppTextStyles.bodyText,
        ),
      ),
    );
  }
}
