import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithLoadingView extends StatelessWidget {
  const HadithLoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final tokens = HadithUiTokens.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: tokens.progressColor),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: tokens.isWarm ? tokens.iconSoft : tokens.englishMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HadithErrorView extends StatelessWidget {
  const HadithErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = HadithUiTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: tokens.iconSoft),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: tokens.sectionTitle,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                style: tokens.isWarm
                    ? FilledButton.styleFrom(
                        backgroundColor: tokens.continueButton,
                        foregroundColor: tokens.onContinueButton,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      )
                    : null,
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text('Retry', style: GoogleFonts.poppins()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HadithEmptyView extends StatelessWidget {
  const HadithEmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = HadithUiTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: tokens.iconSoft),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  // color: tokens.isWarm ? tokens.iconSoft : tokens.englishMuted,
                  color: Colors.brown),
            ),
          ],
        ),
      ),
    );
  }
}

class HadithApiKeyMissingView extends StatelessWidget {
  const HadithApiKeyMissingView({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = HadithUiTokens.of(context);
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.key_off_outlined,
            size: 56,
            color: tokens.isWarm ? tokens.iconSoft : cs.tertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Hadith API key required',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: tokens.isWarm ? tokens.sectionTitle : cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your key at build time:\n\n'
            'flutter run --dart-define=HADITH_API_KEY=your_key_here',
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.45,
              color: tokens.isWarm ? tokens.iconSoft : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
