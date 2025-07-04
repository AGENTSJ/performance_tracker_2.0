import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/widgets/setDetails.component.dart';

class WorkoutDetailsPage extends StatefulWidget {
  final Workout workout;
  final bool isCreateMode;
  const WorkoutDetailsPage({
    super.key,
    required this.workout,
    required this.isCreateMode,
  });
  @override
  State<WorkoutDetailsPage> createState() => _WorkoutDetailsPageState();
}

class _WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  var routineService = locator<RoutineService>();
  Workout? workout;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (widget.isCreateMode) {
        workout = await routineService.addWorkout(widget.workout);
        setState(() {
          
        });
      } else {
        workout = widget.workout;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        title: const Text('Workout Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // header
              Container(
                decoration: BoxDecoration(
                  color: SURFACE2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.workout.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // sets
              SetDetailsComponent(workout: widget.workout,onSetAdded: (weight){
                handleAddNewSet(weight);
              },),
              SizedBox(height: 20),
              // Notes
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(children: [Text("Notes")]),
                      SizedBox(height: 10),
                      TextField(
                        minLines: 7,
                        maxLines: null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: SURFACE,
                          hintText: "Add some notes about this workout",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Progress
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 200,
                width: double.infinity,
                child: Center(child: Text("Progress")),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void handleAddNewSet(double weight) {
    var set = Set(value: weight, history: [], pr: 0,enabled: true);
    widget.workout.sets.add(set);
    routineService.updateWorkout(widget.workout);
    setState(() {});
  }
}
