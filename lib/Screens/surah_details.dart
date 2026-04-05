import 'package:app5/Global.dart';
import 'package:app5/Widget/Custom_Translation.dart';
import 'package:app5/constants/constants.dart';
import 'package:app5/model/Translation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final SolidController _controller = SolidController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: FutureBuilder(
        future: _apiServices.getTranslation(
            Constants.surahIndex!, _translation!.index),
        builder: (BuildContext context,
            AsyncSnapshot<SurahTranslationList> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.brown,
              ),
            );
          } else if (snapshot.hasData) {
            return Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
                  iconTheme: IconThemeData(color: Colors.brown),
                  surfaceTintColor: backgroundColor,
                  backgroundColor: backgroundColor,
                  title: Text(
                    "Surah Details",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: textprimary,
                      letterSpacing: 1,
                    ),
                  )),
              body: ListView.builder(
                itemCount: snapshot.data!.translationList.length,
                itemBuilder: (context, index) {
                  return TranslationTile(
                      index: index,
                      surahTranslation: snapshot.data!.translationList[index]);
                },
              ),
            );
          } else
            return Center(
              child: Text("Translation not found"),
            );
        },
      ),
      bottomSheet: SolidBottomSheet(
        controller: _controller,
        headerBar: Container(
          color: containercolor,
          height: 50,
          child: Center(
            child: Text(
              "Swipe me!",
              style: TextStyle(color: textprimary),
            ),
          ),
        ),
        body: Container(
          color: backgroundColor,
          height: 30,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  buildTile("Urdu", Translation.urdu),
                  buildTile("English", Translation.english),
                  buildTile("Chineese", Translation.chineese),
                  buildTile("Turkish", Translation.turkish),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTile(String title, Translation value) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: textprimary, fontSize: 20),
      ),
      leading: Radio<Translation>(
        activeColor: Colors.brown,
        value: value,
        groupValue: _translation,
        onChanged: (Translation? val) {
          setState(() {
            _translation = val;
          });

          _controller.hide(); // ✅ auto swipe down (close)
        },
      ),
    );
  }
}
