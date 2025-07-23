// lib/services/app_preferences.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // <<--- IMPORTANT: THIS NEW IMPORT IS CRUCIAL FOR JSON

class AppPreferences {
  static const String _lastReadSurahKey = 'lastReadSurah';
  static const String _lastReadAyahKey = 'lastReadAyah';
  static const String _isTafseerExpandedKey = 'isTafseerExpanded';
  static const String _dailyVerseDataKey = 'dailyVerseData';
  static const String _kBookmarksKey = 'bookmarks'; // NEW: Key for bookmarks

  // --- Last Read Position Methods ---

  static Future<void> saveLastReadPosition(
    int surahNumber,
    int ayahNumber, {
    bool isTafseerExpanded = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReadSurahKey, surahNumber);
    await prefs.setInt(_lastReadAyahKey, ayahNumber);
    await prefs.setBool(_isTafseerExpandedKey, isTafseerExpanded);
    print(
      'AppPreferences: Saved last read position Surah: $surahNumber, Ayah: $ayahNumber, Expanded: $isTafseerExpanded',
    );
  }

  static Future<Map<String, dynamic>?> getLastReadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final surahNumber = prefs.getInt(_lastReadSurahKey);
    final ayahNumber = prefs.getInt(_lastReadAyahKey);
    final isTafseerExpanded = prefs.getBool(_isTafseerExpandedKey);

    if (surahNumber != null && ayahNumber != null) {
      print(
        'AppPreferences: Loaded last read position Surah: $surahNumber, Ayah: $ayahNumber, Expanded: ${isTafseerExpanded ?? false}',
      );
      return {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'isTafseerExpanded': isTafseerExpanded ?? false,
      };
    }
    print('AppPreferences: No last read position found. Returning null.');
    return null;
  }

  // --- Daily Verse methods (NOW USING dart:convert) ---

  static Future<void> saveDailyVerse({
    required String date,
    required int surahNumber,
    required int ayahNumber,
    required String arabicText,
    required String translationText,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'date': date,
      'surah': surahNumber,
      'ayah': ayahNumber,
      'arabic': arabicText,
      'translation': translationText,
    };
    // Replaced manual _mapToJson with json.encode
    await prefs.setString(_dailyVerseDataKey, json.encode(data));
    print('AppPreferences: Saved daily verse for $date.');
  }

  static Future<Map<String, dynamic>> getDailyVerse() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_dailyVerseDataKey);
    if (jsonData != null) {
      // Replaced manual _jsonToMap with json.decode
      final Map<String, dynamic> data = json.decode(jsonData);
      print(
        'AppPreferences: Loaded daily verse: ${data['surah']}:${data['ayah']} on ${data['date']}',
      );
      return data;
    }
    print('AppPreferences: No daily verse data found.');
    return {};
  }

  // --- NEW: Bookmark Methods (NOW USING dart:convert) ---

  // Helper to get all current bookmarks
  static Future<List<Map<String, int>>> _getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? bookmarksJson = prefs.getStringList(_kBookmarksKey);

    if (bookmarksJson == null) {
      return [];
    }

    return bookmarksJson.map((jsonString) {
      return Map<String, int>.from(json.decode(jsonString));
    }).toList();
  }

  // Helper to save the list of bookmarks back to SharedPreferences
  static Future<void> _saveBookmarks(List<Map<String, int>> bookmarks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookmarksJson =
        bookmarks.map((bookmark) {
          return json.encode(bookmark);
        }).toList();
    await prefs.setStringList(_kBookmarksKey, bookmarksJson);
    print('AppPreferences: Bookmarks saved: ${bookmarks.length} items.');
  }

  // Add a bookmark for a specific Ayah
  static Future<void> addBookmark(int surahNumber, int ayahNumber) async {
    final bookmarks = await _getBookmarks();
    final newBookmark = {'surahNumber': surahNumber, 'ayahNumber': ayahNumber};

    // Check if the bookmark already exists to avoid duplicates
    bool exists = bookmarks.any(
      (bookmark) =>
          bookmark['surahNumber'] == surahNumber &&
          bookmark['ayahNumber'] == ayahNumber,
    );

    if (!exists) {
      bookmarks.add(newBookmark);
      await _saveBookmarks(bookmarks);
      print(
        'AppPreferences: Bookmark added for Surah: $surahNumber, Ayah: $ayahNumber',
      );
    } else {
      print(
        'AppPreferences: Bookmark already exists for Surah: $surahNumber, Ayah: $ayahNumber',
      );
    }
  }

  // Remove a bookmark for a specific Ayah
  static Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final bookmarks = await _getBookmarks();
    final initialLength = bookmarks.length;
    bookmarks.removeWhere(
      (bookmark) =>
          bookmark['surahNumber'] == surahNumber &&
          bookmark['ayahNumber'] == ayahNumber,
    );

    if (bookmarks.length < initialLength) {
      await _saveBookmarks(bookmarks);
      print(
        'AppPreferences: Bookmark removed for Surah: $surahNumber, Ayah: $ayahNumber',
      );
    } else {
      print(
        'AppPreferences: No bookmark found to remove for Surah: $surahNumber, Ayah: $ayahNumber',
      );
    }
  }

  // Check if a specific Ayah is bookmarked
  static Future<bool> isAyahBookmarked(int surahNumber, int ayahNumber) async {
    final bookmarks = await _getBookmarks();
    return bookmarks.any(
      (bookmark) =>
          bookmark['surahNumber'] == surahNumber &&
          bookmark['ayahNumber'] == ayahNumber,
    );
  }

  // Get all bookmarked Ayahs
  static Future<List<Map<String, int>>> getAllBookmarks() async {
    return await _getBookmarks();
  }

  // --- Utility for debugging/clearing (Optional, remove for production) ---
  static Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBookmarksKey);
    print('AppPreferences: All bookmarks cleared.');
  }
}
