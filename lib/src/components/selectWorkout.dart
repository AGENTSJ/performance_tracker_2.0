import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  setWorkouts(List<Workout> newAvailable)
  {
    for (var work in newAvailable) {
      if(!_foundInSelectedList(work))
      {
        workouts.add(work);
      }
    }
  }
  
  bool _foundInSelectedList(Workout work)
  {
    for (var selected in widget.selectedWorkouts) {
      if(selected.key==work.key)
      {
        return true;
      }
    }
    return false;
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }
  handleSelectWorkout(Workout work)
  {
    widget.selectedWorkouts.add(work);
    workouts.remove(work);
    refreshState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500.h,
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
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
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...workouts.map(
                    (work) => Padding(
                      padding: EdgeInsets.only(bottom: 8.0.h),
                      child: Material(
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          onTap: () {
                            handleSelectWorkout(work);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(12.0.w),
                            child: Text(work.name),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text("Selected"),
                  ...widget.selectedWorkouts.map(
                    (work) => Padding(
                      padding: EdgeInsets.only(bottom: 8.0.h),
                      child: Material(
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.all(12.0.w),
                            child: Text(work.name),
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
    );
  }
}
