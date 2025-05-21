import 'package:booktrack/models/book.dart';
import 'package:booktrack/pages/filter/filterProvider.dart';
import 'package:booktrack/servises/bookServises.dart';
import 'package:booktrack/widgets/BookCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';

class CatalogBookGrid extends StatefulWidget {
  @override
  _CatalogBookGridState createState() => _CatalogBookGridState();
}

class _CatalogBookGridState extends State<CatalogBookGrid> {
  late Stream<List<Book>> _booksStream;

  @override
  void initState() {
    super.initState();
    _booksStream = BookService().getAllBooks();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    final filterProvider = Provider.of<FilterProvider>(context);

    return StreamBuilder<List<Book>>(
        stream: _booksStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final books =
              _applyFilters(snapshot.data!, filterProvider.activeFilters);

          return SingleChildScrollView(
        child:Container(
            padding: EdgeInsets.only(top: AppDimensions.baseScreenTop * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                topRight: Radius.circular(AppDimensions.baseCircual * scale),
              ),
            ),
            child: Padding(
              padding:
                  EdgeInsets.all(AppDimensions.baseCrossAxisSpacing * scale),
              child: GridView.builder(
                shrinkWrap: true, // Добавьте это
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing:
                      AppDimensions.baseCrossAxisSpacingBlock * scale,
                  mainAxisSpacing: AppDimensions.baseMainAxisSpacing * scale,
                  childAspectRatio: AppDimensions.baseImageWidth /
                      (AppDimensions.baseImageHeight + 40 * scale),
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return BookCards(
                    book: book, // Передаем весь объект Book
                    scale: scale,
                    imageWidth: AppDimensions.baseImageWidth * scale,
                    imageHeight: AppDimensions.baseImageHeight * scale,
                    textSizeTitle: AppDimensions.baseTextSizeTitle * scale,
                    textSizeAuthor: AppDimensions.baseTextSizeAuthor * scale,
                    textSpacing: 6.0 * scale,
                  );
                },
              ),
            ),
          ));
        });
  }

  List<Book> _applyFilters(List<Book> books, Map<String, dynamic> filters) {
    return books.where((book) {
      // Фильтр по подписке
      if (filters['isSubscription'] == true && !book.isSubscription) {
        return false;
      }

      // Фильтр по эксклюзивности
      if (filters['isExclusive'] == true && !book.isExclusive) {
        return false;
      }

      // Фильтр по рейтингу
      if (filters['isHighRated'] == true && book.rating < 4) {
        return false;
      }

      // Фильтр по формату
      if (filters['format'] != null && book.format != filters['format']) {
        return false;
      }

      // Фильтр по языку
      if (filters['language'] != null && book.language != filters['language']) {
        return false;
      }

      return true;
    }).toList();
  }
}
