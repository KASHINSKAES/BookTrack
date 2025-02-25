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
                    child: AnimatedBlobsScreen(),
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

class AnimatedBlobsScreen extends StatefulWidget {
  const AnimatedBlobsScreen({super.key});

  @override
  _AnimatedBlobsScreenState createState() => _AnimatedBlobsScreenState();
}

class _AnimatedBlobsScreenState extends State<AnimatedBlobsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

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
                  size: Size.infinite,
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
    Path pathTop = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * .0)
      ..lineTo(0, size.height * .50)
      ..lineTo(0, 0)
      ..close();

    Paint paintTop = Paint()..color = AppColors.background;

    Path pathBottom = Path()
      ..moveTo(0, size.height) // Начинаем с левого нижнего угла
      ..lineTo(size.width, size.height) // Идем в правый нижний угол
      ..lineTo(size.width, size.height * .50) // Поднимаемся вверх на 30% высоты
      ..lineTo(0, size.height * .95) // Опускаемся вниз до 95% высоты
      ..lineTo(0, size.height) // Возвращаемся в левый нижний угол
      ..close(); // Замыкаем путь

    Paint paintBottom = Paint()..color = AppColors.orange;

    canvas.drawPath(pathTop, paintTop);
    canvas.drawPath(pathBottom, paintBottom);
    // bottom line

    // paint
    //   ..color = Colors.green
    //   ..strokeWidth = 20;
    // canvas.drawLine(Offset(-20, size.height - bottomPadding),
    //     Offset(size.width + 20, size.height * .65), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
