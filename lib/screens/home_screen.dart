// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/utils/app_constants.dart';
import 'package:quran_tafseer_app/services/app_preferences.dart';
import 'package:quran_tafseer_app/data/daily_ayahs_data.dart';
import 'package:quran_tafseer_app/data/surahs_data.dart';
import 'package:quran_tafseer_app/models/surah.dart';

// --- IMPORTS FOR NAVIGATION ---
import 'package:quran_tafseer_app/screens/surah_list_screen.dart';
import 'package:quran_tafseer_app/screens/search_screen.dart';
import 'package:quran_tafseer_app/screens/bookmarks_screen.dart';
import 'package:quran_tafseer_app/screens/recitation_screen.dart'; // Ensure this is imported
import 'package:quran_tafseer_app/screens/surah_detail_screen.dart';
import 'package:quran_tafseer_app/screens/tafseer_mode_screen.dart';
// --- END IMPORTS ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _lastReadPosition;
  int _selectedIndex = 0; // For BottomNavigationBar state

  @override
  void initState() {
    super.initState();
    _loadLastReadPosition(); // Load last read data when the screen initializes
  }

  // Method to load the last read position
  Future<void> _loadLastReadPosition() async {
    final position = await AppPreferences.getLastReadPosition();
    // Only update if the widget is still mounted
    if (mounted) {
      setState(() {
        _lastReadPosition = position;
      });
    }
  }

  // Method to navigate to the last read Surah and Ayah
  void _navigateToLastRead() {
    if (_lastReadPosition != null) {
      final surahNumber = _lastReadPosition!['surahNumber']!;
      final ayahNumber = _lastReadPosition!['ayahNumber']!;

      final surah = allSurahs.firstWhere(
        (s) => s.number == surahNumber,
        orElse: () => allSurahs[0], // Fallback to Al-Fatiha if not found
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SurahDetailScreen(
                surah: surah,
                initialAyahNumber: ayahNumber,
              ),
        ),
      ).then((_) {
        // After returning from SurahDetailScreen, reload the position.
        // This is already good for direct navigation.
        _loadLastReadPosition();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No last read position found.')),
      );
    }
  }

  // Helper method for bottom navigation to handle reload
  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on index
    if (index == 0) {
      // Home tab
      _loadLastReadPosition(); // Refresh when returning to home via nav bar
    } else if (index == 1) {
      // Quran tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SurahListScreen()),
      ).then((_) => _loadLastReadPosition()); // Reload when returning
    } else if (index == 2) {
      // Search tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SearchScreen()),
      );
      // Search screen might not save read position, so no reload needed here
    } else if (index == 3) {
      // Bookmarks tab
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookmarksScreen()),
      );
      // Bookmarks screen might not save read position, so no reload needed here
    } else if (index == 4) {
      // NEW: Handle the new 'Listen' tab (index 4)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecitationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        actions: [
          // Continue Reading Button
          if (_lastReadPosition != null)
            TextButton.icon(
              onPressed: _navigateToLastRead,
              icon: const Icon(Icons.menu_book, color: AppColors.white),
              label: Text(
                'Continue (${_lastReadPosition!['surahNumber']}:${_lastReadPosition!['ayahNumber']})',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Navigate to profile screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DailyVerseCard(),
            SizedBox(height: AppDimens.paddingLarge),
            Text('Your Progress', style: AppTextStyles.heading2),
            SizedBox(height: AppDimens.paddingMedium),
            _buildProgressSection(context),
            SizedBox(height: AppDimens.paddingLarge),
            Text('Quick Actions', style: AppTextStyles.heading2),
            SizedBox(height: AppDimens.paddingMedium),
            _buildQuickActionsGrid(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    // ... (unchanged) ...
    final int currentJuzRead = 5;
    final int totalJuz = 30;
    final double readingProgress = currentJuzRead / totalJuz;

    final int currentSurahsListened = 10;
    final int totalSurahs = 114;
    final double listeningProgress = currentSurahsListened / totalSurahs;

    final int currentTafseerLessons = 7;
    final int totalTafseerLessons = 37;
    final double tafseerProgress = currentTafseerLessons / totalTafseerLessons;

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(
              (255 * 0.1).round(),
              AppColors.black.red,
              AppColors.black.green,
              AppColors.black.blue,
            ),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressItem(
            context,
            'Reading',
            currentJuzRead,
            totalJuz,
            'Juz',
            readingProgress,
            AppColors.primaryOrange,
          ),
          _buildProgressItem(
            context,
            'Listening',
            currentSurahsListened,
            totalSurahs,
            'Surahs',
            listeningProgress,
            AppColors.successGreen,
          ),
          _buildProgressItem(
            context,
            'Tafseer',
            currentTafseerLessons,
            totalTafseerLessons,
            'Surahs',
            tafseerProgress,
            AppColors.royalBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final Surah surahAlFatiha = allSurahs.firstWhere(
      (s) => s.number == 1,
      orElse: () {
        debugPrint(
          "Warning: Surah Al-Fatiha (number 1) not found in allSurahs list!",
        );
        return allSurahs[0]; // Fallback to the very first surah
      },
    );
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppDimens.paddingMedium,
      crossAxisSpacing: AppDimens.paddingMedium,
      childAspectRatio: 1.8,
      children: [
        _buildQuickActionButton(
          context,
          Icons.menu_book,
          'Browse Surahs',
          AppColors.primaryOrange,
          () {
            // NEW: Add .then() to reload last read position when returning from SurahListScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SurahListScreen()),
            ).then((_) {
              _loadLastReadPosition(); // Reload the last read position
            });
          },
        ),
        _buildQuickActionButton(
          context,
          Icons.search,
          'Search Quran',
          AppColors.royalBlue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          ),
        ),
        _buildQuickActionButton(
          context,
          Icons.book_rounded,
          'Juz 30 Tafseer',
          AppColors.goldenrod,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TafseerModeScreen(surah: surahAlFatiha),
            ),
          ),
        ),
        _buildQuickActionButton(
          context,
          Icons.headphones,
          'Listen Recitation',
          AppColors.successGreen,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecitationScreen()),
          ),
        ),
        _buildQuickActionButton(
          context,
          Icons.bookmark_border,
          'My Bookmarks',
          AppColors.electricViolet,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookmarksScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTapCallback,
  ) {
    return InkWell(
      onTap: onTapCallback,
      borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
        ),
        color: AppColors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: AppDimens.iconSizeLarge, color: color),
              SizedBox(height: AppDimens.paddingSmall),
              Text(
                label,
                style: AppTextStyles.bodyText.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryOrange,
      unselectedItemColor: AppColors.darkGrey,
      selectedLabelStyle: AppTextStyles.captionText.copyWith(
        color: AppColors.primaryOrange,
      ),
      unselectedLabelStyle: AppTextStyles.captionText.copyWith(
        color: AppColors.darkGrey,
      ),
      currentIndex: _selectedIndex, // Use the state variable
      onTap: _onBottomNavItemTapped, // Call our new method
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          label: 'Quran',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_outline),
          label: 'Bookmarks',
        ),
        // MODIFIED: Changed Settings to Listen
        BottomNavigationBarItem(
          icon: Icon(Icons.headphones_outlined), // Changed icon
          label: 'Listen', // Changed label
        ),
      ],
    );
  }
}

// --- DailyVerseCard and _buildProgressItem remain the same as you provided ---
class DailyVerseCard extends StatefulWidget {
  // ... (unchanged) ...
  const DailyVerseCard({super.key});

  @override
  State<DailyVerseCard> createState() => _DailyVerseCardState();
}

class _DailyVerseCardState extends State<DailyVerseCard> {
  DailyAyahModel? _currentDailyAyah;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyVerse();
  }

  Future<void> _loadDailyVerse() async {
    setState(() {
      _isLoading = true;
    });

    final today = DateTime.now();
    final formattedToday =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final savedVerseData = await AppPreferences.getDailyVerse();
    final savedDate = savedVerseData['date'] as String?;

    if (savedDate == formattedToday && savedVerseData['arabic'] != null) {
      _currentDailyAyah = DailyAyahModel(
        surahNumber: savedVerseData['surah'] as int,
        ayahNumber: savedVerseData['ayah'] as int,
        arabicText: savedVerseData['arabic'] as String,
        translationText: savedVerseData['translation'] as String,
      );
    } else {
      final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
      final verseIndex = dayOfYear % kDailyAyahs.length;

      _currentDailyAyah = kDailyAyahs[verseIndex];

      await AppPreferences.saveDailyVerse(
        date: formattedToday,
        surahNumber: _currentDailyAyah!.surahNumber,
        ayahNumber: _currentDailyAyah!.ayahNumber,
        arabicText: _currentDailyAyah!.arabicText,
        translationText: _currentDailyAyah!.translationText,
      );
    }

    // Only update if the widget is still mounted
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: AppColors.primaryOrange),
      );
    }

    if (_currentDailyAyah == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(
          'Failed to load daily verse.',
          style: AppTextStyles.bodyText,
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(AppDimens.paddingMedium),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.borderRadiusLarge),
      ),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Verse',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.mediumGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimens.paddingMedium),
            Text(
              _currentDailyAyah!.arabicText,
              style: AppTextStyles.arabicAyahStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: AppDimens.paddingSmall),
            Text(
              _currentDailyAyah!.translationText,
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.darkGrey.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: AppDimens.paddingMedium),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '— Surah ${_currentDailyAyah!.surahNumber}, Ayah ${_currentDailyAyah!.ayahNumber}',
                style: AppTextStyles.captionText.copyWith(
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _buildProgressItem remains unchanged
Widget _buildProgressItem(
  BuildContext context,
  String title,
  int count,
  int total,
  String unit,
  double progress,
  Color progressColor,
) {
  final Color backgroundColor = Color.fromARGB(
    (255 * 0.3).round(),
    AppColors.mediumGrey.red,
    AppColors.mediumGrey.green,
    AppColors.mediumGrey.blue,
  );

  return Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppDimens.paddingSmall),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '/ $total $unit',
              style: AppTextStyles.bodyText.copyWith(
                color: AppColors.darkGrey,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        SizedBox(height: AppDimens.paddingSmall),
        SizedBox(
          width: 80,
          child: LinearProgressIndicator(
            value: progress,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            backgroundColor: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimens.borderRadiusSmall),
          ),
        ),
      ],
    ),
  );
}
