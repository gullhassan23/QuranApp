import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which hadith text blocks to show (Arabic / English / Urdu).
class HadithLanguageVisibility {
  const HadithLanguageVisibility({
    required this.showArabic,
    required this.showEnglish,
    required this.showUrdu,
  });

  final bool showArabic;
  final bool showEnglish;
  final bool showUrdu;

  static const HadithLanguageVisibility all = HadithLanguageVisibility(
    showArabic: true,
    showEnglish: true,
    showUrdu: true,
  );
}

/// Persisted toggles + in-memory [ValueNotifier] for Hadith screens.
class HadithDisplayPrefs {
  HadithDisplayPrefs._();

  static final HadithDisplayPrefs instance = HadithDisplayPrefs._();

  final ValueNotifier<HadithLanguageVisibility> visibility =
      ValueNotifier<HadithLanguageVisibility>(HadithLanguageVisibility.all);

  static const _kAr = 'hadith_show_arabic';
  static const _kEn = 'hadith_show_english';
  static const _kUr = 'hadith_show_urdu';

  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final p = await SharedPreferences.getInstance();
    visibility.value = HadithLanguageVisibility(
      showArabic: p.getBool(_kAr) ?? true,
      showEnglish: p.getBool(_kEn) ?? true,
      showUrdu: p.getBool(_kUr) ?? true,
    );
    _loaded = true;
  }

  Future<void> setVisibility(HadithLanguageVisibility v) async {
    visibility.value = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kAr, v.showArabic);
    await p.setBool(_kEn, v.showEnglish);
    await p.setBool(_kUr, v.showUrdu);
    _loaded = true;
  }
}
