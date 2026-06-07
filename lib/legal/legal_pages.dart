import 'package:app5/Global.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

void openTermsAndConditions(BuildContext context) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => const _LegalScrollScreen(
        title: 'Terms & Conditions',
        body: _termsPlaceholder,
      ),
    ),
  );
}

Future<void> openPrivacyPolicy(BuildContext context) async {
  const policyUrl = 'https://gullhassan23.github.io/Quran_privacy/';
  final uri = Uri.parse(policyUrl);

  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to open Privacy Policy link.'),
      ),
    );
  }
}

class _LegalScrollScreen extends StatelessWidget {
  const _LegalScrollScreen({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        surfaceTintColor: backgroundColor,
        backgroundColor: backgroundColor,
        foregroundColor: textprimary,
        elevation: 0,
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textprimary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.5,
              color: dark,
            ),
          ),
        ),
      ),
    );
  }
}

const String _termsPlaceholder = '''
Last updated: April 2026

Replace this text with your real Terms & Conditions (Urdu or English).

By using this application you agree to use it respectfully and in line with applicable laws. The app is provided for personal spiritual use; we do not guarantee uninterrupted availability.

If you have questions, add your support contact here.
''';

