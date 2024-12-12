import 'package:flutter/material.dart';
import '/icons.dart';
import '/widgets/bookGrid.dart';
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

    return DefaultTabController(
      length: 4, // Количество вкладок
      child: Scaffold(
        backgroundColor: const Color(0xff5775CD),
        body: Column(
          children: [
            //Поисковая строка
            Container(
              // Цвет фона AppBar
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  TextField(
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
                ],
              ),
            ),

            Container(
                width: screenWidth - 100,
                padding: const EdgeInsets.only(top: 25),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: CarouselView(
                  backgroundColor: const Color(0xffB8BEF6),
                  itemExtent: 120,
                  children: [
                    Text('Item 1'),
                    Text('Item 2'),
                    Text('Item 3'),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
