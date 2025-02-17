import 'package:booktrack/firebase_options.dart';
import 'package:booktrack/pages/ReadingStatsProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Используйте конфигурацию
  );
  // Инициализация локали
  await initializeDateFormatting('ru_RU', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(
            create: (context) => ReadingStatsProvider()..loadData())
      ],
      child: MyApp(),
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
      home: const BottomNavigationBarEX(),
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
      _selectedCategory =
          category; // Выбираем категорию для отображения BookListPage
    });
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedCategory =
          null; // Сбрасываем категорию, чтобы вернуться на основную страницу
    });
  }

  static List<Widget> _mainPages(
      BuildContext context, Function(String) onCategoryTap) {
    return <Widget>[
      const MainPage(),
      CatalogPage(
          onCategoryTap: onCategoryTap), // Передача обработчика в CatalogPage
      selectedPage(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Основное содержимое
          _mainPages(context, _onCategoryTap)[_selectedIndex],

          // Страница с книгами (если выбрана категория)
          if (_selectedCategory != null)
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: BookListPage(
                  category: _selectedCategory!,
                  onBack: () {
                    setState(() {
                      _selectedCategory = null; // Убираем BookListPage
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
