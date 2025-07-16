import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
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
    print('initRan ${dataPoints.length}');
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
              showTitles: true,
              interval: 2,
              reservedSize: 30.w,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                var text = "";
                return Text(text);
              },
            ),
          ),
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text("");
              },
            )
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints,
            isCurved: true,
            barWidth: 2,
            color: Colors.blue,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
