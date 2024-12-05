import 'package:flutter/material.dart';
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
    final blockWidth = screenWidth * 0.87; // 87% ширины экрана
    final blockHeight = screenHeight * 0.2; // 20% высоты экрана

    // Задаём отступ для "торчащих" частей блоков
    final overlapOffset = screenWidth * 0.035; // 3.5% ширины экрана

    return Scaffold(
      backgroundColor: const Color(0xff5775CD),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(23.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Логотип (SVG)
                  SvgPicture.asset(
                    'assets/images/Logo.svg', // Укажите путь к вашему SVG-файлу
                    height: 99.87,
                    width: 255,
                  ),
                  const SizedBox(height: 20),
                  // Поисковая строка
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Что вы хотите почитать?',
                      hintStyle: TextStyle(
                        fontSize: 14.0,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      filled: true,
                      fillColor: const Color(0xff3A4E88)
                          .withOpacity(0.5), // Прозрачный фон
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(35.0),
                        borderSide: BorderSide.none, // Убираем рамку
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Горизонтальная карусель с использованием carousel_slider
          CarouselSlider.builder(
            itemCount: 3, // Количество блоков
            itemBuilder: (context, index, realIndex) {
              return Container(
                width: blockWidth,
                height: blockHeight,
                margin: EdgeInsets.symmetric(
                  horizontal: overlapOffset / 2,
                ),
                decoration: BoxDecoration(
                  color: Color(0xffFD521B),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              );
            },
            options: CarouselOptions(
              height: blockHeight + 16, // Высота блока с учётом отступов
              viewportFraction: 0.87, // Пропорциональная ширина (87%)
              enableInfiniteScroll: true, // Зацикливание карусели
              enlargeCenterPage: true, // Выделение центрального элемента
              autoPlay: true, // Автопрокрутка (можно включить)
              autoPlayInterval:
                  const Duration(seconds: 4), // Интервал для автопрокрутки
            ),
          ),
        ],
      )),
    );
  }
}

class HomePageMenu extends StatelessWidget {
  const HomePageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем размеры экрана
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Вычисляем размеры блока
    final blockWidth = screenWidth * 0.87; // 87% ширины экрана
    final blockHeight = screenHeight * 0.2; // 20% высоты экрана

    // Задаём отступ для "торчащих" частей блоков
    final overlapOffset = screenWidth * 0.035; // 3.5% ширины экрана

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(23.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Логотип (SVG)
                    SvgPicture.asset(
                      'assets/images/Logo.svg', // Укажите путь к вашему SVG-файлу
                      height: 99.87,
                      width: 255,
                    ),
                    const SizedBox(height: 20),
                    // Поисковая строка
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Что вы хотите почитать?',
                        hintStyle: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xff3A4E88)
                            .withOpacity(0.5), // Прозрачный фон
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(35.0),
                          borderSide: BorderSide.none, // Убираем рамку
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Горизонтальная карусель с использованием carousel_slider
            CarouselSlider.builder(
              itemCount: 3, // Количество блоков
              itemBuilder: (context, index, realIndex) {
                return Container(
                  width: blockWidth,
                  height: blockHeight,
                  margin: EdgeInsets.symmetric(
                    horizontal: overlapOffset / 2,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffFD521B),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                );
              },
              options: CarouselOptions(
                height: blockHeight + 16, // Высота блока с учётом отступов
                viewportFraction: 0.87, // Пропорциональная ширина (87%)
                enableInfiniteScroll: true, // Зацикливание карусели
                enlargeCenterPage: true, // Выделение центрального элемента
                autoPlay: true, // Автопрокрутка (можно включить)
                autoPlayInterval:
                    const Duration(seconds: 4), // Интервал для автопрокрутки
              ),
            ),
          ],
        ));
  }
}
