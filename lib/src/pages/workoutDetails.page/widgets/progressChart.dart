import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/common.service.dart';

class ProgressChart extends StatefulWidget {
  final WorkSet set;
  const ProgressChart({super.key, required this.set});
  @override
  State<StatefulWidget> createState() => ProgressChartState();
}

class ProgressChartState extends State<ProgressChart> {
  var commonService = locator<CommonService>();
  final List<FlSpot> dataPoints = [
  ];
  @override
  void initState() {
    super.initState();
    var i = 0;
    for (var entry in widget.set.history) {
      dataPoints.add(FlSpot(i.toDouble(), entry.value.toDouble()));
      i++;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      
      LineChartData(
        // minX: 0,
        // maxX: 6,
        // minY: 0,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true, 
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final x = touchedSpot.x.toInt(); 
                final y = touchedSpot.y;
                var date = commonService.getDateString(this.widget.set.history[x].entryDate);
                return LineTooltipItem(
                  '$date\nReps: $y',
                  textAlign: TextAlign.start,
                  const TextStyle(color: Colors.white,),
                );
              }).toList();
            },
          ),
        ),
        maxY: widget.set.pr + 2,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
              interval: 1,
              getTitlesWidget: (value, meta) {
                var text = "";
                return Text(text);
              },
            ),
          ),
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints,
            isCurved: false,
            barWidth: 1,
            color: PRIMARY,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
