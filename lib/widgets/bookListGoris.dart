import 'package:booktrack/models/book.dart';
import 'package:booktrack/servises/bookServises.dart';
import 'package:booktrack/widgets/BookCard.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class BookList extends StatefulWidget {
  final int maxItemsToShow;
  final bool showSeeAllButton;
  final String? listType; // Для пользовательских списков
  final String? userId; // Для пользовательских списков
  final String? currentBookId; // Для похожих/авторских книг
  final String? author; // Для книг автора
  final String? format; // Для похожих книг
  final String? language; // Для похожих книг

  const BookList({
    this.maxItemsToShow = 5,
    this.showSeeAllButton = true,
    this.listType,
    this.userId,
    this.currentBookId,
    this.author,
    this.format,
    this.language,
    Key? key,
  }) : super(key: key);

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  late final BookService _bookService;
  late final Stream<List<Book>> _booksStream;

  @override
  void initState() {
    super.initState();
    _bookService = BookService();
    _booksStream = _getCorrectStream();
  }

  Stream<List<Book>> _getCorrectStream() {
    if (widget.listType != null && widget.userId != null) {
      return _bookService.getUserBooksStream(
        userId: widget.userId!,
        listType: widget.listType!,
        limit: widget.maxItemsToShow,
      );
    } else if (widget.author != null && widget.currentBookId != null) {
      return _bookService.getAuthorBooksStream(
        currentBookId: widget.currentBookId!,
        author: widget.author!,
        limit: widget.maxItemsToShow,
      );
    } else if (widget.format != null &&
        widget.language != null &&
        widget.currentBookId != null) {
      return _bookService.getSimilarBooksStream(
        currentBookId: widget.currentBookId!,
        format: widget.format!,
        language: widget.language!,
        limit: widget.maxItemsToShow,
      );
    }
    return _bookService.getBooksStream().map((snapshot) => snapshot.docs
        .take(widget.maxItemsToShow)
        .map((doc) => Book.fromFirestore(doc))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return StreamBuilder<List<Book>>(
      stream: _booksStream,
      builder: (context, snapshot) {
        // Обработка ошибок
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error!, scale);
        }

        // Если есть данные - показываем
        if (snapshot.hasData) {
          final books = snapshot.data!;
          return _buildBookList(books, scale);
        }

        // Если нет данных и идет загрузка
        return _buildLoadingWidget(scale);
      },
    );
  }

  Widget _buildBookList(List<Book> books, double scale) {
    final booksToShow = widget.maxItemsToShow > 0
        ? books.take(widget.maxItemsToShow).toList()
        : books;

    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            booksToShow.length,
            (index) => SizedBox(
              // Ограничиваем ширину
              width: (AppDimensions.baseImageHeight - 40) *
                  scale, // Примерное значение, подберите под ваш дизайн
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    BookCards(
                      book: booksToShow[index],
                      scale: scale,
                      imageWidth: AppDimensions.baseImageWidth * scale,
                      imageHeight: AppDimensions.baseImageHeight * scale,
                      textSizeTitle: AppDimensions.baseTextSizeTitle * scale,
                      textSizeAuthor: AppDimensions.baseTextSizeAuthor * scale,
                      textSpacing: 6.0 * scale,
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildLoadingWidget(double scale) {
    return Center(
      child: SizedBox(
        width: AppDimensions.baseCircualButton * scale,
        height: AppDimensions.baseCircualButton * scale,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(dynamic error, double scale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48 * scale),
            SizedBox(height: 16 * scale),
            Text(
              'Ошибка загрузки',
              style:
                  TextStyle(fontSize: AppDimensions.baseTextSizeTitle * scale),
            ),
            SizedBox(height: 8 * scale),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: AppDimensions.baseTextSizeAuthor * scale),
            ),
            SizedBox(height: 16 * scale),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }
}

class AllBooksPage extends StatelessWidget {
  final String? title;
  final String? listType;
  final String? userId;
  final String? author;
  final String? format;
  final String? language;

  const AllBooksPage({
    this.title,
    this.listType,
    this.userId,
    this.author,
    this.format,
    this.language,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(listType.toString())),
      ),
      body: BookList(
        listType: listType,
        userId: userId,
        author: author,
        format: format,
        language: language,
        maxItemsToShow: 100,
        showSeeAllButton: false,
      ),
    );
  }

  String _getTitle(String type) {
    switch (type) {
      case 'saved_books':
        return 'Избранные книги';
      case 'read_books':
        return 'Прочитанные книги';
      case 'end_books':
        return 'Читаемые книги';
      default:
        return 'Все книги';
    }
  }
}
