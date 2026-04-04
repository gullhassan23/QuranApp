import 'package:app5/hadith/data/hadith_repository.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:app5/hadith/presentation/hadith_themed_scaffold.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:app5/hadith/presentation/widgets/hadith_card.dart';
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
  bool _bookmarked = false;
  double _arabicSize = 22;

  @override
  void initState() {
    super.initState();
    _syncBookmark();
  }

  Future<void> _syncBookmark() async {
    final b = await _repo.isBookmarked(widget.item.bookmarkKey);
    if (mounted) setState(() => _bookmarked = b);
  }

  String _shareText() {
    final buf = StringBuffer();
    buf.writeln(widget.item.bookName);
    buf.writeln(
        '${widget.item.chapterEnglish} · #${widget.item.hadithNumber}');
    if (widget.item.status != null) buf.writeln(widget.item.status);
    buf.writeln();
    if (widget.item.hadithArabic != null) {
      buf.writeln(widget.item.hadithArabic);
      buf.writeln();
    }
    if (widget.item.hadithEnglish != null) {
      buf.writeln(widget.item.hadithEnglish);
    }
    return buf.toString();
  }

  Future<void> _toggleBookmark() async {
    final wasBookmarked = _bookmarked;
    final snippet = widget.item.hadithEnglish ??
        widget.item.hadithArabic ??
        widget.item.englishNarrator;
    await _repo.toggleBookmark(
      HadithBookmark(
        bookSlug: widget.item.bookSlug,
        chapterNumber: widget.item.chapterNumber,
        hadithNumber: widget.item.hadithNumber,
        bookName: widget.item.bookName,
        chapterEnglish: widget.item.chapterEnglish,
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
        title: Text(
          '#${widget.item.hadithNumber}',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            color: tokens.appBarForeground,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Text size',
            icon: Icon(Icons.text_fields, color: tokens.iconSoft),
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
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Copy',
            icon: Icon(Icons.copy_outlined, color: tokens.iconSoft),
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
            icon: Icon(Icons.share_outlined, color: tokens.iconSoft),
            onPressed: () => Share.share(_shareText()),
          ),
          IconButton(
            tooltip: 'Bookmark',
            onPressed: _toggleBookmark,
            icon: Icon(
              _bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: tokens.iconSoft,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HadithCard(
          item: widget.item,
          trailing: null,
          arabicFontSize: _arabicSize,
        ),
      ),
    );
  }
}
