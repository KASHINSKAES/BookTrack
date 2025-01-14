import 'package:booktrack/icons.dart';
import 'package:flutter/material.dart';
import '/widgets/AdaptiveBookGrid.dart';

// Страница с подборкой книг
class BookListPage extends StatefulWidget {
  final String category;
  final VoidCallback onBack;
  static const List<Map<String, String>> books = [
    {
      "title": "Бонсай",
      "author": "Алехандро Самбра",
      "image": "images/img1.svg"
    },
    {
      "title": "Янтарь рассе...",
      "author": "Люцида Аквила",
      "image": "images/img2.svg"
    },
    {
      "title": "Греческие и ...",
      "author": "Филипп Матышак",
      "image": "images/img6.svg"
    },
    {
      "title": "Безмолвное чтение. Том 1. Жюльен",
      "author": "Priest",
      "image": "images/img15.svg"
    },
    {
      "title": "Евгений Онегин",
      "author": "Александр Пушкин",
      "image": "images/img4.svg"
    },
    {
      "title": "Мастер и Маргарита",
      "author": "Михаил Булгаков",
      "image": "images/img5.svg"
    },
    {
      "title": "Бонсай",
      "author": "Алехандро Самбра",
      "image": "images/img1.svg"
    },
    {
      "title": "Янтарь рассе...",
      "author": "Люцида Аквила",
      "image": "images/img2.svg"
    },
    {"title": "Греческие и ...", "author": "Филипп Матышак", "image": ""},
    {
      "title": "Безмолвное чтение. Том 1. Жюльен",
      "author": "Priest",
      "image": "images/img15.svg"
    },
    {
      "title": "Евгений Онегин",
      "author": "Александр Пушкин",
      "image": "images/img4.svg"
    },
    {
      "title": "Мастер и Маргарита",
      "author": "Михаил Булгаков",
      "image": "images/img5.svg"
    },
    {
      "title": "Бонсай",
      "author": "Алехандро Самбра",
      "image": "images/img1.svg"
    },
    {
      "title": "Янтарь рассе...",
      "author": "Люцида Аквила",
      "image": "images/img2.svg"
    },
    {"title": "Греческие и ...", "author": "Филипп Матышак", "image": ""},
    {
      "title": "Безмолвное чтение. Том 1. Жюльен",
      "author": "Priest",
      "image": "images/img15.svg"
    },
    {
      "title": "Евгений Онегин",
      "author": "Александр Пушкин",
      "image": "images/img4.svg"
    },
    {
      "title": "Мастер и Маргарита",
      "author": "Михаил Булгаков",
      "image": "images/img5.svg"
    },
  ];

  const BookListPage({Key? key, required this.category, required this.onBack})
      : super(key: key);

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  int selectedOption = 1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    const baseWidth = 375.0;
    const baseCircual = 20.0;
    const baseImageWidth = 105.0;
    const baseImageHeight = 160.0;
    const baseTextSizeTitle = 13.0;
    const baseTextSizeAuthor = 10.0;
    const baseCrossAxisSpacing = 12.0;
    const baseMainAxisSpacing = 13.0;

    final scale = screenWidth / baseWidth;
    final Circual = baseCircual * scale;
    final imageWidth = baseImageWidth * scale;
    final imageHeight = baseImageHeight * scale;
    final textSizeTitle = baseTextSizeTitle * scale;
    final textSizeAuthor = baseTextSizeAuthor * scale;
    final crossAxisSpacing = baseCrossAxisSpacing * scale;
    final mainAxisSpacing = baseMainAxisSpacing * scale;

    return Scaffold(
      backgroundColor: const Color(0xff5775CD),
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(
            fontSize: 20 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          overflow: TextOverflow.fade,
        ),
        backgroundColor: const Color(0xff5775CD),
        leading: IconButton(
          icon: const Icon(
            MyFlutterApp.back,
            color: Colors.white,
          ),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              MyFlutterApp.search1,
              color: Colors.white,
            ),
            onPressed: widget.onBack,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20.0 * scale),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Circual),
              topRight: Radius.circular(Circual),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: crossAxisSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      onPressed: () => {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return SizedBox(
                                height: imageHeight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    ListTile(
                                      title: const Text('Option 1'),
                                      leading: Radio<int>(
                                        value: 1,
                                        groupValue: selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedOption = value!;
                                          });
                                          Navigator.pop(
                                              context); // Закрыть модальное окно
                                        },
                                      ),
                                    ),
                                    ListTile(
                                      title: const Text('Option 2'),
                                      leading: Radio<int>(
                                        value: 2,
                                        groupValue: selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedOption = value!;
                                          });
                                          Navigator.pop(
                                              context); // Закрыть модальное окно
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                      },
                      icon: const Icon(
                        MyFlutterApp.tuning,
                        color: Color(0xff03044E),
                      ),
                      label: const Text(
                        'Популярные',
                        style: TextStyle(color: Color(0xff03044E)),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      onPressed: () => {},
                      icon: const Icon(
                        MyFlutterApp.sort,
                        color: Color(0xff03044E),
                      ),
                      label: const Text(
                        'Фильтры',
                        style: TextStyle(color: Color(0xff03044E)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(crossAxisSpacing),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: imageWidth / (imageHeight + 40 * scale),
                    ),
                    itemCount: BookListPage.books.length,
                    itemBuilder: (context, index) {
                      final book = BookListPage.books[index];
                      return BookCard(
                        title: book["title"]!,
                        author: book["author"]!,
                        image: book["image"]!,
                        imageWidth: imageWidth,
                        imageHeight: imageHeight,
                        textSizeTitle: textSizeTitle,
                        textSizeAuthor: textSizeAuthor,
                        textSpacing: 6.0 * scale,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
