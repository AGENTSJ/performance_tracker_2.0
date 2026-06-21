import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Workout/widgets/fatigueCard.component.dart';

class FatiguePage extends StatelessWidget {
  const FatiguePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: BACKGROUND,
        title: const Text('Fatigue'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(14.0.w),
          child: const FatigueCard(),
        ),
      ),
    );
  }
}
