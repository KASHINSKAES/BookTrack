import 'package:booktrack/icons.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_pie_chart/easy_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StatisticsPage extends StatefulWidget {
  final VoidCallback onBack;
  StatisticsPage({super.key, required this.onBack});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int selectedWeek = 0;

  int selectedDay = 0;

  final List<String> weeks = ["11.11-17.11", "18.11-24.11", "25.11-01.12"];

  final List<String> days = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"];

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
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
                _buildChartCard2(
                  title: "Страницы",
                  child: _PagesBarChart(),
                ),
                const SizedBox(height: 20),
                _buildChartCard2(
                  title: "Время чтения",
                  child: _ReadingTimeLineChart(),
                ),
                const SizedBox(height: 20),
                _buildDaySelector(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildChartCard(
                      title: "Время чтения",
                      child: TodayPieChart(
                        progress: 35,
                        title: 'минут',
                        value: '35',
                        icon: MyFlutterApp.clock,
                        progressWant: 60,
                      ),
                    ),
                    _buildChartCard(
                      title: "Количество страниц",
                      child: TodayPieChart(
                        progress: 268,
                        title: 'страниц',
                        value: '268',
                        icon: MyFlutterApp.book2,
                        progressWant: 400,
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

  Widget _buildChartCard2({required String title, required Widget child}) {
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

  Widget _buildWeekSelector() {
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

  Widget _buildDaySelector() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed:
                  selectedDay > 0 ? () => setState(() => selectedDay--) : null,
            ),
            Text(days[selectedDay],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: selectedDay < days.length - 1
                  ? () => setState(() => selectedDay++)
                  : null,
            ),
          ],
        );
      },
    );
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
  final List<int> pagesPerDay = [120, 180, 250, 160, 170, 200, 70];

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
          pagesPerDay.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: pagesPerDay[index].toDouble(),
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
  final List<int> readingTime = [60, 120, 30, 45, 80, 20, 100];

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
