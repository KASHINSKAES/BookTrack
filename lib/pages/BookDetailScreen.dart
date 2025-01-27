import 'package:booktrack/icons.dart';
import 'package:booktrack/widgets/blobPath.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookTitle;
  final String authorName;
  final double bookRating;
  final String bookImageUrl;
  final int reviewCount;
  final int pages;
  final int age;

  const BookDetailScreen({
    required this.bookTitle,
    required this.authorName,
    required this.bookRating,
    required this.bookImageUrl,
    required this.reviewCount,
    required this.pages,
    required this.age,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  double _scrollPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              _scrollPosition = scrollNotification.metrics.pixels;
            });
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: _scrollPosition > 355 * scale
                ? AppColors.background
                : Colors.transparent,
            title: _scrollPosition > 355 * scale
                ? Text(
                    widget.bookTitle,
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          body: Stack(
            children: [
              // Фиолетовый фон
              Container(
                padding: EdgeInsets.only(top: 200 * scale),
                color: AppColors.background,
              ),
              Positioned(
                  top: 0,
                  left: -40 * scale,
                  child: BlobShape(
                    width: 200 * scale, // Размеры пятна
                    height: 200 * scale,
                    blobType: 'blob2',
                  )),
              Positioned(
                  top: 10 * scale,
                  left: 140 * scale,
                  child: BlobShape(
                    width: 200 * scale, // Размеры пятна
                    height: 200 * scale,
                    blobType: 'blob3',
                  )),
              // Прокручиваемый контент
              SingleChildScrollView(
                padding: EdgeInsets.only(top: 200 * scale),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Белый блок
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: 30 * scale), // Отступ для картинки
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(MyFlutterApp.star,
                                              size: 16 * scale,
                                              color: AppColors.orange),
                                          Text(
                                            '${widget.bookRating}',
                                            style: TextStyle(
                                                fontSize: 16 * scale,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.orange),
                                          ),
                                          SizedBox(width: 6 * scale),
                                          Icon(MyFlutterApp.chat,
                                              size: 16 * scale,
                                              color: AppColors.grey),
                                          SizedBox(width: 4 * scale),
                                          Text(
                                            '${widget.reviewCount}',
                                            style: TextStyle(
                                                fontSize: 12 * scale,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.grey),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5 * scale),
                                      Text(
                                        widget.bookTitle,
                                        style: TextStyle(
                                          fontSize: 20 * scale,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        widget.authorName,
                                        style: TextStyle(
                                          fontSize: 14 * scale,
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${widget.pages} стр | ${widget.age}+ ',
                                        style: TextStyle(
                                          fontSize: 12 * scale,
                                          color: AppColors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ]),

                                const SizedBox(height: 16),

                                const Divider(),
                                const Text(
                                  'Похожие книги',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 150, child: _buildBookList()),
                                const Text(
                                  'Похожие книги',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 150, child: _buildBookList()),
                                const Text(
                                  'Похожие книги',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 150, child: _buildBookList()),
                                const Text(
                                  'Похожие книги',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 150, child: _buildBookList()),
                                const Divider(),
                                const Text(
                                  'Отзывы',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                    height: 150, child: _buildReviewsList()),
                              ],
                            ),
                          ),
                        ),
                        // Картинка книги между белым и фиолетовым слоями
                        Positioned(
                          top: -190 * scale,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 130 * scale,
                              height: 220 * scale,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: widget.bookImageUrl.isEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFD521B),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: SvgPicture.asset(
                                          widget.bookImageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 750, // Позиция сверху, чтобы "висел"
                left: 16,
                right: 16,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Полностью за 299 ₽'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Отрывок бесплатно'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildReviewsList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: 120,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            const Text(
              'Review Title',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Reviewer Name',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 160,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            const Text(
              'Book Title',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Author Name',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
