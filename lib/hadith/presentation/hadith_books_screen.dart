import 'package:app5/Global.dart';
import 'package:app5/hadith/data/hadith_api_config.dart';
import 'package:app5/hadith/data/hadith_display_prefs.dart';
import 'package:app5/hadith/data/hadith_repository.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:app5/hadith/presentation/hadith_bookmarks_screen.dart';
import 'package:app5/hadith/presentation/hadith_chapters_screen.dart';
import 'package:app5/hadith/presentation/hadith_themed_scaffold.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:app5/hadith/presentation/widgets/hadith_card.dart';
import 'package:app5/hadith/presentation/widgets/hadith_secondary_card.dart';
import 'package:app5/hadith/presentation/widgets/hadith_language_settings_sheet.dart';
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
  Future<List<HadithReadingProgress>>? _recentsFuture;

  @override
  void initState() {
    super.initState();
    HadithDisplayPrefs.instance.ensureLoaded();
    if (HadithApiConfig.hasApiKey) {
      _hotdFuture = _repo.getHadithOfTheDay();
    }
    _recentsFuture = _repo.loadContinueReadingRecents();
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
            tooltip: 'Languages',
            onPressed: () => showHadithLanguageSettingsSheet(context),
            icon: Icon(Icons.translate_outlined, color: textprimary),
          ),
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
            icon: Icon(Icons.bookmarks_outlined, color: textprimary),
          ),
        ],
      ),
      body: !HadithApiConfig.hasApiKey
          ? const SingleChildScrollView(child: HadithApiKeyMissingView())
          : RefreshIndicator(
              color: tokens.progressColor,
              onRefresh: () async {
                _refreshHotd();
                setState(
                  () => _recentsFuture = _repo.loadContinueReadingRecents(),
                );
                await _hotdFuture;
                await _recentsFuture;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _hotdSection(context),
                  _continueReadingSection(context),
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
            return ValueListenableBuilder<HadithLanguageVisibility>(
              valueListenable: HadithDisplayPrefs.instance.visibility,
              builder: (_, vis, __) => HadithCard(item: h, visibility: vis),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _continueReadingSection(BuildContext context) {
    return FutureBuilder<List<HadithReadingProgress>>(
      future: _recentsFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final list = snap.data ?? [];
        if (list.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Continue reading',
              style: TextStyle(
                color: textprimary,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _continueProgressCard(context, list.first, compact: false),
            ...list.skip(1).map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _continueProgressCard(context, p, compact: true),
                  ),
                ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  String _progressSubtitle(HadithReadingProgress p) {
    final ch = p.chapterEnglish.isNotEmpty
        ? p.chapterEnglish
        : 'Chapter ${p.chapterNumber}';
    return '${p.bookName} · $ch · #${p.hadithNumber}';
  }

  void _openContinue(HadithReadingProgress p) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HadithChaptersScreen(
          bookSlug: p.bookSlug,
          bookTitle: p.bookName,
          resumeIntent: p,
        ),
      ),
    );
  }

  Widget _continueProgressCard(
    BuildContext context,
    HadithReadingProgress p, {
    required bool compact,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tokens = HadithUiTokens.of(context);
    final subtitle = _progressSubtitle(p);

    if (!tokens.isWarm) {
      return Card(
        elevation: 0,
        color: tokens.cardContainerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.cardBorderRadius),
          onTap: () => _openContinue(p),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Row(
              children: [
                Icon(
                  Icons.history_edu_outlined,
                  color: cs.primary,
                  size: compact ? 26 : 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: compact ? 12.5 : 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: cs.outline),
              ],
            ),
          ),
        ),
      );
    }

    final r = BorderRadius.circular(tokens.cardBorderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.cardContainerColor,
        borderRadius: r,
        boxShadow: tokens.cardShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: r,
          onTap: () => _openContinue(p),
          splashColor: cs.primary.withValues(alpha: 0.12),
          highlightColor: cs.primary.withValues(alpha: 0.06),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 18,
              vertical: compact ? 12 : 16,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history_edu_outlined,
                  color: cs.primary,
                  size: compact ? 24 : 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: compact ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: compact ? 12 : 12.5,
                      height: 1.35,
                      color: tokens.iconSoft,
                    ),
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
