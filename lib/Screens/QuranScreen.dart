import 'package:app5/Global.dart';
import 'package:app5/Screens/Juz_screen.dart';
import 'package:app5/Screens/surah_details.dart';
import 'package:app5/Service/api_service.dart';
import 'package:app5/Widget/SajdaCustomTile.dart';
import 'package:app5/Widget/SurahCustomFile.dart';
import 'package:app5/constants/constants.dart';
import 'package:app5/model/Surah.dart';
import 'package:app5/model/sajda.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final ApiServices apiServices = ApiServices();
  late final Future<List<Surah>> _surahsFuture;
  late final Future<SajdaList> _sajdaFuture;

  final TextEditingController _surahSearchController = TextEditingController();
  final TextEditingController _sajdaSearchController = TextEditingController();
  final TextEditingController _juzSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _surahsFuture = apiServices.getSurah();
    _sajdaFuture = apiServices.getSajda();
  }

  @override
  void dispose() {
    _surahSearchController.dispose();
    _sajdaSearchController.dispose();
    _juzSearchController.dispose();
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

  List<SajdaAyat> _filterSajda(List<SajdaAyat> all, String query) {
    final q = query.trim();
    if (q.isEmpty) return all;
    final lower = q.toLowerCase();
    final digitsOnly = RegExp(r'^\d+$').hasMatch(q);
    return all.where((s) {
      if (s.surahEnglishName.toLowerCase().contains(lower)) return true;
      if (s.englishNameTranslation.toLowerCase().contains(lower)) return true;
      if (s.surahName.contains(q)) return true;
      if (digitsOnly && s.juzNumber.toString().contains(q)) return true;
      if (digitsOnly && s.number.toString().contains(q)) return true;
      return false;
    }).toList();
  }

  List<int> _filterJuzNumbers(String query) {
    final all = List<int>.generate(30, (i) => i + 1);
    final q = query.trim();
    if (q.isEmpty) return all;
    if (!RegExp(r'^\d+$').hasMatch(q)) return all;
    return all.where((j) => j.toString().contains(q)).toList();
  }

  Widget _searchField({
    required TextEditingController controller,
    required String hint,
    required VoidCallback onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: TextField(
        controller: controller,
        onChanged: (_) => onChanged(),
        style: GoogleFonts.poppins(color: textprimary, fontSize: 15),
        cursorColor: textprimary,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: dark.withOpacity(0.6),
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search, color: textprimary),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: textprimary),
                  onPressed: () {
                    controller.clear();
                    onChanged();
                  },
                )
              : null,
          filled: true,
          fillColor: containercolor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        initialIndex: 0,
        child: SafeArea(
            child: Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: backgroundColor,
            centerTitle: true,
            bottom: TabBar(
              tabs: [
                Text(
                  "Surah",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textprimary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Sajda",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textprimary,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Juz",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: textprimary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FutureBuilder<List<Surah>>(
                  future: _surahsFuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Surah>> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final all = snapshot.data!;
                    final filtered =
                        _filterSurahs(all, _surahSearchController.text);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _searchField(
                          controller: _surahSearchController,
                          hint: 'Search surah by name, translation, or number…',
                          onChanged: () => setState(() {}),
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
                                    final surah = filtered[index];
                                    return SurahCustomListTile(
                                      surah: surah,
                                      context: context,
                                      ontap: () {
                                        setState(() {
                                          Constants.surahIndex = surah.number;
                                        });
                                        Navigator.pushNamed(
                                            context, SurahDetails.id);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }),
              FutureBuilder<SajdaList>(
                future: _sajdaFuture,
                builder: (context, AsyncSnapshot<SajdaList> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final all = snapshot.data!.sajdaAyahs;
                  final filtered =
                      _filterSajda(all, _sajdaSearchController.text);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _searchField(
                        controller: _sajdaSearchController,
                        hint:
                            'Search by surah name, translation, ayah or juz no…',
                        onChanged: () => setState(() {}),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  'No sajda ayah found',
                                  style: GoogleFonts.poppins(
                                    color: dark,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 16),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) =>
                                    SajdaCustomTile(filtered[index], context),
                              ),
                      ),
                    ],
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF6D7C3),
                      Color(0xFFF2C6AD),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _searchField(
                      controller: _juzSearchController,
                      hint: 'Filter juz by number (e.g. 5, 12)…',
                      onChanged: () => setState(() {}),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Builder(
                          builder: (context) {
                            final juzList =
                                _filterJuzNumbers(_juzSearchController.text);
                            if (juzList.isEmpty) {
                              return Center(
                                child: Text(
                                  'No juz matches',
                                  style: GoogleFonts.poppins(
                                    color: dark,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }
                            return GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
                              itemCount: juzList.length,
                              itemBuilder: (context, index) {
                                final juz = juzList[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Constants.juzIndex = juz;
                                    });
                                    Navigator.pushNamed(context, JuzScreen.id);
                                  },
                                  child: Card(
                                    elevation: 4,
                                    color: containercolor,
                                    child: Center(
                                      child: Text(
                                        '$juz',
                                        style: GoogleFonts.poppins(
                                          fontSize: 25,
                                          color: textprimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )));
  }
}
