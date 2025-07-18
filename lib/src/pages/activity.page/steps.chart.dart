import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/services/common.service.dart';

class StepsChart extends StatefulWidget {
  final double totalCount;
  final double count;

  const StepsChart({super.key, required this.totalCount, required this.count});

  @override
  _StepsChartState createState() => _StepsChartState();
}

class _StepsChartState extends State<StepsChart> {
  var commonService = locator<CommonService>();
  var percentCompleted = 0.0;
  @override
  void initState() {
    percentCompleted = commonService.getPercentage(
      widget.totalCount,
      widget.count,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PieChart(
          PieChartData(sections: _getSections(), centerSpaceRadius: 80.r,startDegreeOffset: -90),
        ),
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${widget.count.round()}",
                  style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w500,color: PRIMARY),
                ),
                SizedBox(height: 20.h,),
                RotatedBox(quarterTurns: 3,child: Icon(FontAwesomeIcons.shoePrints,size: 17.sp,color: PRIMARY,))
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getSections() {
    return [
      PieChartSectionData(
        color: PRIMARY,
        value: percentCompleted,
        title: '',
        radius: 20.r,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: BORDER_PRIMARY,
        value: (100 - percentCompleted).clamp(0, 100),
        title: '',
        radius: 20.r,
        titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }
}
