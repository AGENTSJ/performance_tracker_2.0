import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/journey.model.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/services/day.service.dart';
import 'package:performance_tracker/services/user.service.data.dart';

class JourneyGraph extends StatefulWidget {
  final Journey journey;
  const JourneyGraph({super.key ,required this.journey});

  @override
  _JourneyGraphState createState() => _JourneyGraphState();
}

class _JourneyGraphState extends State<JourneyGraph> {
  final List<FlSpot> dataPoints = [
  ];
  var dayService = locator<DayService>();
  var userService = locator<UserService>();
  var commonService = locator<CommonService>();
  User? user;
  @override
  void initState() {
    super.initState();
    setUpUi();
  }
  setUpUi()async
  {
    var count = DateTime.now().difference(widget.journey.startDate).inDays;
    user = await userService.getUserData();
    widget.journey.logs.length = 10;
    for (var i = 0; i < widget.journey.logs.length; i++) {
      var day  = await dayService.getDayDataByDate(widget.journey.startDate.subtract(Duration(days: 10)).add(Duration(days: i)));
      var userAtDay = user!;

      // var caloriePercent = commonService.getPercentage(calories,ca);
      dataPoints.add(FlSpot(i.toDouble(), day!.activity!.steps.toDouble()));
    }
  }
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            // getTooltipItems: (touchedSpots) {
            //   return touchedSpots.map((touchedSpot) {
            //     final x = touchedSpot.x.toInt();
            //     final y = touchedSpot.y;
            //     var date = commonService.getDateString(
            //       this.widget.set.history[x].entryDate,
            //     );
            //     return LineTooltipItem(
            //       '$date\nReps: $y',
            //       textAlign: TextAlign.start,
            //       const TextStyle(color: Colors.white),
            //     );
            //   }).toList();
            // },
          
          ),
        ),
        // maxY: widget.set.pr + 2,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
          rightTitles: AxisTitles(),
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
