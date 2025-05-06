import 'package:flutter/material.dart';
import 'package:booktrack/pages/bookReposityr.dart';
import 'package:booktrack/models/chaptersModel.dart';

class BookScreen extends StatefulWidget {
  final String bookId;

  const BookScreen({required this.bookId, Key? key}) : super(key: key);

  @override
  _BookScreenState createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  late Future<BookWithChapters> _bookData;
  final BookRepository _repository = BookRepository();
  int _currentPageIndex = 0;
  final double _fontSize = 16.0;
  final String _fontFamily = 'Roboto';
  late List<String> _allPages = [];
  late List<Chapter> _chapters = [];
  late List<int> _chapterPageStarts = [];

  @override
  void initState() {
    super.initState();
    _bookData = _repository.getBookWithChapters(widget.bookId).then((book) {
      _precalculateAllPages(book, context);
      return book;
    });
  }

  void _precalculateAllPages(BookWithChapters book, BuildContext context) {
    _chapters = book.chapters;
    _allPages = [];
    _chapterPageStarts = [];

    for (var chapter in book.chapters) {
      // Запоминаем начало каждой главы
      _chapterPageStarts.add(_allPages.length);

      // Объединяем эпиграф и текст главы
      final fullText = chapter.epigraph != null
          ? '${chapter.epigraph!.text}\n\n${chapter.epigraph!.author}\n\n${chapter.text}'
          : chapter.text;

      // Разбиваем на страницы и добавляем в общий список
      final chapterPages =
          _splitTextIntoPages(fullText, context, _fontSize, _fontFamily);
      _allPages.addAll(chapterPages);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чтение'),
        actions: [
          IconButton(
            icon: Icon(Icons.notes),
            onPressed: () => _showFootnotes(context),
          ),
        ],
      ),
      body: FutureBuilder<BookWithChapters>(
        future: _bookData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          return Column(
            children: [
              _buildBookHeader(snapshot.data!, context),
              Expanded(
                child: PageView.builder(
                  itemCount: _allPages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPageIndex = index);
                  },
                  itemBuilder: (context, pageIndex) {
                    return _buildPageContent(pageIndex);
                  },
                ),
              ),
              _buildPageFooter(),
            ],
          );
        },
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
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          Text(
            _allPages[pageIndex],
            style: TextStyle(
              fontSize: _fontSize,
              fontFamily: _fontFamily,
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

  List<String> _splitTextIntoPages(
    String text,
    BuildContext context,
    double fontSize,
    String fontFamily,
  ) {
    List<String> pages = [];
    int start = 0;
    int charsPerPage =
        _calculateCharsPerPage(context, text, fontSize, fontFamily);

    while (start < text.length) {
      int end = start + charsPerPage;
      if (end >= text.length) {
        end = text.length;
      } else {
        while (end > start && text[end] != ' ' && text[end] != '\n') {
          end--;
        }
      }

      pages.add(text.substring(start, end).trim());
      start = end;
    }

    return pages;
  }

  int _calculateCharsPerPage(
    BuildContext context,
    String text,
    double fontSize,
    String fontFamily,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    final charsPerLine = textPainter
        .getPositionForOffset(Offset(
          MediaQuery.of(context).size.width - 32,
          fontSize,
        ))
        .offset;

    final linesPerPage =
        (MediaQuery.of(context).size.height - 200) ~/ (fontSize * 1.5);

    return charsPerLine * linesPerPage;
  }

  Widget _buildBookHeader(BookWithChapters bookData, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bookData.book.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            bookData.book.author,
            style: Theme.of(context).textTheme.titleMedium,
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
}
