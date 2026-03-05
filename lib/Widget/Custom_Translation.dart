import 'package:app5/Global.dart';

import 'package:app5/model/Translation.dart';
import 'package:flutter/material.dart';

class TranslationTile extends StatelessWidget {
  final int index;
  final SurahTranslation surahTranslation;

  const TranslationTile(
      {super.key, required this.index, required this.surahTranslation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [BoxShadow(blurRadius: 1)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: containercolor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8))),
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                ),
                Positioned(
                  top: 3,
                  left: 12,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: textprimary,
                    ),
                    child: Text(
                      surahTranslation.aya!,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    surahTranslation.arabic_text!,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        color: textprimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                  Text(
                    surahTranslation.translation!,
                    textAlign: TextAlign.end,
                    style: TextStyle(color: textprimary, fontSize: 18),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
