import 'package:app5/Global.dart';
import 'package:app5/Screens/AudioScreen.dart';
import 'package:app5/Service/api_service.dart';

import 'package:app5/model/Surah.dart';
import 'package:app5/model/qari.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AudioSurahScreen extends StatefulWidget {
  const AudioSurahScreen({
    Key? key,
    required this.qari,
  }) : super(key: key);
  final Qari qari;

  @override
  State<AudioSurahScreen> createState() => _AudioSurahScreenState();
}

class _AudioSurahScreenState extends State<AudioSurahScreen> {
  ApiServices apiServices = ApiServices();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          surfaceTintColor: backgroundColor,
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Surah List",
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textprimary,
              letterSpacing: 1,
            ),
          ),
        ),
        body: FutureBuilder(
          future: apiServices.getSurah(),
          builder: (BuildContext context, AsyncSnapshot<List<Surah>> snapshot) {
            if (snapshot.hasData) {
              List<Surah>? surah = snapshot.data;
              return ListView.builder(
                  itemCount: surah!.length,
                  itemBuilder: (context, index) => AudioTile(
                      surahName: snapshot.data![index].englishName,
                      totalAya: snapshot.data![index].numberOfAyahs,
                      number: snapshot.data![index].number,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AudioScreen(
                                    qari: widget.qari,
                                    index: index + 1,
                                    list: surah)));
                      }));
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

Widget AudioTile(
    {required String? surahName,
    required totalAya,
    required number,
    required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: containercolor,
            boxShadow: [
              BoxShadow(
                  blurRadius: 3,
                  spreadRadius: 0,
                  color: Colors.black12,
                  offset: Offset(0, 1))
            ]),
        child: Row(
          children: [
            // Container(
            //   alignment: Alignment.center,
            //   height: 30,
            //   width: 40,
            //   padding: EdgeInsets.all(8),
            //   decoration:
            //       BoxDecoration(shape: BoxShape.circle, color: Colors.black),
            //   child: Text(
            //     (number).toString(),
            //     style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold),
            //   ),
            // ),
            Container(
              height: 36,
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: textprimary,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  (number).toString(),
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surahName!,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: textprimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  "Total Aya : $totalAya",
                  style: TextStyle(
                      color: Color.fromARGB(255, 110, 64, 30), fontSize: 16),
                )
              ],
            ),
            Spacer(),
            Icon(
              Icons.play_circle_fill,
              color: textprimary,
            )
          ],
        ),
      ),
    ),
  );
}
