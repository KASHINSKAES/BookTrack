import 'package:booktrack/icons.dart';
import 'package:booktrack/widgets/constants.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatelessWidget {
  final VoidCallback onBack;
  const StatisticsPage({Key? key,required this.onBack}) : super(key: key);
  
 

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.of(context).size.width / AppDimensions.baseWidth;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(scale),
      body: _buildBody(scale),
    );
  }

  AppBar _buildAppBar(double scale) {
    var onBack;
    return AppBar(
      title: Text(
        "Статистика",
        style: TextStyle(
          fontSize: 32 * scale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: Icon(
          size: 35 * scale,
          MyFlutterApp.back,
          color: Colors.white,
        ),
        onPressed: onBack,
      ),
    );
  }

  Widget _buildBody(double scale) {
    return 
    
  }
}
  

  /// Данные для столбчатого графика (количество страниц по дням недели)
  List<BarChartGroupData> _generateBarChartData() {
    final data = [30, 45, 60, 20, 50, 75, 90]; // Пример данных
    return List.generate(
      7,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data[index].toDouble(),
            color: Colors.blue,
            width: 16,
          ),
        ],
      ),
    );
  }

  /// Подписи оси X для столбчатого графика
  FlTitlesData _barTitles() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            const days = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"];
            return Text(days[value.toInt()],
                style: const TextStyle(fontSize: 12));
          },
        ),
      ),
    );
  }

  /// Данные для круговой диаграммы (цели vs выполненное)
  List<PieChartSectionData> _generatePieChartData() {
    return [
      PieChartSectionData(
        value: 70,
        title: "Выполнено",
        color: Colors.green,
        radius: 50,
      ),
      PieChartSectionData(
        value: 30,
        title: "Осталось",
        color: Colors.red,
        radius: 50,
      ),
    ];
  }

  /// Данные для линейного графика (время чтения)
  LineChartBarData _generateLineChartData() {
    return LineChartBarData(
      isCurved: true,
      color: Colors.blue,
      barWidth: 3,
      spots: [
        const FlSpot(0, 15),
        const FlSpot(1, 25),
        const FlSpot(2, 35),
        const FlSpot(3, 20),
        const FlSpot(4, 40),
        const FlSpot(5, 30),
        const FlSpot(6, 50),
      ],
    );
  }

  /// Подписи оси X для линейного графика
  FlTitlesData _lineChartTitles() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, _) {
            const days = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"];
            return Text(days[value.toInt()],
                style: const TextStyle(fontSize: 12));
          },
        ),
      ),
    );
  }
}
