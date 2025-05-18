import 'package:booktrack/models/book.dart';
import 'package:booktrack/servises/bookServises.dart';
import 'package:booktrack/widgets/BookCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class AllBookGrid extends StatelessWidget {
  final BookService _bookService = BookService();

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return StreamBuilder<QuerySnapshot>(
        stream: _bookService.getBooksStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data!.docs.map((doc) {
            debugPrint('Processing doc ${doc.id}');
            try {
              return Book.fromFirestore(doc);
            } catch (e, stack) {
              debugPrint('Error with doc ${doc.id}: $e\n$stack');
              return Book(
                id: doc.id,
                title: '',
                author: '',
                ageRestriction: 'N/A',
                description: '',
                pages: 0,
                price: 0,
                publisher: '',
                genre: '',
                rating: 0,
                isExclusive: false,
                isSubscription: false,
                format: 'text',
                language: 'Русский',
                subcollection: [],
                tags: [],
                imageUrl: '',
                yearPublisher: 0,
              );
            }
          }).toList();

          return Container(
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
          );
        });
  }
}
