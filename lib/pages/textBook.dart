import 'dart:async';
import 'dart:math';

import 'package:booktrack/icons2.dart';
import 'package:booktrack/pages/BrightnessProvider.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/SettingsProvider.dart';
import 'package:booktrack/pages/epigraphWidgers.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:booktrack/pages/bookReposityr.dart';
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
  late Future<BookWithChapters> _bookData;
  final BookRepository _repository = BookRepository();
  int _currentPageIndex = 0;
  late List<String> _allPages = [];
  late List<Chapter> _chapters = [];
  late List<String> _epigraph = [];

  late BookWithChapters _bookDatas;
  late List<int> _chapterPageStarts = [];

  // Система прогресса
  int _pagesSinceLastXP = 0;
  int _sessionPageCount = 0;
  DateTime? _sessionStartTime;
  Timer _debounceTimer = Timer(Duration.zero, () {});
  String? _userId; 

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadUserId().then((_) {
      _startReadingSession();
      _bookData = _repository.getBookWithChapters(widget.bookId);
      _loadBookData().then(
          (_) => _loadProgress()); // Загружаем прогресс после данных книги
    });
  }

  @override
  void dispose() {
    _debounceTimer.cancel();
    _saveAllProgress();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final userModel = authProvider.userModel;

    if (userModel == null || userModel.uid.isEmpty) {
      throw Exception('User not authenticated');
    }

    setState(() {
      _userId = userModel.uid;
    });
  }

  void _startReadingSession() {
    _sessionStartTime = DateTime.now();
    _sessionPageCount = 0;
  }

  Future<void> _loadBookData() async {
    try {
      if (_userId == null) return;
      final book = await _repository.getBookWithChapters(widget.bookId);
      if (mounted) {
        setState(() {
          _bookDatas = book;
          _chapters = book.chapters;
          _precalculateAllPages(book);
        });
        await _loadProgress();

        // После загрузки данных и прогресса - переходим на нужную страницу
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients && _currentPageIndex > 0) {
            _pageController.jumpToPage(_currentPageIndex);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading book: $e');
    }
  }

  Future<void> _loadProgress() async {
    try {
      int loadedPage = 0;

      // 1. Сначала пробуем загрузить из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final prefsPage = prefs.getInt('currentPage_${widget.bookId}') ?? 0;
      loadedPage = prefsPage;

      // 2. Затем проверяем Firestore (если есть пользователь)
      if (_userId != null) {
        final progressDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('reading_progress')
            .doc(widget.bookId)
            .get();

        if (progressDoc.exists) {
          final progressData = progressDoc.data()!;
          final savedPage = progressData['currentPage'] as int? ?? 0;

          // Выбираем максимальный прогресс из всех источников
          loadedPage = max(loadedPage, savedPage);

          // Синхронизируем если количество страниц изменилось
          final savedTotalPages = progressData['totalPages'] as int? ?? 0;
          if (savedTotalPages != _allPages.length) {
            await _saveReadingProgress();
          }
        }
      }

      // Устанавливаем загруженное значение с проверкой границ
      if (mounted) {
        setState(() {
          _currentPageIndex = min(loadedPage, _allPages.length - 1);
          _lastRecordedPage = _currentPageIndex;
        });

        // Прокручиваем к нужной странице после построения виджетов
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(_currentPageIndex);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  void _precalculateAllPages(BookWithChapters book) {
    _allPages = [];
    _chapterPageStarts = [];
    _epigraph = [];

    for (var chapter in book.chapters) {
      _chapterPageStarts.add(_allPages.length);

      if (chapter.epigraph != null) {
        _epigraph.add('${chapter.epigraph!.text}\n${chapter.epigraph!.author}');
      } else {
        _epigraph.add('');
      }

      final chapterPages = _splitTextIntoPages(chapter.text);
      _allPages.addAll(chapterPages);
    }

    // Добавляем последнюю страницу
    if (_allPages.isEmpty || !_allPages.last.contains("Спасибо за прочтение")) {
      _allPages.add("Спасибо за прочтение!");
    }
  }

  int _lastRecordedPage = 0;

  void _onPageChanged(int index) async {
    final prevChapter = _getCurrentChapterIndex();

    // Обновляем текущую страницу
    setState(() => _currentPageIndex = index);

    final currentChapter = _getCurrentChapterIndex();

    // Если перешли в новую главу
    if (currentChapter != prevChapter && index > _lastRecordedPage) {
      await _addXP(2); // Бонус за начало новой главы
    }
    // Учитываем только переходы вперед
    if (index > _lastRecordedPage) {
      final pagesRead = index - _lastRecordedPage;
      _pagesSinceLastXP += pagesRead;
      _sessionPageCount += pagesRead;
      _lastRecordedPage = index;

      // Начисляем XP каждые 10 страниц
      if (_pagesSinceLastXP >= 10) {
        await _addXP(1);
        _pagesSinceLastXP = 0;
      }
    }

    setState(() => _currentPageIndex = index);

    // Проверяем завершение книги
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
        'dateLastRead': DateTime.now(),
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
    try {
      if (_userId == null) return;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(_userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(userRef);

        // Создаем stats если нет
        if (!doc.exists || !doc.data()!.containsKey('stats')) {
          transaction.set(
              userRef,
              {
                'stats': {'current_level': 1, 'pages': 0, 'xp': 0}
              },
              SetOptions(merge: true));
        }

        transaction.update(userRef, {
          'stats.xp': FieldValue.increment(amount),
          'stats.pages': FieldValue.increment(10),
        });
      });
    } catch (e) {
      debugPrint('Error adding XP: $e');
    }
  }

  Future<void> _completeBook() async {
    try {
      if (_userId == null) return;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(_userId);

      await userRef.update({
        'end_books': FieldValue.arrayUnion([widget.bookId]),
        'read_books': FieldValue.arrayRemove([widget.bookId]),
      });

      // Показываем уведомление о завершении
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Книга прочитана!')));
    } catch (e) {
      debugPrint('Error completing book: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Scaffold(
      backgroundColor: _getBackgroundColor(settings.selectedBackgroundStyle),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: widget.onBack,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showTextEditor(scale, settings),
          ),
          IconButton(
            icon: Icon(Icons.notes),
            onPressed: () => _showFootnotes(context),
          ),
        ],
      ),
      body: _chapters.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildBookHeader(_bookDatas, context),
                Expanded(
                  child: PageView.builder(
                    itemCount: _allPages.length, controller: _pageController,
                    onPageChanged:
                        _onPageChanged, // Теперь используется ваш метод
                    itemBuilder: (context, index) => _buildPageContent(index),
                  ),
                ),
                _buildPageFooter(),
              ],
            ),
    );
  }

  Widget _buildPageContent(int pageIndex) {
    // Определяем, к какой главе относится текущая страница
    int chapterIndex = 0;
    for (int i = 0; i < _chapterPageStarts.length; i++) {
      if (pageIndex >= _chapterPageStarts[i]) {
        chapterIndex = i;
      } else {
        break;
      }
    }

    final isFirstPageOfChapter = pageIndex == _chapterPageStarts[chapterIndex];
    final chapter = _chapters[chapterIndex];
    final settings = Provider.of<SettingsProvider>(context);

    if (isFirstPageOfChapter && chapter.epigraph != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок главы
            Text(
              chapter.title,
              style: TextStyle(
                fontSize: settings.fontSize,
                fontFamily: _getFontFamily(settings.selectedFontFamily),
                color: _getTextColor(settings.selectedBackgroundStyle),
              ),
            ),
            // Виджет эпиграфа
            EpigraphWidgets(
              text: chapter.epigraph!.text,
              author: chapter.epigraph!.author,
            ),
            SizedBox(height: 16),
            // Текст страницы
            Text(
              _allPages[pageIndex],
              style: TextStyle(
                fontSize: settings.fontSize,
                fontFamily: _getFontFamily(settings.selectedFontFamily),
                color: _getTextColor(settings.selectedBackgroundStyle),
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFirstPageOfChapter)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                chapter.title,
                style: TextStyle(
                  fontSize: settings.fontSize,
                  fontFamily: _getFontFamily(settings.selectedFontFamily),
                  color: _getTextColor(settings.selectedBackgroundStyle),
                ),
              ),
            ),
          Text(
            _allPages[pageIndex],
            style: TextStyle(
              fontSize: settings.fontSize,
              fontFamily: _getFontFamily(settings.selectedFontFamily),
              color: _getTextColor(settings.selectedBackgroundStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageFooter() {
    // Определяем текущую главу
    int currentChapter = 0;
    for (int i = 0; i < _chapterPageStarts.length; i++) {
      if (_currentPageIndex >= _chapterPageStarts[i]) {
        currentChapter = i;
      } else {
        break;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Глава ${currentChapter + 1}/${_chapters.length} | '
        'Страница ${_currentPageIndex - _chapterPageStarts[currentChapter] + 1}/'
        '${_chapterPageStarts.length > currentChapter + 1 ? _chapterPageStarts[currentChapter + 1] - _chapterPageStarts[currentChapter] : _allPages.length - _chapterPageStarts[currentChapter]}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  List<String> _splitTextIntoPages(String text) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final textStyle = TextStyle(
      fontSize: settings.fontSize,
      fontFamily: _getFontFamily(settings.selectedFontFamily),
      color: _getTextColor(settings.selectedBackgroundStyle),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    // Рассчитываем высоту текста
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    final textHeight = textPainter.height;

    // Определяем количество строк на странице
    final linesPerPage =
        (MediaQuery.of(context).size.height - 200) / textHeight;

    // Разбиваем текст на страницы
    final words = text.split(' ');
    List<String> pages = [];
    String currentPage = '';

    for (final word in words) {
      final testText = currentPage.isEmpty ? word : '$currentPage $word';
      textPainter.text = TextSpan(
        text: testText,
        style: textStyle,
      );
      textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
      final testLines = textPainter.height / textHeight;

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

  Widget _buildBookHeader(BookWithChapters bookData, BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bookData.book.title,
            style: TextStyle(
              fontSize: settings.fontSize,
              fontFamily: _getFontFamily(settings.selectedFontFamily),
              color: _getTextColor(settings.selectedBackgroundStyle),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bookData.book.author,
            style: TextStyle(
              fontSize: settings.fontSize,
              fontFamily: _getFontFamily(settings.selectedFontFamily),
              color: _getTextColor(settings.selectedBackgroundStyle),
            ),
          ),
        ],
      ),
    );
  }

  void _showFootnotes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return FutureBuilder<BookWithChapters>(
          future: _bookData,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();

            // Определяем текущую главу для сносок
            int currentChapter = 0;
            for (int i = 0; i < _chapterPageStarts.length; i++) {
              if (_currentPageIndex >= _chapterPageStarts[i]) {
                currentChapter = i;
              } else {
                break;
              }
            }

            final chapter = snapshot.data!.chapters[currentChapter];
            if (chapter.footnotes == null) return Text('Нет сносок');

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
                                  MyFlutter.sun,
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
                                  MyFlutter.sun,
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
}
