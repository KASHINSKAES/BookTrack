import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/AppState.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';

class TimerPage extends StatefulWidget {
  final VoidCallback onBack;
  TimerPage({super.key, required this.onBack});

  @override
  State<TimerPage> createState() => _TimerPage();
}

class _TimerPage extends State<TimerPage> {
  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;
  int selectedPages = 0;

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Статистика',
            style: TextStyle(
              fontSize: 32 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: Icon(
              size: 35 * scale,
              MyFlutterApp.back,
              color: Colors.white,
            ),
            onPressed: widget.onBack,
          ),
        ),
        body: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 30 * scale),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                    topRight:
                        Radius.circular(AppDimensions.baseCircual * scale),
                  ),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Сколько вы планируете читать сегодня?',
                        style: TextStyle(
                            fontSize: 32, color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    NumberPicker(
                                      value: selectedPages,
                                      minValue: 0,
                                      maxValue: 1000,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedPages = value;
                                        });
                                      },
                                    ),
                                  ]))),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(AppColors.background),
                        ),
                        onPressed: () {
                          if (selectedPages > 0) {
                            // Обновляем значение в AppState
                            Provider.of<AppState>(context, listen: false)
                                .updateReadingPagesPurpose(selectedPages);
                            // Возвращаемся на предыдущую страницу
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Please enter a valid number!")),
                            );
                          }
                        },
                        child: Text(
                          "Применить",
                          style: TextStyle(fontSize: 32, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Запланируйте свое количество страниц в день:',
                        style: TextStyle(
                            fontSize: 32, color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      NumberPicker(
                                        value: selectedHours,
                                        minValue: 0,
                                        maxValue: 24,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedHours = value;
                                          });
                                        },
                                      ),
                                      Text('ч')
                                    ]),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      NumberPicker(
                                        value: selectedMinutes,
                                        minValue: 0,
                                        maxValue: 60,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedMinutes = value;
                                          });
                                        },
                                      ),
                                      Text('мин')
                                    ]),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      NumberPicker(
                                        value: selectedSeconds,
                                        minValue: 0,
                                        maxValue: 60,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedSeconds = value;
                                          });
                                        },
                                      ),
                                      Text('c')
                                    ]),
                              ])),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(AppColors.background),
                        ),
                        onPressed: () {
                          int totalSeconds = (selectedHours * 3600) +
                              (selectedMinutes * 60) +
                              selectedSeconds;
                          if (totalSeconds > 0) {
                            // Обновляем значение в AppState

                            // Передаем данные в провайдер
                            Provider.of<AppState>(context, listen: false)
                                .updateReadingMinutesPurpose(totalSeconds);

                            // Возвращаемся на предыдущую страницу
                            Navigator.pop(
                                context); // Возвращаемся на предыдущую страницу
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Please enter a valid number!")),
                            );
                          }
                        },
                        child: Text(
                          "Применить",
                          style: TextStyle(fontSize: 32, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ]))));
  }
}
/*
Center(
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
      
      Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Колесо выбора часов
                SizedBox(
                  width: 100,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        selectedHours = hours[index];
                      });
                    },
                    children: hours.map((hour) {
                      return Center(
                        child: Text('$hour ч'),
                      );
                    }).toList(),
                  ),
                ),
                // Колесо выбора минут
                SizedBox(
                  width: 100,
                  child: CupertinoPicker(
                    itemExtent: 40,
                    onSelectedItemChanged: (int index) {
                      setState(() {
                        selectedMinutes = minutes[index];
                      });
                    },
                    children: minutes.map((minute) {
                      return Center(
                        child: Text('$minute мин'),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )]*/
