import 'package:booktrack/MyFlutterIcons.dart';
import 'package:booktrack/icons.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';

class LevelScreen extends StatefulWidget {
  final VoidCallback onBack;
  LevelScreen({super.key, required this.onBack});
  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with SingleTickerProviderStateMixin {
  double progress = 0.7; // Прогресс (0.0 - 1.0)

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Уровень',
            style: TextStyle(
              fontSize: 32 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: Icon(
              size: 35 * scale,
              MyFlutterApp.back,
              color: Colors.white,
            ),
            onPressed: widget.onBack,
          ),
        ),
        backgroundColor: AppColors.background,
        body: Container(
          padding: EdgeInsets.only(top: 20 * scale),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.baseCircual * scale),
              topRight: Radius.circular(AppDimensions.baseCircual * scale),
            ),
          ),
          child: Column(
            children: [
              LevelProgressWidget(
                currentLevel: 7,
                nextLevel: 8,
                progress: 0.6, // 60% заполнение шкалы
              ),
              _buildStats(),
              Expanded(child: _buildRewardsList()),
            ],
          ),
        ));
  }

  Widget _buildStats() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(Icons.emoji_events, "3179 XP"),
          _buildStatItem(Icons.book, "432 стр"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 8),
          Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRewardsList() {
    List<Map<String, dynamic>> rewards = [
      {"level": 5, "points": 150, "status": "Получено"},
      {"level": 6, "points": 150, "status": "Получено"},
      {"level": 7, "points": 150, "status": "Получено"},
      {"level": 8, "points": 150, "status": "Закрыто"},
      {"level": 9, "points": 150, "status": "Закрыто"},
    ];

    return ListView.builder(
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final reward = rewards[index];
        return Card(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.orange,
                    child: Text(
                      reward["level"].toString(),
                      style: TextStyle(color: Colors.white, fontSize: 32),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        reward["points"].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.textPrimary),
                      ),
                      Icon(
                        MyFlutter.bonus,
                        color: AppColors.orange,
                        size: 21,
                      )
                    ],
                  ),
                  SizedBox(width: 16),
                  Text(
                    reward["status"],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ));
      },
    );
  }
}

class LevelProgressWidget extends StatelessWidget {
  final int currentLevel;
  final int nextLevel;
  final double progress; // от 0 до 1

  const LevelProgressWidget({
    Key? key,
    required this.currentLevel,
    required this.nextLevel,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Ваш уровень $currentLevel",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth =
                constraints.maxWidth - 60; // Оставляем отступы по бокам
            double progressWidth =
                maxWidth * progress; // Ширина заполненной линии

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Фоновая линия прогресса
                Container(
                  height: 10,
                  width: maxWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Заполненная часть прогресса
                Container(
                  height: 10,
                  width: progressWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Левый круг (текущий уровень)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                        left: 30), // 22 - половина радиуса круга
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.orange,
                      child: Text(
                        "$currentLevel",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Правый круг (следующий уровень)
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(right: 30),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        "$nextLevel",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
