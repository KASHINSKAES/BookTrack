import 'package:booktrack/firebase_options.dart';
import 'package:booktrack/pages/BrightnessProvider.dart';
import 'package:booktrack/pages/ReadingStatsProvider.dart';
import 'package:booktrack/pages/SettingsProvider.dart';
import 'package:booktrack/pages/loadingScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'pages/AppState.dart';
import 'package:booktrack/pages/profilePage.dart';
import 'package:booktrack/pages/selectedPage.dart';
import '/icons.dart';
import '/pages/mainPage.dart';
import '/pages/catalogPage.dart';
import '/widgets/BookListPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('ru_RU', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(
      create: (_) => BrightnessProvider()),
        ChangeNotifierProvider(
            create: (context) => ReadingStatsProvider()..loadData()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: const MyApp(), // Используем MyApp как корневой виджет
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'MPLUSRounded1c'),
      home: const LoadingScreen(), // Загрузочный экран как первый экран
    );
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
      body: Stack(
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
              icon: Icon(MyFlutterApp.home), label: 'Главная'),
          BottomNavigationBarItem(
              icon: Icon(MyFlutterApp.catalog), label: 'Каталог'),
          BottomNavigationBarItem(
              icon: Icon(MyFlutterApp.school), label: 'Избранное'),
          BottomNavigationBarItem(
              icon: Icon(MyFlutterApp.user), label: 'Профиль'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
      ),
    );
  }
}
