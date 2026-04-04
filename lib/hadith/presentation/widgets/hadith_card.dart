import 'package:app5/hadith/domain/hadith_models.dart';
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
  });

  final HadithItem item;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double arabicFontSize;

  @override
  Widget build(BuildContext context) {
    final tokens = HadithUiTokens.of(context);
    final r = BorderRadius.circular(tokens.cardBorderRadius);

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
          if (item.headingEnglish != null &&
              item.headingEnglish!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.headingEnglish!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                height: 1.35,
                color: tokens.isWarm ? tokens.englishText : tokens.sectionTitle,
              ),
            ),
          ],
          if (item.hadithArabic != null &&
              item.hadithArabic!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              item.hadithArabic!,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: arabicFontSize,
                height: 1.68,
                color: tokens.arabicText,
              ),
            ),
          ],
          if (item.englishNarrator != null &&
              item.englishNarrator!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.englishNarrator!,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                height: 1.45,
                color: tokens.englishMuted,
              ),
            ),
          ],
          if (item.hadithEnglish != null &&
              item.hadithEnglish!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.hadithEnglish!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.55,
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
