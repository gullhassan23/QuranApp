import 'package:flutter/material.dart';

class Constants {
  static const kPrimary = Color(0xff8a51d1);
  // static const MaterialColor kSwatchColor =
  //     const MaterialColor(primary, swatch);

  static int? juzIndex;
  static int? surahIndex;
}

Map<String, String> getGreetingAndImage() {
  final currentTime = DateTime.now();
  final hour = currentTime.hour;

  if (hour < 12) {
    return {
      'greeting': 'GOOD MORNING'
      // Replace with your morning image asset
    };
  } else if (hour > 12 && hour < 18) {
    return {
      'greeting': 'GOOD AFTERNOON'
      // Replace with your afternoon image asset
    };
  } else {
    return {
      'greeting': 'GOOD NIGHT'
      // Replace with your evening image asset
    };
  }
}
