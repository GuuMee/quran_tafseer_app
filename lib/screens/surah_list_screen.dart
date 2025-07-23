// lib/screens/surah_list_screen.dart

import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/utils/app_constants.dart';
import 'package:quran_tafseer_app/services/app_preferences.dart';
import 'package:quran_tafseer_app/models/surah.dart';
import 'package:quran_tafseer_app/screens/surah_detail_screen.dart';
import 'package:quran_tafseer_app/data/surahs_data.dart'; // Import the allSurahs list

class SurahListScreen extends StatefulWidget {
  final int? initialSurahNumber;
  const SurahListScreen({super.key, this.initialSurahNumber});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  late ScrollController _scrollController;

  // NEW: Add a TextEditingController for the search bar
  final TextEditingController _searchController = TextEditingController();
  // NEW: A list to hold the currently displayed (filtered) surahs
  List<Surah> _filteredSurahs = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Initialize filteredSurahs with allSurahs at the start
    _filteredSurahs = List.from(allSurahs); // Use a copy of the list

    // NEW: Add a listener to the search controller
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSurahNumber != null &&
          widget.initialSurahNumber! > 0 &&
          widget.initialSurahNumber! <= allSurahs.length) {
        final int targetIndex = allSurahs.indexWhere(
          (s) => s.number == widget.initialSurahNumber,
        );

        if (targetIndex != -1) {
          final double itemHeight = 75.0;
          final double offset = targetIndex * itemHeight;

          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              offset,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    });
  }

  // NEW: Method to handle search input changes
  void _onSearchChanged() {
    _performSearch(_searchController.text);
  }

  // NEW: Method to perform the actual filtering
  void _performSearch(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSurahs = List.from(
          allSurahs,
        ); // If query is empty, show all surahs
      } else {
        _filteredSurahs =
            allSurahs.where((surah) {
              return surah.englishName.toLowerCase().contains(lowerCaseQuery) ||
                  surah.arabicName.toLowerCase().contains(lowerCaseQuery) ||
                  surah.englishNameTranslation.toLowerCase().contains(
                    lowerCaseQuery,
                  ) ||
                  surah.number.toString().contains(
                    lowerCaseQuery,
                  ); // Also allow searching by number
            }).toList();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // NEW: Dispose the search controller
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Surahs List', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primaryOrange,
        // NEW: Add the search bar to the bottom of the AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            kToolbarHeight,
          ), // Standard height for a toolbar
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingSmall,
              vertical: AppDimens.paddingExtraSmall,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Surah name or number...',
                hintStyle: AppTextStyles.bodyText.copyWith(
                  color: AppColors.mediumGrey,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.successGreen),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.mediumGrey),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch(
                              '',
                            ); // Clear search and show all surahs
                          },
                        )
                        : null,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimens.borderRadiusMedium,
                  ),
                  borderSide:
                      BorderSide.none, // No border around the text field
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical:
                      AppDimens.paddingExtraSmall, // Adjust vertical padding
                  horizontal: AppDimens.paddingSmall,
                ),
              ),
              style: AppTextStyles.bodyText.copyWith(color: AppColors.darkGrey),
              cursorColor: AppColors.primaryOrange, // Cursor color
              onSubmitted: (value) {
                // Optional: You can trigger a search when the user presses enter
                // For now, it filters as they type, so this isn't strictly necessary.
              },
            ),
          ),
        ),
      ),
      body:
          _filteredSurahs.isEmpty && _searchController.text.isNotEmpty
              ? Center(
                child: Text(
                  'No Surahs found for "${_searchController.text}"',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              )
              : ListView.separated(
                controller: _scrollController,
                itemCount: _filteredSurahs.length, // Use the filtered list here
                itemBuilder: (context, index) {
                  final surah =
                      _filteredSurahs[index]; // Use the filtered list here
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingSmall,
                      vertical: AppDimens.paddingExtraSmall,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadiusMedium,
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await AppPreferences.saveLastReadPosition(
                          surah.number,
                          1,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tapped ${surah.englishName} - Position saved!',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SurahDetailScreen(surah: surah),
                          ),
                        );
                        print(
                          'Navigating to Surah Detail for ${surah.englishName}',
                        );
                      },
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadiusMedium,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.paddingSmall),
                        child: Row(
                          children: [
                            // Surah Number Circle
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryOrange.withOpacity(0.1),
                                border: Border.all(
                                  color: AppColors.primaryOrange,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '${surah.number}',
                                  style: AppTextStyles.bodyText.copyWith(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppDimens.paddingMedium),
                            // Surah Names and Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    surah.englishName,
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkGrey,
                                    ),
                                  ),
                                  Text(
                                    surah.englishNameTranslation,
                                    style: AppTextStyles.captionText.copyWith(
                                      color: AppColors.mediumGrey,
                                    ),
                                  ),
                                  Text(
                                    surah.arabicName,
                                    style: AppTextStyles.arabicTextSmall
                                        .copyWith(
                                          color: AppColors.darkGrey,
                                          fontSize: 16,
                                        ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                            // Ayah Count and Revelation Type
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${surah.numberOfAyahs} Ayahs',
                                  style: AppTextStyles.captionText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      surah.revelationType == 'Meccan'
                                          ? Icons.location_city
                                          : Icons.mosque,
                                      size: 14,
                                      color: AppColors.mediumGrey,
                                    ),
                                    SizedBox(
                                      width: AppDimens.paddingExtraSmall,
                                    ),
                                    Text(
                                      surah.revelationType,
                                      style: AppTextStyles.captionText.copyWith(
                                        color: AppColors.mediumGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder:
                    (context, index) =>
                        const SizedBox(height: AppDimens.paddingSmall),
              ),
    );
  }
}
