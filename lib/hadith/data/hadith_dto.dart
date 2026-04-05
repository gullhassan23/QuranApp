import 'package:app5/hadith/domain/hadith_models.dart';

class HadithDto {
  static List<HadithChapter> chaptersFromResponse(Map<String, dynamic> json) {
    final list = json['chapters'];
    if (list is! List) return [];
    return list
        .map((e) {
          if (e is! Map<String, dynamic>) return null;
          final id = e['id'];
          final num = e['chapterNumber']?.toString() ?? '';
          final en = e['chapterEnglish']?.toString() ?? '';
          final ar = e['chapterArabic']?.toString();
          final slug = e['bookSlug']?.toString() ?? '';
          if (id is! int) return null;
          return HadithChapter(
            id: id,
            chapterNumber: num,
            chapterEnglish: en,
            chapterArabic: ar,
            bookSlug: slug,
          );
        })
        .whereType<HadithChapter>()
        .toList();
  }

  static HadithPage hadithPageFromResponse(Map<String, dynamic> json) {
    final wrap = json['hadiths'];
    if (wrap is! Map<String, dynamic>) {
      return const HadithPage(
        items: [],
        currentPage: 1,
        lastPage: 1,
        total: 0,
        perPage: 25,
      );
    }
    final data = wrap['data'];
    final items = <HadithItem>[];
    if (data is List) {
      for (final e in data) {
        if (e is Map<String, dynamic>) {
          final h = _hadithItemFromMap(e);
          if (h != null) items.add(h);
        }
      }
    }
    final current = _parseInt(wrap['current_page'], 1);
    final last = _parseInt(wrap['last_page'], 1);
    final total = _parseInt(wrap['total'], items.length);
    final per = _parseInt(wrap['per_page'], 25);
    return HadithPage(
      items: items,
      currentPage: current,
      lastPage: last,
      total: total,
      perPage: per,
    );
  }

  static HadithItem? _hadithItemFromMap(Map<String, dynamic> e) {
    final id = e['id'];
    if (id is! int) return null;
    final book = e['book'];
    String bookName = '';
    if (book is Map<String, dynamic>) {
      bookName = book['bookName']?.toString() ?? '';
    }
    final chapter = e['chapter'];
    String chapterEnglish = '';
    String chapterNumber = e['chapterId']?.toString() ?? '';
    if (chapter is Map<String, dynamic>) {
      chapterEnglish = chapter['chapterEnglish']?.toString() ?? '';
      chapterNumber = chapter['chapterNumber']?.toString() ?? chapterNumber;
    }
    return HadithItem(
      apiId: id,
      hadithNumber: e['hadithNumber']?.toString() ?? '',
      bookSlug: e['bookSlug']?.toString() ?? '',
      chapterNumber: chapterNumber,
      bookName: bookName,
      chapterEnglish: chapterEnglish,
      hadithArabic: e['hadithArabic']?.toString(),
      hadithEnglish: e['hadithEnglish']?.toString(),
      englishNarrator: e['englishNarrator']?.toString(),
      hadithUrdu: e['hadithUrdu']?.toString(),
      urduNarrator: e['urduNarrator']?.toString(),
      status: e['status']?.toString(),
      headingEnglish: e['headingEnglish']?.toString(),
      headingUrdu: e['headingUrdu']?.toString(),
    );
  }

  static int _parseInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }
}
