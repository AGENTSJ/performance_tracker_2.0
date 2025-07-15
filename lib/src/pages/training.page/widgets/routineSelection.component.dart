import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';

class RoutineSelection extends StatefulWidget {
  final List<Workout> selectedWorkouts;
  const RoutineSelection({super.key, required this.selectedWorkouts});

  @override
  State<RoutineSelection> createState() => _RoutineSelectionState();
}

class _RoutineSelectionState extends State<RoutineSelection> {
  var routineService = locator<RoutineService>();
  List<Routine> routines = [];
  @override
  void initState() {
    routines = this.routineService.getAllCustomRoutines();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(14.0.r),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Row(children: [Text("Select a routine")]),
              SizedBox(height: 10.h),
              Material(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8.r),topRight: Radius.circular(8.r)),
                child: Column(
                  children: [
                    ...routines.map(
                      (routine) => Padding(
                        padding: EdgeInsets.only(bottom: 4.0.r),
                        child: Material(
                          child: InkWell(
                            onTap: () {
                              handleSaveRoutine(routine);
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
                                padding: EdgeInsets.all(14.0.r),
                                child: Row(children: [Text(routine.name)]),
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
      ),
    );
  }

  handleSaveRoutine(Routine selectedRoutine) async {
    var workouts = await routineService.getRoutinesWorkouts(selectedRoutine);
    widget.selectedWorkouts.addAll([...workouts]);
    Navigator.of(context).pop();
  }
}
