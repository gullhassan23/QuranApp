// import 'dart:math';

// import 'package:app5/Global.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_compass/flutter_compass.dart';

// class CompassScreen extends StatefulWidget {
//   const CompassScreen({super.key});

//   @override
//   State<CompassScreen> createState() => _CompassScreenState();
// }

// class _CompassScreenState extends State<CompassScreen> {
//   double? heading = 0;

//   @override
//   void initState() {
//     super.initState();
//     FlutterCompass.events!.listen((event) {
//       setState(() {
//         heading = event.heading;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: background,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             "${heading!.ceil()}°",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(
//             height: 50.0,
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Image.asset(
//                   "assets/images/cadrant.png",
//                   color: Colors.white,
//                 ),
//                 Transform.rotate(
//                   angle: ((heading ?? 0) * (pi / 180) * -1),
//                   child: Image.asset(
//                     "assets/images/needle.png",
//                     height: 300,
//                     scale: 1.1,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
