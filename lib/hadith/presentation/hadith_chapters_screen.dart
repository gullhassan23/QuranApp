import 'package:app5/Global.dart';
import 'package:app5/hadith/data/hadith_repository.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:app5/hadith/presentation/hadith_list_screen.dart';
import 'package:app5/hadith/presentation/hadith_themed_scaffold.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:app5/hadith/presentation/widgets/hadith_secondary_card.dart';
import 'package:app5/hadith/presentation/widgets/hadith_state_views.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithChaptersScreen extends StatefulWidget {
  const HadithChaptersScreen({
    super.key,
    required this.bookSlug,
    required this.bookTitle,
  });

  final String bookSlug;
  final String bookTitle;

  @override
  State<HadithChaptersScreen> createState() => _HadithChaptersScreenState();
}

class _HadithChaptersScreenState extends State<HadithChaptersScreen> {
  final _repo = hadithRepository;
  late Future<List<HadithChapter>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getChapters(widget.bookSlug);
  }

  void _retry() {
    setState(() => _future = _repo.getChapters(widget.bookSlug));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = HadithUiTokens.of(context);
    return HadithThemedScaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.brown),
        backgroundColor: backgroundColor,
        title: Text(
          widget.bookTitle,
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w600,
              // color: tokens.appBarForeground,
              color: textprimary),
        ),
      ),
      body: FutureBuilder<List<HadithChapter>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const HadithLoadingView();
          }
          if (snap.hasError) {
            return HadithErrorView(
              message: snap.error.toString(),
              onRetry: _retry,
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const HadithEmptyView(message: 'No chapters found.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final c = list[i];
              return HadithSecondaryCard(
                tokens: tokens,
                child: ListTile(
                  title: Text(
                    c.chapterEnglish,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: tokens.isWarm ? tokens.sectionTitle : cs.onSurface,
                    ),
                  ),
                  subtitle:
                      c.chapterArabic != null && c.chapterArabic!.isNotEmpty
                          ? Text(
                              c.chapterArabic!,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.amiri(
                                fontSize: 16,
                                color: tokens.isWarm
                                    ? tokens.iconSoft
                                    : cs.onSurfaceVariant,
                              ),
                            )
                          : Text(
                              'Chapter ${c.chapterNumber}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: tokens.isWarm
                                    ? tokens.iconSoft
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                  trailing: Icon(Icons.chevron_right, color: tokens.iconSoft),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => HadithListScreen(
                          bookSlug: widget.bookSlug,
                          bookTitle: widget.bookTitle,
                          chapter: c,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
