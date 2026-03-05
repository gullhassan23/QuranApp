import 'package:app5/Global.dart';
import 'package:flutter/material.dart';
import 'package:app5/model/aya_of_the_day.dart';
import 'package:app5/Service/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class Hijri2Widget extends StatefulWidget {
  const Hijri2Widget({super.key});

  @override
  State<Hijri2Widget> createState() => _Hijri2WidgetState();
}

class _Hijri2WidgetState extends State<Hijri2Widget> {
  ApiServices _apiServices = ApiServices();
  // AyaOfTheDay? data;
  @override
  Widget build(BuildContext context) {
    // _apiServices.getAyaOfTheDay().then((value) => data = value);
    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder<AyaOfTheDay>(
            future: _apiServices.getAyaOfTheDay(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(), // retry loader if error
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final data = snapshot.data!;

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: ayatcontainer,
                ),
                child: Column(
                  children: [
                    Text(
                      "Quran Aya of the Day",
                      style: TextStyle(
                        color: textprimary,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(thickness: 0.5),
                    const SizedBox(height: 20),

                    /// Arabic Text
                    Text(
                      softWrap: true,
                      data.arText ?? "",
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: GoogleFonts.amiriQuran(
                        fontSize: 22,
                        height: 0, // 👈 VERY IMPORTANT
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF8A5C49),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// English Translation
                    Text(
                      data.enTran ?? "",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.6,
                        color: const Color(0xFF6E4B3A),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "-${data.surEnName ?? ""}-",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8A5C49),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
