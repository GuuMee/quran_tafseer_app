// lib/screens/surah_detail_screen.dart

import 'package:flutter/material.dart';

import 'package:quran_tafseer_app/models/surah.dart';

import 'package:quran_tafseer_app/models/ayah.dart';

import 'package:quran_tafseer_app/data/ayahs_data.dart';

import 'package:quran_tafseer_app/utils/app_colors.dart';

import 'package:quran_tafseer_app/utils/app_text_styles.dart';

import 'package:quran_tafseer_app/utils/app_constants.dart';

import 'package:quran_tafseer_app/widgets/tafseer_text_widget.dart';

import 'package:quran_tafseer_app/services/app_preferences.dart'; // Import AppPreferences

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;

  // Optional: Add initialAyahNumber to jump to a specific ayah if provided

  final int? initialAyahNumber;

  const SurahDetailScreen({
    super.key,

    required this.surah,
    this.initialAyahNumber, // Add this parameter
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final TextEditingController _ayahSearchController = TextEditingController();

  final ScrollController _scrollController =
      ScrollController(); // NEW: ScrollController

  List<Ayah> _allAyahs = [];

  List<Ayah> _filteredAyahs = [];

  @override
  void initState() {
    super.initState();

    _allAyahs = getAyahsForSurah(
      widget.surah.number,

      widget.surah.numberOfAyahs,
    );

    _filteredAyahs = List.from(_allAyahs);

    _ayahSearchController.addListener(_onAyahSearchChanged);

    // NEW: Scroll to initial Ayah if provided (e.g., from "Continue Reading")
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialAyahNumber != null &&
          widget.initialAyahNumber! > 0 &&
          widget.initialAyahNumber! <= _allAyahs.length) {
        final int targetIndex = _allAyahs.indexWhere(
          (ayah) => ayah.ayahNumber == widget.initialAyahNumber,
        );

        if (targetIndex != -1) {
          // Calculate offset. Assuming each Ayah takes roughly 150-200 logical pixels.

          // This might need fine-tuning based on your actual Ayah card height.

          // A more accurate way is to use GlobalKey for each item and get its renderbox height.

          // For now, let's estimate or scroll to the index directly if ListView.builder is used

          // and items have uniform height. With Card/ExpansionTile, it's variable.

          // Let's use `jumpTo` for immediate scroll or `animateTo` for smooth scroll.

          // Using `animateTo` with a calculated offset (rough estimate):

          final double estimatedItemHeight =
              200.0; // Adjust this based on your average Ayah card height

          final double offset = targetIndex * estimatedItemHeight;

          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              offset,

              duration: const Duration(milliseconds: 700),

              curve: Curves.easeOut,
            );
          }
        }
      }
    });
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

  @override
  void dispose() {
    print('### SurahDetailScreen: dispose() method called ###');
    print(
      'Dispose Check: _scrollController.hasClients = ${_scrollController.hasClients}',
    );
    print(
      'Dispose Check: _filteredAyahs.isNotEmpty = ${_filteredAyahs.isNotEmpty}',
    );

    int surahNumberToSave = widget.surah.number;
    int ayahNumberToSave =
        1; // Default to Ayah 1 if scroll position cannot be determined

    if (_scrollController.hasClients && _filteredAyahs.isNotEmpty) {
      // Only proceed with scroll calculation if controller has clients and list is not empty
      final double firstVisibleOffset = _scrollController.offset;
      double estimatedItemHeight =
          200.0; // Adjust this based on your average Ayah card height

      if (_scrollController.position.maxScrollExtent > 0 &&
          _filteredAyahs.length > 0) {
        estimatedItemHeight =
            _scrollController.position.maxScrollExtent / _filteredAyahs.length;
        if (estimatedItemHeight < 100.0) {
          estimatedItemHeight =
              100.0; // Sanity check for very small estimated heights
        }
      }

      int firstVisibleIndex =
          (firstVisibleOffset / estimatedItemHeight).floor();

      // Ensure index is within bounds
      if (firstVisibleIndex < 0) firstVisibleIndex = 0;
      if (firstVisibleIndex >= _filteredAyahs.length) {
        firstVisibleIndex = _filteredAyahs.length - 1;
      }

      // Now, assign the calculated ayah number to ayahNumberToSave
      ayahNumberToSave = _filteredAyahs[firstVisibleIndex].ayahNumber;

      print('--- SurahDetailScreen Dispose Debug (Calculated) ---');
      print('Current Scroll Offset: $firstVisibleOffset');
      print('Dynamic Estimated Item Height: $estimatedItemHeight');
      print('Calculated First Visible Index: $firstVisibleIndex');
      print(
        'Saving Last Read (Calculated): Surah $surahNumberToSave, Ayah $ayahNumberToSave',
      );
      print('-------------------------------------');
    } else {
      // This block will execute if _scrollController.hasClients is false
      // or if _filteredAyahs is unexpectedly empty.
      print(
        '--- SurahDetailScreen Dispose Debug (Fallback - No Scroll Client or Empty Ayahs) ---',
      );
      print(
        'Scroll controller has no clients or Ayah list is empty. Saving Surah $surahNumberToSave, Ayah $ayahNumberToSave (default).',
      );
      print('-------------------------------------');
    }

    // Save the determined position
    AppPreferences.saveLastReadPosition(surahNumberToSave, ayahNumberToSave);

    _ayahSearchController.removeListener(_onAyahSearchChanged);
    _ayahSearchController.dispose();
    _scrollController.dispose(); // Always dispose the controller
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
              '${widget.surah.number}. ${widget.surah.englishName}',

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
                controller: _scrollController, // Attach the scroll controller

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

                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.all(
                        AppDimens.paddingMedium,
                      ),

                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Ayah Number
                          Align(
                            alignment: Alignment.topRight,

                            child: Container(
                              padding: const EdgeInsets.all(
                                AppDimens.paddingExtraSmall,
                              ),

                              decoration: BoxDecoration(
                                color: AppColors.softGreen.withOpacity(0.2),

                                borderRadius: BorderRadius.circular(
                                  AppDimens.borderRadiusSmall,
                                ),
                              ),

                              child: Text(
                                'Ayah ${ayah.ayahNumber}',

                                style: AppTextStyles.captionText.copyWith(
                                  color: AppColors.successGreen,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: AppDimens.paddingSmall),

                          // Arabic Ayah Text
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

                          // Translation Text
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

                      childrenPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingMedium,
                      ).copyWith(bottom: AppDimens.paddingMedium),

                      children: [
                        if (hasTafseer)
                          Column(
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
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.all(
                              AppDimens.paddingSmall,
                            ),

                            child: Text(
                              'Explanation for this Ayah is not available yet.',

                              style: AppTextStyles.captionText.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                            ),
                          ),
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
