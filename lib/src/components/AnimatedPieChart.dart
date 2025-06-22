import 'package:flutter/material.dart';

class AnimatedPieChart extends StatefulWidget {
  const AnimatedPieChart({Key? key}) : super(key: key);

  @override
  _AnimatedPieChartState createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text('Animated Pie Chart'),
      ),
    );
  }
}