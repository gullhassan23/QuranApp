import 'package:flutter/material.dart';

// Warm Hadith theme — raw colors live only in this file.
const Color _pagePeachTop = Color(0xFFF5E6D8);
const Color _pageBeigeBottom = Color(0xFFEDE4D4);
const Color _tagBg = Color(0xFF8FA888);
const Color _tagFg = Color(0xFFF4F7F2);
const Color _sectionTitleLight = Color(0xFF4A453E);
const Color _iconSoftLight = Colors.brown;
const Color _continueGreen = Color(0xFF2D5A3D);
const Color _onContinue = Color(0xFFF5FAF6);
const Color _continueSubtitle = Color(0xFFB8D4C4);
const Color _cardShadow = Color(0x333D5A45);
const Color _inputFillLight = Color(0xE6F2EDE6);

/// Theme tokens for Hadith screens. Light: warm peach page; cards use [ColorScheme.surfaceContainerHigh]. Dark: [ColorScheme].
class HadithUiTokens {
  const HadithUiTokens._({
    required this.isWarm,
    required this.scaffoldBackground,
    required this.pageGradient,
    required this.cardContainerColor,
    required this.cardShadows,
    required this.cardBorderRadius,
    required this.tagBackground,
    required this.tagForeground,
    required this.arabicText,
    required this.englishText,
    required this.englishMuted,
    required this.sectionTitle,
    required this.iconSoft,
    required this.continueButton,
    required this.onContinueButton,
    required this.continueSubtitle,
    required this.inputFill,
    required this.appBarForeground,
    required this.refreshIcon,
    required this.progressColor,
    required this.colorScheme,
  });

  final bool isWarm;
  final Color scaffoldBackground;
  final LinearGradient? pageGradient;
  final Color cardContainerColor;
  final List<BoxShadow> cardShadows;
  final double cardBorderRadius;
  final Color tagBackground;
  final Color tagForeground;
  final Color arabicText;
  final Color englishText;
  final Color englishMuted;
  final Color sectionTitle;
  final Color iconSoft;
  final Color continueButton;
  final Color onContinueButton;
  final Color continueSubtitle;
  final Color inputFill;
  final Color appBarForeground;
  final Color refreshIcon;
  final Color progressColor;
  final ColorScheme colorScheme;

  static HadithUiTokens of(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bright = Theme.of(context).brightness;
    if (bright == Brightness.dark) {
      return HadithUiTokens._(
        isWarm: false,
        scaffoldBackground: scheme.surface,
        pageGradient: null,
        cardContainerColor: scheme.surfaceContainerHigh,
        cardShadows: const [],
        cardBorderRadius: 16,
        tagBackground: scheme.primaryContainer,
        tagForeground: scheme.onPrimaryContainer,
        arabicText: scheme.onSurface,
        englishText: scheme.onSurface,
        englishMuted: scheme.onSurfaceVariant,
        sectionTitle: scheme.onSurface,
        iconSoft: scheme.outline,
        continueButton: scheme.primary,
        onContinueButton: scheme.onPrimary,
        continueSubtitle: scheme.onPrimaryContainer,
        inputFill: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        appBarForeground: scheme.onSurface,
        refreshIcon: scheme.primary,
        progressColor: scheme.primary,
        colorScheme: scheme,
      );
    }

    return HadithUiTokens._(
      isWarm: true,
      scaffoldBackground: _pagePeachTop,
      pageGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_pagePeachTop, _pageBeigeBottom],
      ),
      cardContainerColor: scheme.surfaceContainerHigh,
      cardShadows: [
        BoxShadow(
          color: _cardShadow,
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      cardBorderRadius: 18,
      tagBackground: _tagBg,
      tagForeground: _tagFg,
      arabicText: scheme.onSurface,
      englishText: scheme.onSurface,
      englishMuted: scheme.onSurfaceVariant,
      sectionTitle: _sectionTitleLight,
      iconSoft: _iconSoftLight,
      continueButton: _continueGreen,
      onContinueButton: _onContinue,
      continueSubtitle: _continueSubtitle,
      inputFill: _inputFillLight,
      appBarForeground: _sectionTitleLight,
      refreshIcon: _iconSoftLight,
      progressColor: _continueGreen,
      colorScheme: scheme,
    );
  }
}
