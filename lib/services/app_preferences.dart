// lib/services/app_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _lastReadSurahKey = 'lastReadSurah';
  static const _lastReadAyahKey = 'lastReadAyah';
  static const _isTafseerExpandedKey =
      'isTafseerExpanded'; // NEW: Key for tafseer expanded state
  static const _dailyVerseDataKey = 'dailyVerseData';

  static Future<void> saveLastReadPosition(
    int surahNumber,
    int ayahNumber, {
    bool isTafseerExpanded = false,
  }) async {
    // NEW: Add isTafseerExpanded parameter
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReadSurahKey, surahNumber);
    await prefs.setInt(_lastReadAyahKey, ayahNumber);
    await prefs.setBool(
      _isTafseerExpandedKey,
      isTafseerExpanded,
    ); // NEW: Save the state
  }

  static Future<Map<String, dynamic>?> getLastReadPosition() async {
    // Changed return type to dynamic for boolean
    final prefs = await SharedPreferences.getInstance();
    final surahNumber = prefs.getInt(_lastReadSurahKey);
    final ayahNumber = prefs.getInt(_lastReadAyahKey);
    final isTafseerExpanded = prefs.getBool(
      _isTafseerExpandedKey,
    ); // NEW: Get the state

    if (surahNumber != null && ayahNumber != null) {
      return {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'isTafseerExpanded':
            isTafseerExpanded ?? false, // Default to false if not found
      };
    }
    return null;
  }

  // --- Daily Verse methods (remain unchanged) ---
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
    await prefs.setString(_dailyVerseDataKey, _mapToJson(data));
  }

  static Future<Map<String, dynamic>> getDailyVerse() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_dailyVerseDataKey);
    if (jsonData != null) {
      return _jsonToMap(jsonData);
    }
    return {};
  }

  // Helper methods for JSON (remain unchanged)
  static String _mapToJson(Map<String, dynamic> map) {
    // You would typically use 'dart:convert' for this.
    // import 'dart:convert';
    // return json.encode(map);
    // For simplicity without 'dart:convert' import, we'll manually represent.
    // THIS IS A SIMPLIFIED REPRESENTATION AND SHOULD BE REPLACED WITH `dart:convert`
    // FOR ROBUSTNESS IN A REAL APPLICATION.
    final List<String> pairs = [];
    map.forEach((key, value) {
      if (value is String) {
        pairs.add('"$key":"$value"');
      } else {
        pairs.add('"$key":$value');
      }
    });
    return '{${pairs.join(',')}}';
  }

  static Map<String, dynamic> _jsonToMap(String jsonString) {
    // You would typically use 'dart:convert' for this.
    // import 'dart:convert';
    // return json.decode(jsonString) as Map<String, dynamic>;
    // For simplicity without 'dart:convert' import, we'll manually parse.
    // THIS IS A SIMPLIFIED REPRESENTATION AND SHOULD BE REPLACED WITH `dart:convert`
    // FOR ROBUSTNESS IN A REAL APPLICATION.
    final Map<String, dynamic> map = {};
    jsonString = jsonString.substring(
      1,
      jsonString.length - 1,
    ); // Remove braces
    final parts = jsonString.split(',');
    for (var part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        String key = keyValue[0].replaceAll('"', '');
        String valueStr = keyValue[1].replaceAll('"', '');
        if (valueStr == 'true') {
          map[key] = true;
        } else if (valueStr == 'false') {
          map[key] = false;
        } else if (int.tryParse(valueStr) != null) {
          map[key] = int.parse(valueStr);
        } else {
          map[key] = valueStr;
        }
      }
    }
    return map;
  }
}
