import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/common.service.dart';

class MacroPieChart extends StatefulWidget {
  final double totalCalories;
  final double protein;
  final double carbs;
  final double fats;
  final Color proteinColor = Color(0xFF42A5F5);      // Blue
  final Color fatColor = Color(0xFFFFA726);         // Orange
  final Color carbohydrateColor = Color(0xFF66BB6A);// Green
  final Color fiberColor = Color(0xFFAB47BC); 
  MacroPieChart({super.key, required this.totalCalories, required this.protein,required this.carbs,required this.fats});
  @override
  MacroPieChartState createState() => MacroPieChartState();
}

class MacroPieChartState extends State<MacroPieChart> {
  double radius = 50;
  final commonService = locator<CommonService>();
  late double proteinPercent = 0;
  late double carbsPercent = 0;
  late double fatPercent = 0;
  final minBadgeWidgetVal = 1.0;
  @override
  void initState() {
    super.initState();
    proteinPercent = commonService.getPercentage(widget.totalCalories, widget.protein*4);
    carbsPercent = commonService.getPercentage(widget.totalCalories, widget.carbs*4);
    fatPercent = commonService.getPercentage(widget.totalCalories, widget.fats*9);
  }

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          // protein
            PieChartSectionData(
            color: widget.proteinColor,
            value: proteinPercent,
            title: '',
            radius: radius,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            badgeWidget: proteinPercent > minBadgeWidgetVal ? Icon(FontAwesomeIcons.drumstickBite, size: 12,) : null,
            badgePositionPercentageOffset: 0.6,
            ),
            // Carbs
            PieChartSectionData(
            color: widget.carbohydrateColor,
            value: carbsPercent,
            title: '',
            radius: radius,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            badgeWidget: carbsPercent > minBadgeWidgetVal ? Icon(FontAwesomeIcons.breadSlice, size: 12,) : null,
            badgePositionPercentageOffset: 0.6,
            ),
            // Fats
            PieChartSectionData(
            color: widget.fatColor,
            value: fatPercent,
            title: '',
            radius: radius,
            titleStyle: TextStyle(fontSize: 16, color: Colors.white),
            badgeWidget: fatPercent > minBadgeWidgetVal ? Icon(FontAwesomeIcons.cheese, size: 12,) : null,
            badgePositionPercentageOffset: 0.6,
            ),
        ],
        sectionsSpace: 0.5,
        centerSpaceRadius: 0, // for donut effect, increase this
      ),
    );
  }
}
