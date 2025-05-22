import 'dart:math';

import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/BookCard/text/textBook.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:booktrack/pages/BookCard/text/SettingsProvider.dart';
import 'package:booktrack/models/chaptersModel.dart';
import 'package:booktrack/pages/BookCard/text/bookReposityr.dart';
import 'package:booktrack/pages/BookCard/text/epigraphWidgers.dart';
import 'package:booktrack/pages/ProfilePages/Quote/QuoteSelectionToolbar.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class BookScreenOtr extends StatefulWidget {
  final String bookId;
  final VoidCallback onBack;

  const BookScreenOtr({required this.bookId, required this.onBack, Key? key})
      : super(key: key);

  @override
  _BookScreenOtrState createState() => _BookScreenOtrState();
}

class _BookScreenOtrState extends State<BookScreenOtr> {
  final BookRepository _repository = BookRepository();
  List<String> _allPages = [];
  List<Chapter> _chapters = [];
  int _currentPageIndex = 0;
  late PageController _pageController;
  bool _isLoading = true;
  String _bookTitle = '';
  String _bookAuthor = '';
  double _loadingProgress = 0;
  bool _processingInterrupted = false;

  @override
  void initState() {
    super.initState();
    _initializeBookData();
  }

  Future<void> _initializeBookData() async {
    try {
      await _loadBookData();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _pageController = PageController(initialPage: 0);
        });
      }
    } catch (e) {
      debugPrint('Error initializing book data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _allPages = ['Error loading book content'];
          _pageController = PageController();
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBookData() async {
    try {
      final bookData = await _repository.getBookWithChapters(widget.bookId);
      _chapters = bookData.chapters;
      _bookTitle = bookData.book.title;
      _bookAuthor = bookData.book.author;
      await _precalculateAllPages(bookData);
    } catch (e) {
      debugPrint('Error loading book: $e');
    }
  }

  Future<void> _precalculateAllPages(BookWithChapters book) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadingProgress = 0;
        _allPages = [];
      });
    }

    try {
      const batchSize = 1;
      final totalChapters = 1; // Only process the first chapter
      int processedChapters = 0;

      for (int i = 0; i < totalChapters; i += batchSize) {
        if (!mounted || _processingInterrupted) break;

        await Future.delayed(const Duration(milliseconds: 50));

        final endIndex = min(i + batchSize, totalChapters);
        final batch = book.chapters.sublist(i, endIndex);

        final batchResults = await Future.wait(
          batch.map((chapter) => splitTextIntoPages(chapter.text, context)),
        );

        if (!mounted || _processingInterrupted) break;

        for (int j = 0; j < batchResults.length; j++) {
          processedChapters++;
          _allPages.addAll(batchResults[j]);

          if (mounted) {
            setState(() {
              _loadingProgress = processedChapters / totalChapters;
            });
          }
        }
      }

      if (!_processingInterrupted && mounted) {
        if (_allPages.isEmpty ||
            !_allPages.last.contains("Спасибо за прочтение")) {
          _allPages.add("Спасибо за прочтение!");
        }
      }
    } catch (e) {
      debugPrint('Error in _precalculateAllPages: $e');
      if (mounted) {
        setState(() {
          _allPages = ['Error loading book content'];
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
            ),
          ),
          CircleAvatar(
            backgroundColor:
                _getBackgroundColor(settings.selectedBackgroundStyle),
            radius: 20,
            child: IconButton(
              icon: Icon(Icons.info_outline,
                  color: _getTextColor(settings.selectedBackgroundStyle)),
              onPressed: () => _showFootnotes(context),
            ),
          ),
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
                    'Загрузка данных...',
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
                _buildBookHeader(context),
                Expanded(
                  child: _allPages.isEmpty
                      ? Center(child: Text('Нет содержимого для отображения'))
                      : PageView.builder(
                          itemCount: _allPages.length,
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPageIndex = index);
                          },
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
    final settings = Provider.of<SettingsProvider>(context);
    final textStyle = TextStyle(
      fontSize: settings.fontSize,
      fontFamily: _getFontFamily(settings.selectedFontFamily),
      color: _getTextColor(settings.selectedBackgroundStyle),
      height: 1.5,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText.rich(
            TextSpan(text: _allPages[pageIndex], style: textStyle),
            style: textStyle.copyWith(height: 1.5),
            textAlign: TextAlign.justify,
            selectionControls: _buildQuoteSelectionControls(
              pageIndex: pageIndex,
              chapterId: _chapters.isNotEmpty ? _chapters[0].id : '',
            ),
          ),
        ],
      ),
    );
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
    // Placeholder for quote saving logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Цитата успешно сохранена')),
    );
  }

  Widget _buildPageFooter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Страница ${_currentPageIndex + 1}/${_allPages.length}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getTextColor(
                Provider.of<SettingsProvider>(context).selectedBackgroundStyle,
              ),
            ),
      ),
    );
  }

  Widget _buildBookHeader(BuildContext context) {
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
          Text(_bookTitle, style: textStyle),
          const SizedBox(height: 8),
          Text(_bookAuthor, style: textStyle),
        ],
      ),
    );
  }

  void _showFootnotes(BuildContext context) {
    final currentChapter = _chapters.isNotEmpty ? _chapters[0] : null;

    if (currentChapter == null ||
        currentChapter.footnotes == null ||
        currentChapter.footnotes!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет сносок для этой главы')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return ListView(
          children: currentChapter.footnotes!.entries
              .map((entry) => ListTile(
                    title: Text(entry.value),
                    leading: Text('${entry.key}'),
                  ))
              .toList(),
        );
      },
    );
  }

  Color _getBackgroundColor(int selectedBackgroundStyle) {
    switch (selectedBackgroundStyle) {
      case 0:
        return Colors.white;
      case 1:
        return Color(0xffFFF7E0);
      case 2:
        return Color(0xff858585);
      case 3:
        return AppColors.textPrimary;
      default:
        return Colors.white;
    }
  }

  Color _getTextColor(int selectedBackgroundStyle) {
    switch (selectedBackgroundStyle) {
      case 0:
        return AppColors.textPrimary;
      case 1:
        return AppColors.textPrimary;
      case 2:
        return Colors.white;
      case 3:
        return Colors.white;
      default:
        return AppColors.textPrimary;
    }
  }

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

        int tempBackgroundStyle = settings.selectedBackgroundStyle;
        int tempFontFamily = settings.selectedFontFamily;
        double tempFontSize = settings.fontSize;
        double tempBrightness = settings.brightness;

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
                          value: tempBrightness,
                          max: 100,
                          onChanged: (double value) {
                            setState(() {
                              tempBrightness = value;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.sunny,
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
                                  Icons.sunny,
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
                              color: Color(0xffFFF7E0),
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
                              color: Color(0xff858585),
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
                              color: AppColors.textPrimary,
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
                            settings.setBackgroundStyle(tempBackgroundStyle);
                            settings.setFontFamily(tempFontFamily);
                            settings.setFontSize(tempFontSize);
                            settings.setBrightness(tempBrightness);
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
    try {
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
    } catch (e) {
      debugPrint('Error in splitTextIntoPages: $e');
      return ['Error processing text'];
    }
  }

  static List<String> splitTextIntoPagesIsolate(Map<String, dynamic> params) {
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
