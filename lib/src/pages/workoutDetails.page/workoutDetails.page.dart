import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';

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
              // sets
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Sets"),
                          TextButton(
                            onPressed: () {
                              handleAddNewSet();
                            },
                            child: Icon(Icons.add),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Text("Kg")),
                          Expanded(child: Text("Pr")),
                          Expanded(child: Text("Latest")),
                          Expanded(child: Text("View")),
                        ],
                      ),
                      Column(
                        children: [
                          ...widget.workout.sets!.map(
                            (set) => Padding(
                              padding: const EdgeInsets.only(
                                top: 5.0,
                                bottom: 5.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(set.value.toString())),
                                  Expanded(child: Text(set.pr.toString())),
                                  Expanded(
                                    child: Text(
                                      (set.history.lastOrNull ?? 0).toString(),
                                    ),
                                  ),
                                  Expanded(child: Icon(Icons.bar_chart)),
                                ],
                              ),
                            ),
                          ),
                          if (widget.workout.sets.isEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              height: 100,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Icon(FontAwesomeIcons.faceSmileWink),
                                    SizedBox(width: 20),
                                    Text(
                                      "Lets start by adding some sets shall we ?",
                                    ),
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
                        minLines: 10,
                        maxLines: 10,
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
            ],
          ),
        ),
      ),
    );
  }

  void handleAddNewSet() {
    var set = Set(value: 10, history: [], pr: 0);
    widget.workout.sets.add(set);
    routineService.updateWorkout(widget.workout);
    setState(() {});
  }
}
