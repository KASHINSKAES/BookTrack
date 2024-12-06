import 'package:flutter/material.dart';
import '/icons.dart';

class bottomNavigator extends StatelessWidget {
  const bottomNavigator({super.key});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
    );
  }
}
