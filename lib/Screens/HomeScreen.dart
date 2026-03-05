import 'package:app5/Global.dart';
import 'package:app5/Widget/Hijri2W.dart';
import 'package:app5/Widget/HijriW.dart';
import 'package:app5/constants/constants.dart';
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
        child: Scaffold(
            backgroundColor: backgroundColor,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(75),
              child: Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: _appBar(),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
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
                                gradient: smallcardcolor),
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            right: 20,
                            child: Image.asset(
                              "assets/images/Quran.png",
                              height: 100,
                              width: 170,
                              color: textprimary,
                            )),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 25.0, left: 40.0),
                              child: HijriW(),
                            ),
                          ],
                        )
                      ],
                    ),

                    // Container(
                    //   margin: EdgeInsets.all(20),
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     gradient: smallcardcolor,
                    //     borderRadius: BorderRadius.circular(18),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.black.withOpacity(0.08),
                    //         blurRadius: 10,
                    //         offset: const Offset(0, 6),
                    //       )
                    //     ],
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         "27 شعبان 1447 AH",
                    //         style: GoogleFonts.amiri(
                    //           fontSize: 20,
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //       Row(
                    //         children: [
                    //           Text(
                    //             "Sun, 15 Feb 2026",
                    //             style: GoogleFonts.poppins(
                    //               fontSize: 15,
                    //               color: Colors.white,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //           Image.asset(
                    //             "assets/images/Quran.png",
                    //             height: 100,
                    //             width: 170,
                    //           )
                    //         ],
                    //       )
                    //     ],
                    //   ),
                    // ),
                    //  next widget
                    Hijri2Widget(),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

AppBar _appBar() => AppBar(
      surfaceTintColor: backgroundColor,
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      elevation: 0,
      centerTitle: true,
      title: Row(children: [
        Text(
          getGreetingAndImage()['greeting']!,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textprimary,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        // IconButton(onPressed: (() => {}), icon: Icons.search),
      ]),
    );
