import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/components/selectWorkout.dart';

class RoutineComponent extends StatefulWidget {
  final Routine routine;
  const RoutineComponent({super.key, required this.routine});
  @override
  State<StatefulWidget> createState() => RoutineComponentState();
}

class RoutineComponentState extends State<RoutineComponent> {
  List<Workout> workouts = [];
  final _routineService = locator<RoutineService>();
  setAllWorkouts() async {
    workouts = await _routineService.getRoutinesWorkouts(widget.routine);
    refreshState();
  }

  @override
  void initState() {
    setAllWorkouts();
    super.initState();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  showAddWorkoutModal() async {
    return showModalBottomSheet(
      context: context,
      builder: (context) => SelectWorkout(selectedWorkouts: workouts),
    );
  }

  handleAddWorkout() async {
    await showAddWorkoutModal();
    widget.routine.workoutsIds = [];
    for (var work in workouts) {
      widget.routine.workoutsIds.add(work.key);
    }
    await _routineService.updateRoutine(widget.routine);
    refreshState();
  }

  handleRemoveWorkout(Workout work) async {
    widget.routine.workoutsIds.remove(work.key);
    workouts.remove(work);
    await _routineService.updateRoutine(widget.routine);
    refreshState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.routine.name,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    handleAddWorkout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SURFACE,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(4),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size(30, 30),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [Icon(Icons.add, size: 20)],
                  ),
                ),
                SizedBox(width: 5),
                TextButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(138, 255, 166, 158),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(4),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size(37, 36),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.trash,
                        color: Colors.redAccent.shade200,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (workouts.isNotEmpty) ...[
              SizedBox(height: 10),
              Column(
                children: [
                  ...workouts.map(
                    (work) => Material(
                      color: SURFACE,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.circle, size: 12, color: PRIMARY),
                                  SizedBox(width: 10),
                                  Text(work.name),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  handleRemoveWorkout(work);
                                },
                                style: ElevatedButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  minimumSize: Size(20, 20),
                                ),
                                child: Icon(Icons.close, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
