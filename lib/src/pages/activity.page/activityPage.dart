import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/user.model.dart';
import 'package:performance_tracker/services/health.service.dart';
import 'package:performance_tracker/services/userGoals.service.dart';
import 'package:performance_tracker/src/pages/activity.page/steps.chart.dart';
import 'package:performance_tracker/src/pages/loading.page/loading.page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int steps = 0;
  Duration? moveMin;
  var moveKm = 0.0;
  var healthService = locator<HealthService>();
  var userGoalsService = locator<UserGoalsService>();
  bool isLoading = true;
  UserGoals? userGoals;
  var smallLabelHeadingDecor = TextStyle(color: TEXT_SECONDARY,fontWeight: FontWeight.w500);
  var smallLabelDecor = TextStyle(color: PRIMARY,fontWeight: FontWeight.w600,fontSize: 17.sp);
  void setUpUi() async {
    userGoals = await userGoalsService.getUserGoals();
    steps = await healthService.getTodaysSteps();
    moveMin = await healthService.getMoveMin();
    moveKm = await healthService.getMoveKm();
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setUpUi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        title: const Text('Activity Page'),
        backgroundColor: BACKGROUND,
      ),
      body: isLoading
          ? LoadingPage()
          : SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(14.0.r),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      height: 180.h,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0.r),
                        child: StepsChart(
                          totalCount: userGoals!.stepGoal.toDouble(),
                          count: steps.toDouble(),
                        ),
                      ),
                    ),
                    SizedBox(height:  20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("${moveMin!.inMinutes}",style: smallLabelDecor,),
                              SizedBox(height: 5.h,),
                              Text("Move Min",style: smallLabelHeadingDecor,),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("${userGoals!.stepGoal}",style: smallLabelDecor,),
                              SizedBox(height: 5.h,),
                              Text("Current Goal",style: smallLabelHeadingDecor,),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(moveKm.toStringAsFixed(2),style: smallLabelDecor,),
                              SizedBox(height: 5.h,),
                              Text("Total Km",style: smallLabelHeadingDecor,),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
