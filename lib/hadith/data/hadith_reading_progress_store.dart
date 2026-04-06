import 'dart:convert';

import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists recent Hadith reading positions (SharedPreferences only).
class HadithReadingProgressStore {
  HadithReadingProgressStore._();

  static final HadithReadingProgressStore instance = HadithReadingProgressStore._();

  static const _prefsKey = 'hadith_continue_reading_v1';
  static const int maxRecents = 5;

  Future<List<HadithReadingProgress>> loadRecents() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) return [];
      final out = <HadithReadingProgress>[];
      for (final e in decoded) {
        if (e is! Map) continue;
        final item = HadithReadingProgress.fromJson(
          Map<String, dynamic>.from(e),
        );
        if (item != null) out.add(item);
      }
      out.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
      return out.length > maxRecents ? out.sublist(0, maxRecents) : out;
    } catch (_) {
      return [];
    }
  }

  Future<void> upsertProgress(HadithReadingProgress progress) async {
    try {
      final list = await loadRecents();
      final next = <HadithReadingProgress>[
        progress.copyWith(updatedAtMs: DateTime.now().millisecondsSinceEpoch),
        ...list.where((e) => e.progressKey != progress.progressKey),
      ];
      final trimmed =
          next.length > maxRecents ? next.sublist(0, maxRecents) : next;
      final p = await SharedPreferences.getInstance();
      await p.setString(
        _prefsKey,
        jsonEncode(trimmed.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      // Ignore persistence failures; UI should not crash.
    }
  }

  Future<void> removeProgress(String progressKey) async {
    try {
      final list =
          (await loadRecents()).where((e) => e.progressKey != progressKey).toList();
      final p = await SharedPreferences.getInstance();
      if (list.isEmpty) {
        await p.remove(_prefsKey);
      } else {
        await p.setString(
          _prefsKey,
          jsonEncode(list.map((e) => e.toJson()).toList()),
        );
      }
    } catch (_) {}
  }

  Future<void> clearAll() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_prefsKey);
    } catch (_) {}
  }
}
