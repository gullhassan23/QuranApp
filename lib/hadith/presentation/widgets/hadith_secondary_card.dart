import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:flutter/material.dart';

/// List row surface: same container color as [HadithCard].
class HadithSecondaryCard extends StatelessWidget {
  const HadithSecondaryCard({
    super.key,
    required this.tokens,
    required this.child,
    this.borderRadius = 14,
    this.margin,
  });

  final HadithUiTokens tokens;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(borderRadius);
    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.cardContainerColor,
        borderRadius: r,
        boxShadow: tokens.cardShadows,
      ),
      child: ClipRRect(borderRadius: r, child: child),
    );
    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }
    return card;
  }
}
