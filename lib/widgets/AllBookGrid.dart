import 'dart:ui';

import 'package:booktrack/models/book.dart';
import 'package:booktrack/widgets/BookCard.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class AllBookGrid extends StatefulWidget {
  final PageStorageKey<String> storageKey;
  final List<Book> books;

  AllBookGrid({required this.storageKey, required this.books});

  @override
  _AllBookGridState createState() => _AllBookGridState();
}

class _AllBookGridState extends State<AllBookGrid>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

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
        padding: EdgeInsets.all(AppDimensions.baseCrossAxisSpacing * scale),
        child: GridView.builder(
          key: widget.storageKey,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppDimensions.baseCrossAxisSpacingBlock * scale,
            mainAxisSpacing: AppDimensions.baseMainAxisSpacing * scale,
            childAspectRatio: AppDimensions.baseImageWidth /
                (AppDimensions.baseImageHeight + 40 * scale),
          ),
          itemCount: widget.books.length,
          itemBuilder: (context, index) {
            final book = widget.books[index];
            return BookCards(
              book: book,
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
  }
}
