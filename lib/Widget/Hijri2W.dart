import 'package:flutter/material.dart';
import 'package:app5/model/aya_of_the_day.dart';
import 'package:app5/Service/api_service.dart';

class Hijri2Widget extends StatefulWidget {
  const Hijri2Widget({super.key});

  @override
  State<Hijri2Widget> createState() => _Hijri2WidgetState();
}

class _Hijri2WidgetState extends State<Hijri2Widget> {
  ApiServices _apiServices = ApiServices();
  // AyaOfTheDay? data;
  @override
  Widget build(BuildContext context) {
    // _apiServices.getAyaOfTheDay().then((value) => data = value);
    return Column(
      children: [
        FutureBuilder<AyaOfTheDay>(
            future: _apiServices.getAyaOfTheDay(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Icon(Icons.sync_problem);
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                case ConnectionState.done:
                  return Container(
                    margin: EdgeInsetsDirectional.all(16),
                    padding: EdgeInsetsDirectional.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFF12202F),
                      // gradient: LinearGradient(
                      //     begin: Alignment.topLeft,
                      //     end: Alignment.bottomRight,
                      //     colors: [
                      //       Color(0xFFDF98FA),
                      //       Color(0xFFB070FD),
                      //       Color(0xFF9055FF),
                      //       Color(0xFF12202F)
                      //     ])

                      // boxShadow: [
                      //   BoxShadow(

                      //     blurRadius: 3,
                      //     spreadRadius: 1,
                      //     offset: Offset(0,1),
                      //   )
                      // ]
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Quran Aya of the Day",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.bold),
                        ),
                        Divider(
                          color: Colors.black,
                          thickness: 0.5,
                        ),
                        Text(
                          snapshot.data!.arText!,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          snapshot.data!.enTran!,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        RichText(
                            text: TextSpan(children: <InlineSpan>[
                          WidgetSpan(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              snapshot.data!.surName.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 5),
                            ),
                          )),
                          WidgetSpan(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              snapshot.data!.surEnName!,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ))
                        ]))
                      ],
                    ),
                  );
              }
            }),
      ],
    );
  }
}
