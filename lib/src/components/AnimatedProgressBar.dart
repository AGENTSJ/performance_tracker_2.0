import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/constants.ui.dart';

class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color color; 
  final double? width;
  @override
  State<StatefulWidget> createState() => _AnimatedProgressBarState();
  AnimatedProgressBar({super.key,required this.value ,this.color =PRIMARY, this.width});
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    var normValue = widget.value;
    if(normValue > 1)
    {
      normValue = 1;
    }
    _controller = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _animation = Tween<double>(begin: 0, end: normValue).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ))
      ..addListener(() => setState(() {}));
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 1,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: 1,
          minY: 0,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: _animation.value,
                  width: widget.width ?? 5.w,
                  color: widget.color,
                  borderRadius: BorderRadius.circular(10.r),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 1,
                    color: BORDER_PRIMARY,
                  ),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barTouchData: BarTouchData(enabled: false)
        ),

      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
