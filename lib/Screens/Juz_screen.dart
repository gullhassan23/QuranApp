import 'package:app5/Service/api_service.dart';
import 'package:app5/Widget/JuzCustomFile.dart';
import 'package:app5/constants/constants.dart';
import 'package:app5/model/Juz.dart';
import 'package:flutter/material.dart';

class JuzScreen extends StatefulWidget {
  static const String id = 'juz_screen';

  @override
  State<JuzScreen> createState() => _JuzScreenState();
}

class _JuzScreenState extends State<JuzScreen> {
  ApiServices apiServices = ApiServices();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: FutureBuilder<JuzModel>(
        future: apiServices.getJuzz(Constants.juzIndex!),
        builder: (context, AsyncSnapshot<JuzModel> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            print('${snapshot.data!.juzAyahs.length}');
            return ListView.builder(
                itemCount: snapshot.data!.juzAyahs.length,
                itemBuilder: (context, index) {
                  return JuzCustomTile(
                      list: snapshot.data!.juzAyahs, index: index);
                });
          } else {
            return Center(
              child: Text("data not found"),
            );
          }
        },
      ),
    ));
  }
}
