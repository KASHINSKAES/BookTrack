import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '/widgets/AdaptiveBookGrid.dart';
import '/icons.dart';
import '/widgets/constants.dart';
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
  String get _formattedTime {
    final hours = (_totalTimeInSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes =
        ((_totalTimeInSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_totalTimeInSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _totalTimeInSeconds = appState.readingMinutesPurpose * 60;
  }

  void _startTimer() {
    setState(() {
      isTimerRunning = true;
    });

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_totalTimeInSeconds > 0) {
          _totalTimeInSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      isTimerRunning = false;
    });
    _countdownTimer?.cancel();
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
      _totalTimeInSeconds = appState.readingMinutesPurpose * 60;
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
    final readingMinutesPurpose = appState.readingMinutesPurpose;
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
                                      _formattedTime,
                                      style: TextStyle(
                                          fontSize: 32 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),

                                    // Отображение минут чтения
                                    Text(
                                      '$readingMinutes/$readingMinutesPurpose минут',
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
                                          builder: (context) => TimerPage()),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    final List<Map<String, String>> books = [
      {
        "title": "Бонсай",
        "author": "Алехандро Самбра",
        "image": "images/img1.svg"
      },
      {
        "title": "Янтарь рассе",
        "author": "Люцида Аквила",
        "image": "images/img2.svg"
      },
      {"title": "Греческие и ", "author": "Филипп Матышак", "image": ""},
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

    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          books.length,
          (index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                BookCard(
                  title: books[index]["title"]!,
                  author: books[index]["author"]!,
                  image: books[index]["image"]!,
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

class TimerPage extends StatelessWidget {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Timer Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: myController,
              decoration: InputDecoration(
                labelText: "Enter Reading Minutes",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final numberPattern = RegExp(r'\d+');
                final matches = numberPattern.allMatches(myController.text);

                if (matches.isNotEmpty) {
                  final extractedNumber =
                      matches.map((match) => match.group(0)).join();
                  final enteredMinutes = int.parse(extractedNumber) ?? 0;

                  if (enteredMinutes > 0) {
                    // Обновляем значение в AppState
                    Provider.of<AppState>(context, listen: false)
                        .updateReadingMinutesPurpose(enteredMinutes);
                    Navigator.pop(
                        context); // Возвращаемся на предыдущую страницу
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter a valid number!")),
                    );
                  }
                }
              },
              child: Text("Submit"),
            ),
          ],
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
