import 'dart:async';

import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/timerAndPages.dart';
import 'package:booktrack/widgets/AdaptiveBookGrid.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';
import 'AppState.dart';

int readingMinutes = 0; // Количество минут чтения

class selectedPage extends StatefulWidget {
  @override
  _selectedPage createState() => _selectedPage();
}

class _selectedPage extends State<selectedPage> {
  bool isTimerRunning = false; // Флаг для управления паузой
  int _totalTimeInSeconds = 0; // Обновляется динамически

// 30 минут в секундах
  Timer? _countdownTimer; // Таймер обратного отсчёта
  Timer? _readingTimer; // Таймер для отслеживания минут чтения

  // Форматированное время для обратного отсчёта

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _totalTimeInSeconds = appState.readingMinutesPurpose;
  }

  String get formattedTime {
    final hours = (_totalTimeInSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes =
        ((_totalTimeInSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_totalTimeInSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  // Запуск обоих таймеров
  void _startTimers() {
    setState(() {
      isTimerRunning = true;
    });

    // Таймер обратного отсчёта
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_totalTimeInSeconds > 0) {
        setState(() {
          _totalTimeInSeconds--;
        });
      } else {
        timer.cancel(); // Остановка таймера при достижении 0
      }
    });

    // Таймер отслеживания минут чтения
    _readingTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        readingMinutes++;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = Provider.of<AppState>(context);
    setState(() {
      _totalTimeInSeconds = appState.readingMinutesPurpose;
    });
  }

  // Пауза обоих таймеров
  void _pauseTimers() {
    setState(() {
      isTimerRunning = false;
    });
    _countdownTimer?.cancel();
    _readingTimer?.cancel();
  }

  // Переключение паузы и возобновления
  void _toggleTimers() {
    if (isTimerRunning) {
      _pauseTimers();
    } else {
      _startTimers();
    }
  }

  @override
  void dispose() {
    // Очищаем ресурсы при закрытии
    _countdownTimer?.cancel();
    _readingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final readingMinutesPurpose = appState.readingMinutesPurpose / 60;
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
        backgroundColor: const Color(0xff5775CD),
        body: ListView(
          padding: EdgeInsets.only(top: 23.0 * scale),
          children: [
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 20 * scale, vertical: 10 * scale),
                child: Text(
                  "Мои книги",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: AppDimensions.baseTextSizeh1 * scale),
                )),
            Container(
              width: screenWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                  topRight: Radius.circular(AppDimensions.baseCircual * scale),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    padding: EdgeInsets.all(22.0 * scale),
                    child: Stack(
                      children: [
                        SvgPicture.asset(
                          'images/fonTaimer.svg',
                          height: 77.0 * scale,
                          width: 350.0 * scale,
                          fit: BoxFit.fill,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  size: 55 * scale,
                                  isTimerRunning
                                      ? MyFlutterApp.clock
                                      : Icons.pause,
                                  color: Colors.white,
                                ),
                                onPressed: _toggleTimers,
                              ),
                              Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                    // Отображение таймера обратного отсчёта
                                    Text(
                                      formattedTime,
                                      style: TextStyle(
                                          fontSize: 32 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),

                                    // Отображение минут чтения
                                    Text(
                                      '$readingMinutes/${readingMinutesPurpose.round()} минут',
                                      style: TextStyle(
                                        fontSize: 16 * scale,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ])),
                              RotatedBox(
                                quarterTurns: 2,
                                child: IconButton(
                                  icon: Icon(MyFlutterApp.back,
                                      size: 29 * scale, color: Colors.white),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TimerPage(
                                                onBack: () {
                                                  Navigator.pop(context);
                                                },
                                              )),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SectionTitle(
                    title: "Отложено",
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AllBooksPage()),
                      );
                    },
                  ),
                  BookList(),
                  SectionTitle(
                    title: "Прочитано",
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AllBooksPage()),
                      );
                    },
                  ),
                  BookList(),
                ],
              ),
            ),
          ],
        ));
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  SectionTitle({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 13.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: Text("Все"),
          ),
        ],
      ),
    );
  }
}

class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          Book.books.length,
          (index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                BookCard(
                  title: Book.books[index].title,
                  author: Book.books[index].author,
                  image: Book.books[index].image,
                  bookRating: Book.books[index].bookRating,
                  reviewCount: Book.books[index].reviewCount,
                  scale: scale,
                  imageWidth: AppDimensions.baseImageWidth * scale,
                  imageHeight: AppDimensions.baseImageHeight * scale,
                  textSizeTitle: AppDimensions.baseTextSizeTitle * scale,
                  textSizeAuthor: AppDimensions.baseTextSizeAuthor * scale,
                  textSpacing: 6.0 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AllBooksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Все книги"),
      ),
      body: Center(
        child: Text("Здесь отображаются все книги."),
      ),
    );
  }
}
