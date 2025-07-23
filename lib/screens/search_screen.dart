// lib/screens/search_screen.dart

import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/utils/app_constants.dart';
import 'package:quran_tafseer_app/models/surah.dart'; // Import Surah model
import 'package:quran_tafseer_app/models/ayah.dart'; // Import Ayah model
import 'package:quran_tafseer_app/data/surahs_data.dart'; // Import allSurahs
import 'package:quran_tafseer_app/data/ayahs_data.dart'; // Import getAyahsForSurah
import 'package:quran_tafseer_app/screens/surah_detail_screen.dart'; // To navigate to Surah detail

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = []; // Custom class for search results
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Implement a debounce here for performance on large datasets
    // For now, let's keep it direct for simplicity
    _performSearch(_searchController.text);
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final List<SearchResult> results = [];
    final lowerCaseQuery = query.toLowerCase();

    // Iterate through all Surahs
    for (final surah in allSurahs) {
      // 1. Search Surah names
      if (surah.englishName.toLowerCase().contains(lowerCaseQuery) ||
          surah.arabicName.toLowerCase().contains(lowerCaseQuery) ||
          surah.englishNameTranslation.toLowerCase().contains(lowerCaseQuery) ||
          surah.number.toString().contains(lowerCaseQuery)) {
        results.add(
          SearchResult(
            type: SearchResultType.surahName,
            surahNumber: surah.number,
            surahName: surah.englishName,
            matchingText:
                'Matched in Surah name: "${surah.englishName}" or "${surah.arabicName}"',
            ayahNumber: null, // No specific ayah for surah name match
          ),
        );
      }

      // 2. Search within Ayahs of the current Surah
      final List<Ayah> ayahsInSurah = getAyahsForSurah(
        surah.number,
        surah.numberOfAyahs,
      );

      for (final ayah in ayahsInSurah) {
        String matchType = '';
        String matchingContent = '';
        bool foundMatch = false;

        // Search Arabic text
        if (ayah.arabicText.toLowerCase().contains(lowerCaseQuery)) {
          matchType = 'Arabic Text';
          matchingContent = ayah.arabicText;
          foundMatch = true;
        }
        // Search Translation text
        else if (ayah.translationText.toLowerCase().contains(lowerCaseQuery)) {
          matchType = 'Translation';
          matchingContent = ayah.translationText;
          foundMatch = true;
        }
        // Search Tafseer text
        else if (ayah.tafseerText != null &&
            ayah.tafseerText!.toLowerCase().contains(lowerCaseQuery)) {
          matchType = 'Tafseer';
          matchingContent = ayah.tafseerText!;
          foundMatch = true;
        }
        // Search Footnotes
        else if (ayah.footnotes != null) {
          ayah.footnotes!.forEach((key, value) {
            if (value.toLowerCase().contains(lowerCaseQuery)) {
              matchType = 'Footnote $key';
              matchingContent = value; // The content of the footnote
              foundMatch = true;
            }
          });
        }

        if (foundMatch) {
          results.add(
            SearchResult(
              type: SearchResultType.ayahContent,
              surahNumber: surah.number,
              surahName: surah.englishName,
              ayahNumber: ayah.ayahNumber,
              matchingText:
                  'Match in $matchType: "${_getSnippet(matchingContent, lowerCaseQuery)}"',
              // Pass the original ayah to navigate easily
              matchedAyah: ayah,
              matchedSurah: surah,
            ),
          );
        }
      }
    }

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  // Helper to get a snippet around the matched query
  String _getSnippet(String fullText, String query) {
    final int queryIndex = fullText.toLowerCase().indexOf(query);
    if (queryIndex == -1) return fullText; // Should not happen if match found

    final int start = (queryIndex - 30).clamp(0, fullText.length);
    final int end = (queryIndex + query.length + 30).clamp(0, fullText.length);

    String snippet = fullText.substring(start, end);
    if (start > 0) snippet = '...$snippet';
    if (end < fullText.length) snippet = '$snippet...';
    return snippet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryOrange,
        title: Text('Global Quran Search', style: AppTextStyles.appBarTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            60.0,
          ), // Height of the search bar
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search all Quran data...',
                hintStyle: AppTextStyles.bodyText.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
                filled: true,
                fillColor: AppColors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: AppColors.white),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.white),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch(''); // Clear results
                          },
                        )
                        : null,
              ),
              style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
              // onChanged: _onSearchChanged is handled by addListener
              textInputAction:
                  TextInputAction.search, // Show search button on keyboard
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              )
              : _searchResults.isEmpty && _searchController.text.isNotEmpty
              ? Center(
                child: Text(
                  'No results found for "${_searchController.text}"',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : _searchResults.isEmpty && _searchController.text.isEmpty
              ? Center(
                child: Text(
                  'Type to search the entire Quran for Surah names, Ayah text, translation, tafseer, or footnotes.',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.mediumGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(AppDimens.paddingMedium),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.symmetric(
                      vertical: AppDimens.paddingSmall,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimens.borderRadiusMedium,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(
                        AppDimens.paddingMedium,
                      ),
                      title: Text(
                        result.type == SearchResultType.surahName
                            ? 'Surah: ${result.surahName} (${result.surahNumber})'
                            : 'Surah: ${result.surahName} (${result.surahNumber}) - Ayah ${result.ayahNumber}',
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppDimens.paddingExtraSmall),
                          Text(
                            result.matchingText,
                            style: AppTextStyles.captionText.copyWith(
                              color: AppColors.darkGrey,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      onTap: () {
                        if (result.matchedSurah != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SurahDetailScreen(
                                    surah: result.matchedSurah!,
                                  ),
                            ),
                          );
                          // TODO: Potentially scroll to specific ayah in SurahDetailScreen
                          // This would require adding an initialAyahNumber parameter to SurahDetailScreen
                        }
                      },
                    ),
                  );
                },
              ),
    );
  }
}

// Helper Enum for Search Result Types
enum SearchResultType { surahName, ayahContent }

// Helper Class to encapsulate Search Results
class SearchResult {
  final SearchResultType type;
  final int surahNumber;
  final String surahName;
  final int? ayahNumber; // Null if it's a surah name match
  final String matchingText;
  final Ayah? matchedAyah; // Original Ayah object for navigation
  final Surah? matchedSurah; // Original Surah object for navigation

  SearchResult({
    required this.type,
    required this.surahNumber,
    required this.surahName,
    this.ayahNumber,
    required this.matchingText,
    this.matchedAyah,
    this.matchedSurah,
  });
}
