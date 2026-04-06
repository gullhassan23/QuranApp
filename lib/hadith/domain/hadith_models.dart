class HadithBookCatalogItem {
  const HadithBookCatalogItem({
    required this.slug,
    required this.englishTitle,
    this.subtitle,
  });

  final String slug;
  final String englishTitle;
  final String? subtitle;
}

class HadithChapter {
  const HadithChapter({
    required this.id,
    required this.chapterNumber,
    required this.chapterEnglish,
    this.chapterArabic,
    required this.bookSlug,
  });

  final int id;
  final String chapterNumber;
  final String chapterEnglish;
  final String? chapterArabic;
  final String bookSlug;
}

class HadithItem {
  const HadithItem({
    required this.apiId,
    required this.hadithNumber,
    required this.bookSlug,
    required this.chapterNumber,
    required this.bookName,
    required this.chapterEnglish,
    this.hadithArabic,
    this.hadithEnglish,
    this.englishNarrator,
    this.hadithUrdu,
    this.urduNarrator,
    this.status,
    this.headingEnglish,
    this.headingUrdu,
  });

  final int apiId;
  final String hadithNumber;
  final String bookSlug;
  final String chapterNumber;
  final String bookName;
  final String chapterEnglish;
  final String? hadithArabic;
  final String? hadithEnglish;
  final String? englishNarrator;
  final String? hadithUrdu;
  final String? urduNarrator;
  final String? status;
  final String? headingEnglish;
  final String? headingUrdu;

  String get bookmarkKey => '$bookSlug|$chapterNumber|$hadithNumber';

  HadithItem copyWith({
    int? apiId,
    String? hadithNumber,
    String? bookSlug,
    String? chapterNumber,
    String? bookName,
    String? chapterEnglish,
    String? hadithArabic,
    String? hadithEnglish,
    String? englishNarrator,
    String? hadithUrdu,
    String? urduNarrator,
    String? status,
    String? headingEnglish,
    String? headingUrdu,
  }) {
    return HadithItem(
      apiId: apiId ?? this.apiId,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      bookSlug: bookSlug ?? this.bookSlug,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      bookName: bookName ?? this.bookName,
      chapterEnglish: chapterEnglish ?? this.chapterEnglish,
      hadithArabic: hadithArabic ?? this.hadithArabic,
      hadithEnglish: hadithEnglish ?? this.hadithEnglish,
      englishNarrator: englishNarrator ?? this.englishNarrator,
      hadithUrdu: hadithUrdu ?? this.hadithUrdu,
      urduNarrator: urduNarrator ?? this.urduNarrator,
      status: status ?? this.status,
      headingEnglish: headingEnglish ?? this.headingEnglish,
      headingUrdu: headingUrdu ?? this.headingUrdu,
    );
  }
}

class HadithPage {
  const HadithPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  final List<HadithItem> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  bool get hasNextPage => currentPage < lastPage;
}

class HadithBookmark {
  const HadithBookmark({
    required this.bookSlug,
    required this.chapterNumber,
    required this.hadithNumber,
    required this.bookName,
    required this.chapterEnglish,
    this.snippet,
  });

  final String bookSlug;
  final String chapterNumber;
  final String hadithNumber;
  final String bookName;
  final String chapterEnglish;
  final String? snippet;

  String get key => '$bookSlug|$chapterNumber|$hadithNumber';

  Map<String, dynamic> toJson() => {
        'bookSlug': bookSlug,
        'chapterNumber': chapterNumber,
        'hadithNumber': hadithNumber,
        'bookName': bookName,
        'chapterEnglish': chapterEnglish,
        'snippet': snippet,
      };

  static HadithBookmark? fromJson(Map<String, dynamic>? m) {
    if (m == null) return null;
    final slug = m['bookSlug'] as String?;
    final ch = m['chapterNumber'] as String?;
    final num = m['hadithNumber'] as String?;
    if (slug == null || ch == null || num == null) return null;
    return HadithBookmark(
      bookSlug: slug,
      chapterNumber: ch,
      hadithNumber: num,
      bookName: m['bookName'] as String? ?? slug,
      chapterEnglish: m['chapterEnglish'] as String? ?? '',
      snippet: m['snippet'] as String?,
    );
  }
}

/// Local reading position for "Continue reading" (recents list in SharedPreferences).
class HadithReadingProgress {
  const HadithReadingProgress({
    required this.bookSlug,
    required this.bookName,
    required this.chapterNumber,
    required this.chapterEnglish,
    required this.hadithNumber,
    required this.scrollOffset,
    required this.updatedAtMs,
    this.apiId,
  });

  final String bookSlug;
  final String bookName;
  final String chapterNumber;
  final String chapterEnglish;
  final String hadithNumber;
  final double scrollOffset;
  final int updatedAtMs;
  final int? apiId;

  /// Same shape as [HadithItem.bookmarkKey] / [HadithBookmark.key].
  String get progressKey => '$bookSlug|$chapterNumber|$hadithNumber';

  Map<String, dynamic> toJson() => {
        'bookSlug': bookSlug,
        'bookName': bookName,
        'chapterNumber': chapterNumber,
        'chapterEnglish': chapterEnglish,
        'hadithNumber': hadithNumber,
        'scrollOffset': scrollOffset,
        'updatedAtMs': updatedAtMs,
        if (apiId != null) 'apiId': apiId,
      };

  static HadithReadingProgress? fromJson(Map<String, dynamic>? m) {
    if (m == null) return null;
    final slug = m['bookSlug'] as String?;
    final bookName = m['bookName'] as String?;
    final ch = m['chapterNumber'] as String?;
    final hadithNumStr = m['hadithNumber'] as String?;
    if (slug == null || bookName == null || ch == null || hadithNumStr == null) {
      return null;
    }
    final chEn = m['chapterEnglish'] as String? ?? '';
    final offsetRaw = m['scrollOffset'];
    final double offset;
    if (offsetRaw is num) {
      offset = offsetRaw.toDouble();
    } else {
      return null;
    }
    final updatedRaw = m['updatedAtMs'];
    final int updatedAt;
    if (updatedRaw is int) {
      updatedAt = updatedRaw;
    } else if (updatedRaw is num) {
      updatedAt = updatedRaw.toInt();
    } else {
      return null;
    }
    final apiRaw = m['apiId'];
    final int? apiId;
    if (apiRaw is int) {
      apiId = apiRaw;
    } else if (apiRaw is num) {
      apiId = apiRaw.toInt();
    } else {
      apiId = null;
    }
    return HadithReadingProgress(
      bookSlug: slug,
      bookName: bookName,
      chapterNumber: ch,
      chapterEnglish: chEn,
      hadithNumber: hadithNumStr,
      scrollOffset: offset.isFinite ? offset : 0,
      updatedAtMs: updatedAt,
      apiId: apiId,
    );
  }

  HadithReadingProgress copyWith({
    String? bookSlug,
    String? bookName,
    String? chapterNumber,
    String? chapterEnglish,
    String? hadithNumber,
    double? scrollOffset,
    int? updatedAtMs,
    int? apiId,
  }) {
    return HadithReadingProgress(
      bookSlug: bookSlug ?? this.bookSlug,
      bookName: bookName ?? this.bookName,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      chapterEnglish: chapterEnglish ?? this.chapterEnglish,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      apiId: apiId ?? this.apiId,
    );
  }

  /// Build from a loaded [HadithItem] and current scroll offset.
  factory HadithReadingProgress.fromItem({
    required HadithItem item,
    required double scrollOffset,
  }) {
    return HadithReadingProgress(
      bookSlug: item.bookSlug,
      bookName: item.bookName,
      chapterNumber: item.chapterNumber,
      chapterEnglish: item.chapterEnglish,
      hadithNumber: item.hadithNumber,
      scrollOffset: scrollOffset.isFinite ? scrollOffset : 0,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      apiId: item.apiId,
    );
  }
}
