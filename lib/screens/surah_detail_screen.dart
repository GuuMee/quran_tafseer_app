// lib/screens/surah_detail_screen.dart

import 'package:flutter/material.dart';
import 'dart:async'; // Import for Timer

import 'package:quran_tafseer_app/models/surah.dart';
import 'package:quran_tafseer_app/models/ayah.dart';
import 'package:quran_tafseer_app/data/ayahs_data.dart';
import 'package:quran_tafseer_app/utils/app_colors.dart';
import 'package:quran_tafseer_app/utils/app_text_styles.dart';
import 'package:quran_tafseer_app/utils/app_constants.dart';
import 'package:quran_tafseer_app/widgets/tafseer_text_widget.dart';
import 'package:quran_tafseer_app/services/app_preferences.dart'; // Import AppPreferences
import 'package:audioplayers/audioplayers.dart'; // NEW: Import audioplayers
import 'package:share_plus/share_plus.dart'; // NEW: Import share_plus

//SurahDetailScreen Widget
//This is the main screen that displays the details of a particular Surah. Since it needs to manage dynamic states like search queries, bookmark statuses, and scroll position, it's implemented as a StatefulWidget.
class SurahDetailScreen extends StatefulWidget {
  //Properties:
  final Surah
  surah; //surah: A Surah object containing details about the current Surah (e.g., its number, English and Arabic names, and total number of Ayahs). This is a required parameter when navigating to this screen.
  final int?
  initialAyahNumber; //initialAyahNumber: An optional int that, if provided, tells the screen to automatically scroll to a specific Ayah when it loads.

  const SurahDetailScreen({
    super.key,
    required this.surah,

    this.initialAyahNumber,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

//_SurahDetailScreenState Class: This class manages the mutable state for the SurahDetailScreen
class _SurahDetailScreenState extends State<SurahDetailScreen> {
  //State Variables:
  final TextEditingController _ayahSearchController =
      TextEditingController(); //_ayahSearchController: A TextEditingController used to manage the text input for the Ayah search bar in the AppBar.
  final ScrollController _scrollController =
      ScrollController(); //_scrollController: A ScrollController that allows programmatic control over the ListView's scrolling behavior, essential for scrolling to specific Ayahs and saving scroll position.

  List<Ayah> _allAyahs =
      []; //_allAyahs: A List<Ayah> that stores all the Ayah objects for the current Surah, fetched initially.
  List<Ayah> _filteredAyahs =
      []; //_filteredAyahs: A List<Ayah> that holds the Ayahs currently displayed. This list changes based on the search query entered by the user.

  // NEW: Set to keep track of bookmarked Ayahs for quick lookup
  //_bookmarkedAyahs: A Set<String> which efficiently stores the identifiers of bookmarked Ayahs (formatted as "surahNumber:ayahNumber"). Using a Set allows for very fast contains lookups. This is a NEW addition for improved bookmark management.
  // Stores strings like "surahNumber:ayahNumber"
  Set<String> _bookmarkedAyahs = {};

  // Debouncer for saving scroll position
  //_savePositionDebounce: A Timer object used to debounce the saving of the scroll position. This prevents excessive writes to preferences while the user is actively scrolling. This is a NEW and important optimization.
  Timer? _savePositionDebounce;

  bool _isLoading =
      true; //_isLoading: A boolean flag (though not directly used in the build method's main conditional rendering in this version, it's good practice for asynchronous operations).

  // NEW: State for tafseer visibility
  //_showTafseer: A bool flag that controls whether the Tafseer (explanation) and footnotes for each Ayah are visible. It defaults to false.
  bool _showTafseer = false; // Default to not showing tafseer

  // NEW: AudioPlayer instance
  late AudioPlayer _audioPlayer;
  // NEW: ValueNotifier to track currently playing ayah
  final ValueNotifier<int?> _currentlyPlayingAyahNumber = ValueNotifier<int?>(
    null,
  );

  // Define a reciter and base URL for audio
  // Example: Mishary Rashid Alafasy (quran.com audio API format)
  // Ensure this URL is correct and accessible.
  static const String _audioBaseUrl =
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/';

  //Lifecycle Methods
  //initState(): Called once when the widget is inserted into the widget tree.
  @override
  void initState() {
    super.initState();

    // NEW: Initialize AudioPlayer and setup listeners
    _audioPlayer = AudioPlayer();
    _setupAudioPlayerListeners();

    //Initializes _allAyahs by fetching all Ayahs for the widget.surah using getAyahsForSurah.
    _allAyahs = getAyahsForSurah(
      widget.surah.number,
      widget.surah.numberOfAyahs,
    );
    //Initializes _filteredAyahs as a copy of _allAyahs.
    _filteredAyahs = List.from(_allAyahs);

    //Attaches a listener (_onAyahSearchChanged) to _ayahSearchController so that the _performAyahSearch method is called whenever the search input changes.
    _ayahSearchController.addListener(_onAyahSearchChanged);

    // NEW: Load existing bookmarks when the screen initializes
    //Calls _loadBookmarks(): This is a NEW and crucial step to load the user's saved bookmarks when the screen first appears, populating _bookmarkedAyahs
    _loadBookmarks(); // <--- Add this call

    //Uses WidgetsBinding.instance.addPostFrameCallback to schedule a scroll action after the widget tree has been built. If initialAyahNumber is provided, it calculates the target scroll offset based on an estimated item height and animates the _scrollController to that position. This ensures the list is rendered before attempting to scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialAyahNumber != null &&
          widget.initialAyahNumber! > 0 &&
          widget.initialAyahNumber! <= _allAyahs.length) {
        final int targetIndex = _allAyahs.indexWhere(
          (ayah) => ayah.ayahNumber == widget.initialAyahNumber,
        );

        if (targetIndex != -1) {
          final double estimatedItemHeight =
              200.0; // Adjust this based on your average Ayah card height
          final double offset = targetIndex * estimatedItemHeight;

          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              offset,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
            );
          }
        }
      }
    });
  }

  // NEW: Setup listeners for audio player
  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerComplete.listen((event) {
      _currentlyPlayingAyahNumber.value = null; // Reset when audio finishes
    });
    // You can add more listeners here for onPlayerStateChanged, onDurationChanged, etc.
  }

  // NEW: Build audio URL for an Ayah
  String _getAudioUrl(int surahNumber, int ayahNumber) {
    // Format: base_url/surah_number/ayah_number.mp3
    return '$_audioBaseUrl$surahNumber/$ayahNumber.mp3';
  }

  // NEW: Play a specific Ayah
  Future<void> _playAyah(Ayah ayah) async {
    // Stop any currently playing audio before playing a new one
    await _audioPlayer.stop();

    _currentlyPlayingAyahNumber.value =
        ayah.ayahNumber; // Set the current playing ayah

    final audioUrl = _getAudioUrl(ayah.surahNumber, ayah.ayahNumber);
    print('Playing: $audioUrl'); // Debug print
    try {
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      print('Error playing audio for Ayah ${ayah.ayahNumber}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to play audio for Ayah ${ayah.ayahNumber}.'),
        ),
      );
      _currentlyPlayingAyahNumber.value = null; // Reset on error
    }
  }

  // NEW: Pause currently playing audio
  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    _currentlyPlayingAyahNumber.value = null; // Reset on pause
  }

  //Methods
  // NEW METHOD: Share Ayah
  Future<void> _shareAyah(Ayah ayah) async {
    // Construct the text to share
    String shareText = 'Quran Tafseer App\n\n';
    shareText +=
        'Surah ${widget.surah.englishName} (${widget.surah.arabicName}) - Ayah ${ayah.ayahNumber}\n\n';
    shareText += 'Arabic Text:\n${ayah.arabicText}\n\n';
    shareText += 'Translation:\n${ayah.translationText}\n';

    if (ayah.tafseerText != null && ayah.tafseerText!.isNotEmpty) {
      shareText += '\nExplanation (Tafseer):\n${ayah.tafseerText}\n';
    }

    // Optionally add a link to Quran.com or your app if it has a deep link
    shareText +=
        '\nRead more at our app Quran Tafseer, download from PlayMarket or Appstore (https://link)';

    try {
      await Share.share(shareText, subject: 'Ayah from the Quran');
    } catch (e) {
      print('Error sharing Ayah: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share Ayah.')));
    }
  }

  // NEW: Toggle method _toggleTafseerVisibility():
  //Toggles the _showTafseer boolean and triggers a setState to rebuild the UI, thereby showing or hiding the Tafseer sections.
  void _toggleTafseerVisibility() {
    setState(() {
      _showTafseer = !_showTafseer;
    });
  }

  // NEW METHOD: Loads bookmarks from AppPreferences _loadBookmarks():
  //An async method that fetches all saved bookmarks using AppPreferences.getAllBookmarks().
  Future<void> _loadBookmarks() async {
    final bookmarks = await AppPreferences.getAllBookmarks();
    if (mounted) {
      // Ensure the widget is still mounted before calling setState
      //It then converts the list of bookmark maps into a Set<String> where each string is formatted as "surahNumber:ayahNumber" (e.g., "1:5").
      setState(() {
        //Calls setState to update the _bookmarkedAyahs set, ensuring the UI reflects the correct bookmark status. It also includes a mounted check to prevent calling setState on a disposed widget.
        _bookmarkedAyahs =
            bookmarks
                .map((b) => '${b['surahNumber']}:${b['ayahNumber']}')
                .toSet();
        print(
          'Loaded ${_bookmarkedAyahs.length} bookmarks for SurahDetailScreen.',
        );
      });
    }
  }

  //_onAyahSearchChanged():
  //A simple callback that triggers _performAyahSearch whenever the text in the search bar changes.
  void _onAyahSearchChanged() {
    _performAyahSearch(_ayahSearchController.text);
  }

  //_performAyahSearch(String query): Filters the _allAyahs list based on the query
  //It converts the query and Ayah text/translation/tafseer to lowercase for case-insensitive searching.
  void _performAyahSearch(String query) {
    final lowerCaseQuery = query.toLowerCase();
    //Ayahs are included in _filteredAyahs if their Ayah number, Arabic text, translation text, or Tafseer text (if available) contain the search query.
    setState(() {
      //setState is called to update the ListView with the filtered results.
      //If the query is empty, _filteredAyahs is reset to _allAyahs.
      if (query.isEmpty) {
        _filteredAyahs = List.from(_allAyahs);
      } else {
        _filteredAyahs =
            _allAyahs.where((ayah) {
              return ayah.ayahNumber.toString().contains(lowerCaseQuery) ||
                  ayah.arabicText.toLowerCase().contains(lowerCaseQuery) ||
                  ayah.translationText.toLowerCase().contains(lowerCaseQuery) ||
                  (ayah.tafseerText != null &&
                      ayah.tafseerText!.toLowerCase().contains(lowerCaseQuery));
            }).toList();
      }
    });
  }

  //_saveCurrentReadPosition():
  // NEW METHOD: Saves the current visible Ayah position
  //It implements a debouncing mechanism using Timer. When scrolling, this method is called frequently. The Timer ensures that AppPreferences.saveLastReadPosition is only called after the user has stopped scrolling for 500 milliseconds. This reduces the number of writes to preferences, improving performance and battery life.
  void _saveCurrentReadPosition() {
    // Cancel any pending save to only save after scrolling has truly stopped for 500ms
    if (_savePositionDebounce?.isActive ?? false) {
      _savePositionDebounce!.cancel();
    }

    _savePositionDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_scrollController.hasClients && _filteredAyahs.isNotEmpty) {
        //It gets the _scrollController.offset to determine the current scroll position.
        //It estimates the firstVisibleIndex based on the scroll offset and an estimated item height.
        final double firstVisibleOffset = _scrollController.offset;
        double estimatedItemHeight = 200.0; // Same estimation as before

        // Refine estimatedItemHeight if scroll extent and list length allow
        if (_scrollController.position.maxScrollExtent > 0 &&
            _filteredAyahs.length > 0) {
          //A more refined estimatedItemHeight is calculated if possible based on maxScrollExtent.
          estimatedItemHeight =
              _scrollController.position.maxScrollExtent /
              _filteredAyahs.length;
          if (estimatedItemHeight < 100.0) {
            estimatedItemHeight = 100.0;
          }
        }

        int firstVisibleIndex =
            (firstVisibleOffset / estimatedItemHeight).floor();

        if (firstVisibleIndex < 0) firstVisibleIndex = 0;
        if (firstVisibleIndex >= _filteredAyahs.length) {
          firstVisibleIndex = _filteredAyahs.length - 1;
        }
        //It then retrieves the Ayah object at that firstVisibleIndex from _filteredAyahs and saves its Surah and Ayah number using AppPreferences.saveLastReadPosition.
        final Ayah lastReadAyah = _filteredAyahs[firstVisibleIndex];

        AppPreferences.saveLastReadPosition(
          widget.surah.number,
          lastReadAyah.ayahNumber,
        );
        //Includes debug prints to show when positions are saved.
        // Debug print for saving on scroll
        print(
          '>>> Scroll Save Debug: Saved Surah ${widget.surah.number}, Ayah ${lastReadAyah.ayahNumber}',
        );
      } else {
        // Fallback: This should ideally not be hit if _filteredAyahs is populated,
        // but acts as a safeguard. Saves Ayah 1 if controller isn't ready.
        AppPreferences.saveLastReadPosition(
          widget.surah.number,
          1, // Default to Ayah 1 if scroll position cannot be determined
        );
        print(
          '>>> Scroll Save Debug: Fallback saving Surah ${widget.surah.number}, Ayah 1 (no client or empty list)',
        );
      }
    });
  }

  // Method to toggle bookmark status _toggleBookmarkStatus(Ayah ayah):
  //This method now directly updates the local _bookmarkedAyahs Set.
  Future<void> _toggleBookmarkStatus(Ayah ayah) async {
    //It still uses AppPreferences to persist the bookmark status.
    bool isBookmarked = await AppPreferences.isAyahBookmarked(
      ayah.surahNumber,
      ayah.ayahNumber,
    );
    if (isBookmarked) {
      //After adding or removing a bookmark, it immediately calls setState to update _bookmarkedAyahs and thus visually update the bookmark icon in the UI without needing FutureBuilder in AyahCard. This makes the UI more reactive and efficient.
      await AppPreferences.removeBookmark(ayah.surahNumber, ayah.ayahNumber);
      //Shows a SnackBar for user feedback.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bookmark removed from ${widget.surah.englishName}:${ayah.ayahNumber}',
          ),
        ),
      );
    } else {
      await AppPreferences.addBookmark(ayah.surahNumber, ayah.ayahNumber);
      //Shows a SnackBar for user feedback.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bookmarked ${widget.surah.englishName}:${ayah.ayahNumber}',
          ),
        ),
      );
    }
    // No need to call setState here, as the bookmark status is checked dynamically in the builder
  }

  //Lifecycle Methods
  //dispose(): Called when the widget is removed from the widget tree.
  @override
  void dispose() {
    // Ensure any pending debounce timer is cancelled
    //Cancels _savePositionDebounce: Important to prevent memory leaks if a timer is still active.
    _savePositionDebounce?.cancel();

    // Perform one last save on dispose, which will use the _saveCurrentReadPosition
    // logic, including its fallback, to ensure something is saved.
    //Calls _saveCurrentReadPosition(): Ensures the final scroll position is saved when the user leaves the screen.
    _saveCurrentReadPosition();

    // NEW: Dispose audio player and notifier
    _audioPlayer.dispose();
    _currentlyPlayingAyahNumber.dispose();

    //Removes the listener from _ayahSearchController and disposes both _ayahSearchController and _scrollController to free up resources.
    _ayahSearchController.removeListener(_onAyahSearchChanged);
    _ayahSearchController.dispose();
    _scrollController.dispose(); // Always dispose scroll controller
    super.dispose();
  }

  //build() Method:
  //Returns a Scaffold for the screen's basic layout.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        //appBar:
        backgroundColor: AppColors.primaryOrange,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Displays the Surah's number, English name, Arabic name, translation, and number of Ayahs in the title, using a Column for better layout.
            Text(
              '${widget.surah.number}. ${widget.surah.englishName}',
              style: AppTextStyles.appBarTitle.copyWith(fontSize: 18),
            ),
            Text(
              '${widget.surah.arabicName} | ${widget.surah.englishNameTranslation} | ${widget.surah.numberOfAyahs} Ayahs',
              style: AppTextStyles.captionText.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        //actions: Contains an IconButton to toggle Tafseer visibility, similar to the previous version.
        actions: [
          // NEW: Tafseer toggle button
          IconButton(
            icon: Icon(
              _showTafseer
                  ? Icons.menu_book_rounded
                  : Icons.info_outline, // Change icon based on state
              color: AppColors.white,
            ),
            onPressed: _toggleTafseerVisibility,
            tooltip: _showTafseer ? 'Hide Tafseer' : 'Show Tafseer',
          ),
          // Add other actions if any (e.g., share, settings)
        ],
        //bottom: A PreferredSize widget is used to place a TextField (the search bar) directly within the AppBar area. This is a common pattern for adding persistent widgets below the main AppBar title.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingSmall,
              vertical: AppDimens.paddingExtraSmall,
            ),
            child: TextField(
              //The TextField is controlled by _ayahSearchController.
              //It has a hint text, a search icon prefix, and a clear button suffix (which only appears if text is entered).
              controller: _ayahSearchController,
              decoration: InputDecoration(
                //Styling is applied using InputDecoration and AppTextStyles
                hintText: 'Search within Ayahs (text, translation, number)...',
                hintStyle: AppTextStyles.bodyText.copyWith(
                  color: AppColors.mediumGrey,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.mediumGrey,
                ),
                suffixIcon:
                    _ayahSearchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.mediumGrey,
                          ),
                          onPressed: () {
                            _ayahSearchController.clear();
                            _performAyahSearch('');
                          },
                        )
                        : null,
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimens.borderRadiusMedium,
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppDimens.paddingExtraSmall,
                  horizontal: AppDimens.paddingSmall,
                ),
              ),
              style: AppTextStyles.bodyText.copyWith(color: AppColors.darkGrey),
              cursorColor: AppColors.primaryOrange,
            ),
          ),
        ),
      ),
      //body:
      //Conditional Display:
      body:
          //If _filteredAyahs is empty and the search controller is not empty, it shows a "No Ayahs found" message.
          _filteredAyahs.isEmpty && _ayahSearchController.text.isNotEmpty
              ? Center(
                child: Text(
                  'No Ayahs found for "${_ayahSearchController.text}" in this Surah.',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
              )
              //Otherwise, it displays the list of Ayahs using a NotificationListener wrapped around a ListView.separated.
              //NotificationListener<ScrollNotification>:
              ////NEW and crucial for _saveCurrentReadPosition. This widget listens for scroll events from its child (ListView.separated).
              : NotificationListener<ScrollNotification>(
                // <--- NEW: Wrap ListView with NotificationListener
                //onNotification: This callback is triggered for various scroll events. Specifically, if (scrollInfo is ScrollEndNotification) checks if the user has stopped scrolling. When this condition is met, _saveCurrentReadPosition() is called to save the last visible Ayah. Returning true allows the notification to continue to other listeners.
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo is ScrollEndNotification) {
                    // Call the method to save position when scrolling stops
                    _saveCurrentReadPosition();
                  }
                  // Return true to allow the notification to continue bubbling up (important!)
                  return true;
                },
                //ListView.separated:
                child: ListView.separated(
                  //controller: Attached to _scrollController
                  controller: _scrollController, // Attach the scroll controller
                  //padding: Adds consistent padding around the list.
                  padding: const EdgeInsets.all(AppDimens.paddingMedium),
                  //itemCount: Uses _filteredAyahs.length to display only the filtered Ayahs.
                  itemCount: _filteredAyahs.length,

                  //itemBuilder:
                  //Builds each Ayah card.
                  itemBuilder: (context, index) {
                    final ayah = _filteredAyahs[index];
                    final bool hasTafseer =
                        ayah.tafseerText != null &&
                        ayah.tafseerText!.isNotEmpty;

                    // Determine if this Ayah is currently playing for highlighting
                    final bool isPlayingThisAyah =
                        _currentlyPlayingAyahNumber.value == ayah.ayahNumber;

                    //Each Ayah is displayed within a Card widget.
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimens.borderRadiusMedium,
                        ),
                      ),
                      // NEW: Conditional background color for highlighting playing Ayah
                      color:
                          isPlayingThisAyah
                              ? AppColors.primaryOrange.withOpacity(0.3)
                              : AppColors.white,
                      //ExpansionTile: NEW improvement. Instead of a simple Column or AyahCard widget, each Ayah is now wrapped in an ExpansionTile. This allows the Tafseer and footnotes to be hidden by default and expanded/collapsed by tapping on the Ayah's main content area.
                      child: ExpansionTile(
                        // Use a ValueKey to ensure ExpansionTile state is preserved/reset correctly
                        key: ValueKey(
                          'ayah_tile_${ayah.surahNumber}_${ayah.ayahNumber}_${_showTafseer}',
                        ),
                        // Control initial expansion based on the global toggle
                        initiallyExpanded: _showTafseer,
                        //tilePadding: Padding for the header of the ExpansionTile.
                        tilePadding: const EdgeInsets.all(
                          AppDimens.paddingMedium,
                        ),
                        //title: Contains the Ayah number, bookmark button, Arabic text, and translation text. This is what's visible when the tile is collapsed.
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // NEW: Row for Play/Pause, Bookmark Button and Ayah Number
                            // The Ayah number is on the right, and the bookmark icon is on the left.
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween, // Distribute space
                              children: [
                                // Group Play/Pause and Bookmark buttons
                                Row(
                                  children: [
                                    // NEW: Play/Pause Button for this Ayah
                                    ValueListenableBuilder<int?>(
                                      // Listen to changes from parent
                                      valueListenable:
                                          _currentlyPlayingAyahNumber,
                                      builder: (
                                        context,
                                        currentPlayingAyah,
                                        child,
                                      ) {
                                        final bool isThisAyahPlaying =
                                            currentPlayingAyah ==
                                            ayah.ayahNumber;
                                        return IconButton(
                                          icon: Icon(
                                            isThisAyahPlaying
                                                ? Icons.pause_circle_filled
                                                : Icons.play_circle_filled,
                                            color:
                                                AppColors
                                                    .successGreen, // Or any color you prefer for audio
                                            size: 28,
                                          ),
                                          onPressed: () {
                                            if (isThisAyahPlaying) {
                                              _pauseAudio(); // Pause if this Ayah is already playing
                                            } else {
                                              _playAyah(ayah); // Play this Ayah
                                            }
                                          },
                                        );
                                      },
                                    ),
                                    // Bookmark Button
                                    IconButton(
                                      icon: Icon(
                                        _bookmarkedAyahs.contains(
                                              '${ayah.surahNumber}:${ayah.ayahNumber}',
                                            )
                                            ? Icons
                                                .bookmark // Filled icon if bookmarked
                                            : Icons
                                                .bookmark_border, // Bordered icon if not bookmarked
                                        color:
                                            _bookmarkedAyahs.contains(
                                                  '${ayah.surahNumber}:${ayah.ayahNumber}',
                                                )
                                                ? AppColors
                                                    .primaryOrange // Color for bookmarked
                                                : AppColors
                                                    .mediumGrey, // Color for not bookmarked
                                      ),
                                      //The bookmark icon's status is now directly checked against the _bookmarkedAyahs Set, making it more efficient and reactive. When the icon is pressed, it calls _toggleBookmarkStatus, which updates the Set and then setState.
                                      onPressed: () async {
                                        final bookmarkId =
                                            '${ayah.surahNumber}:${ayah.ayahNumber}';
                                        if (_bookmarkedAyahs.contains(
                                          bookmarkId,
                                        )) {
                                          await AppPreferences.removeBookmark(
                                            ayah.surahNumber,
                                            ayah.ayahNumber,
                                          );
                                          if (mounted) {
                                            setState(() {
                                              _bookmarkedAyahs.remove(
                                                bookmarkId,
                                              );
                                              print(
                                                'Bookmark removed: $bookmarkId',
                                              );
                                            });
                                          }
                                        } else {
                                          await AppPreferences.addBookmark(
                                            ayah.surahNumber,
                                            ayah.ayahNumber,
                                          );
                                          if (mounted) {
                                            setState(() {
                                              _bookmarkedAyahs.add(bookmarkId);
                                              print(
                                                'Bookmark added: $bookmarkId',
                                              );
                                            });
                                          }
                                        }
                                      },
                                    ),
                                    // NEW: Share Button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.share,
                                        color:
                                            AppColors
                                                .mediumGrey, // Or a distinct share color
                                        size: 24,
                                      ),
                                      onPressed: () => _shareAyah(ayah),
                                    ),
                                  ],
                                ),
                                // Existing Ayah Number (wrapped in Expanded to take available space)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                      AppDimens.paddingExtraSmall,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.softGreen.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppDimens.borderRadiusSmall,
                                      ),
                                    ),
                                    child: Text(
                                      'Ayah ${ayah.ayahNumber}',
                                      style: AppTextStyles.captionText.copyWith(
                                        color: AppColors.successGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppDimens.paddingSmall),
                            // Arabic Ayah Text
                            Text(
                              ayah.arabicText,
                              style: AppTextStyles.arabicAyahStyle.copyWith(
                                fontSize: 22,
                                color: AppColors.darkGrey,
                              ),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                            ),
                            SizedBox(height: AppDimens.paddingMedium),
                            // Translation Text
                            Text(
                              ayah.translationText,
                              style: AppTextStyles.bodyText.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.mediumGrey,
                              ),
                              textAlign: TextAlign.left,
                              textDirection: TextDirection.ltr,
                            ),
                          ],
                        ),
                        //childrenPadding: Padding for the content displayed when the ExpansionTile is expanded.
                        childrenPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingMedium,
                        ).copyWith(bottom: AppDimens.paddingMedium),
                        //children: Contains the Tafseer and footnotes, displayed conditionally:
                        children: [
                          //If hasTafseer is true, it shows a "Explanation (Tafseer):" label and a TafseerTextWidget.
                          if (hasTafseer)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(
                                  height: AppDimens.paddingMedium * 2,
                                ),
                                Text(
                                  'Explanation (Tafseer):',
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                                SizedBox(height: AppDimens.paddingSmall),
                                TafseerTextWidget(
                                  text: ayah.tafseerText!,
                                  footnotes: ayah.footnotes,
                                ),
                              ],
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.all(
                                AppDimens.paddingSmall,
                              ),
                              //Otherwise, it displays a "Explanation for this Ayah is not available yet" message.
                              child: Text(
                                'Explanation for this Ayah is not available yet.',
                                style: AppTextStyles.captionText.copyWith(
                                  color: AppColors.mediumGrey,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  //separatorBuilder: This is used by ListView.separated to add a fixed space (SizedBox) between each Ayah card, providing clear visual separation.
                  separatorBuilder:
                      (context, index) =>
                          const SizedBox(height: AppDimens.paddingMedium),
                ),
              ),
    );
  }
}
