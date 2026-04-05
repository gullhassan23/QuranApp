import 'package:app5/hadith/data/hadith_display_prefs.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showHadithLanguageSettingsSheet(BuildContext context) async {
  await HadithDisplayPrefs.instance.ensureLoaded();
  if (!context.mounted) return;
  final tokens = HadithUiTokens.of(context);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return ValueListenableBuilder<HadithLanguageVisibility>(
        valueListenable: HadithDisplayPrefs.instance.visibility,
        builder: (context, vis, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hadith languages',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: tokens.sectionTitle,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose which texts appear below each hadith.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.4,
                    color: tokens.englishMuted,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Arabic', style: GoogleFonts.poppins()),
                  value: vis.showArabic,
                  onChanged: (on) => HadithDisplayPrefs.instance.setVisibility(
                    HadithLanguageVisibility(
                      showArabic: on,
                      showEnglish: vis.showEnglish,
                      showUrdu: vis.showUrdu,
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('English', style: GoogleFonts.poppins()),
                  value: vis.showEnglish,
                  onChanged: (on) => HadithDisplayPrefs.instance.setVisibility(
                    HadithLanguageVisibility(
                      showArabic: vis.showArabic,
                      showEnglish: on,
                      showUrdu: vis.showUrdu,
                    ),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Urdu', style: GoogleFonts.poppins()),
                  value: vis.showUrdu,
                  onChanged: (on) => HadithDisplayPrefs.instance.setVisibility(
                    HadithLanguageVisibility(
                      showArabic: vis.showArabic,
                      showEnglish: vis.showEnglish,
                      showUrdu: on,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
