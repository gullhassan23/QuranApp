import 'package:app5/Global.dart';
import 'package:app5/Screens/HomeScreen.dart';
import 'package:app5/Screens/PrayerScreen.dart';

import 'package:app5/Screens/QariScreen.dart';
import 'package:app5/Screens/QuranScreen.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: gray,
        type: BottomNavigationBarType.fixed,
        currentIndex: current,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "HOME",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/prayerlogo.png",
              height: 30,
              width: 50,
            ),
            label: "HOME",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/Quran.png",
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
    );
  }
}
