import 'package:quran_tafseer_app/services/central_audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart'; // You need to import this for AudioPlayer
import 'package:quran_tafseer_app/main.dart'; // To access globalAudioHandler

class AppAudioManager {
  static final AppAudioManager _instance = AppAudioManager._internal();
  factory AppAudioManager() => _instance;

  AppAudioManager._internal() {
    print("✅ AppAudioManager initialized");
  }

  CentralAudioHandler get audioHandler => globalAudioHandler;
  AudioPlayer get audioPlayer => globalAudioHandler.player; // now safe

  String getAudioUrl(int surahNumber, int ayahNumber) {
    return 'https://everyayah.com/data/Menshawi_16kbps/${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3';
  }

  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required String surahEnglishName,
  }) async {
    final url =
        'https://everyayah.com/data/Menshawi_16kbps/${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3';

    final mediaItem = MediaItem(
      id: url,
      album: 'Quran Recitation',
      title: '$surahEnglishName Ayah $ayahNumber',
      artist: 'Minshawi (EveryAyah)',
    );

    await globalAudioHandler.playFromUri(Uri.parse(url), {
      'mediaItem': mediaItem,
    });
  }

  Future<void> stop() => globalAudioHandler.stop();
  Future<void> pause() => globalAudioHandler.pause();
  Future<void> resume() => globalAudioHandler.play();
}
