import 'package:flutter/material.dart';
import '/icons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Catalogpage extends StatelessWidget {
  const Catalogpage({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем размеры экрана
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Вычисляем размеры блока
    final blockWidth = screenWidth * 0.108; // 87% ширины экрана
    final blockHeight = screenHeight * 0.07; // 20% высоты экрана

    // Задаём отступ для "торчащих" частей блоков
    final overlapOffset = screenWidth * 0.035; // 3.5% ширины экрана

    return Scaffold(
        backgroundColor: const Color(0xff5775CD),
        body: ListView(children: [
          //Поисковая строка
          Container(
            // Цвет фона AppBar
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 23),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Что вы хотите почитать?',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      prefixIcon: Opacity(
                          opacity: 0.6,
                          child: Icon(
                            MyFlutterApp.magnifer,
                            size: 21.0,
                            color: Colors.white,
                          )),
                      filled: true,
                      fillColor: const Color(0xff3A4E88).withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            width: screenWidth,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(children: [
              UncontainedLayout(
                text: 'Художественная литература'
                ),
              UncontainedLayout(
                text: 'Учебная литература',
              ),
              UncontainedLayout(
                text: 'Саморазвитие',
              ),
              UncontainedLayout(
                text: 'Психология',
              ),
              UncontainedLayout(
                text: 'Детская литература',
              ),
              UncontainedLayout(text: 'Художественная литература'),
              UncontainedLayout(
                text: 'Учебная литература',
              ),
              UncontainedLayout(
                text: 'Саморазвитие',
              ),
              UncontainedLayout(
                text: 'Психология',
              ),
              UncontainedLayout(
                text: 'Детская литература',
              ),
            ]),
          )
        ]));
  }
}

class UncontainedLayout extends StatelessWidget {
  final String text;

  const UncontainedLayout({
    super.key,
    required this.text,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
        textDirection: TextDirection.ltr,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 30, left: 26),
              child: Text(
                text,
              )),
          UncontainedLayoutCard()
        ]);
  }
}

class UncontainedLayoutCard extends StatelessWidget {
  const UncontainedLayoutCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      child: ListView(
        // This next line does the trick.
        scrollDirection: Axis.horizontal,
        children: List<Widget>.generate(20, (int index) {
          return Box();
        }),
      ),
    );
  }
}

class Box extends StatelessWidget {
  const Box({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 110,
        margin: EdgeInsets.only(top: 15, left: 26),
        decoration: BoxDecoration(
          color: const Color(0xffB8BEF6),
          borderRadius: BorderRadius.circular(12.0),
        ));
  }
}
