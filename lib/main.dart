import 'package:app5/Screens/Juz_screen.dart';
import 'package:app5/Screens/SplashScreen.dart';
import 'package:app5/Screens/surah_details.dart';
import 'package:app5/Widget/BottomW.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  bool alreadyUsed = false;

  void getData() async {
    final prefs = await SharedPreferences.getInstance();
    alreadyUsed = prefs.getBool("already used") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: alreadyUsed?BottomW():SplashScreen(),
      routes: {
        JuzScreen.id: (context) => JuzScreen(),
        SurahDetails.id: (context) => SurahDetails(),
      },
    );
  }
}
