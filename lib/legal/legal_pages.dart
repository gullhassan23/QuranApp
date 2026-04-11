import 'package:app5/Global.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

void openPrivacyPolicy(BuildContext context) {
  Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => const _LegalScrollScreen(
        title: 'Privacy Policy',
        body: _privacyPlaceholder,
      ),
    ),
  );
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

const String _privacyPlaceholder = '''

Privacy Policy for Quran App

Information We Collect

We aim to keep your experience private and secure. Our app may collect:

No Personal Information (Default): We do not collect personally identifiable information such as your name, email, or phone number.
Usage Data (Optional): We may collect anonymous usage data (such as app usage statistics) to improve the app experience.
Device Information: Basic device information (such as device type, OS version) may be collected automatically.

How We Use Information

Any collected information is used to:

Improve app performance and user experience
Fix bugs and technical issues
Understand general usage trends

Third-Party Services

Our app may use third-party services that may collect information, such as:

Analytics tools (e.g., Google Analytics)
Advertising services (if ads are enabled)

These services have their own Privacy Policies.

Data Security

We value your trust and strive to use commercially acceptable means of protecting your information. However, no method of transmission over the internet is 100% secure.

Children’s Privacy

Our app is suitable for all ages. We do not knowingly collect personal information from children.
Changes to This Policy

We may update our Privacy Policy from time to time. Any changes will be posted on this page.

---

Note: This app is designed to provide Quranic content for educational and spiritual purposes only.
''';
