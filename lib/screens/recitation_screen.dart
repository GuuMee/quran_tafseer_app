// lib/screens/recitation_screen.dart

import 'package:flutter/material.dart';
import 'package:quran_tafseer_app/services/central_audio_handler.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/data/surahs_data.dart'; // Import Surah data
import 'package:quran_tafseer_app/models/surah.dart'; // Import Surah model
// Ayahs_data might not be strictly needed here for audio, but keep if used elsewhere for Ayah objects
// Ayah model might not be strictly needed here for audio, but keep if used elsewhere for Ayah objects
import 'package:quran_tafseer_app/services/app_audio_manager.dart';
import 'package:just_audio/just_audio.dart'; // Correct import for AudioPlayer
// Correct import for MediaItem

// Import your custom PlayerState enum and alias it for clarity
import 'package:quran_tafseer_app/models/player_state_enum.dart'
    as AppPlayerState;

// Convert to StatefulWidget to manage playback state
class RecitationScreen extends StatefulWidget {
  const RecitationScreen({super.key});

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  //final CentralAudioHandler _audioHandler = AppAudioManager().audioHandler;
  // Make the audio handler nullable to avoid the crash
  // Get the audio handler directly from the manager
  // Use a non-nullable variable because it's guaranteed to be initialized.
  final CentralAudioHandler _audioHandler =
      AppAudioManager().audioHandler!; // Use '!' to unwrap

  // No longer needed here as AppAudioManager handles the base URL and URL generation
  // static const String _audioBaseUrl = 'https://everyayah.com/data/Menshawi_16kbps/';

  // State for playback
  int? _currentPlayingSurahIndex; // Index in `allSurahs`
  int? _currentPlayingAyahNumber; // Ayah number within the current Surah
  String?
  _currentPlayingAyahUrl; // To keep track of the currently playing URL for caching later

  // Use your custom AppPlayerState enum for _playerState
  AppPlayerState.PlayerState _playerState = AppPlayerState.PlayerState.stopped;

  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // List of all surahs
  final List<Surah> _allSurahs = allSurahs;

  // --- Initialization and Disposal ---
  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration.zero, () {
    //   _setupAudioPlayerListeners(); // ensures background is fully initialized
    // });
    //_initAudioService();
    // No need for a separate init method, just set up the listeners directly
    _setupAudioPlayerListeners();
  }

  // void _initAudioService() {
  //   _audioHandler = AppAudioManager().audioHandler;
  //   if (_audioHandler != null) {
  //     _setupAudioPlayerListeners();
  //   } else {
  //     print(
  //       'Audio service is not initialized. Playback features are disabled.',
  //     );
  //   }
  // }

  void _setupAudioPlayerListeners() {
    // ... all of your existing listener code goes here ...
    // ... you need to wrap every use of _audioHandler with a null check.

    _audioHandler!.playerStateStream.listen((playerState) {
      if (!mounted) return;
      setState(() {
        // ... your existing state-setting logic ...
      });
    });

    _audioHandler!.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration ?? Duration.zero;
        });
      }
    });

    _audioHandler!.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentDuration = position;
        });
      }
    });

    _audioHandler!.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        print('Playback error: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Playback Error: $e')));
        }
        _playNextAyah();
      },
    );

    //to play Next Ayah Automatically
    _audioHandler!.playbackEventStream.listen(
      (event) {
        if (!mounted) return;
        // This is the CRITICAL part for automatic playback
        if (event.processingState == ProcessingState.completed) {
          print('Playback completed, playing next ayah...');
          _playNextAyah(); // Call the method to play the next ayah
        }
      },
      onError: (Object e, StackTrace st) {
        print('Playback error: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Playback Error: $e')));
        }
        _playNextAyah(); // Try to advance to the next ayah on error
      },
    );
  }

  // Define _scrollToAyah method (placeholder for now, implement actual scrolling if needed)
  void _scrollToAyah(int ayahNumber) {
    // Implement actual scrolling logic here if you have a scrollable list of ayahs
    // For now, it just prints:
    print('Scrolling to Ayah: $ayahNumber');
  }

  // --- Audio URL Helper (remove as AppAudioManager handles it now) ---
  // String _getAudioUrl(int surahNumber, int ayahNumber) { ... }

  // --- Playback Control Methods ---

  // Play a full Surah (starts from its first Ayah)
  Future<void> _playSurah(int surahIndex) async {
    // Add a small delay to prevent the race condition
    // This allows the player to finish its 'completed' state processing
    await Future.delayed(Duration(milliseconds: 100));

    await _audioHandler!.stop(); // Stop any currently playing audio
    // ... rest of your logic

    setState(() {
      _currentPlayingSurahIndex = surahIndex;
      _currentPlayingAyahNumber =
          1; // Always start from the first Ayah of the selected Surah
      _playerState =
          AppPlayerState.PlayerState.stopped; // Reset state before playing
      _currentDuration = Duration.zero;
      _totalDuration = Duration.zero;
    });

    await _playAyahInSequence(); // Start playing the first Ayah
  }

  // Play a single Ayah in sequence (called internally for full Surah playback)
  Future<void> _playAyahInSequence() async {
    if (_currentPlayingSurahIndex == null ||
        _currentPlayingAyahNumber == null) {
      print('Error: Cannot play in sequence. Surah or Ayah index is null.');
      // Fallback to a default, like the first ayah of the first surah
      await AppAudioManager().playAyah(
        surahNumber: 1,
        ayahNumber: 1,
        surahEnglishName: 'Al-Fatiha',
      );
      return;
    }
    final Surah currentSurah = _allSurahs[_currentPlayingSurahIndex!];

    try {
      // Call the playAyah method on the shared manager
      await AppAudioManager().playAyah(
        surahNumber: currentSurah.number,
        ayahNumber: _currentPlayingAyahNumber!,
        surahEnglishName: currentSurah.englishName,
      );
      // _currentPlayingAyahUrl = AppAudioManager()._getAudioUrl(currentSurah.number, _currentPlayingAyahNumber!); // If you need to track URL, get from manager
      _currentPlayingAyahUrl = AppAudioManager().getAudioUrl(
        currentSurah.number,
        _currentPlayingAyahNumber!,
      ); // Keep track of the current playing URL
      _scrollToAyah(_currentPlayingAyahNumber!);
    } catch (e) {
      print('Audio Player Error for Ayah $_currentPlayingAyahNumber: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing Ayah: $_currentPlayingAyahNumber\n$e'),
          ),
        );
      }
      _playNextAyah(); // Try to advance to the next ayah on error
    }
  }

  // Play the next Ayah in the current Surah or move to the next Surah
  void _playNextAyah() {
    if (_currentPlayingSurahIndex == null) {
      print('DEBUG: _playNextAyah called but no surah is selected.');
      return;
    }
    final Surah currentSurah = _allSurahs[_currentPlayingSurahIndex!];
    final int nextAyahNum = (_currentPlayingAyahNumber ?? 0) + 1;

    print('DEBUG: _playNextAyah called for Surah ${currentSurah.number}.');
    print('DEBUG: Current playing Ayah: $_currentPlayingAyahNumber');
    print('DEBUG: Next Ayah number to check: $nextAyahNum');
    print(
      'DEBUG: Total Ayahs in Surah ${currentSurah.number}: ${currentSurah.numberOfAyahs}',
    );

    if (nextAyahNum <= currentSurah.numberOfAyahs) {
      print(
        'DEBUG: Condition met: nextAyahNum ($nextAyahNum) is <= totalAyahs.',
      );
      setState(() {
        _currentPlayingAyahNumber = nextAyahNum;
      });
      _playAyahInSequence();
    } else {
      print(
        'DEBUG: Condition NOT met: nextAyahNum ($nextAyahNum) is > totalAyahs.',
      );
      print('DEBUG: Playing next surah...');
      // If last Ayah of current Surah, try to play the next Surah
      _playNextSurah();
    }
  }

  // Play the previous Ayah in the current Surah or move to the previous Surah
  void _playPreviousAyah() {
    if (_currentPlayingSurahIndex == null) return;

    final int prevAyahNum = (_currentPlayingAyahNumber ?? 1) - 1;

    if (prevAyahNum >= 1) {
      setState(() {
        _currentPlayingAyahNumber = prevAyahNum;
      });
      _playAyahInSequence();
    } else {
      // If first Ayah of current Surah, try to play the previous Surah
      _playPreviousSurah();
    }
  }

  // Play the next Surah in the list
  void _playNextSurah() {
    if (_currentPlayingSurahIndex == null) {
      print(
        'DEBUG: _playNextSurah called with no surah playing. Starting from the beginning.',
      );
      _playSurah(0); // If nothing is playing, start from the first surah
      return;
    }

    final int nextSurahIndex = _currentPlayingSurahIndex! + 1;
    print('DEBUG: Attempting to play next surah at index: $nextSurahIndex');
    if (nextSurahIndex < _allSurahs.length) {
      print(
        'DEBUG: Next surah index is valid. Playing Surah: ${_allSurahs[nextSurahIndex].englishName}',
      );
      _playSurah(nextSurahIndex);
    } else {
      // End of playlist
      print('DEBUG: End of playlist reached.');
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

  // Toggle play/pause state
  Future<void> _togglePlayPause() async {
    if (_playerState == AppPlayerState.PlayerState.playing) {
      await _audioHandler!.pause();
    } else if (_playerState == AppPlayerState.PlayerState.paused) {
      await _audioHandler!.play(); // Use play() to resume
    } else {
      // If stopped or completed, start from the current or first surah
      if (_currentPlayingSurahIndex == null) {
        _playSurah(0); // Start from the first surah if nothing is selected
      } else {
        await _playAyahInSequence(); // If there was a current ayah, try to play it again
      }
    }
  }

  // Dedicated Stop Function
  void _stopAudio() async {
    if (_audioHandler == null) return;
    await _audioHandler!.stop(); // just_audio uses stop()
    setState(() {
      _playerState = AppPlayerState.PlayerState.stopped;
      _currentPlayingSurahIndex = null;
      _currentPlayingAyahNumber = null;
      _currentPlayingAyahUrl = null;
      _currentDuration = Duration.zero;
      _totalDuration = Duration.zero;
    });
    print('Audio Stopped');
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
    // DO NOT dispose the global _audioPlayer here.
    // It should only be disposed when the app is completely shut down (e.g., in AppAudioManager.dispose()).
    super.dispose();
  }

  // --- Widget Build Method ---
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
          Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: _buildPlayerControls(),
          ),
        ],
      ),
    );
  }

  // Player Control Widget (already updated in previous response)
  Widget _buildPlayerControls() {
    if (_audioHandler == null) {
      return SizedBox();
    }

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
          // Playback buttons (all wrapped in Expanded)
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
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.replay_10,
                    size: 32,
                    color: AppColors.softDarkGray,
                  ),
                  onPressed: _playPreviousAyah,
                  tooltip: 'Previous Ayah',
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.stop_circle,
                    size: 48,
                    color: AppColors.primaryOrange,
                  ),
                  onPressed: _stopAudio,
                  tooltip: 'Stop Playback',
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(
                    _playerState == AppPlayerState.PlayerState.playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 56,
                    color: AppColors.primaryOrange,
                  ),
                  onPressed: _togglePlayPause,
                  tooltip:
                      _playerState == AppPlayerState.PlayerState.playing
                          ? 'Pause'
                          : 'Play',
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.forward_10,
                    size: 32,
                    color: AppColors.softDarkGray,
                  ),
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
