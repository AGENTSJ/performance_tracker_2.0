import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/components/workout.component.dart';
import 'package:performance_tracker/src/features/Workout/pages/workoutDetails.page.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});
  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  var routineService = locator<WorkoutService>();
  List<Workout> workouts = [];
  @override
  void initState() {
    workouts = routineService.getAllWorkouts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        scrolledUnderElevation: 0,
      ),
      body: workouts.isEmpty
          ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: empty,
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "No workouts found",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
          : SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(14.0.w),
                child: Container(
                  decoration: BoxDecoration(color: SURFACE2,borderRadius: BorderRadius.circular(8.r)),
                  child: Column(
                    children: [
                      ...workouts.map(
                        (work) => Container(
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: BORDER_PRIMARY)),
                            borderRadius: BorderRadius.circular(8.r)
                          ),
                          child: WorkoutComponent(
                            workout: work,
                            onUpdated: (val) {
                              if (val) {
                                getAndSetWorkouts();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY,
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: () {
          handleAddWorkout();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  handleAddWorkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailsPage(
          workout: Workout(name: "New One", sets: [], enabled: true,desc: '',volumes: []),
          isCreateMode: true,
        ),
      ),
    );
    getAndSetWorkouts();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  getAndSetWorkouts() {
    workouts = routineService.getAllWorkouts();
    refreshState();
  }
}
