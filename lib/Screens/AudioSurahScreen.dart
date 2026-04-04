import 'package:app5/Global.dart';
import 'package:app5/Screens/AudioScreen.dart';
import 'package:app5/Service/api_service.dart';

import 'package:app5/model/Surah.dart';
import 'package:app5/model/qari.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AudioSurahScreen extends StatefulWidget {
  const AudioSurahScreen({
    Key? key,
    required this.qari,
  }) : super(key: key);
  final Qari qari;

  @override
  State<AudioSurahScreen> createState() => _AudioSurahScreenState();
}

class _AudioSurahScreenState extends State<AudioSurahScreen> {
  final ApiServices apiServices = ApiServices();
  final TextEditingController _searchController = TextEditingController();
  late final Future<List<Surah>> _surahsFuture;

  @override
  void initState() {
    super.initState();
    _surahsFuture = apiServices.getSurah();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Surah> _filterSurahs(List<Surah> all, String query) {
    final q = query.trim();
    if (q.isEmpty) return all;
    final lower = q.toLowerCase();
    final digitsOnly = RegExp(r'^\d+$').hasMatch(q);
    return all.where((s) {
      if (s.englishName.toLowerCase().contains(lower)) return true;
      if (s.englishNameTranslation.toLowerCase().contains(lower)) return true;
      if (s.name.contains(q)) return true;
      if (digitsOnly && s.number.toString().contains(q)) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          surfaceTintColor: backgroundColor,
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Surah List",
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: textprimary,
              letterSpacing: 1,
            ),
          ),
        ),
        body: FutureBuilder<List<Surah>>(
          future: _surahsFuture,
          builder: (BuildContext context, AsyncSnapshot<List<Surah>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final all = snapshot.data!;
            final filtered = _filterSurahs(all, _searchController.text);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: GoogleFonts.poppins(
                      color: textprimary,
                      fontSize: 15,
                    ),
                    cursorColor: textprimary,
                    decoration: InputDecoration(
                      hintText: 'Search by name, translation, or number…',
                      hintStyle: GoogleFonts.poppins(
                        color: dark.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: textprimary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: textprimary),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: containercolor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No surah found',
                            style: GoogleFonts.poppins(
                              color: dark,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            return AudioTile(
                              surahName: s.englishName,
                              totalAya: s.numberOfAyahs,
                              number: s.number,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AudioScreen(
                                      qari: widget.qari,
                                      index: s.number,
                                      list: all,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget AudioTile(
    {required String? surahName,
    required totalAya,
    required number,
    required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: containercolor,
            boxShadow: [
              BoxShadow(
                  blurRadius: 3,
                  spreadRadius: 0,
                  color: Colors.black12,
                  offset: Offset(0, 1))
            ]),
        child: Row(
          children: [
            // Container(
            //   alignment: Alignment.center,
            //   height: 30,
            //   width: 40,
            //   padding: EdgeInsets.all(8),
            //   decoration:
            //       BoxDecoration(shape: BoxShape.circle, color: Colors.black),
            //   child: Text(
            //     (number).toString(),
            //     style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold),
            //   ),
            // ),
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
                  (number).toString(),
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surahName!,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: textprimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  "Total Aya : $totalAya",
                  style: TextStyle(
                      color: Color.fromARGB(255, 110, 64, 30), fontSize: 16),
                )
              ],
            ),
            Spacer(),
            Icon(
              Icons.play_circle_fill,
              color: textprimary,
            )
          ],
        ),
      ),
    ),
  );
}
