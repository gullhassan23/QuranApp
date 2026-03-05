import 'package:adhan/adhan.dart';
import 'package:app5/Global.dart';
import 'package:app5/constants/constants.dart';
import 'package:app5/Service/notification_provider.dart';
import 'package:app5/Service/prayer_alarm_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final Location _location = Location();
  double? _latitude;
  double? _longitude;
  String? _selectedAlarmPrayer;

  static const double _fallbackLat = 30.8138;
  static const double _fallbackLng = 73.4534;

  @override
  void initState() {
    super.initState();
    _loadEnabledPrayer();
  }

  Future<void> _loadEnabledPrayer() async {
    final enabled = await PrayerAlarmService.getEnabledPrayer();
    if (mounted) setState(() => _selectedAlarmPrayer = enabled);
  }

  Future<void> _getLoc() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }
    var permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }
    final data = await _location.getLocation();
    if (data.latitude != null && data.longitude != null) {
      _latitude = data.latitude!;
      _longitude = data.longitude!;
      await PrayerAlarmService.saveCoordinates(_latitude!, _longitude!);
    }
  }

  Coordinates _getCoordinates() {
    if (_latitude != null && _longitude != null) {
      return Coordinates(_latitude!, _longitude!);
    }
    return Coordinates(_fallbackLat, _fallbackLng);
  }

  Future<void> _onAlarmToggle(String prayerName, String time) async {
    final newSelection =
        _selectedAlarmPrayer == prayerName ? null : prayerName;
    setState(() => _selectedAlarmPrayer = newSelection);
    if (newSelection != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your alarm is set on $time')),
      );
    }
    try {
      await prayerAlarmService.setEnabledPrayer(newSelection);
    } catch (_) {
      if (mounted) setState(() => _selectedAlarmPrayer = _selectedAlarmPrayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          centerTitle: true,
          title: Text(
            "Prayer Timings",
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textprimary,
              letterSpacing: 1,
            ),
          ),
        ),
        backgroundColor: backgroundColor,
        body: FutureBuilder<void>(
          future: _getLoc(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Constants.kPrimary),
              );
            }
            final coordinates = _getCoordinates();
            final params = CalculationMethod.karachi.getParameters();
            params.madhab = Madhab.hanafi;
            final prayerTimes = PrayerTimes.today(coordinates, params);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _PrayerRow(
                    label: 'Fajr',
                    time: DateFormat.jm().format(prayerTimes.fajr),
                    alarmPrayer: 'Fajr',
                    selectedAlarmPrayer: _selectedAlarmPrayer,
                    onAlarmToggle: _onAlarmToggle,
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sunrise',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: textprimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat.jm().format(prayerTimes.sunrise),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: textprimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  _PrayerRow(
                    label: 'Zuhr',
                    time: DateFormat.jm().format(prayerTimes.dhuhr),
                    alarmPrayer: 'Zuhr',
                    selectedAlarmPrayer: _selectedAlarmPrayer,
                    onAlarmToggle: _onAlarmToggle,
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  _PrayerRow(
                    label: 'Asar',
                    time: DateFormat.jm().format(prayerTimes.asr),
                    alarmPrayer: 'Asr',
                    selectedAlarmPrayer: _selectedAlarmPrayer,
                    onAlarmToggle: _onAlarmToggle,
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  _PrayerRow(
                    label: 'Maghrib',
                    time: DateFormat.jm().format(prayerTimes.maghrib),
                    alarmPrayer: 'Maghrib',
                    selectedAlarmPrayer: _selectedAlarmPrayer,
                    onAlarmToggle: _onAlarmToggle,
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  _PrayerRow(
                    label: 'Isha',
                    time: DateFormat.jm().format(prayerTimes.isha),
                    alarmPrayer: 'Isha',
                    selectedAlarmPrayer: _selectedAlarmPrayer,
                    onAlarmToggle: _onAlarmToggle,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.label,
    required this.time,
    required this.alarmPrayer,
    required this.selectedAlarmPrayer,
    required this.onAlarmToggle,
  });

  final String label;
  final String time;
  final String alarmPrayer;
  final String? selectedAlarmPrayer;
  final void Function(String prayerName, String time) onAlarmToggle;

  @override
  Widget build(BuildContext context) {
    final isEnabled = selectedAlarmPrayer == alarmPrayer;
    return SwitchListTile(
      title: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: textprimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: textprimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      value: isEnabled,
      onChanged: (_) => onAlarmToggle(alarmPrayer, time),
      activeColor: accentgreen,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
    );
  }
}
