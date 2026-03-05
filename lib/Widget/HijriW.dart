import 'package:app5/Global.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HijriW extends StatefulWidget {
  const HijriW({super.key});

  @override
  State<HijriW> createState() => _HijriWState();
}

class _HijriWState extends State<HijriW> {
  @override
  Widget build(BuildContext context) {
    HijriCalendar.setLocal('ar');
    var _hijri = HijriCalendar.now();
    var day = DateTime.now();
    var format = DateFormat('EEE, d MMM yyyy');
    var formatted = format.format(day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 3.0),
                child: Text(
                  _hijri.hDay.toString(),
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textprimary,
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _hijri.longMonthName,
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textprimary,
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(
                  '${_hijri.hYear} AH',
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textprimary,
                  ),
                )),
          ],
        ),
        Text(
          formatted,
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: textprimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
