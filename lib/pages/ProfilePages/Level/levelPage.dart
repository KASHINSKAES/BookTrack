import 'package:booktrack/BookTrackIcon.dart';
import 'package:booktrack/pages/LoginPAGES/AuthProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LevelScreen extends StatefulWidget {
  final VoidCallback onBack;
  const LevelScreen({super.key, required this.onBack});

  @override
  _LevelScreenState createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  late Future<Map<String, dynamic>> _userDataFuture;
  late Future<QuerySnapshot> _levelsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final userModel = authProvider.userModel;
    if (userModel == null || userModel.uid.isEmpty) {
      throw Exception('User not authenticated');
    }

    try {
      _userDataFuture = FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.uid)
          .get()
          .then((doc) {
        final data = doc.data() ?? {};
        debugPrint(data.toString()); // Печатаем данные, а не Future
        return data;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }

    _levelsFuture = FirebaseFirestore.instance
        .collection('game_levels')
        .orderBy('level')
        .get()
        .then((querySnapshot) {
      debugPrint(querySnapshot.docs.toString()); // Печатаем результаты запроса
      return querySnapshot;
    });
  }

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
            BookTrackIcon.onBack,
            color: Colors.white,
          ),
          onPressed: widget.onBack,
        ),
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder(
        future: Future.wait([_userDataFuture, _levelsFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint(snapshot.toString());
            return Center(child: Text('Ошибка загрузки данных'));
          }

          final userData = snapshot.data![0] as Map<String, dynamic>;
          final levelsSnapshot = snapshot.data![1] as QuerySnapshot;

          final stats = userData['stats'] ?? {};
          final currentLevel = stats['current_level'] ?? 1;
          final xp = stats['xp'] ?? 0;
          final pages = stats['pages'] ?? 0;

          final levels = levelsSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          // Находим текущий и следующий уровни
          final currentLevelData = levels.firstWhere(
            (level) => level['level'] == currentLevel,
            orElse: () => {'xp_required': 0, 'pages_required': 0},
          );

          final nextLevelData = levels.firstWhere(
            (level) => level['level'] == currentLevel + 1,
            orElse: () =>
                {'xp_required': currentLevelData['xp_required'] + 1000},
          );

          final progress = _calculateProgress(
            currentXP: xp,
            currentLevelXP: currentLevelData['xp_required'],
            nextLevelXP: nextLevelData['xp_required'],
          );

          return Container(
            padding: EdgeInsets.only(top: 20 * scale),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                topRight: Radius.circular(AppDimensions.baseCircual * scale),
              ),
            ),
            child: Column(
              children: [
                LevelProgressWidget(
                  currentLevel: currentLevel,
                  nextLevel: currentLevel + 1,
                  progress: progress,
                ),
                _buildStats(xp: xp.toString(), pages: pages.toString()),
                Expanded(child: _buildRewardsList(levels, currentLevel)),
              ],
            ),
          );
        },
      ),
    );
  }

  double _calculateProgress({
    required int currentXP,
    required int currentLevelXP,
    required int nextLevelXP,
  }) {
    final xpNeeded = nextLevelXP - currentLevelXP;
    final xpEarned = currentXP - currentLevelXP;
    return (xpEarned / xpNeeded).clamp(0.0, 1.0);
  }

  Widget _buildStats({required String xp, required String pages}) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(BookTrackIcon.medailProfile, xp, "XP"),
          _buildStatItem(BookTrackIcon.bookSelectet, pages, "стр"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.blueColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary),
          SizedBox(width: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRewardsList(
      List<Map<String, dynamic>> levels, int currentLevel) {
    return ListView.builder(
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        final levelNumber = level['level'];
        final points = level['reward_points'];
        final isUnlocked = levelNumber <= currentLevel;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Круг с номером уровня
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isUnlocked
                          ? [Colors.orange.shade300, Colors.orange.shade700]
                          : [Colors.grey.shade300, Colors.grey.shade700],
                    ),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: Offset(0, 0),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      levelNumber.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                  ),
                ),

                // Бонусные очки
                Row(
                  children: [
                    Text(
                      points.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isUnlocked ? AppColors.textPrimary : Colors.grey,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      BookTrackIcon.bonusProfilesvg,
                      color: isUnlocked ? AppColors.orange : Colors.grey,
                      size: 21,
                    ),
                  ],
                ),

                // Статус
                Text(
                  _getStatusText(levelNumber, currentLevel),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isUnlocked ? AppColors.textPrimary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(int levelNumber, int currentLevel) {
    if (levelNumber < currentLevel) return "Получено";
    if (levelNumber == currentLevel) return "Текущий";
    return "Закрыто";
  }
}

class LevelProgressWidget extends StatelessWidget {
  final int currentLevel;
  final int nextLevel;
  final double progress;

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
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth - 60;
            double progressWidth = maxWidth * progress;

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Фоновая линия
                Container(
                  height: 10,
                  width: maxWidth,
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: AppColors.blueColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Прогресс
                Container(
                  height: 10,
                  width: progressWidth,
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Текущий уровень
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 30),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.orange.shade300,
                          Colors.orange.shade700
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "$currentLevel",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Следующий уровень
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 30),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.blueColor,
                      child: Text(
                        "$nextLevel",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
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
