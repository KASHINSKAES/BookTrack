import 'dart:async';
import 'dart:math';

import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/BookCard/text/AppState.dart';
import 'package:booktrack/pages/BookCard/text/BrightnessProvider.dart';
import 'package:booktrack/pages/BookCard/text/loadingText.dart';
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
  LoadingPhase _loadingPhase = LoadingPhase.downloading;
  late PageController _pageController = PageController(); // Initialize here
  final BookRepository _repository = BookRepository();
  int _currentPageIndex = 0;
  List<String> _allPages = [];
  List<Chapter> _chapters = [];
  DateTime? _sessionStart;
  int _sessionPages = 0;
  Timer? _sessionTimer;
  late BookWithChapters _bookData;
  List<int> _chapterPageStarts = [];
  int _pagesSinceLastXP = 0;
  int _sessionPageCount = 0;
  DateTime? _sessionStartTime;
  Timer _debounceTimer = Timer(Duration.zero, () {});
  String? _userId;
  int _lastRecordedPage = 0;
  late LevelService _levelService;
  bool _isLoading = true;
  bool _processingInterrupted = false;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeReadingSession();
  }

  Future<void> _initializeReadingSession() async {
    try {
      await _loadUserId();
      _startNewSession();
      _startReadingSession();
      await _loadBookData();
      await _loadProgress(); // Теперь _currentPageIndex установлен правильно

      if (mounted) {
        setState(() {
          _isLoading = false;
          // Инициализируем контроллер только после загрузки данных
          _pageController = PageController(
            initialPage: _allPages.isNotEmpty
                ? _currentPageIndex.clamp(0, _allPages.length - 1)
                : 0,
          );
        });
      }
    } catch (e) {
      debugPrint('Error initializing reading session: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _allPages = ['Error loading book content'];
          // Инициализируем контроллер даже при ошибке
          _pageController = PageController();
        });
      }
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

      // Проверка на полученные данные
      if (_bookData.book.title.isEmpty) {
        throw Exception('Не удалось загрузить данные книги');
      }

      _chapters = _bookData.chapters;

      // Проверка на наличие глав
      if (_chapters.isEmpty) {
        throw Exception('Книга не содержит глав');
      }

      await _precalculateAllPages(_bookData, context);
    } catch (e) {
      debugPrint('Error loading book: $e');
      if (mounted) {
        setState(() {
          _allPages = ['Ошибка загрузки книги: ${e.toString()}'];
          _isLoading = false;
        });
      }
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
          _currentPageIndex = loadedPage.clamp(0, _allPages.length - 1);
          _lastRecordedPage = _currentPageIndex;

          // Если контроллер уже инициализирован, переходим на нужную страницу
          if (_pageController != null && _pageController.hasClients) {
            _pageController.jumpToPage(_currentPageIndex);
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
    }
  }

  void _onPageChanged(int index) async {
    if (!mounted || index == _currentPageIndex || _allPages.isEmpty) return;

    final prevChapter = _getCurrentChapterIndex();
    setState(() => _currentPageIndex = index);
    final currentChapter = _getCurrentChapterIndex();

    // Обновляем данные только если листаем вперед
    if (index > _lastRecordedPage) {
      final pagesRead = index - _lastRecordedPage;
      _sessionPages += pagesRead;
      _pagesSinceLastXP += pagesRead;
      _sessionPageCount += pagesRead;
      _lastRecordedPage = index;

      // Обновляем AppState в реальном времени
      final appState = Provider.of<AppState>(context, listen: false);

      if (_pagesSinceLastXP >= 10) {
        await _addXP(5);
        _pagesSinceLastXP = 0;
      }
    }

    _debounceSaveProgress();
  }

  // Добавляем недостающий метод
  void _debounceSaveProgress() {
    _debounceTimer?.cancel();
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
    if (_chapterPageStarts.isEmpty) return 0;

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

      // Сохраняем в Firestore
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('reading_goals')
          .doc('goal_${today.year}_${today.month}_${today.day}');

      await docRef.set({
        'date': today,
        'readPages': FieldValue.increment(_sessionPageCount),
        'readMinutes': FieldValue.increment(readingTime.inMinutes),
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
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadingProgress = 0;
        _allPages = [];
        _chapterPageStarts = [];
      });
    }

    try {
      if (book.chapters.isEmpty) {
        throw Exception('Книга не содержит глав');
      }

      const batchSize = 2;
      final totalChapters = book.chapters.length;
      int processedChapters = 0;

      for (int i = 0; i < totalChapters; i += batchSize) {
        if (!mounted || _processingInterrupted) break;

        await Future.delayed(const Duration(milliseconds: 50));

        final endIndex = min(i + batchSize, totalChapters);
        final batch = book.chapters.sublist(i, endIndex);

        // Используем List<Future<List<String>>> для batchFutures
        final List<Future<List<String>>> batchFutures =
            batch.map((chapter) async {
          if (chapter.text.isEmpty) {
            return ['Глава не содержит текста'];
          }
          try {
            return await splitTextIntoPages(chapter.text, context);
          } catch (e) {
            debugPrint('Ошибка обработки главы: $e');
            return ['Ошибка загрузки содержимого главы'];
          }
        }).toList();

        final batchResults = await Future.wait<List<String>>(batchFutures);

        if (!mounted || _processingInterrupted) break;

        for (int j = 0; j < batchResults.length; j++) {
          processedChapters++;
          _chapterPageStarts.add(_allPages.length);
          _allPages.addAll(batchResults[j]);

          if (mounted) {
            setState(() {
              _loadingProgress = processedChapters / totalChapters;
            });
          }
        }
      }

      if (!_processingInterrupted && mounted) {
        if (_allPages.isEmpty) {
          _allPages.add('Книга не содержит текста для отображения');
        }

        if (_pageController.hasClients) {
          _pageController
              .jumpToPage(_currentPageIndex.clamp(0, _allPages.length - 1));
        }
      }
    } catch (e) {
      debugPrint('Ошибка в _precalculateAllPages: $e');
      if (mounted) {
        setState(() {
          _allPages = ['Ошибка загрузки книги: ${e.toString()}'];
          _isLoading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    // Проверка на отсутствие данных
    if (_chapters.isEmpty || _allPages.isEmpty && _isLoading == false) {
      return Scaffold(
        backgroundColor: _getBackgroundColor(settings.selectedBackgroundStyle),
        appBar: AppBar(
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(BookTrackIcon.onBack,
                color: _getTextColor(settings.selectedBackgroundStyle)),
            onPressed: widget.onBack,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book, size: 50, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'Книга не содержит текста',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: widget.onBack,
                child: Text('Вернуться назад'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: _getBackgroundColor(settings.selectedBackgroundStyle),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(BookTrackIcon.onBack,
              color: _getTextColor(settings.selectedBackgroundStyle)),
          onPressed: widget.onBack,
          color: AppColors.textPrimary,
        ),
        actions: [
          CircleAvatar(
              backgroundColor:
                  _getBackgroundColor(settings.selectedBackgroundStyle),
              radius: 20,
              child: IconButton(
                icon: Icon(Icons.settings,
                    color: _getTextColor(settings.selectedBackgroundStyle)),
                onPressed: () => _showTextEditor(scale, settings),
              )),
          CircleAvatar(
              backgroundColor:
                  _getBackgroundColor(settings.selectedBackgroundStyle),
              radius: 20,
              child: IconButton(
                icon: Icon(BookTrackIcon.snoskText,
                    color: _getTextColor(settings.selectedBackgroundStyle)),
                onPressed: () => _showFootnotes(context),
              )),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _loadingProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.background),
                        strokeWidth: 6,
                      ),
                      Text(
                        '${(_loadingProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _loadingPhase == LoadingPhase.downloading
                        ? 'Загрузка данных...'
                        : _loadingPhase == LoadingPhase.processing
                            ? 'Обработка текста...'
                            : 'Финальная подготовка...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _processingInterrupted = true;
                        _isLoading = false;
                      });
                    },
                    child: const Text(
                      'Отменить',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildBookHeader(_bookData, context),
                Expanded(
                  child: _allPages.isEmpty
                      ? Center(child: Text('Нет содержимого для отображения'))
                      : PageView.builder(
                          itemCount: _allPages.length,
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, index) =>
                              _buildPageContent(index),
                        ),
                ),
                _buildPageFooter(),
              ],
            ),
    );
  }

  Widget _buildPageContent(int pageIndex) {
    // Проверка на выход за границы списка
    if (pageIndex < 0 || pageIndex >= _allPages.length) {
      return Center(
        child: Text(
          'Страница не найдена',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    final settings = Provider.of<SettingsProvider>(context);
    final chapterIndex = _getCurrentChapterIndexForPage(pageIndex);

    // Проверка на выход за границы списка глав
    if (chapterIndex < 0 || chapterIndex >= _chapters.length) {
      return Center(
        child: Text(
          'Глава не найдена',
          style: TextStyle(color: Colors.red),
        ),
      );
    }

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

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Ошибка загрузки страницы: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
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
    if (_chapterPageStarts.isEmpty) return 0;

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
    String text,
    BuildContext context,
  ) async {
    try {
      // Проверка на пустой текст
      if (text.isEmpty) {
        return ['Текст главы отсутствует'];
      }

      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final textStyle = TextStyle(
        fontSize: settings.fontSize,
        fontFamily: _getFontFamily(settings.selectedFontFamily),
      );

      // Предварительный расчёт высоты строки
      final textPainter = TextPainter(
        text: TextSpan(text: 'Sample', style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      );
      textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
      final lineHeight = textPainter.height;

      final screenHeight = MediaQuery.of(context).size.height;
      final linesPerPage = ((screenHeight - 200) / lineHeight).floor();

      // Запускаем тяжёлую работу в изоляте
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
    } catch (e) {
      debugPrint('Error in splitTextIntoPages: $e');
      return ['Ошибка обработки текста: ${e.toString()}'];
    }
  }

  List<String> splitTextIntoPagesIsolate(Map<String, dynamic> params) {
    try {
      final text = params['text'] as String;
      final lineHeight = params['lineHeight'] as double;
      final linesPerPage = params['linesPerPage'] as double;
      final maxWidth = params['maxWidth'] as double;
      final fontFamily = params['fontFamily'] as String;
      final fontSize = params['fontSize'] as double;

      final textStyle = TextStyle(fontSize: fontSize, fontFamily: fontFamily);
      final words = text.split(' ');
      final pages = <String>[];
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
    } catch (e) {
      debugPrint('Error in isolate: $e');
      return ['Error processing text'];
    }
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
