import 'dart:convert';

import 'package:app5/hadith/data/hadith_api_config.dart';
import 'package:app5/hadith/data/hadith_dto.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:http/http.dart' as http;

class HadithApiException implements Exception {
  HadithApiException(this.message, [this.statusCode]);
  final String message;
  final int? statusCode;

  @override
  String toString() => 'HadithApiException: $message';
}

class HadithApiClient {
  HadithApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  void _ensureKey() {
    if (!HadithApiConfig.hasApiKey) {
      throw HadithApiException(
        'Missing HADITH_API_KEY. Run with --dart-define=HADITH_API_KEY=your_key',
      );
    }
  }

  Future<List<HadithChapter>> fetchChapters(String bookSlug) async {
    _ensureKey();
    final uri = Uri.https(
      HadithApiConfig.host,
      '${HadithApiConfig.chaptersPathPrefix}$bookSlug/chapters',
      {'apiKey': HadithApiConfig.apiKey},
    );
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw HadithApiException('Chapters request failed', res.statusCode);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final status = map['status'];
    if (status is int && status != 200) {
      throw HadithApiException(map['message']?.toString() ?? 'API error', status);
    }
    return HadithDto.chaptersFromResponse(map);
  }

  /// [page] is 1-based (Laravel-style pagination).
  Future<HadithPage> fetchHadiths({
    required String bookSlug,
    required String chapterNumber,
    int page = 1,
    int paginate = 20,
    String? hadithEnglish,
    String? hadithArabic,
    String? hadithUrdu,
    String? status,
    String? hadithNumber,
  }) async {
    _ensureKey();
    final q = <String, String>{
      'apiKey': HadithApiConfig.apiKey,
      'book': bookSlug,
      'chapter': chapterNumber,
      'paginate': '$paginate',
      'page': '$page',
    };
    if (hadithEnglish != null && hadithEnglish.trim().isNotEmpty) {
      q['hadithEnglish'] = hadithEnglish.trim();
    }
    if (hadithArabic != null && hadithArabic.trim().isNotEmpty) {
      q['hadithArabic'] = hadithArabic.trim();
    }
    if (hadithUrdu != null && hadithUrdu.trim().isNotEmpty) {
      q['hadithUrdu'] = hadithUrdu.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      q['status'] = status.trim();
    }
    if (hadithNumber != null && hadithNumber.trim().isNotEmpty) {
      q['hadithNumber'] = hadithNumber.trim();
    }
    final uri = Uri.https(HadithApiConfig.host, HadithApiConfig.hadithsPath, q);
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw HadithApiException('Hadiths request failed', res.statusCode);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final st = map['status'];
    if (st is int && st != 200) {
      throw HadithApiException(map['message']?.toString() ?? 'API error', st);
    }
    return HadithDto.hadithPageFromResponse(map);
  }
}
