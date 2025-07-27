// lib/screens/recitation_screen.dart

import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/data/surahs_data.dart'; // Import Surah data
import 'package:quran_tafseer_app/models/surah.dart'; // Import Surah model
import 'package:quran_tafseer_app/data/ayahs_data.dart'; // Import Ayah data
import 'package:quran_tafseer_app/models/ayah.dart'; // Import Ayah model
import 'package:audioplayers/audioplayers.dart'; // Import audio player

// Convert to StatefulWidget to manage playback state
class RecitationScreen extends StatefulWidget {
  const RecitationScreen({super.key});

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  // Audio player instance
  late AudioPlayer _audioPlayer;

  // Reciter: Muhammad Siddiq Al-Minshawi
  // Source: https://everyayah.com/data/Menshawi_16kbps/
  static const String _audioBaseUrl =
      'https://everyayah.com/data/Menshawi_16kbps/';

  // State for playback
  int? _currentPlayingSurahIndex; // Index in `allSurahs`
  int? _currentPlayingAyahNumber; // Ayah number within the current Surah
  PlayerState _playerState = PlayerState.stopped;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // List of all surahs
  final List<Surah> _allSurahs = allSurahs;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
        print('Player State Changed: $state'); // Debug print
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
        print('Duration Changed: $_totalDuration'); // Debug print
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentDuration = position;
        });
        // print('Position Changed: $_currentDuration / $_totalDuration'); // Too verbose, uncomment if needed
      }
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      print('Player Completed event received.'); // Debug print
      // Only proceed to next Ayah if the player actually finished playing (not just stopped or errored out quickly)
      // Sometimes onPlayerComplete fires on error or immediate stop if source is bad
      // Removed the _playerState == PlayerState.completed check.
      // We now trust onPlayerComplete to mean "finished this audio segment".
      _playNextAyah();
    });
  }

  // Helper to get audio URL for a specific Ayah from a Surah
  String _getAudioUrl(int surahNumber, int ayahNumber) {
    // EveryAyah.com format: base_url/SSSAAAY.mp3 (SSS=Surah padded, AAA=Ayah padded)
    String surahPadded = surahNumber.toString().padLeft(3, '0');
    String ayahPadded = ayahNumber.toString().padLeft(3, '0');
    return '$_audioBaseUrl$surahPadded$ayahPadded.mp3';
  }

  // --- Playback Controls ---

  // Play a full Surah
  Future<void> _playSurah(int surahIndex) async {
    // Stop any existing playback
    await _audioPlayer.stop();

    setState(() {
      _currentPlayingSurahIndex = surahIndex;
      _currentPlayingAyahNumber = 1; // Start from the first Ayah
      _playerState = PlayerState.stopped; // Reset state before playing
      _currentDuration = Duration.zero;
      _totalDuration = Duration.zero;
    });

    // Start playing from the first Ayah of the selected Surah
    await _playAyahInSequence(); // Wait for the first ayah to attempt playing
  }

  // Play a single Ayah in sequence (for full Surah playback)
  Future<void> _playAyahInSequence() async {
    if (_currentPlayingSurahIndex == null) return;

    final Surah currentSurah = _allSurahs[_currentPlayingSurahIndex!];
    final int currentAyahNum = _currentPlayingAyahNumber!;

    if (currentAyahNum <= currentSurah.numberOfAyahs) {
      final String audioUrl = _getAudioUrl(currentSurah.number, currentAyahNum);
      print('Attempting to play: $audioUrl'); // Debug print
      try {
        await _audioPlayer.play(UrlSource(audioUrl));
        // After successfully calling play, the player state should change to playing
        // but we rely on the listener to update _playerState
      } catch (e) {
        print(
          'Error calling play for Ayah $currentAyahNum of Surah ${currentSurah.number}: $e',
        );
        // Do not immediately call _playNextAyah here, let onError listener handle it
      }
    } else {
      // End of Surah, move to next Surah (This will be controlled by auto-play setting later)
      _playNextSurah();
    }
  }

  // Play the next Ayah in the current Surah or move to next Surah
  void _playNextAyah() {
    if (_currentPlayingSurahIndex == null) return;

    final Surah currentSurah = _allSurahs[_currentPlayingSurahIndex!];
    final int nextAyahNum = (_currentPlayingAyahNumber ?? 0) + 1;

    if (nextAyahNum <= currentSurah.numberOfAyahs) {
      setState(() {
        _currentPlayingAyahNumber = nextAyahNum;
      });
      _playAyahInSequence();
    } else {
      // If last Ayah of current Surah, try to play next Surah
      _playNextSurah();
    }
  }

  // Play the previous Ayah in the current Surah or move to previous Surah
  void _playPreviousAyah() {
    if (_currentPlayingSurahIndex == null) return;

    final int prevAyahNum = (_currentPlayingAyahNumber ?? 1) - 1;

    if (prevAyahNum >= 1) {
      setState(() {
        _currentPlayingAyahNumber = prevAyahNum;
      });
      _playAyahInSequence();
    } else {
      // If first Ayah of current Surah, try to play previous Surah
      _playPreviousSurah();
    }
  }

  // Play the next Surah in the list
  void _playNextSurah() {
    // This method will be modified later for auto-play and repeat
    if (_currentPlayingSurahIndex == null) {
      _playSurah(0); // If nothing is playing, start from the first surah
      return;
    }

    final int nextSurahIndex = _currentPlayingSurahIndex! + 1;
    if (nextSurahIndex < _allSurahs.length) {
      _playSurah(nextSurahIndex);
    } else {
      // End of playlist
      _stopAudio(); // Stop explicitly when playlist ends
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Playlist completed.')));
    }
  }

  // Play the previous Surah in the list
  void _playPreviousSurah() {
    if (_currentPlayingSurahIndex == null) return;

    final int prevSurahIndex = _currentPlayingSurahIndex! - 1;
    if (prevSurahIndex >= 0) {
      _playSurah(prevSurahIndex);
    } else {
      // Already at the beginning of the playlist
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already at the beginning of the playlist.'),
        ),
      );
    }
  }

  Future<void> _togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else if (_playerState == PlayerState.paused) {
      await _audioPlayer.resume();
    } else {
      // If stopped or completed, start from the current or first surah
      if (_currentPlayingSurahIndex == null) {
        _playSurah(0); // Start from the first surah if nothing is selected
      } else {
        // If there was a current ayah, try to play it again
        await _playAyahInSequence();
      }
    }
  }

  // NEW: Dedicated Stop Function
  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _currentPlayingSurahIndex = null;
        _currentPlayingAyahNumber = null;
        _playerState = PlayerState.stopped;
        _currentDuration = Duration.zero;
        _totalDuration = Duration.zero;
      });
      print('Audio Stopped and state reset.');
    }
  }

  // Formatting duration for display
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _audioPlayer.stop(); // Stop audio when screen is disposed
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get bottom padding from safe area to prevent overlap
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text('Listen Recitation', style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
      ),
      body: Column(
        children: [
          // List of Surahs for selection
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _allSurahs.length,
              itemBuilder: (context, index) {
                final surah = _allSurahs[index];
                final bool isSelected = _currentPlayingSurahIndex == index;

                return Card(
                  elevation: isSelected ? 4 : 1,
                  color: isSelected ? AppColors.lemonChiffon : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side:
                        isSelected
                            ? BorderSide(
                              color: AppColors.primaryOrange,
                              width: 1.5,
                            )
                            : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.electricLimeGreen,
                      child: Text(
                        '${surah.number}',
                        style: AppTextStyles.captionText.copyWith(
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${surah.englishName} (${surah.arabicName})',
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${surah.englishNameTranslation} | ${surah.numberOfAyahs} Ayahs',
                      style: AppTextStyles.captionText.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.headphones,
                              color: AppColors.primaryOrange,
                            )
                            : Icon(
                              Icons.play_arrow,
                              color: AppColors.primaryOrange,
                            ),
                    onTap: () => _playSurah(index),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 8.0),
            ),
          ),
          // Player Controls at the bottom
          // NEW: Added Padding for UI overlap fix
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: _buildPlayerControls(),
          ),
        ],
      ),
    );
  }

  // Player Control Widget
  Widget _buildPlayerControls() {
    final Surah? currentSurah =
        _currentPlayingSurahIndex != null
            ? _allSurahs[_currentPlayingSurahIndex!]
            : null;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white, // Darker background for controls
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current playing info
          Text(
            currentSurah != null
                ? 'Now Playing: ${currentSurah.englishName} Ayah ${_currentPlayingAyahNumber ?? 1}'
                : 'Select a Surah to play',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          // Progress bar (simple for now, Ayah specific progress is complex)
          LinearProgressIndicator(
            value:
                _totalDuration.inMilliseconds > 0 &&
                        _currentDuration.inMilliseconds <=
                            _totalDuration.inMilliseconds
                    ? _currentDuration.inMilliseconds /
                        _totalDuration.inMilliseconds
                    : 0,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.successGreen),
            backgroundColor: AppColors.mediumGrey.withOpacity(0.4),
          ),
          SizedBox(height: 8.0),
          // Durations
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_currentDuration),
                style: AppTextStyles.captionText.copyWith(
                  color: AppColors.black.withOpacity(0.7),
                ),
              ),
              Text(
                _formatDuration(_totalDuration),
                style: AppTextStyles.captionText.copyWith(
                  color: AppColors.black.withOpacity(0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          // Playback buttons (Rewind/Forward Ayah added)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                    size: 32,
                    color: AppColors.darkGrey,
                  ),
                  onPressed: _playPreviousSurah,
                  tooltip: 'Previous Surah',
                ),
              ),
              // NEW: Previous Ayah button
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.replay_10,
                    size: 32,
                    color: AppColors.softDarkGray,
                  ), // Or Icons.fast_rewind
                  onPressed: _playPreviousAyah,
                  tooltip: 'Previous Ayah',
                ),
              ),
              Expanded(
                child: IconButton(
                  // NEW: Stop button
                  icon: Icon(
                    Icons.stop_circle,
                    size: 48,
                    color: AppColors.primaryOrange,
                  ), // Distinct color for stop
                  onPressed: _stopAudio,
                  tooltip: 'Stop Playback',
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(
                    _playerState == PlayerState.playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 56,
                    color: AppColors.primaryOrange,
                  ),
                  onPressed: _togglePlayPause,
                  tooltip:
                      _playerState == PlayerState.playing ? 'Pause' : 'Play',
                ),
              ),
              // NEW: Next Ayah button
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.forward_10,
                    size: 32,
                    color: AppColors.softDarkGray,
                  ), // Or Icons.fast_forward
                  onPressed: _playNextAyah,
                  tooltip: 'Next Ayah',
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.skip_next,
                    size: 32,
                    color: AppColors.darkGrey,
                  ),
                  onPressed: _playNextSurah,
                  tooltip: 'Next Surah',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
