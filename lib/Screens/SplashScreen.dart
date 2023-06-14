import 'dart:async';
import 'package:app5/Global.dart';

import 'package:app5/Widget/BottomW.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:shoes/Screen/HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 

  @override
  void initState() {
    super.initState();
   
    Timer(
        Duration(seconds: 5),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BottomW())));
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Quran App",
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 29),
                    ),
                    Center(
                      child: Image.asset(
                        "assets/images/logo.png",
                        color: Colors.green,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Center(
                        child: Text(
                          "Learn Quran and Recite once everyday",
                          style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}
