import 'package:app5/Global.dart';
import 'package:app5/model/Surah.dart';
import 'package:flutter/material.dart';

Widget SurahCustomListTile(
    {required Surah surah,
    required BuildContext context,
    required VoidCallback ontap}) {
  return GestureDetector(
    onTap: ontap,
    child: Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF6D7C3), // light peach
              Color(0xFFF2C6AD), // darker peach
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3.0,
            )
          ]),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 36,
                width: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: textprimary,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    surah.number.toString(),
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    surah.englishNameTranslation,
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              Spacer(),
              Text(
                surah.name,
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )
            ],
          )
        ],
      ),
    ),
  );
}
