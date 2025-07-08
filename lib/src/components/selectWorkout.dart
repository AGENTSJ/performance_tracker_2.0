import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/workout.service.dart';

class SelectWorkout extends StatefulWidget {
  final List<Workout> selectedWorkouts;
  const SelectWorkout({super.key, required this.selectedWorkouts});

  @override
  SelectWorkoutState createState() => SelectWorkoutState();
}

class SelectWorkoutState extends State<SelectWorkout> {
  var workoutService = locator<WorkoutService>();
  var searchController = TextEditingController();
  List<Workout> workouts = [];

  @override
  void initState() {
    var allWorkouts = workoutService.getAllWorkouts();
    setWorkouts(allWorkouts);
    searchController.addListener(
      () => handleSearchWorkouts(searchController.text),
    );
    super.initState();
  }

  handleSearchWorkouts(String name) {
    var searchedRes = workoutService.searchWorkoutByName(name);
    setWorkouts(searchedRes);
    refreshState();
  }

  setWorkouts(List<Workout> newAvailable) {
    workouts = [];
    for (var work in newAvailable) {
      if (!_foundInSelectedList(work)) {
        workouts.add(work);
      }
    }
  }

  bool _foundInSelectedList(Workout work) {
    for (var selected in widget.selectedWorkouts) {
      if (selected.key == work.key) {
        return true;
      }
    }
    return false;
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  handleSelectWorkout(Workout work) {
    widget.selectedWorkouts.add(work);
    workouts.remove(work);
    refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.h,
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(top: 20.0.h, left: 15.w, right: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search workout',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (workouts.isEmpty) ...[
                          SizedBox(child: empty, width: 100.w, height: 100.h),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("No workout found...",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.sp),),
                            ),
                          )
                        ],
                        ...workouts.map(
                          (work) => Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                handleSelectWorkout(work);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: TEXT_SECONDARY,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.circle,
                                        size: 14.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(work.name),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
