import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';
import 'package:performance_tracker/src/features/Workout/services/routine.service.dart';
import 'package:performance_tracker/src/features/Workout/widgets/selectWorkout.dart';

/// Lists custom routines; tapping one adds all of its workouts to
/// [selectedWorkouts] and closes the sheet.
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
    super.initState();
    routines = routineService.getAllCustomRoutines();
  }

  @override
  Widget build(BuildContext context) {
    if (routines.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(width: 90.w, height: 90.h, child: empty),
            SizedBox(height: 10.h),
            Text(
              "No routines yet",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                color: TEXT_PRIMARY,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Create one from the Routines page",
              style: TextStyle(fontSize: 12.sp, color: TEXT_SECONDARY),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      itemCount: routines.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, i) {
        final routine = routines[i];
        final count = routine.workoutsIds.length;
        return PickerTile(
          icon: FontAwesomeIcons.layerGroup,
          title: routine.name,
          subtitle: "$count workout${count == 1 ? '' : 's'}",
          trailingIcon: Icons.playlist_add,
          onTap: () => handleSaveRoutine(routine),
        );
      },
    );
  }

  handleSaveRoutine(Routine selectedRoutine) async {
    var workouts = await routineService.getRoutinesWorkouts(selectedRoutine);
    widget.selectedWorkouts.addAll([...workouts]);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
