import 'dart:async';

import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/timerAndPages.dart';
import 'package:booktrack/widgets/bookListGoris.dart';
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
  String? userId;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final auth = Provider.of<AuthProviders>(context, listen: false);
    final appState = Provider.of<AppState>(context, listen: false);
    userId = auth.userModel?.uid ?? '';

    if (auth.userModel != null) {
      await appState.loadUserData(auth.userModel!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
      backgroundColor: const Color(0xff5775CD),
      body: ListView(
        padding: EdgeInsets.only(top: 23.0 * scale),
        children: [
          Padding(
            padding: EdgeInsets.only(
                right: 20 * scale, left: 20 * scale, top: 10 * scale),
            child: Text(
              "Мои книги",
              style: TextStyle(
                color: Colors.white,
                fontSize: AppDimensions.baseTextSizeh1 * scale,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.height,
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
                                appState.dailyGoalAchieved
                                    ? Icons.celebration
                                    : Icons.auto_awesome,
                                color: Colors.white,
                              ),
                              onPressed: null,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    appState.formattedRemainingTime,
                                    style: TextStyle(
                                      fontSize: 32 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${appState.pagesReadToday}/${appState.readingPagesPurpose} страниц',
                                    style: TextStyle(
                                      fontSize: 16 * scale,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RotatedBox(
                              quarterTurns: 2,
                              child: IconButton(
                                icon: Icon(
                                  MyFlutterApp.back,
                                  size: 29 * scale,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TimerPage(
                                        onBack: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
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
                  title: "Избранные",
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllBooksPage()),
                    );
                  },
                ),
                BookList(
                  listType: 'saved_books',
                  userId: userId,
                ),

// Прочитанные книги
                SectionTitle(
                  title: "Прочитано",
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllBooksPage()),
                    );
                  },
                ),
                BookList(
                  listType: 'read_books',
                  userId: userId,
                ),

// Читаемые книги
                SectionTitle(
                  title: "Читаемые",
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllBooksPage()),
                    );
                  },
                ),
                BookList(
                  listType: 'end_books',
                  userId: userId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
