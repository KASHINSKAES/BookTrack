import 'package:booktrack/MyFlutterIcons.dart';
import 'package:booktrack/pages/AppState.dart';
import 'package:booktrack/pages/BrightnessProvider.dart';
import 'package:booktrack/pages/SettingsProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

Future<String> fetchText() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('books')
      .doc('book_1')
      .collection('chapters')
      .get();

  String text = '';

  for (var doc in snapshot.docs) {
    final data = doc.data();
    text += data['text'];
  }

  return text;
}

class TextBook extends StatefulWidget {
  final VoidCallback onBack;
  TextBook({super.key, required this.onBack});

  @override
  State<TextBook> createState() => _TextBookState();
}

class _TextBookState extends State<TextBook> {
  String textBook = '';
  bool isLoading = true;
  List<String> pages = [];
  int currentPage = 0;
  DateTime? startReadingTime;
  double goalMinutes = 0; // Минуты цели чтения
  int goalPages = 0; // Прогресс чтения в процентах
  int totalReadingTimeInSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadData(); // Загружаем данные книги
    _loadCurrentPage().then((page) {
      setState(() {
        currentPage = page; // Устанавливаем текущую страницу
      });
    });
    _startReadingTimer(); // Запускаем таймер чтения
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Получаем данные из Provider после инициализации контекста
    final appState = Provider.of<AppState>(context, listen: false);
    setState(() {
      goalMinutes = appState.readingMinutesPurpose / 60.round();
      goalPages = appState.readingPagesPurpose;
    });
  }

  // Запуск таймера чтения
  void _startReadingTimer() {
    startReadingTime = DateTime.now();
  }

  // Остановка таймера чтения
  void _stopReadingTimer() {
    if (startReadingTime != null) {
      final endReadingTime = DateTime.now();
      final difference = endReadingTime.difference(startReadingTime!);
      totalReadingTimeInSeconds += difference.inSeconds;
      startReadingTime = null;
    }
  }

  // Загрузка данных книги
  Future<void> _loadData() async {
    try {
      final data = await fetchText(); // Получаем текст книги
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      setState(() {
        textBook = data;
        isLoading = false;
        pages = _splitTextIntoPages(
          textBook,
          context,
          settings.fontSize,
          _getFontFamily(settings.selectedFontFamily),
        );
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки текста: $e')),
      );
    }
  }

  // Разбиение текста на страницы
  List<String> _splitTextIntoPages(
    String text,
    BuildContext context,
    double fontSize,
    String fontFamily,
  ) {
    List<String> pages = [];
    int start = 0;
    int charsPerPage =
        _calculateCharsPerPage(context, text, fontSize, fontFamily);

    while (start < text.length) {
      int end = start + charsPerPage;
      if (end >= text.length) {
        end = text.length;
      } else {
        while (end > start && text[end] != ' ' && text[end] != '\n') {
          end--;
        }
      }

      pages.add(text.substring(start, end).trim());
      start = end;
    }

    return pages;
  }

  // Расчет количества символов на странице
  int _calculateCharsPerPage(
    BuildContext context,
    String text,
    double fontSize,
    String fontFamily,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);
    final charsPerLine = textPainter
        .getPositionForOffset(Offset(
          MediaQuery.of(context).size.width - 32,
          fontSize,
        ))
        .offset;

    final linesPerPage =
        (MediaQuery.of(context).size.height - 200) ~/ (fontSize * 1.5);

    return charsPerLine * linesPerPage;
  }

  // Загрузка текущей страницы из SharedPreferences
  Future<int> _loadCurrentPage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('currentPage') ?? 0;
  }

  // Сохранение текущей страницы в SharedPreferences
  Future<void> _saveCurrentPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentPage', page);
  }

  // Сохранение прогресса чтения в Firestore
  Future<void> _saveReadingProgress() async {
    final firestore = FirebaseFirestore.instance;
    final userId = 'user_1'; // Замените на реальный ID пользователя
    if (userId == null) return;

    final readingProgressRef = firestore
        .collection('users')
        .doc(userId)
        .collection('reading_progress')
        .doc('book_1');

    final readingProgressData = {
      'totalPages': pages.length,
      'currentPage': currentPage,
      'dateLastRead': DateTime.now(),
      'totalReadingTimeInSeconds': totalReadingTimeInSeconds,
    };

    await readingProgressRef.set(readingProgressData, SetOptions(merge: true));
  }

  // Сохранение ежедневного прогресса чтения в коллекцию reading_goals
  Future<void> _saveDailyReadingProgress() async {
    final firestore = FirebaseFirestore.instance;
    final userId = 'user_1'; // Замените на реальный ID пользователя

    if (userId == null) return;

    final today = DateTime.now();
    final goalId = 'goal_${today.year}_${today.month}_${today.day}';

    final readingGoalsRef = firestore
        .collection('users')
        .doc(userId)
        .collection('reading_goals')
        .doc(goalId);

    // Обновляем данные
    final dailyProgressData = {
      'readPages':
          currentPage, // Текущее количество прочитанных страниц за день
      'date': DateTime.now(),
      'goalPages': goalPages, // Цель по страницам за день
      'readMinutes': totalReadingTimeInSeconds ~/
          60, // Текущее количество прочитанных минут за день
      'goalMinutes': goalMinutes, // Цель по минутам за день
      'weekStart': DateTime(today.year, today.month,
          today.day - today.weekday + 1), // Начало недели
    };

    // Сохраняем данные
    await readingGoalsRef.set(dailyProgressData, SetOptions(merge: true));
  }

  // Обработка изменения страницы
  void _onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
    _saveCurrentPage(index); // Сохраняем текущую страницу
    _saveReadingProgress(); // Сохраняем общий прогресс
    _saveDailyReadingProgress(); // Сохраняем ежедневный прогресс
  }

  @override
  void dispose() {
    _stopReadingTimer(); // Останавливаем таймер
    _saveReadingProgress(); // Сохраняем прогресс перед закрытием
    _saveDailyReadingProgress(); // Сохраняем ежедневный прогресс
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
      backgroundColor: _getBackgroundColor(settings.selectedBackgroundStyle),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: widget.onBack,
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showTextEditor(scale, settings),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: PageController(initialPage: currentPage),
                    itemCount: pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          color: _getBackgroundColor(
                              settings.selectedBackgroundStyle),
                          child: Text(
                            pages[index],
                            style: TextStyle(
                              fontSize: settings.fontSize,
                              fontFamily:
                                  _getFontFamily(settings.selectedFontFamily),
                              color: _getTextColor(
                                  settings.selectedBackgroundStyle),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  // Получение цвета фона на основе выбранного стиля
  Color _getBackgroundColor(int selectedBackgroundStyle) {
    switch (selectedBackgroundStyle) {
      case 0:
        return Colors.white; // Белый фон
      case 1:
        return Color(0xffFFF7E0); // Светло-желтый фон
      case 2:
        return Color(0xff858585); // Серый фон
      case 3:
        return AppColors.textPrimary; // Черный фон
      default:
        return Colors.white;
    }
  }

  // Получение цвета текста на основе выбранного стиля
  Color _getTextColor(int selectedBackgroundStyle) {
    switch (selectedBackgroundStyle) {
      case 0:
        return AppColors.textPrimary; // Черный текст
      case 1:
        return AppColors.textPrimary; // Черный текст
      case 2:
        return Colors.white; // Белый текст
      case 3:
        return Colors.white; // Белый текст
      default:
        return AppColors.textPrimary;
    }
  }

  // Получение шрифта на основе выбранного стиля
  String _getFontFamily(int selectedFontFamily) {
    switch (selectedFontFamily) {
      case 0:
        return 'MPLUSRounded1c';
      case 1:
        return 'Rubik';
      case 2:
        return 'Inter';
      case 3:
        return 'AdventPro';
      default:
        return 'MPLUSRounded1c';
    }
  }

  void _showTextEditor(double scale, SettingsProvider settings) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.8;

        // Локальные переменные для временных настроек
        int tempBackgroundStyle = settings.selectedBackgroundStyle;
        int tempFontFamily = settings.selectedFontFamily;
        double tempFontSize = settings.fontSize;
        double tempBrightness = settings.brightness;
        final brightnessProvider = Provider.of<BrightnessProvider>(context);

        return StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              height: height,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.0 * scale),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Настройки',
                      style: TextStyle(
                        fontSize: 32 * scale,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 11 * scale),
                    Text(
                      "Яркость",
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 11 * scale),
                    Column(
                      children: [
                        Slider(
                          activeColor: Colors.orange,
                          value: brightnessProvider.brightness,
                          max: 100,
                          onChanged: (double value) {
                            brightnessProvider.setBrightness(value);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  MyFlutter.sun,
                                  size: 30 * scale,
                                  color: AppColors.orange,
                                ),
                                Text(
                                  '0%',
                                  style: TextStyle(
                                    fontSize: 16 * scale,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  MyFlutter.sun,
                                  size: 30 * scale,
                                  color: AppColors.orange,
                                ),
                                Text(
                                  '100%',
                                  style: TextStyle(
                                    fontSize: 16 * scale,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20 * scale),
                    Text(
                      'Цветовая тема',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempBackgroundStyle = 0;
                            });
                          },
                          child: Container(
                            width: 80 * scale,
                            height: 35 * scale,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: tempBackgroundStyle == 0
                                    ? AppColors.orange
                                    : Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Аа',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16 * scale,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempBackgroundStyle = 1;
                            });
                          },
                          child: Container(
                            width: 80 * scale,
                            height: 35 * scale,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: tempBackgroundStyle == 1
                                    ? AppColors.orange
                                    : Colors.white,
                              ),
                              color: Color(0xffFFF7E0), // Цвет фона для стиля 1
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Аа',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16 * scale,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempBackgroundStyle = 2;
                            });
                          },
                          child: Container(
                            width: 80 * scale,
                            height: 35 * scale,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: tempBackgroundStyle == 2
                                    ? AppColors.orange
                                    : Colors.white,
                              ),
                              color: Color(0xff858585), // Цвет фона для стиля 2
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Аа',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * scale,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempBackgroundStyle = 3;
                            });
                          },
                          child: Container(
                            width: 80 * scale,
                            height: 35 * scale,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: tempBackgroundStyle == 3
                                    ? AppColors.orange
                                    : Colors.white,
                              ),
                              color: AppColors
                                  .textPrimary, // Цвет фона для стиля 3
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Аа',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16 * scale,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Шрифт',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempFontFamily = 0;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80 * scale,
                                height: 35 * scale,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: tempFontFamily == 0
                                        ? AppColors.orange
                                        : AppColors.blueColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Аа',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16 * scale,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                'Rounded',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempFontFamily = 1;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80 * scale,
                                height: 35 * scale,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: tempFontFamily == 1
                                        ? AppColors.orange
                                        : AppColors.blueColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Аа',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontFamily: "Rubik",
                                    fontSize: 16 * scale,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                'Rubik',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempFontFamily = 2;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80 * scale,
                                height: 35 * scale,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: tempFontFamily == 2
                                        ? AppColors.orange
                                        : AppColors.blueColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Аа',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontFamily: "Inter",
                                    fontSize: 16 * scale,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                'Inter',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              tempFontFamily = 3;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 80 * scale,
                                height: 35 * scale,
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: tempFontFamily == 3
                                        ? AppColors.orange
                                        : AppColors.blueColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Аа',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontFamily: "AdventPro",
                                    fontSize: 16 * scale,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                'Advent',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 14 * scale,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Размер текста',
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 16 * scale,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'A',
                              style: TextStyle(
                                fontSize: 40 * scale,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SfSlider(
                          activeColor: AppColors.orange,
                          min: 16.0,
                          max: 40.0,
                          value: tempFontSize,
                          interval: 4,
                          showTicks: true,
                          minorTickShape: const SfTickShape(),
                          onChanged: (value) {
                            setState(() {
                              tempFontSize = value;
                            });
                          },
                        ),
                        SizedBox(height: 16 * scale),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              AppColors.background,
                            ),
                          ),
                          onPressed: () {
                            // Применяем настройки через провайдер
                            settings.setBackgroundStyle(tempBackgroundStyle);
                            settings.setFontFamily(tempFontFamily);
                            settings.setFontSize(tempFontSize);
                            settings.setBrightness(tempBrightness);

                            // Закрываем модальное окно
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Применить",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}