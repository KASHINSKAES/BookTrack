import 'package:flutter/material.dart';
import '/icons.dart';
import '/widgets/bottomNavigator.dart';
import '/widgets/bookGrid.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carousel_slider/carousel_slider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'MPLUSRounded1c'),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем размеры экрана
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Вычисляем размеры блока
    final blockWidth = screenWidth * 0.97; // 87% ширины экрана
    final blockHeight = screenHeight * 0.2; // 20% высоты экрана

    // Задаём отступ для "торчащих" частей блоков
    final overlapOffset = screenWidth * 0.035; // 3.5% ширины экрана

    return DefaultTabController(
      length: 4, // Количество вкладок
      child: Scaffold(
        backgroundColor: const Color(0xff5775CD),
        body: Column(
          children: [
            // Логотип и поисковая строка
            Container(
              // Цвет фона AppBar
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SvgPicture.asset(
                    'assets/images/Logo.svg', // Укажите путь к вашему SVG-файлу
                    height: 60,
                    width: 150,
                  ),
                  const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            // Горизонтальная карусель
            CarouselSlider.builder(
              itemCount: 3, // Количество блоков
              itemBuilder: (context, index, realIndex) {
                return Container(
                  width: blockWidth,
                  height: blockHeight,
                  margin: EdgeInsets.symmetric(horizontal: overlapOffset / 2),
                  decoration: BoxDecoration(
                    color: const Color(0xffFD521B),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                );
              },
              options: CarouselOptions(
                height: blockHeight + 16, // Высота блока с учётом отступов
                viewportFraction: 0.87, // Пропорциональная ширина (87%)
                enableInfiniteScroll: true, // Зацикливание карусели
                enlargeCenterPage: true, // Выделение центрального элемента
                autoPlay: true, // Автопрокрутка
                autoPlayInterval: const Duration(seconds: 10), // Интервал
              ),
            ),
            const SizedBox(height: 10),
            // TabBar с вкладками
            const TabBar(
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              tabAlignment: TabAlignment.start,
              unselectedLabelColor: Color(0xff03044E),
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Рекомендации'),
                Tab(text: 'Популярные'),
                Tab(text: 'Жанры'),
                Tab(text: 'Скоро в продаже'),
              ],
            ),
            const SizedBox(height: 10),
            // Содержимое вкладок
            Expanded(
              child: TabBarView(
                children: [
                  Container(
                      padding: const EdgeInsets.only(top: 25),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: BookGrid()),
                ],
              ),
            ),
            bottomNavigator()
          ],
        ),
      ),
    );
  }
}
