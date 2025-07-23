// lib/models/surah.dart

class Surah {
  final int number;
  final String arabicName;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType; // e.g., 'Meccan', 'Medinan'
  final int numberOfAyahs;

  Surah({
    required this.number,
    required this.arabicName,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  // Optional: A factory constructor to create a Surah from a JSON map (useful later)
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      arabicName: json['arabicName'] as String,
      englishName: json['englishName'] as String,
      englishNameTranslation: json['englishNameTranslation'] as String,
      revelationType: json['revelationType'] as String,
      numberOfAyahs: json['numberOfAyahs'] as int,
    );
  }
}
