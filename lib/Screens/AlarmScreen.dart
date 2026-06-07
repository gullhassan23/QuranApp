import 'dart:convert';

import 'package:app5/Global.dart';
import 'package:app5/Service/notification_provider.dart';
import 'package:app5/Service/prayer_alarm_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

/// Route name for navigation.
const String alarmScreenRoute = '/alarm';

/// Alarm screen shown when prayer alarm or snooze fires.
/// Displays prayer name, time, and Dismiss / Snooze actions; plays Azan audio.
class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  static const String id = alarmScreenRoute;

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _prayerName = 'Prayer';
  String _timeFormatted = '';

  @override
  void initState() {
    super.initState();
    _parseArguments();
    _playAlarmSound();
  }

  void _parseArguments() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == null) return;
    if (args is Map<String, dynamic>) {
      _prayerName = args[payloadPrayer] as String? ?? 'Prayer';
      _timeFormatted = args[payloadTime] as String? ?? '';
      return;
    }
    if (args is String) {
      try {
        final map = jsonDecode(args) as Map<String, dynamic>;
        _prayerName = map[payloadPrayer] as String? ?? 'Prayer';
        _timeFormatted = map[payloadTime] as String? ?? '';
      } catch (_) {}
    }
  }

  Future<void> _playAlarmSound() async {
    try {
      await _audioPlayer.setAsset('assets/audio/azan.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
    } catch (_) {
      // Asset missing or play failed; continue without sound
    }
  }

  Future<void> _stopAndPop() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
    } catch (_) {}
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _dismiss() async {
    await _stopAndPop();
  }

  Future<void> _snooze() async {
    final service = prayerAlarmService;
    await service.scheduleSnooze(_prayerName, _timeFormatted);
    await _stopAndPop();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use current time for large display if we don't have formatted time, else show formatted
    final now = DateTime.now();
    final displayTime = _timeFormatted.isNotEmpty
        ? _timeFormatted
        : '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text(
                displayTime,
                style: GoogleFonts.robotoMono(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  color: textprimary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _prayerName,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: textprimary,
                ),
              ),
              if (_timeFormatted.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _timeFormatted,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: dark,
                  ),
                ),
              ],
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    label: 'Snooze',
                    onPressed: _snooze,
                    backgroundColor: containercolor,
                  ),
                  _ActionButton(
                    label: 'Dismiss',
                    onPressed: _dismiss,
                    backgroundColor: accentgreen,
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
  });

  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textprimary,
            ),
          ),
        ),
      ),
    );
  }
}

