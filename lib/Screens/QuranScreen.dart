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
          appBar: AppBar(
            backgroundColor: background,
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Text(
                  "Surah",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                ),
                Text(
                  "Sajda",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                ),
                Text(
                  "Juz",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                ),
              ],
            ),
            title: Text("Quran"),
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
                builder: (context,AsyncSnapshot<SajdaList> snapshot){
                  if(snapshot.hasError){
                    return Center(child: Text('Something went wrong'),);
                  }
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.sajdaAyahs.length,
                    itemBuilder: (context , index) => SajdaCustomTile(snapshot.data!.sajdaAyahs[index], context),
                  );
                },
              ),
              GestureDetector(
                child: Container(
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
                              color: Colors.blueGrey,
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30),
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
