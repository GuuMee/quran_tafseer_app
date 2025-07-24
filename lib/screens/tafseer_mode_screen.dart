// lib/screens/tafseer_mode_screen.dart

import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer

import 'package:quran_tafseer_app/models/surah.dart';
import 'package:quran_tafseer_app/models/ayah.dart';
import 'package:quran_tafseer_app/data/ayahs_data.dart'; // Assuming you have this to get Ayahs
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/utils/app_constants.dart';
import 'package:quran_tafseer_app/widgets/tafseer_text_widget.dart';
import 'package:quran_tafseer_app/services/app_preferences.dart'; // For bookmarks

class TafseerModeScreen extends StatefulWidget {
  final Surah surah; // Or List<Surah> if showing multiple for a Juz

  const TafseerModeScreen({
    super.key,
    required this.surah, // Adjust as needed for Juz 30
  });

  @override
  State<TafseerModeScreen> createState() => _TafseerModeScreenState();
}

class _TafseerModeScreenState extends State<TafseerModeScreen> {
  final TextEditingController _ayahSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Ayah> _allAyahs = [];
  List<Ayah> _filteredAyahs = [];
  Set<String> _bookmarkedAyahs = {}; // Bookmarks are still useful here
  Timer? _savePositionDebounce;

  @override
  void initState() {
    super.initState();

    // Fetch Ayahs for the provided surah (or multiple surahs for Juz 30)
    _allAyahs = getAyahsForSurah(
      widget.surah.number,
      widget.surah.numberOfAyahs,
    );
    _filteredAyahs = List.from(_allAyahs);

    _ayahSearchController.addListener(_onAyahSearchChanged);
    _loadBookmarks(); // Load bookmarks for this mode too
  }

  Future<void> _loadBookmarks() async {
    final bookmarks = await AppPreferences.getAllBookmarks();
    if (mounted) {
      setState(() {
        _bookmarkedAyahs =
            bookmarks
                .map((b) => '${b['surahNumber']}:${b['ayahNumber']}')
                .toSet();
      });
    }
  }

  void _onAyahSearchChanged() {
    _performAyahSearch(_ayahSearchController.text);
  }

  void _performAyahSearch(String query) {
    final lowerCaseQuery = query.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredAyahs = List.from(_allAyahs);
      } else {
        _filteredAyahs =
            _allAyahs.where((ayah) {
              return ayah.ayahNumber.toString().contains(lowerCaseQuery) ||
                  ayah.arabicText.toLowerCase().contains(lowerCaseQuery) ||
                  ayah.translationText.toLowerCase().contains(lowerCaseQuery) ||
                  (ayah.tafseerText != null &&
                      ayah.tafseerText!.toLowerCase().contains(lowerCaseQuery));
            }).toList();
      }
    });
  }

  Future<void> _toggleBookmarkStatus(Ayah ayah) async {
    final bookmarkId = '${ayah.surahNumber}:${ayah.ayahNumber}';
    if (_bookmarkedAyahs.contains(bookmarkId)) {
      await AppPreferences.removeBookmark(ayah.surahNumber, ayah.ayahNumber);
      if (mounted) {
        setState(() {
          _bookmarkedAyahs.remove(bookmarkId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bookmark removed from ${widget.surah.englishName}:${ayah.ayahNumber}',
            ),
          ),
        );
      }
    } else {
      await AppPreferences.addBookmark(ayah.surahNumber, ayah.ayahNumber);
      if (mounted) {
        setState(() {
          _bookmarkedAyahs.add(bookmarkId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bookmarked ${widget.surah.englishName}:${ayah.ayahNumber}',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _savePositionDebounce
        ?.cancel(); // If you implement scroll position saving here
    _ayahSearchController.removeListener(_onAyahSearchChanged);
    _ayahSearchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tafseer Mode: ${widget.surah.englishName}', // Indicate Tafseer Mode
              style: AppTextStyles.appBarTitle.copyWith(fontSize: 18),
            ),
            Text(
              '${widget.surah.arabicName} | ${widget.surah.englishNameTranslation} | ${widget.surah.numberOfAyahs} Ayahs',
              style: AppTextStyles.captionText.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          // No toggle here, Tafseer is always shown in this mode
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingSmall,
              vertical: AppDimens.paddingExtraSmall,
            ),
            child: TextField(
              controller: _ayahSearchController,
              decoration: InputDecoration(
                hintText: 'Search within Ayahs (text, translation, number)...',
                hintStyle: AppTextStyles.bodyText.copyWith(
                  color: AppColors.mediumGrey,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.mediumGrey,
                ),
                suffixIcon:
                    _ayahSearchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.mediumGrey,
                          ),
                          onPressed: () {
                            _ayahSearchController.clear();
                            _performAyahSearch('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimens.borderRadiusMedium,
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppDimens.paddingExtraSmall,
                  horizontal: AppDimens.paddingSmall,
                ),
              ),
              style: AppTextStyles.bodyText.copyWith(color: AppColors.darkGrey),
              cursorColor: AppColors.primaryOrange,
            ),
          ),
        ),
      ),
      body:
          _filteredAyahs.isEmpty && _ayahSearchController.text.isNotEmpty
              ? Center(
                child: Text(
                  'No Ayahs found for "${_ayahSearchController.text}" in this Surah.',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              )
              : ListView.separated(
                controller:
                    _scrollController, // You can add scroll saving here if desired
                padding: const EdgeInsets.all(AppDimens.paddingMedium),
                itemCount: _filteredAyahs.length,
                itemBuilder: (context, index) {
                  final ayah = _filteredAyahs[index];
                  final bool hasTafseer =
                      ayah.tafseerText != null && ayah.tafseerText!.isNotEmpty;

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadiusMedium,
                      ),
                    ),
                    color: AppColors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(
                            AppDimens.paddingMedium,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _bookmarkedAyahs.contains(
                                            '${ayah.surahNumber}:${ayah.ayahNumber}',
                                          )
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color:
                                          _bookmarkedAyahs.contains(
                                                '${ayah.surahNumber}:${ayah.ayahNumber}',
                                              )
                                              ? AppColors.primaryOrange
                                              : AppColors.mediumGrey,
                                    ),
                                    onPressed: () async {
                                      _toggleBookmarkStatus(ayah);
                                    },
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          AppDimens.paddingExtraSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.softGreen
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            AppDimens.borderRadiusSmall,
                                          ),
                                        ),
                                        child: Text(
                                          'Ayah ${ayah.ayahNumber}',
                                          style: AppTextStyles.captionText
                                              .copyWith(
                                                color: AppColors.successGreen,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppDimens.paddingSmall),
                              Text(
                                ayah.arabicText,
                                style: AppTextStyles.arabicAyahStyle.copyWith(
                                  fontSize: 22,
                                  color: AppColors.darkGrey,
                                ),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                              ),
                              SizedBox(height: AppDimens.paddingMedium),
                              Text(
                                ayah.translationText,
                                style: AppTextStyles.bodyText.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.mediumGrey,
                                ),
                                textAlign: TextAlign.left,
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),
                        // Tafseer is ALWAYS displayed here if available
                        if (hasTafseer)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.paddingMedium,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(
                                  height: AppDimens.paddingMedium * 2,
                                ),
                                Text(
                                  'Explanation (Tafseer):',
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                                SizedBox(height: AppDimens.paddingSmall),
                                TafseerTextWidget(
                                  text: ayah.tafseerText!,
                                  footnotes: ayah.footnotes,
                                ),
                              ],
                            ),
                          )
                        else // Show 'not available' message if no Tafseer
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.paddingMedium,
                            ).copyWith(top: AppDimens.paddingMedium),
                            child: Text(
                              'Explanation for this Ayah is not available yet.',
                              style: AppTextStyles.captionText.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ),
                        // Add padding at the bottom of the card if Tafseer is displayed,
                        // to ensure consistent spacing even when the Tafseer section is short or absent.
                        SizedBox(height: AppDimens.paddingMedium),
                      ],
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
