import 'dart:math';
import 'dart:ui';

import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class AnimatedWaveScreenAuthWrap extends StatefulWidget {
  const AnimatedWaveScreenAuthWrap({super.key});

  @override
  _AnimatedWaveScreenStateAuthWrap createState() =>
      _AnimatedWaveScreenStateAuthWrap();
}

class _AnimatedWaveScreenStateAuthWrap extends State<AnimatedWaveScreenAuthWrap>
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
                  painter:
                      BlobPainterAuthWrap(animationValue: _animation.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BlobPainterAuthWrap extends CustomPainter {
  final double animationValue;

  BlobPainterAuthWrap({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Верхняя диагональ с анимацией волны
    Path pathTop = Path();
    _drawAnimatedWave(pathTop, size, animationValue, isTop: true);

    Paint paintTop = Paint()..color = AppColors.orange;

    // Нижняя диагональ с анимацией волны
    Path pathBottom = Path();
    _drawAnimatedWave(pathBottom, size, animationValue, isTop: false);

    Paint paintBottom = Paint()..color = AppColors.background;

    // Отрисовка
    canvas.drawPath(pathTop, paintTop);
    canvas.drawPath(pathBottom, paintBottom);
  }

  // Метод для рисования анимированной волны
  void _drawAnimatedWave(Path path, Size size, double animationValue,
      {required bool isTop}) {
    final double waveHeight = 10.0; // Высота волны
    final double waveLength = size.width / 2; // Длина волны
    final double offset = animationValue * waveLength; // Смещение для анимации

    if (isTop) {
      // Верхняя диагональ (отзеркаленная)
      double startY = size.height * 0.05; // Начинаем на середине левого края
      path.moveTo(0, startY); // Начало
      for (double x = 0; x <= size.width; x++) {
        // Вычисляем y с учетом отзеркаленной волны
        double y = startY +
            (startY * (x / size.width)) +
            waveHeight * sin((x + offset) * 2 * pi / waveLength);
        path.lineTo(x, y);
      }
      path.lineTo(size.width, 0.5);
      path.lineTo(0, 0);
      path.lineTo(0, startY);
    } else {
      path.moveTo(0, size.height);
      for (double x = 0; x <= size.width; x++) {
        double y = (size.height * 0.65) +
            (size.height * 0.15 * (x / size.width) +
                waveHeight * sin((x + offset) * 2 * pi / waveLength));
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
