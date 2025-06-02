import 'dart:async';
import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/PagesMainBottom/SelectetPage/timerAndPages.dart';
import 'package:booktrack/pages/ProfilePages/Statistic/ReadingStatsProvider.dart';
import 'package:booktrack/servises/levelServises.dart';
import 'package:booktrack/widgets/bookListGoris.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../BookCard/text/AppState.dart';

class SelectedPage extends StatefulWidget {
  @override
  _SelectedPageState createState() => _SelectedPageState();
}

class _SelectedPageState extends State<SelectedPage> {
  late LevelService _levelService;
  String? userId;
  late AppState _appState;
  late ReadingStatsProvider _statsProvider;
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appState = Provider.of<AppState>(context);
    _statsProvider = Provider.of<ReadingStatsProvider>(context, listen: false);
    userId =
        Provider.of<AuthProviders>(context, listen: false).userModel?.uid ?? '';

    if (userId!.isNotEmpty) {
      _levelService = LevelService(userId!);
      _appState.loadUserData(userId!);
    }
  }

  Future<void> _loadInitialData() async {
    await _statsProvider.loadData(context);
  }

  Future<void> _addXP(int amount) async {
    if (userId == null || userId!.isEmpty) return;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);
        final doc = await transaction.get(userRef);

        if (!doc.exists) {
          transaction.set(userRef, {
            'stats': {
              'current_level': 1,
              'pages': amount,
              'xp': amount,
            },
          });
          return;
        }

        final stats = doc.data()?['stats'] as Map<String, dynamic>? ?? {};
        transaction.update(userRef, {
          'stats.xp': (stats['xp'] ?? 0) + amount,
        });

        if (mounted) {
          await _levelService.checkLevelUp(context);
        }
      });
    } catch (e) {
      debugPrint('Error in _addXP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                topRight: Radius.circular(AppDimensions.baseCircual * scale),
              ),
            ),
            child: Column(
              children: [
                // Таймер и статистика чтения
                _buildReadingStats(scale),

                // Списки книг
                SectionTitle(
                  title: "Избранные",
                  onSeeAll: () => _navigateToBookList('saved_books'),
                ),
                BookList(listType: 'saved_books', userId: userId),

                SectionTitle(
                  title: "Читаемые",
                  onSeeAll: () => _navigateToBookList('read_books'),
                ),
                BookList(listType: 'read_books', userId: userId),

                SectionTitle(
                  title: "Прочитано",
                  onSeeAll: () => _navigateToBookList('end_books'),
                ),
                BookList(listType: 'end_books', userId: userId),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingStats(double scale) {
    return Selector<AppState, bool>(
      selector: (_, appState) => appState.dailyGoalAchieved,
      builder: (context, goalAchieved, child) {
        // Проверяем достижение цели после построения UI

        if (goalAchieved) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final prefs = await SharedPreferences.getInstance();
            bool xpWasAdded = prefs.getBool('daily_xp_added') ?? false;

            if (!xpWasAdded) {
              _addXP(15);
              await prefs.setBool('daily_xp_added', true); // Сохраняем флаг
              if (mounted) setState(() {}); // Обновляем UI при необходимости
            }
          });
        }

        return Container(
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
                        BookTrackIcon.taimerSelectet,
                        size: 55 * scale,
                        color: Colors.white,
                      ),
                      onPressed: null,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Selector<AppState, String>(
                            selector: (_, appState) =>
                                appState.formattedRemainingTime,
                            builder: (context, time, child) {
                              return Text(
                                time,
                                style: TextStyle(
                                  fontSize: 32 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          Selector<AppState, int>(
                            selector: (_, appState) => appState.pagesReadToday,
                            builder: (context, pagesRead, child) {
                              return Text(
                                '$pagesRead/${_appState.readingPagesPurpose} страниц',
                                style: TextStyle(
                                  fontSize: 16 * scale,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    RotatedBox(
                      quarterTurns: 2,
                      child: IconButton(
                        icon: Icon(
                          BookTrackIcon.onBack,
                          size: 29 * scale,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimerPage(
                              onBack: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToBookList(String listType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllBooksPage(
          listType: listType,
          userId: userId,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const SectionTitle({required this.title, required this.onSeeAll});

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
              color: AppColors.textPrimary,
            ),
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
