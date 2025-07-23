// lib/screens/bookmarks_screen.dart

import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/models/ayah.dart';
import 'package:quran_tafseer_app/models/surah.dart';
import 'package:quran_tafseer_app/services/app_preferences.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/utils/app_constants.dart';
import 'package:quran_tafseer_app/data/ayahs_data.dart';
import 'package:quran_tafseer_app/data/surahs_data.dart'; // Import for allSurahs
import 'package:quran_tafseer_app/screens/surah_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, int>> _bookmarkReferences = [];
  List<Ayah> _bookmarkedAyahsData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _isLoading = true;
    });

    final List<Map<String, int>> references =
        await AppPreferences.getAllBookmarks();
    final List<Ayah> ayahsData = [];

    for (var ref in references) {
      final int surahNumber = ref['surahNumber']!;
      final int ayahNumber = ref['ayahNumber']!;

      // Use the global 'allSurahs' variable directly
      final Surah surah = allSurahs.firstWhere(
        // <<-- CHANGED: Using 'allSurahs'
        (s) => s.number == surahNumber,
        orElse:
            () => throw Exception('Surah not found for bookmark: $surahNumber'),
      );

      final List<Ayah> surahAyahs = getAyahsForSurah(
        surahNumber,
        surah.numberOfAyahs,
      );
      final Ayah bookmarkedAyah = surahAyahs.firstWhere(
        (a) => a.ayahNumber == ayahNumber,
        orElse:
            () =>
                throw Exception(
                  'Ayah not found for bookmark: $surahNumber:$ayahNumber',
                ),
      );
      ayahsData.add(bookmarkedAyah);
    }

    ayahsData.sort((a, b) {
      int surahCompare = a.surahNumber.compareTo(b.surahNumber);
      if (surahCompare != 0) {
        return surahCompare;
      }
      return a.ayahNumber.compareTo(b.ayahNumber);
    });

    if (mounted) {
      setState(() {
        _bookmarkReferences = references;
        _bookmarkedAyahsData = ayahsData;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeBookmark(int surahNumber, int ayahNumber) async {
    await AppPreferences.removeBookmark(surahNumber, ayahNumber);
    await _loadBookmarks();
  }

  void _navigateToAyah(Ayah ayah) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (context) => SurahDetailScreen(
                  surah: allSurahs.firstWhere(
                    (s) => s.number == ayah.surahNumber,
                  ), // <<-- CHANGED: Using 'allSurahs'
                  initialAyahNumber: ayah.ayahNumber,
                ),
          ),
        )
        .then((_) {
          _loadBookmarks();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        title: Text('Bookmarks', style: AppTextStyles.appBarTitle),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              )
              : _bookmarkedAyahsData.isEmpty
              ? Center(
                child: Text(
                  'No bookmarks added yet. Tap the bookmark icon on an Ayah to add it!',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(AppDimens.paddingMedium),
                itemCount: _bookmarkedAyahsData.length,
                itemBuilder: (context, index) {
                  final ayah = _bookmarkedAyahsData[index];
                  final Surah surah = allSurahs.firstWhere(
                    // <<-- CHANGED: Using 'allSurahs'
                    (s) => s.number == ayah.surahNumber,
                    orElse:
                        () =>
                            throw Exception(
                              'Surah not found for Ayah: ${ayah.surahNumber}',
                            ),
                  );

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadiusMedium,
                      ),
                    ),
                    color: AppColors.white,
                    child: ListTile(
                      onTap: () => _navigateToAyah(ayah),
                      contentPadding: const EdgeInsets.all(
                        AppDimens.paddingMedium,
                      ),
                      title: Text(
                        '${ayah.surahNumber}. ${surah.englishName} : Ayah ${ayah.ayahNumber}',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.darkGrey,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(
                          top: AppDimens.paddingSmall,
                        ),
                        child: Text(
                          ayah.translationText,
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark),
                        color: AppColors.primaryOrange,
                        onPressed:
                            () => _removeBookmark(
                              ayah.surahNumber,
                              ayah.ayahNumber,
                            ),
                      ),
                    ),
                  );
                },
                separatorBuilder:
                    (context, index) =>
                        const SizedBox(height: AppDimens.paddingMedium),
              ),
    );
  }
}
