import 'package:booktrack/pages/statistikPages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '/widgets/constants.dart';
import '/MyFlutter_icons.dart';
import 'chatPage.dart';
import '/icons.dart';
import 'dart:math';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          actions: [
            IconButton(
              icon: Icon(
                MyFlutter.setting,
              ),
              onPressed: () {
                // Действие для настроек
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Container(
          color: AppColors.background,
          child: Column(children: [
            // Верхний блок с аватаром
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: SvgPicture.asset(
                      'images/logoProfile.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(
                    "Павел",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 18 * scale),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 23 * scale),
                  decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(37 * scale),
                        topRight: Radius.circular(37 * scale),
                      )),
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 16.0 * scale),
                          child: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 19 * scale),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: Offset(4, 8), // Shadow position
                                  ),
                                ],
                                borderRadius: BorderRadius.all(Radius.circular(
                                    AppDimensions.baseCircual * scale)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 14 * scale,
                                          horizontal: 19 * scale),
                                      child: Text(
                                        "Мои достижения",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 24 * scale,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                  MenuItem(
                                    title: "Уровень",
                                    icon: MyFlutter.level,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LevelPage()),
                                      );
                                    },
                                    scale: scale,
                                  ),
                                  Divider(color: Color(0xffDCDCDC)),
                                  MenuItem(
                                    title: "Статистика",
                                    icon: MyFlutter.statistik,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StatisticsPage()),
                                      );
                                    },
                                    scale: scale,
                                  ),
                                  Divider(color: Color(0xffDCDCDC)),
                                  MenuItem(
                                    title: "Трекер чтения",
                                    icon: MyFlutter.calendar,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ReadingTrackerPage()),
                                      );
                                    },
                                    scale: scale,
                                  ),
                                  Divider(color: Color(0xffDCDCDC)),
                                  MenuItem(
                                    title: "История бонусов",
                                    icon: MyFlutter.bonus,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BonusHistoryPage()),
                                      );
                                    },
                                    scale: scale,
                                  ),
                                ],
                              ))),
                      // Блок "Чат"
                      Padding(
                          padding: EdgeInsets.only(top: 16.0 * scale),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: Offset(4, 8), // Shadow position
                                ),
                              ],
                              borderRadius: BorderRadius.all(Radius.circular(
                                  AppDimensions.baseCircual * scale)),
                            ),
                            child: MenuItem(
                              title: "Чат",
                              icon: MyFlutter.chatObsh,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChatPage(onBack: () {
                                            Navigator.pop(context);
                                          })),
                                );
                              },
                              scale: scale,
                            ),
                          )),
                      // Блок "Настройки"
                      Padding(
                        padding: EdgeInsets.only(top: 16 * scale),
                        child: Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: 19 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: Offset(4, 8), // Shadow position
                                ),
                              ],
                              borderRadius: BorderRadius.all(Radius.circular(
                                  AppDimensions.baseCircual * scale)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14 * scale,
                                        horizontal: 19 * scale),
                                    child: Text(
                                      "Настройки",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 24 * scale,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                Divider(color: Color(0xffDCDCDC)),
                                MenuItem2(
                                  title: "Способы оплаты",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PaymentMethodsPage()),
                                    );
                                  },
                                  scale: scale,
                                ),
                                Divider(color: Color(0xffDCDCDC)),
                                MenuItem2(
                                  title: "Ваши платежи",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PaymentsPage()),
                                    );
                                  },
                                  scale: scale,
                                ),
                                Divider(color: Color(0xffDCDCDC)),
                                MenuItem2(
                                  title: "Язык интерфейса",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LanguagePage()),
                                    );
                                  },
                                  scale: scale,
                                  trailing: Text(
                                    "Русский",
                                    style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14 * scale),
                                  ),
                                ),
                                Divider(color: Color(0xffDCDCDC)),
                                MenuItem2(
                                  title: "Скачивать только по Wi-Fi",
                                  trailing: Switch(
                                    value: true,
                                    onChanged: (value) {
                                      // Обработка переключателя
                                    },
                                  ),
                                  scale: scale,
                                ),
                              ],
                            )),
                      )
                    ],
                  )),
            )
          ]),
        )));
  }
}

class SectionTitleProfile extends StatelessWidget {
  final String title;

  SectionTitleProfile({required this.title, required Null Function() onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double? scale;

  MenuItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.trailing,
    required this.scale,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20 * scale!,
        ),
      ),
      onTap: onTap,
    );
  }
}

class MenuItem2 extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double? scale;

  MenuItem2({
    required this.title,
    this.onTap,
    this.trailing,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20 * scale!,
        ),
      ),
      trailing: trailing ??
          Transform.rotate(
            angle: 180 * pi / 180,
            child: Icon(
              MyFlutterApp.back,
              color: AppColors.textPrimary,
            ),
          ),
      onTap: onTap,
    );
  }
}

// Заглушки для страниц
class LevelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Уровень")));
  }
}

class ReadingTrackerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Трекер чтения")));
  }
}

class BonusHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("История бонусов")));
  }
}

class PaymentMethodsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Способы оплаты")));
  }
}

class PaymentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Ваши платежи")));
  }
}

class LanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Язык интерфейса")));
  }
}
