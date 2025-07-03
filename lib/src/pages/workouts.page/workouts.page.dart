import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/components/workout.component.dart';
import 'package:performance_tracker/src/pages/workoutDetails.page/workoutDetails.page.dart';

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({Key? key}) : super(key: key);

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  var routineService = locator<RoutineService>();
  List<Workout> workouts = [];

  @override
  void initState()
  {
    workouts = routineService.getAllWorkouts();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workouts'),backgroundColor: BACKGROUND,),
      body: Padding(
        padding: EdgeInsets.all(14), 
        child: Column(
          children: [
            ...workouts.map((work)=>Padding(
              padding: const EdgeInsets.all(8.0),
              child: WorkoutComponent(workout: work,),
            ))
          ],
        )),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkoutDetailsPage(workout: Workout(name: "New One", sets: []),isCreateMode: true,)));
      },child: Icon(Icons.add),),
    );
  }
}
