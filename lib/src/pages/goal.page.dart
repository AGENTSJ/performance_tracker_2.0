import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/constants.ui.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({Key? key}) : super(key: key);

  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BACKGROUND,
        title: const Text('Goal Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(14.0.r),
        child: Column(
          children: [
            
          ],
        ),
      ),
    );
  }
}