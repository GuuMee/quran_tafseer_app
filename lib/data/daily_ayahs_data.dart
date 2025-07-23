//It's said:
// lib/data/daily_ayahs_data.dart

class DailyAyahModel {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String translationText;

  DailyAyahModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.translationText,
  });
}

final List<DailyAyahModel> kDailyAyahs = [
  DailyAyahModel(
    surahNumber: 1,
    ayahNumber: 1,
    arabicText: 'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
    translationText:
        'With the name of Allah, the Merciful to believers and nonbelievers in the present life, the Merciful to belivers in the Afterlife.',
  ),
  DailyAyahModel(
    surahNumber: 1,
    ayahNumber: 5,
    arabicText: 'إِيَّاكَ ن عَْبُدُ وَإِيَّاكَ نَسْتَعِيُ',
    translationText: 'You are whom we worship and from You we seek aid.',
  ),
  DailyAyahModel(
    surahNumber: 1,
    ayahNumber: 7,
    arabicText:
        'صِرَاطَ الَّذِينَ أَنْ عَمْتَ عَلَيْهِمْ غَير الْمَغْضُوبِ عَلَيْهِمْ وَلا الضَّآلِّيَ ',
    translationText:
        'The path of those upon whom You have bestowed, not the path of those whose share is punishment, and not the path of the astray.',
  ),
  DailyAyahModel(
    surahNumber: 78,
    ayahNumber: 1,
    arabicText: 'عَمَّ ي تََسَاءَلُونَ',
    translationText: 'Concerning what are they inquisitive?',
  ),
  DailyAyahModel(
    surahNumber: 78,
    ayahNumber: 17,
    arabicText: 'إِنَّ ي وَْمَ الْفَصْلِ كَانَ مِيقَاتًا',
    translationText: 'Verily, the Day of Segregation was appointed',
  ),
  DailyAyahModel(
    surahNumber: 112,
    ayahNumber: 4,
    arabicText: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    translationText: 'And there was never for Him any similar.',
  ),
  DailyAyahModel(
    surahNumber: 114,
    ayahNumber: 1,
    arabicText: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
    translationText: 'Say, "I seek refuge with the Lord of mankind,',
  ),
  DailyAyahModel(
    surahNumber: 114,
    ayahNumber: 2,
    arabicText: 'مَلِكِ النَّاسِ',
    translationText: 'The King of mankind,',
  ),
  DailyAyahModel(
    surahNumber: 114,
    ayahNumber: 3,
    arabicText: 'إِلَهِ النَّاسِ',
    translationText: 'The God of mankind,',
  ),
];
