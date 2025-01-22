import 'package:flutter/material.dart';
import '/widgets/constants.dart';
import '/MyFlutter_icons.dart';
import '/icons.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          actions: [
            IconButton(
              icon: Icon(
                MyFlutter.setting2,
              ),
              onPressed: () {
                // Действие для настроек
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Container(
          color: AppColors.background,
          child: Column(children: [
            // Верхний блок с аватаром
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(
                        'assets/profile_image.png'), // Добавьте изображение
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Павел",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 18 * scale),
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 23 * scale),
                  decoration: BoxDecoration(
                      color: Color(0xffF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(37 * scale),
                        topRight: Radius.circular(37 * scale),
                      )),
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(top: 16.0 * scale),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: Offset(4, 8), // Shadow position
                                  ),
                                ],
                                borderRadius: BorderRadius.all(Radius.circular(
                                    AppDimensions.baseCircual * scale)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 14 * scale,
                                          horizontal: 19 * scale),
                                      child: Text(
                                        "Мои достижения",
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 24 * scale,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )),
                                  MenuItem(
                                    title: "Уровень",
                                    icon: MyFlutter.level,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LevelPage()),
                                      );
                                    },
                                  ),
                                  MenuItem(
                                    title: "Статистика",
                                    icon: MyFlutter.statistik,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StatisticsPage()),
                                      );
                                    },
                                  ),
                                  MenuItem(
                                    title: "Трекер чтения",
                                    icon: MyFlutter.calendar,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ReadingTrackerPage()),
                                      );
                                    },
                                  ),
                                  MenuItem(
                                    title: "История бонусов",
                                    icon: MyFlutter.bonus,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BonusHistoryPage()),
                                      );
                                    },
                                  ),
                                ],
                              ))),
                      // Блок "Чат"
                      Padding(
                          padding: EdgeInsets.only(top: 16.0 * scale),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: Offset(4, 8), // Shadow position
                                ),
                              ],
                              borderRadius: BorderRadius.all(Radius.circular(
                                  AppDimensions.baseCircual * scale)),
                            ),
                            child: MenuItem(
                              title: "Чат",
                              icon: Icons.chat,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPage()),
                                );
                              },
                            ),
                          )),
                      // Блок "Настройки"
                      Padding(
                        padding: EdgeInsets.only(top: 16 * scale),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: Offset(4, 8), // Shadow position
                                ),
                              ],
                              borderRadius: BorderRadius.all(Radius.circular(
                                  AppDimensions.baseCircual * scale)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14 * scale,
                                        horizontal: 19 * scale),
                                    child: Text(
                                      "Настройки",
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 24 * scale,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
                                MenuItem(
                                  title: "Способы оплаты",
                                  icon: Icons.payment,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PaymentMethodsPage()),
                                    );
                                  },
                                ),
                                MenuItem(
                                  title: "Ваши платежи",
                                  icon: Icons.receipt,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PaymentsPage()),
                                    );
                                  },
                                ),
                                MenuItem(
                                  title: "Язык интерфейса",
                                  icon: Icons.language,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LanguagePage()),
                                    );
                                  },
                                ),
                                MenuItem(
                                  title: "Скачивать только по Wi-Fi",
                                  icon: Icons.wifi,
                                  trailing: Switch(
                                    value: true,
                                    onChanged: (value) {
                                      // Обработка переключателя
                                    },
                                  ),
                                ),
                              ],
                            )),
                      )
                    ],
                  )),
            )
          ]),
        )));
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  MenuItem(
      {required this.title, required this.icon, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: trailing ?? Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}

// Заглушки для страниц
class LevelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Уровень")));
  }
}

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Статистика")));
  }
}

class ReadingTrackerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Трекер чтения")));
  }
}

class BonusHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("История бонусов")));
  }
}

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Чат")));
  }
}

class PaymentMethodsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Способы оплаты")));
  }
}

class PaymentsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Ваши платежи")));
  }
}

class LanguagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Язык интерфейса")));
  }
}

class AnimatedBlobsPage extends StatefulWidget {
  @override
  _AnimatedBlobsPageState createState() => _AnimatedBlobsPageState();
}

class _AnimatedBlobsPageState extends State<AnimatedBlobsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true); // Зацикленная анимация
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: BlobPainter(animationValue: _controller.value),
                child: Container(),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                      'assets/avatar.png'), // Замените на свой аватар
                ),
                const SizedBox(height: 20),
                const Text(
                  "Павел",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class AnimatedBlobsScreen extends StatefulWidget {
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
    )..repeat(reverse: true); // Зацикленная анимация

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
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final path = Path();

    // Центральные координаты
    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // Переменные для изменения формы
    double baseRadius = 150; // Базовый размер пятна
    double distortion = 50 * animationValue; // Анимация изменений

    // Рисуем пятно с искажениями
    path.moveTo(centerX, centerY - baseRadius);

    path.quadraticBezierTo(
      centerX + baseRadius + distortion,
      centerY - baseRadius,
      centerX + baseRadius,
      centerY,
    );
    path.quadraticBezierTo(
      centerX + baseRadius,
      centerY + baseRadius + distortion,
      centerX,
      centerY + baseRadius,
    );
    path.quadraticBezierTo(
      centerX - baseRadius - distortion,
      centerY + baseRadius,
      centerX - baseRadius,
      centerY,
    );
    path.quadraticBezierTo(
      centerX - baseRadius,
      centerY - baseRadius - distortion,
      centerX,
      centerY - baseRadius,
    );

    path.close();

    // Отрисовка фигуры
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}