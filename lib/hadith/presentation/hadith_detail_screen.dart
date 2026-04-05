import 'package:app5/Global.dart';
import 'package:app5/hadith/data/hadith_display_prefs.dart';
import 'package:app5/hadith/data/hadith_repository.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:app5/hadith/presentation/hadith_themed_scaffold.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:app5/hadith/presentation/widgets/hadith_card.dart';
import 'package:app5/hadith/presentation/widgets/hadith_language_settings_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class HadithDetailScreen extends StatefulWidget {
  const HadithDetailScreen({super.key, required this.item});

  final HadithItem item;

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  final _repo = hadithRepository;
  late HadithItem _item;
  bool _bookmarked = false;
  double _arabicSize = 22;
  double _urduSize = 17;
  bool _enrichingUrdu = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    HadithDisplayPrefs.instance.ensureLoaded();
    _syncBookmark();
    _enrichUrduIfNeeded();
  }

  Future<void> _enrichUrduIfNeeded() async {
    if ((_item.hadithUrdu ?? '').trim().isNotEmpty) return;
    setState(() => _enrichingUrdu = true);
    final enriched = await _repo.enrichWithCdnUrduIfNeeded(_item);
    if (!mounted) return;
    setState(() {
      _item = enriched;
      _enrichingUrdu = false;
    });
  }

  Future<void> _syncBookmark() async {
    final b = await _repo.isBookmarked(_item.bookmarkKey);
    if (mounted) setState(() => _bookmarked = b);
  }

  String _shareText() {
    final vis = HadithDisplayPrefs.instance.visibility.value;
    final buf = StringBuffer();
    buf.writeln(_item.bookName);
    buf.writeln('${_item.chapterEnglish} · #${_item.hadithNumber}');
    if (_item.status != null) buf.writeln(_item.status);
    buf.writeln();
    if (vis.showEnglish &&
        _item.headingEnglish != null &&
        _item.headingEnglish!.trim().isNotEmpty) {
      buf.writeln(_item.headingEnglish);
      buf.writeln();
    }
    if (vis.showUrdu &&
        _item.headingUrdu != null &&
        _item.headingUrdu!.trim().isNotEmpty) {
      buf.writeln(_item.headingUrdu);
      buf.writeln();
    }
    if (vis.showArabic && _item.hadithArabic != null) {
      buf.writeln(_item.hadithArabic);
      buf.writeln();
    }
    if (vis.showEnglish &&
        _item.englishNarrator != null &&
        _item.englishNarrator!.trim().isNotEmpty) {
      buf.writeln(_item.englishNarrator);
    }
    if (vis.showEnglish && _item.hadithEnglish != null) {
      buf.writeln(_item.hadithEnglish);
      buf.writeln();
    }
    if (vis.showUrdu &&
        _item.urduNarrator != null &&
        _item.urduNarrator!.trim().isNotEmpty) {
      buf.writeln(_item.urduNarrator);
    }
    if (vis.showUrdu && _item.hadithUrdu != null) {
      buf.writeln(_item.hadithUrdu);
    }
    return buf.toString().trim();
  }

  Future<void> _toggleBookmark() async {
    final wasBookmarked = _bookmarked;
    final snippet = _item.hadithEnglish ??
        _item.hadithUrdu ??
        _item.hadithArabic ??
        _item.englishNarrator;
    await _repo.toggleBookmark(
      HadithBookmark(
        bookSlug: _item.bookSlug,
        chapterNumber: _item.chapterNumber,
        hadithNumber: _item.hadithNumber,
        bookName: _item.bookName,
        chapterEnglish: _item.chapterEnglish,
        snippet: snippet != null && snippet.length > 160
            ? '${snippet.substring(0, 160)}…'
            : snippet,
      ),
    );
    await _syncBookmark();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasBookmarked ? 'Removed from bookmarks' : 'Saved to bookmarks',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = HadithUiTokens.of(context);
    return HadithThemedScaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.brown),
        backgroundColor: backgroundColor,
        title: Text(
          '#${_item.hadithNumber}',
          style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w600,
              // color: tokens.appBarForeground,
              color: textprimary),
        ),
        actions: [
          IconButton(
            tooltip: 'Languages',
            icon: Icon(Icons.translate_outlined, color: textprimary),
            onPressed: () => showHadithLanguageSettingsSheet(context),
          ),
          IconButton(
            tooltip: 'Text size',
            icon: Icon(
              Icons.text_fields,
              color: textprimary,
            ),
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Arabic size',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Slider(
                        value: _arabicSize,
                        min: 16,
                        max: 32,
                        divisions: 16,
                        label: _arabicSize.round().toString(),
                        onChanged: (v) => setState(() => _arabicSize = v),
                      ),
                      Text(
                        'Urdu size',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Slider(
                        value: _urduSize,
                        min: 14,
                        max: 26,
                        divisions: 12,
                        label: _urduSize.round().toString(),
                        onChanged: (v) => setState(() => _urduSize = v),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Copy',
            icon: Icon(Icons.copy_outlined, color: textprimary),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _shareText()));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copied', style: GoogleFonts.poppins()),
                  ),
                );
              }
            },
          ),
          IconButton(
            tooltip: 'Share',
            icon: Icon(Icons.share_outlined, color: textprimary),
            onPressed: () => Share.share(_shareText()),
          ),
          IconButton(
            tooltip: 'Bookmark',
            onPressed: _toggleBookmark,
            icon: Icon(
              _bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: textprimary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_enrichingUrdu)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tokens.progressColor,
                    ),
                  ),
                ),
              ),
            ValueListenableBuilder<HadithLanguageVisibility>(
              valueListenable: HadithDisplayPrefs.instance.visibility,
              builder: (context, vis, _) {
                return HadithCard(
                  item: _item,
                  trailing: null,
                  arabicFontSize: _arabicSize,
                  urduFontSize: _urduSize,
                  visibility: vis,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
