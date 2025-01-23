import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '/widgets/constants.dart';
import '/MyFlutter_icons.dart';
import '/icons.dart';
import 'dart:math';

class ChatPage extends StatelessWidget {
  final VoidCallback onBack;
  const ChatPage({Key? key, required this.onBack}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(scale),
      // body: _buildBody(scale),
    );
  }

  AppBar _buildAppBar(double scale) {
    return AppBar(
        title: Text(
          "Чат",
          style: TextStyle(
            fontSize: 20 * scale,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(
            MyFlutterApp.back,
            color: Colors.white,
          ),
          onPressed: onBack,
        ));
  }
}
