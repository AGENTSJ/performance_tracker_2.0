import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        child: Column(
          children: [
            SizedBox(height: 15.h),
            Container(
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: BORDER_PRIMARY))),
              child: Padding(
                padding: EdgeInsets.symmetric( vertical:  17.h,horizontal: 14.w),
                child: Row(
                  children: [
                    Text(
                      "Select a routine",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Material(
              color: SURFACE,
              shape: Border.all(color: BORDER_SECONDARY),
              child: Column(
                children: [
                  ...routines.map(
                    (routine) => Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          handleSaveRoutine(routine);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: BORDER_SECONDARY),
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal:  14.0.w,vertical: 14.h),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.layerGroup,
                                  size: 18.sp,
                                  color: TEXT_SECONDARY,
                                ),
                                SizedBox(width: 20.w),
                                Text(routine.name,style: TextStyle(fontSize: 14.sp,fontWeight: FontWeight.w500),),
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
    );
  }

  handleSaveRoutine(Routine selectedRoutine) async {
    var workouts = await routineService.getRoutinesWorkouts(selectedRoutine);
    widget.selectedWorkouts.addAll([...workouts]);
    Navigator.of(context).pop();
  }
}
