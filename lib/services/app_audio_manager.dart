// lib/services/app_audio_manager.dart

import 'dart:io';
import 'package:quran_tafseer_app/services/central_audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart'; // You need to import this for AudioPlayer
import 'package:quran_tafseer_app/main.dart'
    as main_file; // To access globalAudioHandler
import 'package:quran_tafseer_app/models/surah.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class AppAudioManager {
  static final AppAudioManager _instance = AppAudioManager._internal();
  factory AppAudioManager() => _instance;

  // Add this getter
  //bool get isInitialized => main.globalAudioHandler != null;

  AppAudioManager._internal() {
    _init(); // Initialize the local path on creation
    print("✅ AppAudioManager initialized");
  }

  // Use a nullable getter to safely retrieve the handler
  CentralAudioHandler? get audioHandler => main_file.globalAudioHandler;

  // --- New Caching Logic ---
  late String _localPath;
  final Dio _dio = Dio();
  final String _audioBaseUrl = 'https://everyayah.com/data/Menshawi_16kbps/';

  // Get local path for storing audio files
  Future<void> _init() async {
    final directory = await getApplicationDocumentsDirectory();
    _localPath = directory.path;
    print('📂 Local audio path: $_localPath');
  }

  String _getAudioFileName(int surahNumber, int ayahNumber) {
    final surahStr = surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayahNumber.toString().padLeft(3, '0');
    return '$surahStr$ayahStr.mp3';
  }

  String _getFilePath(int surahNumber, int ayahNumber) {
    final fileName = _getAudioFileName(surahNumber, ayahNumber);
    return '$_localPath/$fileName';
  }

  Future<bool> _isCached(int surahNumber, int ayahNumber) async {
    final file = File(_getFilePath(surahNumber, ayahNumber));
    return await file.exists();
  }

  Future<void> _downloadAyah(int surahNumber, int ayahNumber) async {
    final fileName = _getAudioFileName(surahNumber, ayahNumber);
    final filePath = _getFilePath(surahNumber, ayahNumber);
    final url = '$_audioBaseUrl$fileName';

    try {
      print('⏳ Downloading from $url...');
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            print('  Progress: ${progress.toStringAsFixed(0)}%');
            // You could use a Stream to notify the UI of the download progress here
          }
        },
      );
      print('✅ Download complete! File saved to $filePath');
    } catch (e) {
      print('❌ Download error: $e');
      rethrow;
    }
  }

  // --- Audio Playback Methods (Corrected) ---

  // Since audioHandler is now nullable, all methods need null checks.
  // The RecitationScreen should handle null safety for this getter.
  // This getter can be simplified since the check is handled in the UI.
  AudioPlayer? get audioPlayer => audioHandler?.player;

  // The `getAudioUrl` method now returns the local file path if cached.
  String getAudioUrl(int surahNumber, int ayahNumber) {
    final fileName = _getAudioFileName(surahNumber, ayahNumber);
    return '$_audioBaseUrl$fileName';
  }

  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required String surahEnglishName,
  }) async {
    final url = getAudioUrl(surahNumber, ayahNumber);
    final filePath = _getFilePath(surahNumber, ayahNumber);

    // Check if file is already cached
    final isCached = await _isCached(surahNumber, ayahNumber);

    Uri audioUri;
    if (isCached) {
      print('🎧 Playing from local cache: $filePath');
      audioUri = Uri.file(filePath); // Use file:// URI for local files
    } else {
      print('🌐 Streaming from network: $url');
      audioUri = Uri.parse(url); // Use https:// URI for network files
    }

    // The id, title, and artist fields in MediaItem must not be null
    final mediaItem = MediaItem(
      id: isCached ? filePath : url, // Use file path as ID if cached
      album: 'Quran Recitation',
      title: '$surahEnglishName Ayah $ayahNumber',
      artist: ' Muhammad Siddiq Al-Minshawi',
    );

    // This is the core logic change:
    // We update the audio source based on whether the file is local or remote.
    // The playFromUri method can handle both types of URIs.
    await audioHandler!.playFromUri(audioUri, {'mediaItem': mediaItem});
  }

  Future<void> stop() async {
    await audioHandler?.stop();
  }

  Future<void> pause() async {
    await audioHandler?.pause();
  }

  Future<void> resume() async {
    await audioHandler?.play();
  }

  // Inside AppAudioManager class
  Future<void> downloadSurah(Surah surah) async {
    print('Starting download for Surah ${surah.englishName}...');
    for (int i = 1; i <= surah.numberOfAyahs; i++) {
      final isCached = await _isCached(surah.number, i);
      if (!isCached) {
        try {
          await _downloadAyah(surah.number, i);
        } catch (e) {
          print('Failed to download Ayah $i: $e');
          // Handle error gracefully, maybe show a toast message
        }
      } else {
        print('Ayah $i of ${surah.englishName} is already cached. Skipping.');
      }
    }
    print('✅ Download for Surah ${surah.englishName} complete.');
  }
}
