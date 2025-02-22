import 'package:booktrack/MyFlutterIcons.dart';
import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/ReadingStatsProvider.dart';
import 'package:booktrack/pages/SettingsProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
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
    text += data['text']; // Предположим, что поле с текстом называется 'text'
  }

  return text;
}

class textBook extends StatefulWidget {
  final VoidCallback onBack;
  textBook({super.key, required this.onBack});

  @override
  State<textBook> createState() => _textBook();
}

class _textBook extends State<textBook> {
  int selectedIndexBackgroundStyle = 0;
  double selectedIndexFontSize = 0;
  int selectedIndexFontFamily = 0;
  double _currentSliderValue = 0;
  String textBook = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await fetchText(); // Добавьте скобки
    setState(() {
      textBook = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            size: 35 * scale,
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
          IconButton(
            icon: const Icon(
              MyFlutterApp.search1,
              color: Colors.white,
            ),
            onPressed: () => _showTextwEditor(scale),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(textBook),
              ),
            ),
    );
  }

  void _showTextwEditor(double scale) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true, // Позволяет сделать листаемое содержимое
        builder: (context) {
          final height =
              MediaQuery.of(context).size.height * 0.8; // Занимает 80% экрана

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
                              color: AppColors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 11 * scale),
                        Text("Яркость",
                            style: TextStyle(
                                fontSize: 16 * scale,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w300)),
                        SizedBox(height: 11 * scale),
                        Column(
                          children: [
                            Consumer<SettingsProvider>(
                              builder: (context, settings, child) {
                                return Slider(
                                  activeColor: AppColors.orange,
                                  value: settings.brightness,
                                  max: 100,
                                  onChanged: (double value) {
                                    settings.setBrightness(value);
                                  },
                                );
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
                                    Text('0%',
                                        style: TextStyle(
                                            fontSize: 16 * scale,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w300))
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      MyFlutter.sun,
                                      size: 30 * scale,
                                      color: AppColors.orange,
                                    ),
                                    Text('100%',
                                        style: TextStyle(
                                            fontSize: 16 * scale,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w300))
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 20 * scale),
                        Text('Цветовая тема',
                            style: TextStyle(
                                fontSize: 16 * scale,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w300)),
                        SizedBox(height: 16 * scale),
                        Consumer<SettingsProvider>(
                          builder: (context, settings, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    settings.setBackgroundStyle(0);
                                  },
                                  child: Container(
                                    width: 80 * scale,
                                    height: 35 * scale,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            settings.selectedBackgroundStyle ==
                                                    0
                                                ? AppColors.orange
                                                : Colors.white,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Аа',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16 * scale),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                // Остальные кнопки для выбора темы
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      settings.setBackgroundStyle(1);
                                    });
                                  },
                                  child: Container(
                                    width: 80 * scale,
                                    height: 35 * scale,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            settings.selectedBackgroundStyle ==
                                                    1
                                                ? AppColors.orange
                                                : Colors.white,
                                      ),
                                      color: Color(0xffFFF7E0),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Аа',
                                      style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16 * scale),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      settings.setBackgroundStyle(2);
                                    });
                                  },
                                  child: Container(
                                    width: 80 * scale,
                                    height: 35 * scale,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            settings.selectedBackgroundStyle ==
                                                    2
                                                ? AppColors.orange
                                                : Colors.white,
                                      ),
                                      color: Color(0xff858585),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Аа',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16 * scale),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      settings.setBackgroundStyle(3);
                                    });
                                  },
                                  child: Container(
                                    width: 80 * scale,
                                    height: 35 * scale,
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            settings.selectedBackgroundStyle ==
                                                    3
                                                ? AppColors.orange
                                                : Colors.white,
                                      ),
                                      color: AppColors.textPrimary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Аа',
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 16 * scale),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 16 * scale),
                        Text('Шрифт',
                            style: TextStyle(
                                fontSize: 16 * scale,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w300)),
                        SizedBox(height: 16 * scale),
                        Consumer<SettingsProvider>(
                            builder: (context, settings, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      settings.setFontFamily(0);
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
                                            color:
                                                settings.selectedFontFamily == 0
                                                    ? AppColors.orange
                                                    : AppColors.blueColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Аа',
                                          style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16 * scale),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        'Rounded',
                                        style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14 * scale),
                                      )
                                    ],
                                  )),
                              SizedBox(width: 10),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      settings.setFontFamily(1);
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
                                            color:
                                                settings.selectedFontFamily == 1
                                                    ? AppColors.orange
                                                    : AppColors.blueColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Аа',
                                          style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16 * scale),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        'Rubik',
                                        style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14 * scale),
                                      )
                                    ],
                                  )),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      settings.setFontFamily(2);
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
                                            color:
                                                settings.selectedFontFamily == 2
                                                    ? AppColors.orange
                                                    : AppColors.blueColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Аа',
                                          style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16 * scale),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        'Inter',
                                        style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14 * scale),
                                      )
                                    ],
                                  )),
                              GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      settings.setFontFamily(3);
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
                                            color:
                                                settings.selectedFontFamily == 3
                                                    ? AppColors.orange
                                                    : AppColors.blueColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'Аа',
                                          style: TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16 * scale),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        'Advent',
                                        style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14 * scale),
                                      )
                                    ],
                                  )),
                            ],
                          );
                        }),
                        SizedBox(height: 16 * scale),
                        Text('Размер текста',
                            style: TextStyle(
                                fontSize: 16 * scale,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w300)),
                        SizedBox(height: 16 * scale),
                        Consumer<SettingsProvider>(
                            builder: (context, settings, child) {
                          return Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('A',
                                    style: TextStyle(
                                        fontSize: 16 * scale,
                                        color: AppColors.textPrimary)),
                                Text('A',
                                    style: TextStyle(
                                        fontSize: 40 * scale,
                                        color: AppColors.textPrimary))
                              ],
                            ),
                            SfSlider(
                                activeColor: AppColors.orange,
                                min: 0.0,
                                max: 100.0,
                                value: settings.fontSize,
                                showTicks: true,
                                interval:
                                    10, // Устанавливаем интервал между основными делениями
                                minorTickShape: const SfTickShape(),
                                onChanged: (value) {
                                  setState(() {
                                    settings.setFontSize(value);
                                  });
                                }),
                            SizedBox(height: 16 * scale),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    AppColors.background),
                              ),
                              onPressed: () {
                                
                              },
                              child: Text(
                                "Применить",
                                style: TextStyle(
                                    fontSize: 32, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]);
                        }),
                      ])));
        });
  }
}
