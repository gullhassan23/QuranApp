import 'package:app5/Global.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:flutter/material.dart';

/// Hadith screens: warm full-screen gradient + transparent app bar (light only).
class HadithThemedScaffold extends StatelessWidget {
  const HadithThemedScaffold({
    super.key,
    required this.appBar,
    required this.body,
  });

  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final tokens = HadithUiTokens.of(context);
    final theme = Theme.of(context);

    if (!tokens.isWarm) {
      return Scaffold(
        // backgroundColor: tokens.scaffoldBackground,
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: body,
      );
    }

    final topInset = MediaQuery.paddingOf(context).top;
    final appBarHeight = appBar.preferredSize.height;
    final contentTop = topInset + appBarHeight;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: tokens.pageGradient),
        ),
        Theme(
          data: theme.copyWith(
            appBarTheme: theme.appBarTheme.copyWith(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              foregroundColor: tokens.appBarForeground,
              iconTheme: IconThemeData(color: tokens.iconSoft),
              actionsIconTheme: IconThemeData(color: tokens.iconSoft),
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: appBar,
            body: Padding(
              padding: EdgeInsets.only(top: contentTop),
              child: body,
            ),
          ),
        ),
      ],
    );
  }
}
