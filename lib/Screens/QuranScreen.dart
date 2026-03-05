import 'package:app5/Global.dart';
import 'package:app5/Screens/Juz_screen.dart';
import 'package:app5/Screens/surah_details.dart';
import 'package:app5/Service/api_service.dart';
import 'package:app5/Widget/SajdaCustomTile.dart';
import 'package:app5/Widget/SurahCustomFile.dart';
import 'package:app5/constants/constants.dart';
import 'package:app5/model/Surah.dart';
import 'package:app5/model/sajda.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  ApiServices apiServices = ApiServices();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: SafeArea(
            child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Text(
                  "Surah",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textprimary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Sajda",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textprimary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Juz",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textprimary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FutureBuilder(
                  future: apiServices.getSurah(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Surah>> snapshot) {
                    if (snapshot.hasData) {
                      List<Surah>? surah = snapshot.data;

                      return ListView.builder(
                        itemCount: surah!.length,
                        itemBuilder: (context, index) => SurahCustomListTile(
                            surah: surah[index],
                            context: context,
                            ontap: () {
                              setState(() {
                                Constants.surahIndex = (index + 1);
                              });
                              Navigator.pushNamed(context, SurahDetails.id);
                            }),
                      );
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
              FutureBuilder(
                future: apiServices.getSajda(),
                builder: (context, AsyncSnapshot<SajdaList> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.sajdaAyahs.length,
                    itemBuilder: (context, index) => SajdaCustomTile(
                        snapshot.data!.sajdaAyahs[index], context),
                  );
                },
              ),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFF6D7C3), // light peach
                        Color(0xFFF2C6AD), // darker peach
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                        itemCount: 30,
                        itemBuilder: ((context, index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                Constants.juzIndex = (index + 1);
                              });

                              Navigator.pushNamed(context, JuzScreen.id);
                            },
                            child: Card(
                              elevation: 4,
                              color: containercolor,
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 25,
                                    color: textprimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        })),
                  ),
                ),
              )
            ],
          ),
        )));
  }
}
