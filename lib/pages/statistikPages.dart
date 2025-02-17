import 'package:booktrack/icons.dart';
import 'package:booktrack/pages/AppState.dart';
import 'package:booktrack/pages/ReadingStatsProvider.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_pie_chart/easy_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

Future<Map<String, List<int>>> fetchReadingStats(String type) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc('user_1')
      .collection('reading_goals')
      .orderBy('date')
      .get();

  final Map<String, List<int>> weeklyData = {};

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final date = (data['date'] as Timestamp).toDate();
    final weekKey =
        _getWeekKey(date); // Получаем ключ недели (например, "11.11-17.11")

    // Инициализируем список для недели, если его ещё нет
    if (!weeklyData.containsKey(weekKey)) {
      weeklyData[weekKey] = List.filled(7, 0);
    }

    final weekday = (date.weekday % 7); // Приводим к началу недели (ВС–СБ)
    if (type == "pages") {
      weeklyData[weekKey]![weekday] =
          (weeklyData[weekKey]![weekday] + (data['readPages'] ?? 0)).toInt();
    } else if (type == "minutes") {
      weeklyData[weekKey]![weekday] =
          (weeklyData[weekKey]![weekday] + (data['readMinutes'] ?? 0)).toInt();
    }
  }

  return weeklyData;
}

Future<Map<String, int>> fetchDailyReadingStats(String type) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc('user_1')
      .collection('reading_goals')
      .orderBy('date')
      .get();

  final Map<String, int> dailyData = {};

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final date = (data['date'] as Timestamp).toDate();
    final dayKey =
        _formatDate(date); // Форматируем дату в строку (например, "2023-11-15")

    if (type == "pages") {
      dailyData[dayKey] =
          ((dailyData[dayKey] ?? 0) + (data['readPages'] ?? 0)).toInt();
    } else if (type == "minutes") {
      dailyData[dayKey] =
          ((dailyData[dayKey] ?? 0) + (data['readMinutes'] ?? 0)).toInt();
    }
  }

  return dailyData;
}

// Вспомогательная функция для форматирования даты
String _formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}

// Вспомогательная функция для получения ключа недели
String _getWeekKey(DateTime date) {
  final startOfWeek = date.subtract(Duration(days: date.weekday % 7));
  final endOfWeek = startOfWeek.add(Duration(days: 6));
  return "${startOfWeek.day}.${startOfWeek.month}-${endOfWeek.day}.${endOfWeek.month}";
}

class StatisticsPage extends StatefulWidget {
  final VoidCallback onBack;
  StatisticsPage({super.key, required this.onBack});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int selectedWeekPages = 0;
  int selectedWeekMinutes = 0;
  int selectedWeek = 0;
  int selectedDay = 0;
  Map<String, List<int>> weeklyData = {};
  Map<String, int> dailyDataPages = {};
  Map<String, int> dailyDataMinutes = {};
  Map<String, int> dailyGoalPages = {}; // Целевые значения для страниц
  Map<String, int> dailyGoalMinutes = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataMinutes();
    _loadDataPages();
    _loadData();
  }

  Future<void> _loadDataMinutes() async {
    final data = await fetchReadingStats("minutes");
    setState(() {
      weeklyData = data;
      isLoading = false;
    });
  }

  Future<void> _loadDataPages() async {
    final data = await fetchReadingStats("pages");
    setState(() {
      weeklyData = data;
      isLoading = false;
    });
  }

  Future<void> _loadData() async {
    await _loadDataPagesDate();
    await _loadDataMinutesDate();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadDataPagesDate() async {
    final data = await fetchDailyReadingStats("pages");
    setState(() {
      dailyDataPages = data;
    });
  }

  Future<void> _loadDataMinutesDate() async {
    final data = await fetchDailyReadingStats("minutes");
    setState(() {
      dailyDataMinutes = data;
    });
  }

  // final List<String> weeks = ["11.11-17.11", "18.11-24.11", "25.11-01.12"];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReadingStatsProvider>(context);

    if (provider.dailyDataPages.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final weeks = weeklyData.keys.toList();
    final currentWeekDataPages =
        weeklyData[weeks[selectedWeekPages]] ?? List.filled(7, 0);
    final currentWeekDataMinutes =
        weeklyData[weeks[selectedWeekMinutes]] ?? List.filled(7, 0);

    if (provider.dailyDataPages.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final days = provider.dailyDataPages.keys.toList();
    final selectedDate = provider.selectedDate;
    final pages = provider.pages;
    final minutes = provider.minutes;
    final goalPages = provider.goalPages;
    final goalMinutes = provider.goalMinutes;

    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;

    Widget _buildDaySelector(ReadingStatsProvider provider) {
      final days = provider.dailyDataPages.keys.toList();
      if (days.isEmpty) {
        return Center(child: Text("Нет данных"));
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: provider.selectedDay > 0
                ? () => provider.setSelectedDay(provider.selectedDay - 1)
                : null,
          ),
          Text(days[provider.selectedDay],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: provider.selectedDay < days.length - 1
                ? () => provider.setSelectedDay(provider.selectedDay + 1)
                : null,
          ),
        ],
      );
    }

    Widget _buildWeekSelector() {
      final weeks = weeklyData.keys.toList();
      return StatefulBuilder(
        builder: (context, setState) {
          return Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: selectedWeek > 0
                    ? () => setState(() => selectedWeek--)
                    : null,
              ),
              Text(weeks[selectedWeek],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: selectedWeek < weeks.length - 1
                    ? () => setState(() => selectedWeek++)
                    : null,
              ),
            ],
          );
        },
      );
    }

    Widget buildChartCard2({required String title, required Widget child}) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    softWrap: true,
                  ),
                  _buildWeekSelector(),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(height: 200, child: child),
            ],
          ),
        ),
      );
    }

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Статистика',
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
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.baseCircual * scale),
                topRight: Radius.circular(AppDimensions.baseCircual * scale),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                buildChartCard2(
                  title: "Страницы",
                  child: _PagesBarChart(
                    readingPages: currentWeekDataPages,
                  ),
                ),
                const SizedBox(height: 20),
                buildChartCard2(
                  title: "Время чтения",
                  child: _ReadingTimeLineChart(
                    readingTime: currentWeekDataMinutes,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDaySelector(provider),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildChartCard(
                      title: "Время чтения",
                      child: TodayPieChart(
                        progress: minutes.toDouble(),
                        title: 'минут',
                        value: '$minutes',
                        icon: MyFlutterApp.clock,
                        progressWant: goalMinutes.toDouble(),
                      ),
                    ),
                    _buildChartCard(
                      title: "Количество страниц",
                      child: TodayPieChart(
                        progress: pages.toDouble(),
                        title: 'страниц',
                        value: '$pages',
                        icon: MyFlutterApp.book2,
                        progressWant: goalPages.toDouble(),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _BooksReadToday(
                        scale: scale,
                      ),
                    ))
              ],
            ),
          ),
        ));
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 120),
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                softWrap: true,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(height: 145, child: child),
          ],
        ),
      ),
    );
  }
}

class _PagesBarChart extends StatelessWidget {
  final List<int> readingPages;

  const _PagesBarChart({required this.readingPages});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ["ВС", "ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ"];
                  return Text(days[value.toInt()],
                      style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 40),
            )),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        barGroups: List.generate(
          readingPages.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: readingPages[index].toDouble(),
                  color: Colors.blue,
                  width: 16,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingTimeLineChart extends StatelessWidget {
  final List<int> readingTime;

  const _ReadingTimeLineChart({required this.readingTime});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const days = ["ВС", "ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ"];
                  return Text(days[value.toInt()],
                      style: const TextStyle(fontSize: 12));
                },
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false, reservedSize: 40),
            )),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
              spots: List.generate(
                  readingTime.length,
                  (index) =>
                      FlSpot(index.toDouble(), readingTime[index].toDouble())),
              isCurved: false,
              color: Color(0xffFFD3C5),
              barWidth: 3,
              dotData: FlDotData(show: true, checkToShowDot: (_, __) => true),
              belowBarData: (BarAreaData(show: false))),
        ],
      ),
    );
  }
}

class TodayPieChart extends StatelessWidget {
  final double progress;
  final double progressWant;
  final String title;
  final String value;
  final IconData icon;

  TodayPieChart({
    required this.progress,
    required this.progressWant,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
                width: 100,
                height: 100,
                child: EasyPieChart(
                  children: [
                    PieData(
                        value: progressWant - progress,
                        color: Color(0xffFFD3C5)),
                    PieData(value: progress, color: AppColors.orange),
                  ],
                  borderEdge: StrokeCap.round,
                  showValue: false,
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: Colors.blue.shade900),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text(value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 3),
            Text(title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }
}

class _BooksReadToday extends StatelessWidget {
  final double scale;
  _BooksReadToday({
    required this.scale,
  });
  final List<String> bookCovers = [
    "images/img1.svg",
    "images/img1.svg",
    "images/img1.svg",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text("Что вы читали сегодня",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: bookCovers.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.asset(
              bookCovers[index],
              width: 150 * scale,
              height: 200 * scale,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ]);
  }
}
