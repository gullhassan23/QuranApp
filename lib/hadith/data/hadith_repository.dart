import 'dart:convert';

import 'package:app5/hadith/data/hadith_api_config.dart';
import 'package:app5/hadith/data/hadith_api_client.dart';
import 'package:app5/hadith/data/hadith_catalog.dart';
import 'package:app5/hadith/data/hadith_reading_progress_store.dart';
import 'package:app5/hadith/data/hadith_urdu_cdn_client.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CacheEntry<T> {
  _CacheEntry(this.value, this.expiresAt);
  final T value;
  final DateTime expiresAt;

  bool get valid => DateTime.now().isBefore(expiresAt);
}

class HadithRepository {
  HadithRepository({
    HadithApiClient? apiClient,
    Duration cacheTtl = const Duration(minutes: 20),
  })  : _api = apiClient ?? HadithApiClient(),
        _ttl = cacheTtl;

  final HadithApiClient _api;
  final Duration _ttl;

  final Map<String, _CacheEntry<List<HadithChapter>>> _chaptersCache = {};
  final Map<String, _CacheEntry<HadithPage>> _hadithPageCache = {};

  static const _prefsBookmarks = 'hadith_bookmarks_json';
  static const _prefsHotdDate = 'hadith_hotd_date';
  static const _prefsHotdJson = 'hadith_hotd_json';
  static const _prefsLastBook = 'hadith_last_book_slug';
  static const _prefsLastChapter = 'hadith_last_chapter_number';
  static const _prefsLastBookName = 'hadith_last_book_name';
  static const _prefsLastChapterEn = 'hadith_last_chapter_en';

  List<HadithBookCatalogItem> get books => kHadithBookCatalog;

  String _chaptersKey(String bookSlug) => 'chapters|$bookSlug';

  String _hadithKey(
    String book,
    String chapter,
    int page,
    int paginate,
    String? en,
    String? ar,
    String? ur,
    String? status,
    String? hadithNumber,
  ) =>
      'hadith|$book|$chapter|$page|$paginate|${en ?? ''}|${ar ?? ''}|${ur ?? ''}|${status ?? ''}|${hadithNumber ?? ''}';

  Future<List<HadithChapter>> getChapters(String bookSlug) async {
    final key = _chaptersKey(bookSlug);
    final hit = _chaptersCache[key];
    if (hit != null && hit.valid) return hit.value;
    final list = await _api.fetchChapters(bookSlug);
    _chaptersCache[key] = _CacheEntry(list, DateTime.now().add(_ttl));
    return list;
  }

  Future<HadithPage> getHadithPage({
    required String bookSlug,
    required String chapterNumber,
    int page = 1,
    int paginate = 20,
    String? hadithEnglish,
    String? hadithArabic,
    String? hadithUrdu,
    String? status,
    String? hadithNumber,
    bool bypassCache = false,
  }) async {
    final key = _hadithKey(
      bookSlug,
      chapterNumber,
      page,
      paginate,
      hadithEnglish,
      hadithArabic,
      hadithUrdu,
      status,
      hadithNumber,
    );
    if (!bypassCache) {
      final hit = _hadithPageCache[key];
      if (hit != null && hit.valid) return hit.value;
    }
    final result = await _api.fetchHadiths(
      bookSlug: bookSlug,
      chapterNumber: chapterNumber,
      page: page,
      paginate: paginate,
      hadithEnglish: hadithEnglish,
      hadithArabic: hadithArabic,
      hadithUrdu: hadithUrdu,
      status: status,
      hadithNumber: hadithNumber,
    );
    _hadithPageCache[key] = _CacheEntry(result, DateTime.now().add(_ttl));
    return result;
  }

  Future<HadithItem?> fetchHadithForBookmark(HadithBookmark b) async {
    final page = await getHadithPage(
      bookSlug: b.bookSlug,
      chapterNumber: b.chapterNumber,
      page: 1,
      paginate: 10,
      hadithNumber: b.hadithNumber,
      bypassCache: true,
    );
    for (final h in page.items) {
      if (h.hadithNumber == b.hadithNumber) return h;
    }
    return page.items.isNotEmpty ? page.items.first : null;
  }

  /// Exact match only (no fallback to another hadith) — for resume / continue reading.
  Future<HadithItem?> fetchHadithForReadingProgress(
    HadithReadingProgress p,
  ) async {
    final page = await getHadithPage(
      bookSlug: p.bookSlug,
      chapterNumber: p.chapterNumber,
      page: 1,
      paginate: 10,
      hadithNumber: p.hadithNumber,
      bypassCache: true,
    );
    for (final h in page.items) {
      if (h.hadithNumber == p.hadithNumber) return h;
    }
    return null;
  }

  Future<List<HadithReadingProgress>> loadContinueReadingRecents() =>
      HadithReadingProgressStore.instance.loadRecents();

  Future<void> saveContinueReadingProgress(HadithReadingProgress p) =>
      HadithReadingProgressStore.instance.upsertProgress(p);

  Future<void> removeContinueReadingProgress(String progressKey) =>
      HadithReadingProgressStore.instance.removeProgress(progressKey);

  Future<void> clearContinueReadingProgress() =>
      HadithReadingProgressStore.instance.clearAll();

  /// Fills [hadithUrdu] from CDN when the API left it empty (supported books only).
  Future<HadithItem> enrichWithCdnUrduIfNeeded(HadithItem item) async {
    if ((item.hadithUrdu ?? '').trim().isNotEmpty) return item;
    final text = await HadithUrduCdnClient.instance.fetchUrduBody(
      bookSlug: item.bookSlug,
      hadithNumber: item.hadithNumber,
    );
    if (text == null || text.trim().isEmpty) return item;
    return item.copyWith(hadithUrdu: text.trim());
  }

  Future<void> saveLastRead({
    required String bookSlug,
    required String chapterNumber,
    required String bookName,
    required String chapterEnglish,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsLastBook, bookSlug);
    await p.setString(_prefsLastChapter, chapterNumber);
    await p.setString(_prefsLastBookName, bookName);
    await p.setString(_prefsLastChapterEn, chapterEnglish);
  }

  Future<({String slug, String chapter, String bookName, String chapterEn})?>
      loadLastRead() async {
    final p = await SharedPreferences.getInstance();
    final slug = p.getString(_prefsLastBook);
    final ch = p.getString(_prefsLastChapter);
    if (slug == null || ch == null) return null;
    return (
      slug: slug,
      chapter: ch,
      bookName: p.getString(_prefsLastBookName) ?? slug,
      chapterEn: p.getString(_prefsLastChapterEn) ?? '',
    );
  }

  Future<List<HadithBookmark>> loadBookmarks() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_prefsBookmarks);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => HadithBookmark.fromJson(e as Map<String, dynamic>))
          .whereType<HadithBookmark>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveBookmarks(List<HadithBookmark> list) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      _prefsBookmarks,
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  Future<bool> isBookmarked(String key) async {
    final all = await loadBookmarks();
    return all.any((b) => b.key == key);
  }

  Future<void> toggleBookmark(HadithBookmark bookmark) async {
    final all = await loadBookmarks();
    final i = all.indexWhere((b) => b.key == bookmark.key);
    if (i >= 0) {
      all.removeAt(i);
    } else {
      all.insert(0, bookmark);
    }
    await _saveBookmarks(all);
  }

  Future<void> removeBookmark(String key) async {
    final all = await loadBookmarks();
    all.removeWhere((b) => b.key == key);
    await _saveBookmarks(all);
  }

  /// Deterministic hadith-of-the-day; caches per calendar day (local).
  Future<HadithItem?> getHadithOfTheDay() async {
    final p = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = p.getString(_prefsHotdDate);
    final savedJson = p.getString(_prefsHotdJson);
    if (savedDate == today && savedJson != null && savedJson.isNotEmpty) {
      try {
        final map = jsonDecode(savedJson) as Map<String, dynamic>;
        return _itemFromHotdCache(map);
      } catch (_) {}
    }
    final item = await _computeHadithOfTheDay();
    if (item != null) {
      await p.setString(_prefsHotdDate, today);
      await p.setString(_prefsHotdJson, jsonEncode(_itemToHotdCache(item)));
    }
    return item;
  }

  String _todayString() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _itemToHotdCache(HadithItem h) => {
        'apiId': h.apiId,
        'hadithNumber': h.hadithNumber,
        'bookSlug': h.bookSlug,
        'chapterNumber': h.chapterNumber,
        'bookName': h.bookName,
        'chapterEnglish': h.chapterEnglish,
        'hadithArabic': h.hadithArabic,
        'hadithEnglish': h.hadithEnglish,
        'englishNarrator': h.englishNarrator,
        'hadithUrdu': h.hadithUrdu,
        'urduNarrator': h.urduNarrator,
        'status': h.status,
        'headingEnglish': h.headingEnglish,
        'headingUrdu': h.headingUrdu,
      };

  HadithItem? _itemFromHotdCache(Map<String, dynamic> m) {
    final id = m['apiId'];
    if (id is! int) return null;
    return HadithItem(
      apiId: id,
      hadithNumber: m['hadithNumber']?.toString() ?? '',
      bookSlug: m['bookSlug']?.toString() ?? '',
      chapterNumber: m['chapterNumber']?.toString() ?? '',
      bookName: m['bookName']?.toString() ?? '',
      chapterEnglish: m['chapterEnglish']?.toString() ?? '',
      hadithArabic: m['hadithArabic']?.toString(),
      hadithEnglish: m['hadithEnglish']?.toString(),
      englishNarrator: m['englishNarrator']?.toString(),
      hadithUrdu: m['hadithUrdu']?.toString(),
      urduNarrator: m['urduNarrator']?.toString(),
      status: m['status']?.toString(),
      headingEnglish: m['headingEnglish']?.toString(),
      headingUrdu: m['headingUrdu']?.toString(),
    );
  }

  Future<HadithItem?> _computeHadithOfTheDay() async {
    if (!HadithApiConfig.hasApiKey) return null;
    final seed = _todayString().hashCode.abs();
    final books = kHadithBookCatalog;
    if (books.isEmpty) return null;
    final book = books[seed % books.length];
    List<HadithChapter> chapters;
    try {
      chapters = await getChapters(book.slug);
    } catch (_) {
      return null;
    }
    if (chapters.isEmpty) return null;
    final ch = chapters[(seed >> 3) % chapters.length];
    HadithPage page;
    try {
      page = await getHadithPage(
        bookSlug: book.slug,
        chapterNumber: ch.chapterNumber,
        page: 1,
        paginate: 25,
        bypassCache: true,
      );
    } catch (_) {
      return null;
    }
    if (page.items.isEmpty) return null;
    return page.items[(seed >> 7) % page.items.length];
  }
}

/// Shared instance so chapter/hadith caches and bookmarks stay consistent.
final HadithRepository hadithRepository = HadithRepository();
