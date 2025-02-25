import 'dart:math';

import 'package:booktrack/MyFlutterIcons.dart';
import 'package:booktrack/main.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_svg/svg.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      setState(() {
        isLoaded = true;
      });
      // Переход на основной экран
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomNavigationBarEX()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return AnimatedSwitcher(
      duration: const Duration(seconds: 30),
      child: isLoaded
          ? const BottomNavigationBarEX() // Переход на основной экран
          : Scaffold(
              backgroundColor: Colors.white,
              body: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: AnimatedWaveScreen(),
                  ),
                  Center(
                    child: SvgPicture.asset(
                      "images/logoLoadingScreen.svg",
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class AnimatedWaveScreen extends StatefulWidget {
  const AnimatedWaveScreen({super.key});

  @override
  _AnimatedWaveScreenState createState() => _AnimatedWaveScreenState();
}

class _AnimatedWaveScreenState extends State<AnimatedWaveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(); // Бесконечная анимация

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: BlobPainter(animationValue: _animation.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BlobPainter extends CustomPainter {
  final double animationValue;

  BlobPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Верхняя диагональ с анимацией волны
    Path pathTop = Path();
    _drawAnimatedWave(pathTop, size, animationValue, isTop: true);

    Paint paintTop = Paint()..color = AppColors.background;

    // Нижняя диагональ с анимацией волны
    Path pathBottom = Path();
    _drawAnimatedWave(pathBottom, size, animationValue, isTop: false);

    Paint paintBottom = Paint()..color = AppColors.orange;

    // Отрисовка
    canvas.drawPath(pathTop, paintTop);
    canvas.drawPath(pathBottom, paintBottom);
  }

  // Метод для рисования анимированной волны
  void _drawAnimatedWave(Path path, Size size, double animationValue,
      {required bool isTop}) {
    final double waveHeight = 20.0; // Высота волны
    final double waveLength = size.width / 2; // Длина волны
    final double offset = animationValue * waveLength; // Смещение для анимации

    if (isTop) {
      // Верхняя диагональ (отзеркаленная)
      double startY = size.height * 0.5; // Начинаем на середине левого края
      path.moveTo(0, startY); // Начало в (0, size.height * 0.5)
      for (double x = 0; x <= size.width; x++) {
        // Вычисляем y с учетом отзеркаленной волны
        double y = startY -
            (startY * (x / size.width)) +
            waveHeight * sin((-x + offset) * 2 * pi / waveLength);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, 0); // Заканчиваем в правом верхнем углу
      path.lineTo(0, 0); // Возвращаемся к началу по нижней границе
      path.lineTo(0, startY); // Замыкаем путь
    } else {
      // Нижняя диагональ (без изменений)
      path.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x++) {
        double y = size.height -
            (size.height * 0.5 * (x / size.width)) +
            waveHeight * sin((x + offset) * 2 * pi / waveLength);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
