import 'dart:math';

import 'package:booktrack/main.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/pages/LoginPAGES/AuthWrap.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _showLoading = true;
  bool _hasError = false;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final auth = Provider.of<AuthProviders>(context, listen: false);

      // 1. Проверяем сохраненный userId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      // 2. Если есть сохраненный ID, пробуем загрузить пользователя
      if (userId != null && userId.isNotEmpty) {
        await auth.loadUserData();
      }

      // 3. Проверяем текущего пользователя в Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && auth.userModel == null) {
        await auth.loadUserData();
      }

      // 4. Рассчитываем оставшееся время до 5 секунд
      final elapsed = DateTime.now().difference(_startTime);
      final remaining = Duration(seconds: 15) - elapsed;

      if (remaining > Duration.zero) {
        await Future.delayed(remaining);
      }

      if (mounted) {
        setState(() {
          _showLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _showLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoading) {
      return _buildLoadingScreen();
    }

    if (_hasError) {
      return _buildErrorScreen();
    }

    return _redirectBasedOnAuth();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: AnimatedWaveScreen()),
          Center(child: SvgPicture.asset("images/logoLoadingScreen.svg")),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ошибка загрузки'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeApp,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _redirectBasedOnAuth() {
    final auth = Provider.of<AuthProviders>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (auth.userModel != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BottomNavigationBarEX()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    });

    return _buildLoadingScreen();
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
