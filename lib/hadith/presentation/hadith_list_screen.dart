import 'package:app5/hadith/data/hadith_repository.dart';
import 'package:app5/hadith/domain/hadith_models.dart';
import 'package:app5/hadith/presentation/hadith_detail_screen.dart';
import 'package:app5/hadith/presentation/hadith_themed_scaffold.dart';
import 'package:app5/hadith/presentation/hadith_ui_tokens.dart';
import 'package:app5/hadith/presentation/widgets/hadith_card.dart';
import 'package:app5/hadith/presentation/widgets/hadith_state_views.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HadithListScreen extends StatefulWidget {
  const HadithListScreen({
    super.key,
    required this.bookSlug,
    required this.bookTitle,
    required this.chapter,
  });

  final String bookSlug;
  final String bookTitle;
  final HadithChapter chapter;

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  final _repo = hadithRepository;
  final _scroll = ScrollController();
  final _searchController = TextEditingController();
  final List<HadithItem> _items = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  static const _perPage = 20;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(reset: true);
    _repo.saveLastRead(
      bookSlug: widget.bookSlug,
      chapterNumber: widget.chapter.chapterNumber,
      bookName: widget.bookTitle,
      chapterEnglish: widget.chapter.chapterEnglish,
    );
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loadingMore || _page >= _lastPage) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    if (_scroll.position.pixels > max - 280) {
      _loadMore();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _items.clear();
      });
    }
    try {
      final page = await _repo.getHadithPage(
        bookSlug: widget.bookSlug,
        chapterNumber: widget.chapter.chapterNumber,
        page: 1,
        paginate: _perPage,
        hadithEnglish: _searchQuery.isEmpty ? null : _searchQuery,
        bypassCache: reset,
      );
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(page.items);
        _lastPage = page.lastPage;
        _page = page.currentPage;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _lastPage) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final page = await _repo.getHadithPage(
        bookSlug: widget.bookSlug,
        chapterNumber: widget.chapter.chapterNumber,
        page: next,
        paginate: _perPage,
        hadithEnglish: _searchQuery.isEmpty ? null : _searchQuery,
        bypassCache: true,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _page = page.currentPage;
        _lastPage = page.lastPage;
        _loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  void _submitSearch() {
    _searchQuery = _searchController.text.trim();
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = HadithUiTokens.of(context);
    return HadithThemedScaffold(
      appBar: AppBar(
        title: Text(
          widget.chapter.chapterEnglish,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: tokens.appBarForeground,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _submitSearch(),
              style: GoogleFonts.poppins(
                color: tokens.isWarm ? tokens.sectionTitle : cs.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search English text…',
                hintStyle: GoogleFonts.poppins(
                  color: tokens.isWarm ? tokens.iconSoft : cs.onSurfaceVariant,
                ),
                prefixIcon: Icon(Icons.search, color: tokens.iconSoft),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: tokens.iconSoft,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    if (_searchQuery.isNotEmpty) {
                      _searchQuery = '';
                      _load(reset: true);
                    }
                  },
                ),
                filled: true,
                fillColor: tokens.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const HadithLoadingView()
                : _error != null
                    ? HadithErrorView(
                        message: _error!,
                        onRetry: () => _load(reset: true),
                      )
                    : _items.isEmpty
                        ? HadithEmptyView(
                            message: _searchQuery.isEmpty
                                ? 'No hadith in this chapter.'
                                : 'No results for your search.',
                            icon: Icons.search_off_outlined,
                          )
                        : ListView.separated(
                            controller: _scroll,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: _items.length + (_loadingMore ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              if (i >= _items.length) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: tokens.progressColor,
                                    ),
                                  ),
                                );
                              }
                              final item = _items[i];
                              return HadithCard(
                                item: item,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          HadithDetailScreen(item: item),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
