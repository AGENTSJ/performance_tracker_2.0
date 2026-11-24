import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/core/services/common.service.dart';

class StepsChart extends StatefulWidget {
  final double totalCount;
  final double count;
  final double centerSpace;
  final double lineRadius;
  final bool showCenterPart;
  const StepsChart({
    super.key,
    required this.totalCount,
    required this.count,
    this.centerSpace = 80,
    this.lineRadius = 20,
    this.showCenterPart = true,
  });

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PieChart(
          PieChartData(
            sections: _getSections(),
            sectionsSpace: 0,
            centerSpaceRadius: widget.centerSpace.r,
            startDegreeOffset: -90,
          ),
        ),
        if(widget.showCenterPart)
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${widget.count.round()}",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: TEXT_SECONDARY,
                  ),
                ),
                SizedBox(height: 10.h),
                RotatedBox(
                  quarterTurns: 3,
                  child: Icon(
                    FontAwesomeIcons.shoePrints,
                    size: 12.sp,
                    color: PRIMARY,
                  ),
                ),
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
        radius: widget.lineRadius.r,
        titleStyle: TextStyle(color: TEXT_TERTIARY, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        color: BORDER_PRIMARY,
        value: (100 - percentCompleted).clamp(0, 100),
        title: '',
        radius: widget.lineRadius.r,
        titleStyle: TextStyle(color: TEXT_TERTIARY, fontWeight: FontWeight.bold),
      ),
    ];
  }
}
