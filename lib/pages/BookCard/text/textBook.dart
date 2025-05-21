import 'dart:async';
import 'dart:math';

import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/BookCard/text/AppState.dart';
import 'package:booktrack/pages/BookCard/text/BrightnessProvider.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/BookCard/text/SettingsProvider.dart';
import 'package:booktrack/pages/BookCard/text/epigraphWidgers.dart';
import 'package:booktrack/servises/levelServises.dart';
import 'package:booktrack/pages/ProfilePages/Quote/QuoteSelectionToolbar.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:booktrack/pages/BookCard/text/bookReposityr.dart';
import 'package:booktrack/models/chaptersModel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class BookScreen extends StatefulWidget {
  final String bookId;
  final VoidCallback onBack;

  const BookScreen({required this.bookId, required this.onBack, Key? key})
      : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  late final PageController _pageController;
  final BookRepository _repository = BookRepository();
  int _currentPageIndex = 0;
  late List<String> _allPages = [];
  late List<Chapter> _chapters = [];
  DateTime? _sessionStart;
  int _sessionPages = 0;
  Timer? _sessionTimer;
  late BookWithChapters _bookData;
  late List<int> _chapterPageStarts = [];
  int _pagesSinceLastXP = 0;
  int _sessionPageCount = 0;
  DateTime? _sessionStartTime;
  Timer _debounceTimer = Timer(Duration.zero, () {});
  String? _userId;
  int _lastRecordedPage = 0;
  late LevelService _levelService;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeReadingSession();
  }

  Future<void> _initializeReadingSession() async {
    await _loadUserId();
    _startNewSession();
    _startReadingSession();
    await _loadBookData();
    await _loadProgress(); // загружаем прогресс

    // Инициализируем PageController только здесь
    _pageController = PageController(
      initialPage: _allPages.isNotEmpty
          ? min(_currentPageIndex, _allPages.length - 1)
          : 0,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _debounceTimer.cancel();
    _saveAllProgress();
    _pageController.dispose();
    _saveSessionProgress();
    _sessionTimer?.cancel();
    super.dispose();
  }

  void _startNewSession() {
    _sessionStart = DateTime.now();
    _sessionPages = 0;
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _saveSessionProgress();
    });
  }

  Future<void> _saveSessionProgress() async {
    if (_sessionStart == null || _sessionPages == 0) return;

    final minutes = DateTime.now().difference(_sessionStart!).inMinutes;
    if (minutes > 0) {
      final auth = Provider.of<AuthProviders>(context, listen: false);
      final appState = Provider.of<AppState>(context, listen: false);

      await appState.updateReadingProgress(
        minutes: minutes,
        pages: _sessionPages,
        userId: auth.userModel!.uid,
      );

      appState.updatePagesReadToday(_sessionPages);
    }
    _startNewSession();
  }

  Future<void> _loadUserId() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final userModel = authProvider.userModel;

    if (userModel == null || userModel.uid.isEmpty) {
      throw Exception('User not authenticated');
    }

    setState(() {
      _userId = userModel.uid;
      _levelService = LevelService(_userId!);
    });
  }

  void _startReadingSession() {
    _sessionStartTime = DateTime.now();
    _sessionPageCount = 0;
  }

  Future<void> _loadBookData() async {
    try {
      _bookData = await _repository.getBookWithChapters(widget.bookId);
      _chapters = _bookData.chapters;
      await _precalculateAllPages(_bookData, context);
    } catch (e) {
      debugPrint('Error loading book: $e');
    }
  }

  Future<void> _loadProgress() async {
    try {
      int loadedPage = 0;
      final prefs = await SharedPreferences.getInstance();
      loadedPage = prefs.getInt('currentPage_${widget.bookId}') ?? 0;

      if (_userId != null) {
        final progressDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('reading_progress')
            .doc(widget.bookId)
            .get();

        if (progressDoc.exists) {
          final savedPage = progressDoc.data()!['currentPage'] as int? ?? 0;
          loadedPage = max(loadedPage, savedPage);
        }
      }

      if (mounted) {
        setState(() {
          // Обновляем позицию, но не создаём новый контроллер
          _currentPageIndex = loadedPage.clamp(0, _allPages.length - 1);
          _lastRecordedPage = _currentPageIndex;
        });
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  void _onPageChanged(int index) async {
    if (!mounted) return;

    final prevChapter = _getCurrentChapterIndex();
    setState(() => _currentPageIndex = index);
    final currentChapter = _getCurrentChapterIndex();

    if (currentChapter != prevChapter && index > _lastRecordedPage) {
      await _addXP(10);
    }

    if (index > _lastRecordedPage) {
      _sessionPages += index - _lastRecordedPage;
      final pagesRead = index - _lastRecordedPage;
      _pagesSinceLastXP += pagesRead;
      _sessionPageCount += pagesRead;
      _lastRecordedPage = index;

      if (_pagesSinceLastXP >= 10) {
        await _addXP(5);
        _pagesSinceLastXP = 0;
      }
    }

    if (_isLastPage) {
      await _completeBook();
    }

    _debounceSaveProgress();
  }

  bool get _isLastPage => _currentPageIndex == _allPages.length - 1;

  void _debounceSaveProgress() {
    _debounceTimer.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () async {
      await _saveAllProgress();
    });
  }

  Future<void> _saveAllProgress() async {
    await Future.wait([
      _saveCurrentPage(),
      _saveReadingProgress(),
      _updateSessionTime(),
    ]);
  }

  Future<void> _saveCurrentPage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentPage_${widget.bookId}', _currentPageIndex);
    } catch (e) {
      debugPrint('Error saving current page: $e');
    }
  }

  Future<void> _saveReadingProgress() async {
    try {
      if (_userId == null) return;
      final currentChapter = _getCurrentChapterIndex();
      final chapterProgress = _getChapterProgress(currentChapter);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('reading_progress')
          .doc(widget.bookId)
          .set({
        'currentPage': _currentPageIndex,
        'currentChapter': currentChapter,
        'chapterProgress': chapterProgress,
        'totalPages': _allPages.length,
        'dateLastRead': FieldValue.serverTimestamp(),
        'bookId': widget.bookId,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving reading progress: $e');
    }
  }

  int _getCurrentChapterIndex() {
    for (int i = 0; i < _chapterPageStarts.length; i++) {
      if (i == _chapterPageStarts.length - 1 ||
          _currentPageIndex < _chapterPageStarts[i + 1]) {
        return i;
      }
    }
    return 0;
  }

  double _getChapterProgress(int chapterIndex) {
    final startPage = _chapterPageStarts[chapterIndex];
    final endPage = chapterIndex < _chapterPageStarts.length - 1
        ? _chapterPageStarts[chapterIndex + 1]
        : _allPages.length;
    final chapterLength = endPage - startPage;
    final progressInChapter = _currentPageIndex - startPage;

    return chapterLength > 0 ? progressInChapter / chapterLength : 0;
  }

  Future<void> _updateSessionTime() async {
    if (_sessionStartTime == null) return;

    final sessionDuration = DateTime.now().difference(_sessionStartTime!);
    await _saveDailyReadingProgress(sessionDuration);
    _startReadingSession();
  }

  Future<void> _saveDailyReadingProgress(Duration readingTime) async {
    try {
      if (_userId == null) return;
      final today = DateTime.now();
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('reading_goals')
          .doc('goal_${today.year}_${today.month}_${today.day}');

      await docRef.set({
        'date': today,
        'readPages': FieldValue.increment(_sessionPageCount),
        'readMinutes': FieldValue.increment(readingTime.inMinutes),
        'weekStart':
            DateTime(today.year, today.month, today.day - today.weekday + 1),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving daily progress: $e');
    }
  }

  Future<void> _addXP(int amount) async {
    if (_userId == null) {
      debugPrint('User ID is null');
      return;
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(_userId);
        final doc = await transaction.get(userRef);

        if (!doc.exists) {
          transaction.set(userRef, {
            'stats': {
              'current_level': 1,
              'pages': 10,
              'xp': amount,
            },
          });
          return;
        }

        final stats = doc.data()?['stats'] as Map<String, dynamic>? ?? {};
        int currentXP = stats['xp'] ?? 0;
        int currentPages = stats['pages'] ?? 0;

        final int newXP = currentXP + amount;
        final int newPages = currentPages + 10;

        transaction.update(userRef, {
          'stats.xp': newXP,
          'stats.pages': newPages,
        });

        if (mounted) {
          await _levelService.checkLevelUp(context);
        }
      });
    } catch (e) {
      debugPrint('Error in _addXP: $e');
    }
  }

  Future<void> _completeBook() async {
    try {
      if (_userId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(_userId).update({
        'end_books': FieldValue.arrayUnion([widget.bookId]),
        'read_books': FieldValue.arrayRemove([widget.bookId]),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Книга прочитана!')),
        );
        await _addXP(30);
      }
    } catch (e) {
      debugPrint('Error completing book: $e');
    }
  }

  Future<void> _precalculateAllPages(
      BookWithChapters book, BuildContext context) async {
    _allPages = [];
    _chapterPageStarts = [];

    for (var chapter in book.chapters) {
      _chapterPageStarts.add(_allPages.length);
      final chapterPages =
          await splitTextIntoPages(chapter.text, context); // Ждём результат
      _allPages.addAll(
          chapterPages); // Теперь chapterPages - это List<String>, а не Future
    }

    if (_allPages.isEmpty || !_allPages.last.contains("Спасибо за прочтение")) {
      _allPages.add("Спасибо за прочтение!");
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
      backgroundColor: _getBackgroundColor(settings.selectedBackgroundStyle),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: _getTextColor(settings.selectedBackgroundStyle)),
          onPressed: widget.onBack,
        ),
        actions: [
          CircleAvatar(
              backgroundColor: _getBackgroundColor(
                  settings.selectedBackgroundStyle), // цвет круга
              radius: 20, // радиус круга
              child: IconButton(
                icon: Icon(Icons.settings,
                    color: _getTextColor(settings.selectedBackgroundStyle)),
                onPressed: () => _showTextEditor(scale, settings),
              )),
          CircleAvatar(
              backgroundColor: _getBackgroundColor(
                  settings.selectedBackgroundStyle), // цвет круга
              radius: 20, // радиус круга
              child: IconButton(
                icon: Icon(BookTrackIcon.snoskText,
                    color: _getTextColor(settings.selectedBackgroundStyle)),
                onPressed: () => _showFootnotes(context),
              )),
        ],
      ),
      body: _isLoading
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            )
          : Column(
              children: [
                _buildBookHeader(_bookData, context),
                Expanded(
                  child: PageView.builder(
                    itemCount: _allPages.length,
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) => _buildPageContent(index),
                  ),
                ),
                _buildPageFooter(),
              ],
            ),
    );
  }

  Widget _buildPageContent(int pageIndex) {
    final settings = Provider.of<SettingsProvider>(context);
    final chapterIndex = _getCurrentChapterIndexForPage(pageIndex);
    final chapter = _chapters[chapterIndex];

    return FutureBuilder(
      future: Future.microtask(
          () => _buildPageText(pageIndex, chapterIndex, chapter, settings)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          );
        }
        return snapshot.data ?? SizedBox();
      },
    );
  }

  Future<Widget> _buildPageText(int pageIndex, int chapterIndex,
      Chapter chapter, SettingsProvider settings) async {
    final isFirstPageOfChapter = pageIndex == _chapterPageStarts[chapterIndex];
    final textStyle = TextStyle(
      fontSize: settings.fontSize,
      fontFamily: _getFontFamily(settings.selectedFontFamily),
      color: _getTextColor(settings.selectedBackgroundStyle),
      height: 1.5,
    );

    return Listener(
      onPointerMove: (PointerMoveEvent event) {
        if (event.delta.dx > 5) {
          // Добавил порог в 5 пикселей для избежания случайных срабатываний
          // Свайп вправо, перелистываем на предыдущую страницу
          if (_pageController.page!.round() > 0) {
            // Используем текущую страницу из pageController
            _pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        } else if (event.delta.dx < -5) {
          // Аналогичный порог
          // Свайп влево, перелистываем на следующую страницу
          if (_pageController.page!.round() < _allPages.length - 1) {
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFirstPageOfChapter) ...[
              Text(
                chapter.title,
                style: textStyle.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (chapter.epigraph != null)
                EpigraphWidgets(
                  text: chapter.epigraph!.text,
                  author: chapter.epigraph!.author,
                ),
              const SizedBox(height: 16),
            ],
            SelectableText.rich(
              TextSpan(text: _allPages[pageIndex], style: textStyle),
              style: textStyle.copyWith(
                height: 1.5, // Регулировка высоты строки для лучшей читаемости
              ),
              textAlign: TextAlign.justify, // Выравнивание текста по ширине
              selectionControls: _buildQuoteSelectionControls(
                pageIndex: pageIndex,
                chapterId: chapter.id,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCurrentChapterIndexForPage(int pageIndex) {
    for (int i = 0; i < _chapterPageStarts.length; i++) {
      if (i == _chapterPageStarts.length - 1 ||
          pageIndex < _chapterPageStarts[i + 1]) {
        return i;
      }
    }
    return 0;
  }

  TextSelectionControls _buildQuoteSelectionControls({
    required int pageIndex,
    required String chapterId,
  }) {
    return QuoteTextSelectionControls(
      pageIndex: pageIndex,
      chapterId: chapterId,
      onSaveQuote: (selectedText) => _handleQuoteSave(
        selectedText: selectedText,
        pageIndex: pageIndex,
        chapterId: chapterId,
      ),
    );
  }

  Future<void> _handleQuoteSave({
    required String selectedText,
    required int pageIndex,
    required String chapterId,
  }) async {
    try {
      if (_userId == null || _userId!.isEmpty) {
        await _loadUserId();
        if (_userId == null || _userId!.isEmpty) {
          throw Exception('User not authenticated');
        }
      }

      if (widget.bookId.isEmpty || chapterId.isEmpty || selectedText.isEmpty) {
        throw Exception('Required fields are missing');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('quotes')
          .add({
        'bookId': widget.bookId,
        'chapterId': chapterId,
        'quoteText': selectedText,
        'createdAt': FieldValue.serverTimestamp(),
        'pageIndex': pageIndex,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Цитата успешно сохранена')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}')),
        );
      }
      debugPrint('Error saving quote: $e');
    }
  }

  Widget _buildPageFooter() {
    final currentChapter = _getCurrentChapterIndex();
    final chapterStart = _chapterPageStarts[currentChapter];
    final chapterEnd = currentChapter < _chapterPageStarts.length - 1
        ? _chapterPageStarts[currentChapter + 1]
        : _allPages.length;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Глава ${currentChapter + 1}/${_chapters.length} | '
        'Страница ${_currentPageIndex - chapterStart + 1}/${chapterEnd - chapterStart}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getTextColor(
                Provider.of<SettingsProvider>(context).selectedBackgroundStyle,
              ),
            ),
      ),
    );
  }

  Widget _buildBookHeader(BookWithChapters bookData, BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final textStyle = TextStyle(
      fontSize: settings.fontSize,
      fontFamily: _getFontFamily(settings.selectedFontFamily),
      color: _getTextColor(settings.selectedBackgroundStyle),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(bookData.book.title, style: textStyle),
          const SizedBox(height: 8),
          Text(bookData.book.author, style: textStyle),
        ],
      ),
    );
  }

  void _showFootnotes(BuildContext context) {
    final currentChapter = _getCurrentChapterIndex();
    final chapter = _chapters[currentChapter];

    if (chapter.footnotes == null || chapter.footnotes!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет сносок для этой главы')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView(
          children: chapter.footnotes!.entries
              .map((entry) => ListTile(
                    title: Text(entry.value),
                    leading: Text('${entry.key}'),
                  ))
              .toList(),
        );
      },
    );
  }

// Получение цвета фона на основе выбранного стиля
  Color _getBackgroundColor(int selectedBackgroundStyle) {
    switch (selectedBackgroundStyle) {
      case 0:
        return Colors.white; // Белый фон
      case 1:
        return Color(0xffFFF7E0); // Светло-желтый фон
      case 2:
        return Color(0xff858585); // Серый фон
      case 3:
        return AppColors.textPrimary; // Черный фон
      default:
        return Colors.white;
    }
  }

  // Получение цвета текста на основе выбранного стиля
  Color _getTextColor(int selectedBackgroundStyle) {
    switch (selectedBackgroundStyle) {
      case 0:
        return AppColors.textPrimary; // Черный текст
      case 1:
        return AppColors.textPrimary; // Черный текст
      case 2:
        return Colors.white; // Белый текст
      case 3:
        return Colors.white; // Белый текст
      default:
        return AppColors.textPrimary;
    }
  }

  // Получение шрифта на основе выбранного стиля
  String _getFontFamily(int selectedFontFamily) {
    switch (selectedFontFamily) {
      case 0:
        return 'MPLUSRounded1c';
      case 1:
        return 'Rubik';
      case 2:
        return 'Inter';
      case 3:
        return 'AdventPro';
      default:
        return 'MPLUSRounded1c';
    }
  }

  void _showTextEditor(double scale, SettingsProvider settings) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.8;

        // Локальные переменные для временных настроек
        int tempBackgroundStyle = settings.selectedBackgroundStyle;
        int tempFontFamily = settings.selectedFontFamily;
        double tempFontSize = settings.fontSize;
        double tempBrightness = settings.brightness;
        final brightnessProvider =
            Provider.of<BrightnessProvider>(context, listen: false);

        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: height,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Настройки',
                      style: TextStyle(
                        fontSize: 32 * scale,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 11 * scale),
                    Text(
                      "Яркость",
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 11 * scale),
                    Column(
                      children: [
                        Slider(
                          activeColor: Colors.orange,
                          value: brightnessProvider.brightness,
                          max: 100,
                          onChanged: (double value) {
                            brightnessProvider.setBrightness(value);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  BookTrackIcon.sunSettingBook,
                                  size: 30 * scale,
                                  color: AppColors.orange,
                                ),
                                Text(
                                  '0%',
                                  style: TextStyle(
                                    fontSize: 16 * scale,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  BookTrackIcon.sunSettingBook,
                                  size: 30 * scale,
                                  color: AppColors.orange,
                                ),
                                Text(
                                  '100%',
                                  style: TextStyle(
                                    fontSize: 16 * scale,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * scale),
                    Text(
                      'Цветовая тема',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempBackgroundStyle = 0;
                            });
                          },
                          child: Container(
                            width: 80 * scale,
                            height: 35 * scale,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: tempBackgroundStyle == 0
                                    ? AppColors.orange
                                    : Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Аа',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16 * scale,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempBackgroundStyle = 1;
                            });
                          },
                          child: Container(
                            width: 80 * scale,
                            height: 35 * scale,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: tempBackgroundStyle == 1
                                    ? AppColors.orange
                                    : Colors.white,
                              ),
                              color: Color(0xffFFF7E0), // Цвет фона для стиля 1
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Аа',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16 * scale,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempBackgroundStyle = 2;
                            });
                          },
                          child: Container(
                            width: 80 * scale,
                            height: 35 * scale,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: tempBackgroundStyle == 2
                                    ? AppColors.orange
                                    : Colors.white,
                              ),
                              color: Color(0xff858585), // Цвет фона для стиля 2
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Аа',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * scale,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempBackgroundStyle = 3;
                            });
                          },
                          child: Container(
                            width: 80 * scale,
                            height: 35 * scale,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: tempBackgroundStyle == 3
                                    ? AppColors.orange
                                    : Colors.white,
                              ),
                              color: AppColors
                                  .textPrimary, // Цвет фона для стиля 3
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Аа',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * scale,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Шрифт',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempFontFamily = 0;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80 * scale,
                                height: 35 * scale,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: tempFontFamily == 0
                                        ? AppColors.orange
                                        : AppColors.blueColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Аа',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16 * scale,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                'Rounded',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempFontFamily = 1;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80 * scale,
                                height: 35 * scale,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: tempFontFamily == 1
                                        ? AppColors.orange
                                        : AppColors.blueColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Аа',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontFamily: "Rubik",
                                    fontSize: 16 * scale,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                'Rubik',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempFontFamily = 2;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80 * scale,
                                height: 35 * scale,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: tempFontFamily == 2
                                        ? AppColors.orange
                                        : AppColors.blueColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Аа',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontFamily: "Inter",
                                    fontSize: 16 * scale,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                'Inter',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempFontFamily = 3;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80 * scale,
                                height: 35 * scale,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: tempFontFamily == 3
                                        ? AppColors.orange
                                        : AppColors.blueColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Аа',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontFamily: "AdventPro",
                                    fontSize: 16 * scale,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                'Advent',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Размер текста',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 40 * scale,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SfSlider(
                          activeColor: AppColors.orange,
                          min: 16.0,
                          max: 40.0,
                          value: tempFontSize,
                          interval: 4,
                          showTicks: true,
                          minorTickShape: const SfTickShape(),
                          onChanged: (value) {
                            setState(() {
                              tempFontSize = value;
                            });
                          },
                        ),
                        SizedBox(height: 16 * scale),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              AppColors.background,
                            ),
                          ),
                          onPressed: () {
                            // Применяем настройки через провайдер
                            settings.setBackgroundStyle(tempBackgroundStyle);
                            settings.setFontFamily(tempFontFamily);
                            settings.setFontSize(tempFontSize);
                            settings.setBrightness(tempBrightness);

                            // Закрываем модальное окно
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Применить",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<String>> splitTextIntoPages(
      String text, BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final textStyle = TextStyle(
      fontSize: settings.fontSize,
      fontFamily: _getFontFamily(settings.selectedFontFamily),
    );

    final textPainter = TextPainter(
      text: TextSpan(text: 'Sample', style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    final lineHeight = textPainter.height;

    final screenHeight = MediaQuery.of(context).size.height;
    final linesPerPage = ((screenHeight - 200) / lineHeight).floor();

    return await compute(
      splitTextIntoPagesIsolate,
      {
        'text': text,
        'lineHeight': lineHeight,
        'linesPerPage': linesPerPage.toDouble(),
        'maxWidth': MediaQuery.of(context).size.width - 32,
        'fontSize': settings.fontSize,
        'fontFamily': _getFontFamily(settings.selectedFontFamily),
      },
    );
  }

  List<String> splitTextIntoPagesIsolate(Map<String, dynamic> params) {
    final text = params['text'] as String;
    final double lineHeight = params['lineHeight'];
    final double linesPerPage = params['linesPerPage'];
    final double maxWidth = params['maxWidth'];
    final String fontFamily = params['fontFamily'];
    final double fontSize = params['fontSize'];

    final textStyle = TextStyle(fontSize: fontSize, fontFamily: fontFamily);

    final words = text.split(' ');
    List<String> pages = [];
    String currentPage = '';

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    for (final word in words) {
      final testText = currentPage.isEmpty ? word : '$currentPage $word';
      textPainter.text = TextSpan(text: testText, style: textStyle);
      textPainter.layout(maxWidth: maxWidth);
      final testLines = (textPainter.height / lineHeight).ceil();

      if (testLines <= linesPerPage) {
        currentPage = testText;
      } else {
        pages.add(currentPage);
        currentPage = word;
      }
    }

    if (currentPage.isNotEmpty) {
      pages.add(currentPage);
    }

    return pages;
  }
}

class QuoteTextSelectionControls extends MaterialTextSelectionControls {
  final int pageIndex;
  final String chapterId;
  final Function(String)? onSaveQuote;

  QuoteTextSelectionControls({
    required this.pageIndex,
    required this.chapterId,
    this.onSaveQuote,
  });

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double toolbarHeight,
    Offset position,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ValueListenable<ClipboardStatus>? clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    // Откладываем показ диалога до следующего кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showQuoteDialog(context, delegate);
    });

    return const SizedBox.shrink();
  }

  void _showQuoteDialog(BuildContext context, TextSelectionDelegate delegate) {
    final selection = delegate.textEditingValue.selection;
    final text = delegate.textEditingValue.text;

    // Проверяем, что выделение действительно содержит текст
    if (selection.isValid &&
        !selection.isCollapsed &&
        selection.start >= 0 &&
        selection.end <= text.length) {
      showDialog(
        context: context,
        builder: (context) => QuoteSelectionDialog(
          delegate: delegate,
          onSaveQuote: (selectedText) {
            if (onSaveQuote != null) {
              onSaveQuote!(selectedText);
            }
          },
        ),
      );
    } else {
      // Если выделение невалидно, показываем сообщение
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выделите текст для цитирования')),
      );
    }
  }
}
