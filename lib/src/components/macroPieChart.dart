import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/services/common.service.dart';
import 'package:performance_tracker/constants.ui.dart';

class MacroPieChart extends StatefulWidget {
  final double totalCalories;
  final double protein;
  final double carbs;
  final double fats;
  
  MacroPieChart({super.key, required this.totalCalories, required this.protein,required this.carbs,required this.fats});
  @override
  MacroPieChartState createState() => MacroPieChartState();
}

class MacroPieChartState extends State<MacroPieChart> with SingleTickerProviderStateMixin {
  double radius = 50;
  final commonService = locator<CommonService>();
  late double proteinPercent = 0;
  late double carbsPercent = 0;
  late double fatPercent = 0;
  final minBadgeWidgetVal = 10.0;
  
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    proteinPercent = commonService.getPercentage(widget.totalCalories, widget.protein*4);
    carbsPercent = commonService.getPercentage(widget.totalCalories, widget.carbs*4);
    fatPercent = commonService.getPercentage(widget.totalCalories, widget.fats*9);

    _controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _animation = Tween<double>(begin: 0, end: carbsPercent).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ))
      ..addListener(() => setState(() {}));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          // protein
            PieChartSectionData(
            color: PROTEIN_COLOR,
            value: proteinPercent,
            title: '',
            radius: radius,
            titleStyle: TextStyle(fontSize: 16, color: CONT_BACKGROUND),
            badgeWidget: proteinPercent > minBadgeWidgetVal ? Icon(FontAwesomeIcons.drumstickBite, size: 12,) : null,
            badgePositionPercentageOffset: 0.6,
            ),
            // Carbs
            PieChartSectionData(
            color: CARBS_COLOR,
            value: _animation.value,
            title: '',
            radius: radius,
            titleStyle: TextStyle(fontSize: 16, color: CONT_BACKGROUND),
            badgeWidget: carbsPercent > minBadgeWidgetVal ? Icon(FontAwesomeIcons.breadSlice, size: 12,) : null,
            badgePositionPercentageOffset: 0.6,
            ),
            // Fats
            PieChartSectionData(
            color: FAT_COLOR,
            value: fatPercent,
            title: '',
            radius: radius,
            titleStyle: TextStyle(fontSize: 16, color: CONT_BACKGROUND),
            badgeWidget: fatPercent > minBadgeWidgetVal ? Icon(FontAwesomeIcons.cheese, size: 12,) : null,
            badgePositionPercentageOffset: 0.6,
            ),
        ],
        sectionsSpace: 0.5,
        centerSpaceRadius: 0, // for donut effect, increase this
      ),
    );
  }

   @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
