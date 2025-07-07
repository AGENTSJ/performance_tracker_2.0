import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/components/workout.component.dart';
import 'package:performance_tracker/src/pages/workouts.page/workouts.page.dart';
import 'package:performance_tracker/src/components/selectWorkout.dart';
import 'package:performance_tracker/src/pages/routines.page/routines.page.dart';

class TrainingModulePage extends StatefulWidget {
  const TrainingModulePage({super.key});

  @override
  State<TrainingModulePage> createState() => TrainingModulePageState();
}

class TrainingModulePageState extends State<TrainingModulePage> {
  final workoutService = locator<WorkoutService>();
  final buttonDecor = ElevatedButton.styleFrom(
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(side: BorderSide.none),
  );
  final addFromButtonDecor = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    minimumSize: Size(0, 0),
    textStyle: TextStyle(fontSize: 14.sp),
    elevation: 0,
    shadowColor: Colors.transparent,
  );
  Routine? routine;
  List<Workout> workouts = [];
  @override
  void initState() {
    routine = workoutService.getTodaysWorkout();
    super.initState();
  }

  getAllWorkouts() async {
    for (var wId in routine!.workoutsIds) {
      var workout = await workoutService.getWorkOutById(wId);
      if (workout != null) {
        workouts.add(workout);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        title: const Text('Training Page'),
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 40.h),
          child: Container(
            height: 40.h,
            width: double.infinity,
            color: SURFACE,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RoutinesPage()),
                      );
                    },
                    style: buttonDecor,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0.w, right: 8.0.w),
                      child: Text('Routines'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WorkoutsPage()),
                      );
                    },
                    style: buttonDecor,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8.0.w, right: 8.0.w),
                      child: Text('Workouts'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(14.0.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...workouts.map(
                (work) => Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: WorkoutComponent(workout: work, onUpdated: (value) {}),
                ),
              ),
              if (workouts.isEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0.h),
                  child: Container(
                    width: double.infinity,
                    height: 100.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.faceGrinWink, color: Colors.grey),
                        SizedBox(height: 10.h),
                        Text(
                          "Add some workouts to get started",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              Container(
                width: double.infinity,
                height: 130.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(14.0.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 180.w,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: addFromButtonDecor,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0.w),
                                    child: Icon(
                                      FontAwesomeIcons.plus,
                                      color: Colors.grey,
                                      size: 15.w,
                                    ),
                                  ),
                                  Text("Add From Routines"),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 180.w,
                            child: ElevatedButton(
                              onPressed: () {
                                handleAddWorkout();
                              },
                              style: addFromButtonDecor,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0.w),
                                    child: Icon(
                                      FontAwesomeIcons.plus,
                                      color: Colors.grey,
                                      size: 15.w,
                                    ),
                                  ),
                                  Text("Add From Workout"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleAddWorkout() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SelectWorkout(selectedWorkouts: [],),
    );
  }
}
