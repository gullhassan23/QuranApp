import 'package:app5/Global.dart';
import 'package:app5/Widget/Custom_Translation.dart';
import 'package:app5/constants/constants.dart';
import 'package:app5/model/Translation.dart';
import 'package:flutter/material.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import 'package:app5/Service/api_service.dart';

enum Translation { urdu, english, chineese, turkish }

class SurahDetails extends StatefulWidget {
  const SurahDetails({super.key});

  static const String id = 'surahDetails_screen';
  @override
  State<SurahDetails> createState() => _SurahDetailsState();
}

class _SurahDetailsState extends State<SurahDetails> {
  ApiServices _apiServices = ApiServices();
  Translation? _translation = Translation.urdu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: FutureBuilder(
        future: _apiServices.getTranslation(
            Constants.surahIndex!, _translation!.index),
        builder: (BuildContext context,
            AsyncSnapshot<SurahTranslationList> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.translationList.length,
              itemBuilder: (context, index) {
                return TranslationTile(
                    index: index,
                    surahTranslation: snapshot.data!.translationList[index]);
              },
            );
          } else
            return Center(
              child: Text("Translation not found"),
            );
        },
      ),
      bottomSheet: SolidBottomSheet(
        headerBar: Container(
          color: background,
          height: 50,
          child: Center(
            child: Text(
              "Swipe me!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Container(
          color: dark,
          height: 30,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "urdu",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    leading: Radio<Translation>(
                      value: Translation.urdu,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "english",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    leading: Radio<Translation>(
                      value: Translation.english,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "chineese",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    leading: Radio<Translation>(
                      focusColor: Colors.yellow,
                      value: Translation.chineese,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "turkish",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    leading: Radio<Translation>(
                      value: Translation.turkish,
                      groupValue: _translation,
                      onChanged: (Translation? value) {
                        setState(() {
                          _translation = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
