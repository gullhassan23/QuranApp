import 'package:app5/Global.dart';
import 'package:app5/Screens/AudioSurahScreen.dart';
import 'package:app5/Service/api_service.dart';
import 'package:app5/Widget/qariCustomTile.dart';
import 'package:app5/model/qari.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class QariScreen extends StatelessWidget {
  ApiServices apiServices = ApiServices();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: gray,
        body: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 12, right: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text("List of Qari",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),)),
              ),
              SizedBox(
                height: 12,
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                  child: FutureBuilder(
                future: apiServices.getQariList(),
                builder:
                    (BuildContext context, AsyncSnapshot<List<Qari>> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Qari\'s data not found'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return QariCustomTile(
                            qari: snapshot.data![index],
                            ontap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AudioSurahScreen(
                                          qari: snapshot.data![index])));
                            });
                      });
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}
