import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class bottomNavigator extends StatelessWidget {
  const bottomNavigator({super.key});
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      unselectedLabelStyle: TextStyle(fontSize: 11.0),
      selectedLabelStyle: TextStyle(fontSize: 11.0),
      iconSize: 35.0,
      showUnselectedLabels: true,
      selectedItemColor: AppColors.buttonBorder,
      unselectedItemColor: AppColors.orange,
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
    );
  }
}
