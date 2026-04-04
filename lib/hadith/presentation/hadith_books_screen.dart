import 'package:app5/Global.dart';
import 'package:app5/hadith/data/hadith_api_config.dart';
import 'package:app5/hadith/data/hadith_repository.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:app5/hadith/presentation/hadith_bookmarks_screen.dart';
import 'package:app5/hadith/presentation/hadith_chapters_screen.dart';
import 'package:app5/hadith/presentation/hadith_themed_scaffold.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:app5/hadith/presentation/widgets/hadith_card.dart';
import 'package:app5/hadith/presentation/widgets/hadith_secondary_card.dart';
import 'package:app5/hadith/presentation/widgets/hadith_state_views.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithBooksScreen extends StatefulWidget {
  const HadithBooksScreen({super.key});

  @override
  State<HadithBooksScreen> createState() => _HadithBooksScreenState();
}

class _HadithBooksScreenState extends State<HadithBooksScreen> {
  final _repo = hadithRepository;
  Future<HadithItem?>? _hotdFuture;
  Future<({String slug, String chapter, String bookName, String chapterEn})?>?
      _lastReadFuture;

  @override
  void initState() {
    super.initState();
    if (HadithApiConfig.hasApiKey) {
      _hotdFuture = _repo.getHadithOfTheDay();
    }
    _lastReadFuture = _repo.loadLastRead();
  }

  void _refreshHotd() {
    if (!HadithApiConfig.hasApiKey) return;
    setState(() => _hotdFuture = _repo.getHadithOfTheDay());
  }

  @override
  Widget build(BuildContext context) {
    final tokens = HadithUiTokens.of(context);

    return HadithThemedScaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Hadith',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: textprimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            color: textprimary,
            tooltip: 'Bookmarks',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const HadithBookmarksScreen(),
                ),
              );
            },
            icon: Icon(Icons.bookmarks_outlined, color: tokens.iconSoft),
          ),
        ],
      ),
      body: !HadithApiConfig.hasApiKey
          ? const SingleChildScrollView(child: HadithApiKeyMissingView())
          : RefreshIndicator(
              color: tokens.progressColor,
              onRefresh: () async {
                _refreshHotd();
                setState(() => _lastReadFuture = _repo.loadLastRead());
                await _hotdFuture;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _hotdSection(context),
                  FutureBuilder(
                    future: _lastReadFuture,
                    builder: (context, snap) {
                      final data = snap.data;
                      if (data == null) return const SizedBox.shrink();
                      return _continueCard(context, data);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Collections',
                    // style: GoogleFonts.playfairDisplay(
                    //   fontSize: 20,
                    //   fontWeight: FontWeight.w600,
                    //   color: tokens.sectionTitle,
                    // ),
                    style: TextStyle(
                      color: textprimary,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._repo.books.map((b) => _bookTile(context, b)),
                ],
              ),
            ),
    );
  }

  Widget _hotdSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hadith of the day',
                style: TextStyle(
                  color: textprimary,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: _refreshHotd,
              icon: Icon(Icons.refresh, color: textprimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FutureBuilder<HadithItem?>(
          future: _hotdFuture,
          builder: (context, snap) {
            if (_hotdFuture == null) {
              return const SizedBox.shrink();
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const HadithLoadingView();
            }
            if (snap.hasError) {
              return HadithErrorView(
                message: snap.error.toString(),
                onRetry: _refreshHotd,
              );
            }
            final h = snap.data;
            if (h == null) {
              return const HadithEmptyView(
                message: 'Could not load a hadith right now.',
              );
            }
            return HadithCard(item: h);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _continueCard(
    BuildContext context,
    ({String slug, String chapter, String bookName, String chapterEn}) data,
  ) {
    final cs = Theme.of(context).colorScheme;
    final tokens = HadithUiTokens.of(context);
    void go() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HadithChaptersScreen(
            bookSlug: data.slug,
            bookTitle: data.bookName,
          ),
        ),
      );
    }

    final subtitle =
        '${data.bookName} · ${data.chapterEn.isNotEmpty ? data.chapterEn : 'Chapter ${data.chapter}'}';

    if (!tokens.isWarm) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Card(
          elevation: 0,
          color: tokens.cardContainerColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
            onTap: go,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.history_edu_outlined, color: cs.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue reading',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: cs.outline),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final r = BorderRadius.circular(tokens.cardBorderRadius);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.cardContainerColor,
          borderRadius: r,
          boxShadow: tokens.cardShadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: r,
            onTap: go,
            splashColor: cs.primary.withValues(alpha: 0.12),
            highlightColor: cs.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.history_edu_outlined,
                    color: cs.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue reading',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            letterSpacing: 0.2,
                            color: tokens.sectionTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            height: 1.35,
                            color: tokens.iconSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: tokens.iconSoft,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bookTile(BuildContext context, HadithBookCatalogItem b) {
    final cs = Theme.of(context).colorScheme;
    final tokens = HadithUiTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HadithSecondaryCard(
        tokens: tokens,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          title: Text(
            b.englishTitle,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: tokens.isWarm ? tokens.sectionTitle : cs.onSurface,
            ),
          ),
          subtitle: b.subtitle != null
              ? Text(
                  b.subtitle!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color:
                        tokens.isWarm ? tokens.iconSoft : cs.onSurfaceVariant,
                  ),
                )
              : null,
          trailing: Icon(Icons.chevron_right, color: tokens.iconSoft),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HadithChaptersScreen(
                  bookSlug: b.slug,
                  bookTitle: b.englishTitle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
