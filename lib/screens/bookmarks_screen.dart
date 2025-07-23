import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookmarks', style: AppTextStyles.appBarTitle),
        backgroundColor:
            AppColors.electricViolet, // Or another appropriate color
      ),
      body: Center(
        child: Text(
          'Your bookmarks will appear here!',
          style: AppTextStyles.bodyText,
        ),
      ),
    );
  }
}
