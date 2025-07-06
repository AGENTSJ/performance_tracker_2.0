import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/workout.service.dart';
import 'package:performance_tracker/src/components/workout.component.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/workoutDetails.page.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});
  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  var workoutService = locator<WorkoutService>();
  List<Workout> workouts = [];
  @override
  void initState() {
    workouts = workoutService.getAllWorkouts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: BACKGROUND,
      ),
      body: workouts.isEmpty
          ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: PRIMARY,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: SvgPicture.asset(
                          "assets/man-hold-dumbell.svg",
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Resting huh 🤨 ?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    ...workouts.map(
                      (work) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: WorkoutComponent(
                          workout: work,
                          onUpdated: (val) {
                            if (val) {
                              getAndSetWorkouts();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY,
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: () {
          handleAddWorkout();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  handleAddWorkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailsPage(
          workout: Workout(name: "New One", sets: [], enabled: true),
          isCreateMode: true,
        ),
      ),
    );
    getAndSetWorkouts();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  getAndSetWorkouts() {
    workouts = workoutService.getAllWorkouts();
    refreshState();
  }
}
