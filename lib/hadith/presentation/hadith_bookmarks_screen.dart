import 'package:app5/hadith/data/hadith_display_prefs.dart';
import 'package:app5/hadith/data/hadith_repository.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:app5/hadith/presentation/hadith_detail_screen.dart';
import 'package:app5/hadith/presentation/hadith_themed_scaffold.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:app5/hadith/presentation/widgets/hadith_language_settings_sheet.dart';
import 'package:app5/hadith/presentation/widgets/hadith_secondary_card.dart';
import 'package:app5/hadith/presentation/widgets/hadith_state_views.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithBookmarksScreen extends StatefulWidget {
  const HadithBookmarksScreen({super.key});

  @override
  State<HadithBookmarksScreen> createState() => _HadithBookmarksScreenState();
}

class _HadithBookmarksScreenState extends State<HadithBookmarksScreen> {
  final _repo = hadithRepository;
  late Future<List<HadithBookmark>> _future;

  @override
  void initState() {
    super.initState();
    HadithDisplayPrefs.instance.ensureLoaded();
    _future = _repo.loadBookmarks();
  }

  void _reload() {
    setState(() => _future = _repo.loadBookmarks());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = HadithUiTokens.of(context);
    return HadithThemedScaffold(
      appBar: AppBar(
        title: Text(
          'Saved hadith',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            color: tokens.appBarForeground,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Languages',
            icon: Icon(Icons.translate_outlined, color: tokens.iconSoft),
            onPressed: () => showHadithLanguageSettingsSheet(context),
          ),
        ],
      ),
      body: FutureBuilder<List<HadithBookmark>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const HadithLoadingView();
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const HadithEmptyView(
              message: 'No bookmarks yet. Tap the bookmark icon on a hadith.',
              icon: Icons.bookmark_border,
            );
          }
          return RefreshIndicator(
            color: tokens.progressColor,
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final b = list[i];
                return HadithSecondaryCard(
                  tokens: tokens,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      '${b.bookName} · #${b.hadithNumber}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: tokens.isWarm
                            ? tokens.sectionTitle
                            : cs.onSurface,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        b.snippet ?? b.chapterEnglish,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.4,
                          color: tokens.isWarm
                              ? tokens.iconSoft
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: cs.error),
                      onPressed: () async {
                        await _repo.removeBookmark(b.key);
                        _reload();
                      },
                    ),
                    onTap: () async {
                      final item = await _repo.fetchHadithForBookmark(b);
                      if (!context.mounted) return;
                      if (item == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Could not load this hadith.',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        );
                        return;
                      }
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => HadithDetailScreen(item: item),
                        ),
                      );
                      _reload();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
