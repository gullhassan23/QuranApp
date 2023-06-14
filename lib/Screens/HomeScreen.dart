import 'package:app5/Global.dart';
import 'package:app5/Widget/Hijri2W.dart';
import 'package:app5/Widget/HijriW.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(75),
            child: Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: _appBar(),
            ),
          ),
          backgroundColor: background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 25.0, left: 25.0, top: 9.0),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFDF98FA),
                                  Color(0xFFB070FD),
                                  Color(0xFF9055FF)
                                ])),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Image.asset(
                          "assets/images/Quran.png",
                          height: 100,
                          width: 170,
                        )),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0, left: 40.0),
                          child: HijriW(),
                        ),
                      ],
                    )
                  ],
                ),
                //  next widget
                Hijri2Widget(),
              ],
            ),
          )),
    );
  }
}

AppBar _appBar() => AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: true,
      title: Row(children: [
        Text(
          'Quran App',
          style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        // IconButton(onPressed: (() => {}), icon: Icons.search),
      ]),
    );
