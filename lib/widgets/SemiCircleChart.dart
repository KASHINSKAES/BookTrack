import 'dart:math';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class SemiCircleChart extends StatelessWidget {
  final double progress; // Значение от 0 до 1

  const SemiCircleChart({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 100), // Ширина x высота (полукруг)
      painter: _SemiCirclePainter(
        progress: progress,
        strokeWidth: 15,
        progressColor: AppColors.orange,
        backgroundColor: AppColors.orangeLight,
      ),
    );
  }
}

class _SemiCirclePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _SemiCirclePainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Определяем прямоугольник для дуги. Высота умножаем на 2, чтобы получить полный круг,
    // а затем рисуем только нижнюю половину (начиная с PI).
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    // Фон дуги (серый)
    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round // Закруглённые концы
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Рисуем полную полуокружность (180° = PI)
    canvas.drawArc(rect, pi, pi, false, backgroundPaint);

    // Дуга прогресса (например, оранжевая)
    final Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Вычисляем угол заполнения
    final double sweepAngle = pi * progress;
    canvas.drawArc(rect, pi, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
