import 'package:app5/Screens/HomeScreen.dart';
import 'package:app5/Screens/PrayerScreen.dart';

import 'package:app5/Screens/QariScreen.dart';
import 'package:app5/Screens/QuranScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomW extends StatefulWidget {
  const BottomW({super.key});

  @override
  State<BottomW> createState() => _BottomWState();
}

class _BottomWState extends State<BottomW> {
  int current = 0;
  final tabs = [
    Home(),
    PrayerScreen(),
    QuranScreen(),
    QariScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // remove white area
        statusBarIconBrightness: Brightness.light, // android icons white
        statusBarBrightness: Brightness.dark, // ios
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black, // your screen bg
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFFF1D2CB),
          selectedItemColor: Color(0xFF4D8B5E),
          unselectedItemColor: Color(0xFF7A4E44),
          type: BottomNavigationBarType.fixed,
          currentIndex: current,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/images/home.png",
                height: 30,
                width: 50,
              ),
              label: "HOME",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/images/prayer.png",
                height: 30,
                width: 50,
              ),
              label: "HOME",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/images/quran.png",
                height: 30,
                width: 50,
              ),
              label: "Quran",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note_outlined),
              label: "Quran",
            ),
          ],
          onTap: (index) {
            setState(() {
              current = index;
            });
          },
        ),
        body: tabs[current],
      ),
    );
  }
}
