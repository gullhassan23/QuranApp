/// HadithAPI authentication.
/// Optional override: `flutter run --dart-define=HADITH_API_KEY=other_key`
/// (embedded key is used when the define is omitted).
class HadithApiConfig {
  HadithApiConfig._();

  static const String _embeddedApiKey =
      r'$2y$10$ezXENQCoTvRjWPzwC6zTbuSDOC6QpTsuWPXWiruZ729H1g1PpNXOS';
  static const String _envApiKey = String.fromEnvironment('HADITH_API_KEY');

  static String get apiKey =>
      _envApiKey.isNotEmpty ? _envApiKey : _embeddedApiKey;

  static const String host = 'hadithapi.com';
  static const String chaptersPathPrefix = '/api/';
  static const String hadithsPath = '/api/hadiths/';

  static bool get hasApiKey => apiKey.isNotEmpty;
}
