import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';

class RecitationScreen extends StatelessWidget {
  const RecitationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listen Recitation', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.successGreen,
      ),
      body: Center(
        child: Text(
          'Audio player for recitations will be here!',
          style: AppTextStyles.bodyText,
        ),
      ),
    );
  }
}
