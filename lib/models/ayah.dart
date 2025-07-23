// lib/models/ayah.dart

class Ayah {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String translationText;
  final String? tafseerText;
  final Map<String, String>? footnotes;
  // You can add more fields later if needed, e.g., audio URL, words breakdown.

  Ayah({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.translationText,
    this.tafseerText,
    this.footnotes, // <--- Add to constructor
  });

  // Optional: A factory constructor to create an Ayah from a JSON map (useful later)
  // You'd update fromJson if loading from JSON later
  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      arabicText: json['arabicText'] as String,
      translationText: json['translationText'] as String,
      tafseerText: json['tafseerText'] as String?,
      footnotes: (json['footnotes'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
    );
  }
}
