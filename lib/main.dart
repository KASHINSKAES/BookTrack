import 'package:flutter/material.dart';
import '/icons.dart';
import '/pages/mainPage.dart';
import '/pages/catalogPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'MPLUSRounded1c'),
      home: BottomNavigationBarEX(),
    );
  }
}

class BottomNavigationBarEX extends StatefulWidget {
  const BottomNavigationBarEX({super.key});

  @override
  State<BottomNavigationBarEX> createState() => HomePage();
}

class HomePage extends State<BottomNavigationBarEX> {
  static int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    MainPage(),
    Catalogpage(),
    Icon(
      Icons.chat,
      size: 150,
    ),
     Icon(
      Icons.chat,
      size: 150,
    ),
  ];
  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedLabelStyle: TextStyle(fontSize: 11.0),
        selectedLabelStyle: TextStyle(fontSize: 11.0),
        iconSize: 35.0,
        showUnselectedLabels: true,
        selectedItemColor: Color(0xff5775CD),
        unselectedItemColor: Color(0xffFD521B),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(MyFlutterApp.widget_2), label: 'Главная'),
          BottomNavigationBarItem(
              icon: Icon(MyFlutterApp.server_minimalistic), label: 'Каталог'),
          BottomNavigationBarItem(
              icon: Icon(MyFlutterApp.notebook_bookmark), label: 'Избранное'),
          BottomNavigationBarItem(
              icon: Icon(MyFlutterApp.user), label: 'Профиль'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
      ),
    );
  }
}
