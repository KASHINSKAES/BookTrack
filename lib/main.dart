import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/firebase_options.dart';
import 'package:booktrack/keys.dart';
import 'package:booktrack/pages/BookCard/text/BrightnessProvider.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/LoginPAGES/AuthWrap.dart';
import 'package:booktrack/pages/ProfilePages/Statistic/ReadingStatsProvider.dart';
import 'package:booktrack/pages/BookCard/text/SettingsProvider.dart';
import 'package:booktrack/pages/filter/filterProvider.dart';
import 'package:booktrack/pages/ProfilePages/Level/levelProvider.dart';
import 'package:booktrack/pages/loadingScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'pages/BookCard/text/AppState.dart';
import 'package:booktrack/pages/PagesMainBottom/profilePage.dart';
import 'package:booktrack/pages/PagesMainBottom/SelectetPage/selectedPage.dart';
import 'pages/PagesMainBottom/mainPage.dart';
import 'pages/PagesMainBottom/catalogPage.dart';
import '/widgets/BookListPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ru_RU', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => LevelProvider.empty()),
        ChangeNotifierProvider(create: (_) => BrightnessProvider()),
        ChangeNotifierProvider(create: (context) => ReadingStatsProvider()),
        ChangeNotifierProvider(create: (context) => AuthProviders()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => FilterProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'MPLUSRounded1c',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context);
    final levelProvider = Provider.of<LevelProvider>(context);

    // Обновляем LevelProvider при изменении userModel
    if (authProvider.userModel != null && levelProvider.userId.isEmpty) {
      levelProvider.updateUserId(authProvider.userModel!.uid);
    }

    if (authProvider.isLoading) {
      return const LoadingScreen();
    }

    return authProvider.userModel != null
        ? const BottomNavigationBarEX()
        : const AuthScreen();
  }
}

class BottomNavigationBarEX extends StatefulWidget {
  const BottomNavigationBarEX({super.key});

  @override
  State<BottomNavigationBarEX> createState() => _BottomNavigationBarEXState();
}

class _BottomNavigationBarEXState extends State<BottomNavigationBarEX> {
  int _selectedIndex = 0;
  String? _selectedCategory;

  void _onCategoryTap(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedCategory = null;
    });
  }

  static List<Widget> _mainPages(
      BuildContext context, Function(String) onCategoryTap) {
    return <Widget>[
      const MainPage(),
      CatalogPage(onCategoryTap: onCategoryTap),
      selectedPage(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedCategory != null ? 1 : 0,
        children: [
          _mainPages(context, _onCategoryTap)[_selectedIndex],
          if (_selectedCategory != null)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: BookListPage(
                  category: _selectedCategory!,
                  onBack: () {
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedLabelStyle: const TextStyle(fontSize: 11.0),
        selectedLabelStyle: const TextStyle(fontSize: 11.0),
        iconSize: 35.0,
        showUnselectedLabels: true,
        selectedItemColor: const Color(0xff5775CD),
        unselectedItemColor: const Color(0xffFD521B),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(BookTrackIcon.homeScren), label: 'Главная'),
          BottomNavigationBarItem(
              icon: Icon(BookTrackIcon.catalogScreen), label: 'Каталог'),
          BottomNavigationBarItem(
              icon: Icon(BookTrackIcon.selectetScreen), label: 'Избранное'),
          BottomNavigationBarItem(
              icon: Icon(BookTrackIcon.profileScreen), label: 'Профиль'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
      ),
    );
  }
}
