import 'dart:convert';

import 'package:http/http.dart' as http;

/// Maps [kHadithBookCatalog] slugs to fawazahmed0/hadith-api Urdu edition names.
/// CDN: `https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions/{edition}/{hadithNumber}.min.json`
String? hadithUrduCdnEditionForBookSlug(String bookSlug) {
  switch (bookSlug) {
    case 'sahih-bukhari':
      return 'urd-bukhari';
    case 'sahih-muslim':
      return 'urd-muslim';
    case 'al-tirmidhi':
      return 'urd-tirmidhi';
    case 'abu-dawood':
      return 'urd-abudawud';
    case 'ibn-e-majah':
      return 'urd-ibnmajah';
    case 'sunan-nasai':
      return 'urd-nasai';
    default:
      return null;
  }
}

/// Fetches Urdu body text when HadithAPI omits [hadithUrdu] for a collection.
class HadithUrduCdnClient {
  HadithUrduCdnClient({http.Client? httpClient})
      : _client = httpClient ?? http.Client();

  final http.Client _client;

  static final HadithUrduCdnClient instance = HadithUrduCdnClient();

  static const _base =
      'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1/editions';

  final Map<String, String> _cache = {};

  /// Returns Urdu `text` for [hadithNumber] or null if unavailable / request fails.
  Future<String?> fetchUrduBody({
    required String bookSlug,
    required String hadithNumber,
  }) async {
    final edition = hadithUrduCdnEditionForBookSlug(bookSlug);
    if (edition == null) return null;
    final n = hadithNumber.trim();
    if (n.isEmpty) return null;
    final cacheKey = '$edition|$n';
    final hit = _cache[cacheKey];
    if (hit != null) return hit.isEmpty ? null : hit;

    final uri = Uri.parse('$_base/$edition/$n.min.json');
    try {
      final res = await _client.get(uri);
      if (res.statusCode != 200) {
        _cache[cacheKey] = '';
        return null;
      }
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final list = map['hadiths'];
      if (list is! List) {
        _cache[cacheKey] = '';
        return null;
      }
      final want = int.tryParse(n);
      for (final e in list) {
        if (e is! Map<String, dynamic>) continue;
        final hn = e['hadithnumber'];
        final match = hn is int
            ? hn == want
            : hn is String && int.tryParse(hn) == want;
        if (match) {
          final text = e['text']?.toString();
          if (text != null && text.trim().isNotEmpty) {
            _cache[cacheKey] = text;
            return text;
          }
        }
      }
      _cache[cacheKey] = '';
      return null;
    } catch (_) {
      _cache[cacheKey] = '';
      return null;
    }
  }
}
