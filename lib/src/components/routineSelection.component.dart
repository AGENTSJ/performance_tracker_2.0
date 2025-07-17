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
        child: Padding(
          padding: EdgeInsets.all(14.0.r),
          child: Column(
            children: [
              SizedBox(height: 15.h),
              Row(children: [Text("Select a routine",style: TextStyle(color: TEXT_SECONDARY,fontSize: 16.sp,fontWeight: FontWeight.w500),)]),
              SizedBox(height: 20.h),
              Material(
                color: SURFACE,
                borderRadius: BorderRadius.circular(8.r),
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
                                bottom: BorderSide(
                                  color: BORDER_PRIMARY,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(8.r)
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(14.0.r),
                              child: Row(children: [Icon(FontAwesomeIcons.layerGroup,size: 18.sp,color: TEXT_SECONDARY,),SizedBox(width: 20.w,),Text(routine.name)]),
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
