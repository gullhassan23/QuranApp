import 'package:app5/model/Juz.dart';

import 'package:flutter/material.dart';

class JuzCustomTile extends StatelessWidget {
  final List<JuzAyahs> list;
  final int index;

  const JuzCustomTile({super.key, required this.list, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3.0)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            list[index].ayahNumber.toString(),
            style: TextStyle(fontSize: 15),
          ),
          Text(
            list[index].ayahsText.toString(),
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            textAlign: TextAlign.end,
          ),
          Text(
            list[index].ayahNumber.toString(),
            style: TextStyle(fontSize: 15),
          ),
          Text(
            list[index].surahName.toString(),
            style: TextStyle(fontSize: 21),
          )
        ],
      ),
    );
  }
}
