import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class CentralAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player; // <-- add this getter here

  CentralAudioHandler() {
    _notifyAudioHandlerAboutPlaybackEvents();
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(
        PlaybackState(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState:
              const {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: null,
        ),
      );
    });
  }

  @override
  Future<void> playFromUri(Uri uri, [Map<String, dynamic>? extras]) async {
    final mediaItem = extras?['mediaItem'] as MediaItem?;
    if (mediaItem != null) {
      await updateMediaItem(mediaItem); // ✅ Show in notification
      await _player.setAudioSource(AudioSource.uri(uri, tag: mediaItem));
      await _player.play();
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  AudioPlayer get audioPlayer => _player;

  // Expose position stream from AudioPlayer
  Stream<Duration> get positionStream => _player.positionStream;

  // Expose duration stream from AudioPlayer
  Stream<Duration?> get durationStream => _player.durationStream;

  // Expose player state stream from AudioPlayer
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // Expose playback event stream from AudioPlayer
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;
}
