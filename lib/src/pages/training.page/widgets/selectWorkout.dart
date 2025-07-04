import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';

class SelectWorkout extends StatefulWidget {
  const SelectWorkout({super.key});

  @override
  SelectWorkoutState createState() => SelectWorkoutState();
}

class SelectWorkoutState extends State<SelectWorkout> {
  var routineService = locator<RoutineService>();
  var searchController = TextEditingController();
  List<Workout> workouts = [];
  @override
  void initState() {
    workouts = routineService.getAllWorkouts();
    searchController.addListener(
      () => handleSearchWorkouts(searchController.text),
    );
    super.initState();
  }

  handleSearchWorkouts(String name) {
    
    workouts = routineService.searchWorkoutByName(name);
    refreshState();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search workout',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...workouts.map(
                    (work) => Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(work.name),
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
