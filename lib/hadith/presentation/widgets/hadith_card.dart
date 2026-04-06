import 'package:app5/hadith/data/hadith_display_prefs.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:app5/hadith/presentation/hadith_search_language.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithCard extends StatelessWidget {
  const HadithCard({
    super.key,
    required this.item,
    this.onTap,
    this.trailing,
    this.arabicFontSize = 19,
    this.urduFontSize = 15,
    this.visibility = HadithLanguageVisibility.all,
    this.highlightQuery,
    this.highlightLanguage = HadithSearchLanguage.english,
  });

  final HadithItem item;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double arabicFontSize;
  final double urduFontSize;
  final HadithLanguageVisibility visibility;
  final String? highlightQuery;
  final HadithSearchLanguage highlightLanguage;

  TextSpan _highlightSpan({
    required String text,
    required String query,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
    required bool caseInsensitive,
  }) {
    final q = query.trim();
    if (q.isEmpty) return TextSpan(text: text, style: baseStyle);

    final hay = caseInsensitive ? text.toLowerCase() : text;
    final needle = caseInsensitive ? q.toLowerCase() : q;

    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final i = hay.indexOf(needle, start);
      if (i < 0) break;
      if (i > start) {
        spans.add(TextSpan(text: text.substring(start, i), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(i, i + needle.length),
        style: highlightStyle,
      ));
      start = i + needle.length;
    }
    if (spans.isEmpty) return TextSpan(text: text, style: baseStyle);
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
    }
    return TextSpan(children: spans);
  }

  Widget _maybeHighlightedText({
    required HadithUiTokens tokens,
    required String text,
    required TextStyle style,
    required bool shouldHighlight,
    required bool caseInsensitive,
    TextDirection? textDirection,
    TextAlign? textAlign,
  }) {
    final q = (highlightQuery ?? '').trim();
    if (!shouldHighlight || q.isEmpty) {
      return Text(
        text,
        textDirection: textDirection,
        textAlign: textAlign,
        style: style,
      );
    }

    final highlightStyle = style.copyWith(
      backgroundColor: tokens.colorScheme.primary.withValues(alpha: 0.18),
      fontWeight: FontWeight.w700,
    );

    return Text.rich(
      _highlightSpan(
        text: text,
        query: q,
        baseStyle: style,
        highlightStyle: highlightStyle,
        caseInsensitive: caseInsensitive,
      ),
      textDirection: textDirection,
      textAlign: textAlign,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = HadithUiTokens.of(context);
    final r = BorderRadius.circular(tokens.cardBorderRadius);
    final q = (highlightQuery ?? '').trim();
    final highlightOn = q.isNotEmpty;

    final content = Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(context, tokens, item.bookName),
                    _chip(context, tokens, 'Ch. ${item.chapterNumber}'),
                    _chip(context, tokens, '#${item.hadithNumber}'),
                    if (item.status != null && item.status!.isNotEmpty)
                      _chip(context, tokens, item.status!),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (visibility.showEnglish &&
              item.headingEnglish != null &&
              item.headingEnglish!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _maybeHighlightedText(
              tokens: tokens,
              text: item.headingEnglish!,
              shouldHighlight:
                  highlightOn && highlightLanguage == HadithSearchLanguage.english,
              caseInsensitive: true,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                height: 1.35,
                color: tokens.isWarm ? tokens.englishText : tokens.sectionTitle,
              ),
            ),
          ],
          if (visibility.showUrdu &&
              item.headingUrdu != null &&
              item.headingUrdu!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _maybeHighlightedText(
              tokens: tokens,
              text: item.headingUrdu!,
              shouldHighlight:
                  highlightOn && highlightLanguage == HadithSearchLanguage.urdu,
              caseInsensitive: false,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: tokens.isWarm ? tokens.englishText : tokens.sectionTitle,
              ),
            ),
          ],
          if (visibility.showArabic &&
              item.hadithArabic != null &&
              item.hadithArabic!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _maybeHighlightedText(
              tokens: tokens,
              text: item.hadithArabic!,
              shouldHighlight:
                  highlightOn && highlightLanguage == HadithSearchLanguage.arabic,
              caseInsensitive: false,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: arabicFontSize,
                height: 1.68,
                color: tokens.arabicText,
              ),
            ),
          ],
          if (visibility.showEnglish &&
              item.englishNarrator != null &&
              item.englishNarrator!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _maybeHighlightedText(
              tokens: tokens,
              text: item.englishNarrator!,
              shouldHighlight:
                  highlightOn && highlightLanguage == HadithSearchLanguage.english,
              caseInsensitive: true,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                height: 1.45,
                color: tokens.englishMuted,
              ),
            ),
          ],
          if (visibility.showEnglish &&
              item.hadithEnglish != null &&
              item.hadithEnglish!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _maybeHighlightedText(
              tokens: tokens,
              text: item.hadithEnglish!,
              shouldHighlight:
                  highlightOn && highlightLanguage == HadithSearchLanguage.english,
              caseInsensitive: true,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.55,
                color: tokens.englishText,
              ),
            ),
          ],
          if (visibility.showUrdu &&
              item.urduNarrator != null &&
              item.urduNarrator!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _maybeHighlightedText(
              tokens: tokens,
              text: item.urduNarrator!,
              shouldHighlight:
                  highlightOn && highlightLanguage == HadithSearchLanguage.urdu,
              caseInsensitive: false,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                height: 1.55,
                color: tokens.englishMuted,
              ),
            ),
          ],
          if (visibility.showUrdu &&
              item.hadithUrdu != null &&
              item.hadithUrdu!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _maybeHighlightedText(
              tokens: tokens,
              text: item.hadithUrdu!,
              shouldHighlight:
                  highlightOn && highlightLanguage == HadithSearchLanguage.urdu,
              caseInsensitive: false,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: GoogleFonts.notoNastaliqUrdu(
                fontSize: urduFontSize,
                height: 1.75,
                color: tokens.englishText,
              ),
            ),
          ],
        ],
      ),
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.cardContainerColor,
        borderRadius: r,
        boxShadow: tokens.cardShadows,
      ),
      child: onTap != null
          ? Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: r,
                onTap: onTap,
                splashColor: tokens.colorScheme.primary.withValues(alpha: 0.12),
                highlightColor:
                    tokens.colorScheme.primary.withValues(alpha: 0.06),
                child: content,
              ),
            )
          : content,
    );

    return decorated;
  }

  Widget _chip(BuildContext context, HadithUiTokens tokens, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tokens.tagBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
          color: tokens.tagForeground,
        ),
      ),
    );
  }
}
