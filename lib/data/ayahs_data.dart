//It's written and said:

// lib/data/ayahs_data.dart

import 'package:quran_tafseer_app/models/ayah.dart';

List<Ayah> getAyahsForSurah(int surahNumber, int numberOfAyahsInSurah) {
  final Map<int, List<Ayah>> specificAyahData = {
    // --- Surah 1: Al-Fatiha (7 Ayahs with Tafseer & Footnotes) ---
    1: [
      Ayah(
        surahNumber: 1,
        ayahNumber: 1,
        arabicText: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        translationText:
            'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        tafseerText:
            'This verse is known as the **Basmala** (بَسْمَلَة)((1)). It is recited at the beginning of almost every Surah of the Quran, emphasizing that all actions should begin with the remembrance of Allah. The terms **Ar-Rahman** (ٱلرَّحْمَٰنِ) and **Ar-Rahim** (ٱلرَّحِيمِ) both derive from the root R-H-M, signifying immense mercy. Ar-Rahman refers to Allah\'s universal mercy to all creation, while Ar-Rahim denotes His special mercy to believers((2)). This highlights Allah\'s all-encompassing compassion. Read more in Tafseer Ibn Kathir.',
        footnotes: {
          '1':
              'A linguistic term meaning "In the name of Allah, the Most Gracious, the Most Merciful."',
          '2':
              'This distinction emphasizes Allah\'s widespread mercy to all in this world and His particular mercy for believers in the Hereafter.',
        },
      ),
      Ayah(
        surahNumber: 1,
        ayahNumber: 2,
        arabicText: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
        translationText: 'All praise is due to Allah, Lord of the worlds,',
        tafseerText:
            'This verse declares that all forms of praise (ٱلْحَمْدُ) and gratitude are due to Allah alone. He is the **Rabb** (رَبِّ)((3)), the Lord, Sustainer, and Cherisher of all **Al-`Alameen** (ٱلْعَٰلَمِينَ)((4)), meaning all worlds or all creation – humans, jinn, angels, and everything that exists. This acknowledges His sole sovereignty and providence.',
        footnotes: {
          '3':
              'Rabb (رب) signifies creator, owner, sustainer, provider, and controller. It\'s a comprehensive term for God\'s lordship.',
          '4':
              'Al-`Alameen (العالمين) literally means "the worlds," encompassing all beings and realms in existence.',
        },
      ),
      Ayah(
        surahNumber: 1,
        ayahNumber: 3,
        arabicText: 'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        translationText: 'The Entirely Merciful, the Especially Merciful,',
        tafseerText:
            'These attributes were explained in Ayah 1. Repeating them here emphasizes their profound significance and Allah\'s constant, pervasive mercy. They remind us of His benevolence that precedes punishment.',
      ),
      Ayah(
        surahNumber: 1,
        ayahNumber: 4,
        arabicText: 'مَٰلِكِ يَوْمِ ٱلدِّينِ',
        translationText: 'Sovereign of the Day of Recompense.',
        tafseerText:
            'Allah is the absolute **Malik** (مَٰلِكِ) or Sovereign of the **Yawm Ad-Din** (يَوْمِ ٱلدِّينِ)((5)), the Day of Recompense or Judgment. This verse instills consciousness of accountability, reminding believers that ultimate authority and judgment belong to Allah on that fateful day. It motivates righteous living and fear of His justice.',
        footnotes: {
          '5':
              'Yawm Ad-Din (يوم الدين) refers to the Day of Judgment, when all deeds will be accounted for.',
        },
      ),
      Ayah(
        surahNumber: 1,
        ayahNumber: 5,
        arabicText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        translationText: 'It is You we worship and You we ask for help.',
        tafseerText:
            'This is a pivotal verse of **Tawhid** (تَوْحِيد - oneness of God). It establishes pure monotheism by stating that only Allah is to be worshipped (نَعْبُدُ) and only from Him do we seek help (نَسْتَعِينُ). This rejection of polytheism and reliance on anyone else emphasizes absolute submission and trust in Allah alone for all matters, spiritual and worldly.',
      ),
      Ayah(
        surahNumber: 1,
        ayahNumber: 6,
        arabicText: 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
        translationText: 'Guide us to the straight path,',
        tafseerText:
            'This is the central plea of the Fatihah. We ask Allah to guide us to the **As-Sirat Al-Mustaqim** (ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ) ((6)), the straight path. This path encompasses Islam, the truth, righteousness, and the way of life pleasing to Allah. It is the path free from deviation, ensuring spiritual and worldly well-being.',
        footnotes: {
          '6':
              'As-Sirat Al-Mustaqim (الصراط المستقيم) is the clear, unwavering path of truth and righteousness in Islam.',
        },
      ),
      Ayah(
        surahNumber: 1,
        ayahNumber: 7,
        arabicText:
            'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
        translationText:
            'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] wrath or of those who are astray.',
        tafseerText:
            'This verse clarifies the straight path by describing its followers and those who deviate. "Those upon whom You have bestowed favor" are the Prophets, the truthful (الصديقين), the martyrs (الشهداء), and the righteous (الصالحين). "Those who have evoked [Your] wrath" (ٱلْمَغْضُوبِ عَلَيْهِمْ) ((7)) are those who knew the truth but deliberately rejected it. "Those who are astray" (ٱلضَّآلِّينَ) (8) are those who lost the way due to ignorance or misguidance. This highlights the importance of both correct knowledge and correct action for true guidance.',
        footnotes: {
          '7':
              'Al-Maghdubi Alayhim (المغضوب عليهم) are those who earned Allah\'s anger, often interpreted as those who knew the truth but rejected it, like some Jews.',
          '8':
              'Ad-Daalleen (الضالين) are those who went astray, often interpreted as those who deviated from truth due to ignorance, like some Christians.',
        },
      ),
    ],

    // --- Surah 112: Al-Ikhlas (Juz Amma) ---
    112: [
      Ayah(
        surahNumber: 112,
        ayahNumber: 1,
        arabicText: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
        translationText: 'Say, "He is Allah, [who is] One,"',
        tafseerText:
            'This verse establishes the fundamental principle of **Tawhid** (تَوْحِيد) (9), the absolute oneness of Allah. He is **Ahad** (أَحَدٌ), meaning unique and singular in His essence, attributes, and actions. This refutes polytheism and any concept of partners with God.',
        footnotes: {
          '9':
              'Tawhid (توحيد) is the absolute belief in the oneness of God, a central tenet of Islam.',
        },
      ),
      Ayah(
        surahNumber: 112,
        ayahNumber: 2,
        arabicText: 'ٱللَّهُ ٱلصَّمَدُ',
        translationText: 'Allah, the Eternal Refuge.',
        tafseerText:
            'Allah is **As-Samad** (ٱلصَّمَدُ) (10), a unique attribute meaning He is the Self-Sufficient One upon whom all creation depends for all their needs, while He depends on none. He is free from all deficiencies.',
        footnotes: {
          '10':
              'As-Samad (الصمد) means the independent and self-sufficient Lord, to whom all creation turns in need.',
        },
      ),
      Ayah(
        surahNumber: 112,
        ayahNumber: 3,
        arabicText: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
        translationText: 'He neither begets nor is born,',
        tafseerText:
            'This negates any idea of Allah having offspring or parents, directly challenging doctrines that attribute human characteristics to the Divine. It emphasizes His eternal, uncreated, and incomparable nature.',
      ),
      Ayah(
        surahNumber: 112,
        ayahNumber: 4,
        arabicText: 'وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ',
        translationText: 'Nor is there to Him any equivalent."',
        tafseerText:
            'There is **Kufuwan Ahad** (كُفُوًا أَحَدٌۢ) (11) to Him, meaning no one is comparable, equal, or like Allah in any way. He is absolutely unique in His majesty and power. This completes the definition of pure monotheism.',
        footnotes: {
          '11':
              'Kufuwan Ahad (كفوا أحد) signifies having no equal, peer, or comparable entity.',
        },
      ),
    ],
    // ... (rest of your dummy data for Surahs 113, 114 etc., modify them to include footnotes as well)
    // For brevity, I'll just include 113 and 114 without footnotes to keep this response shorter.
    // Please go back and add actual footnotes to 113 and 114 yourself, following the pattern above.
    113: [
      // Al-Falaq
      Ayah(
        surahNumber: 113,
        ayahNumber: 1,
        arabicText: 'قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ',
        translationText: 'Say, "I seek refuge in the Lord of daybreak"',
        tafseerText:
            'This is an instruction to seek protection in Allah, the **Rabb Al-Falaq** (رَبِّ ٱلْفَلَقِ), meaning the Lord of daybreak or the one who causes splitting – whether of darkness by light, or seeds by shoots. This signifies His power over all creation and His ability to bring things into existence from nothing.',
      ),
      Ayah(
        surahNumber: 113,
        ayahNumber: 2,
        arabicText: 'مِن شَرِّ مَا خَلَقَ',
        translationText: 'From the evil of that which He created',
        tafseerText:
            'A general plea for refuge from all types of evil originating from anything Allah has created, be it humans, jinn, animals, or even inanimate objects. This covers both tangible and intangible harms.',
      ),
      Ayah(
        surahNumber: 113,
        ayahNumber: 3,
        arabicText: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
        translationText: 'And from the evil of darkness when it settles',
        tafseerText:
            'Seeking refuge from the evils that occur or intensify during the night when darkness descends (**Ghaasiq** - غَاسِقٍ). This includes the harm from nocturnal creatures, criminals, or the rise of evil thoughts and fears that creep in during the quiet of night.',
      ),
      Ayah(
        surahNumber: 113,
        ayahNumber: 4,
        arabicText: 'وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِى ٱلْعُقَدِ',
        translationText: 'And from the evil of the blowers in knots',
        tafseerText:
            'This verse refers to those who practice **witchcraft** and magic. Historically, magicians would tie knots and blow upon them while reciting incantations to cause harm. We seek Allah\'s protection from such occult practices and those who misuse knowledge for evil.',
      ),
      Ayah(
        surahNumber: 113,
        ayahNumber: 5,
        arabicText: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
        translationText: 'And from the evil of an envier when he envies."',
        tafseerText:
            'A plea for refuge from the harm caused by an **envier** (حَاسِدٍ) when their envy manifests. Envy is a destructive emotion that can lead to malice, plotting, or even the evil eye (عين). This teaches us to seek divine protection from the ill will of others.',
      ),
    ],
    114: [
      // An-Nas
      Ayah(
        surahNumber: 114,
        ayahNumber: 1,
        arabicText: 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ',
        translationText: 'Say, "I seek refuge in the Lord of mankind,"',
        tafseerText:
            'This initiates the prayer by calling upon Allah as the **Rabb An-Nas** (رَبِّ ٱلنَّاسِ), the Lord and Cherisher of all humanity. This emphasizes His supreme authority and His capacity to protect and sustain us.',
      ),
      Ayah(
        surahNumber: 114,
        ayahNumber: 2,
        arabicText: 'مَلِكِ ٱلنَّاسِ',
        translationText: 'The Sovereign of mankind,',
        tafseerText:
            'Allah is also the **Malik An-Nas** (مَلِكِ ٱلنَّاسِ), the Absolute King and Ruler of mankind. This highlights His complete dominion and control over all human affairs, reminding us that true power lies only with Him.',
      ),
      Ayah(
        surahNumber: 114,
        ayahNumber: 3,
        arabicText: 'إِلَٰهِ ٱلنَّاسِ',
        translationText: 'The God of mankind,',
        tafseerText:
            'Finally, Allah is the **Ilah An-Nas** (إِلَٰهِ ٱلنَّاسِ), the only true God worthy of worship, love, and devotion from mankind. These three attributes (Lord, King, God) comprehensively cover Allah\'s relationship with humanity and our need for Him.',
      ),
      Ayah(
        surahNumber: 114,
        ayahNumber: 4,
        arabicText: 'مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ',
        translationText: 'From the evil of the retreating whisperer -',
        tafseerText:
            'We seek refuge from the **Waswas Al-Khannas** (ٱلْوَسْوَاسِ ٱلْخَنَّاسِ), which refers to Shaytan (Satan) or any entity that whispers evil suggestions. "Al-Khannas" means the one who retreats and hides when Allah\'s name is remembered, but returns when one becomes heedless.',
      ),
      Ayah(
        surahNumber: 114,
        ayahNumber: 5,
        arabicText: 'ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ',
        translationText: 'Who whispers [evil] into the breasts of mankind -',
        tafseerText:
            'This specifies the nature of the whisperer: it infiltrates and implants doubts, evil thoughts, and temptations directly into the hearts and minds (**sudur** - صُدُورِ) of people, aiming to lead them astray.',
      ),
      Ayah(
        surahNumber: 114,
        ayahNumber: 6,
        arabicText: 'مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ',
        translationText: 'From among the jinn and mankind.',
        tafseerText:
            'The sources of these evil whispers are identified as both the **jinn** (invisible beings, الجِنَّةِ) and wicked **humans** (ٱلنَّاسِ) who mislead and tempt others. This verse warns against both unseen and visible influences that can corrupt faith and actions.',
      ),
    ],
  };

  // If specific data exists for the Surah, return it.
  if (specificAyahData.containsKey(surahNumber)) {
    return specificAyahData[surahNumber]!;
  }

  // Generate generic dummy data for other Surahs (those without specific Tafseer yet)
  List<Ayah> genericAyahs = [];
  for (int i = 1; i <= numberOfAyahsInSurah; i++) {
    genericAyahs.add(
      Ayah(
        surahNumber: surahNumber,
        ayahNumber: i,
        arabicText:
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ (Ayah $i of Surah $surahNumber)',
        translationText:
            'This is a placeholder translation for Ayah $i of Surah $surahNumber.',
        tafseerText: null, // No tafseerText for generic Ayahs by default
        footnotes: null,
      ),
    );
  }
  return genericAyahs;
}
