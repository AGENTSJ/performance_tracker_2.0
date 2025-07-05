import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/pages/training.page/widgets/selectWorkout.dart';
import 'package:performance_tracker/src/components/workout.component.dart';
import 'package:performance_tracker/src/pages/workouts.page/workouts.page.dart';

class TrainingModulePage extends StatefulWidget {
  const TrainingModulePage({super.key});

  @override
  State<TrainingModulePage> createState() => _TrainingModulePageState();
}

class _TrainingModulePageState extends State<TrainingModulePage> {
  final routineService = locator<RoutineService>();
  final buttonDecor = ElevatedButton.styleFrom(
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(side: BorderSide.none),
  );
  final addFromButtonDecor = ElevatedButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6), 
    minimumSize: Size(0, 0), 
    textStyle: TextStyle(fontSize: 14), 
    elevation: 0,
    shadowColor: Colors.transparent,
  );
  Routine? routine;
  List<Workout> workouts = [];
  @override
  void initState() {
    routine = routineService.getTodaysWorkout();
    super.initState();
  }

  getAllWorkouts()async {
    for (var wId in routine!.workoutsIds) {
      var workout = await routineService.getWorkOutById(wId);
      if (workout != null) {
        workouts.add(workout);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        title: const Text('Training Page'),
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 40),
          child: Container(
            height: 40,
            width: double.infinity,
            color: SURFACE,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      
                    },
                    style: buttonDecor,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0,right: 8.0),
                      child: Text('Routines'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>WorkoutsPage()));
                    },
                    style: buttonDecor,
                    child: Padding(
                      padding: const EdgeInsets.only(left:8.0,right: 8.0),
                      child: Text('Workouts'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ...workouts.map(
                (work) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: WorkoutComponent(workout: work,onUpdated: (value){},),
                ),
                
              ),
              if(workouts.isEmpty ) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:  30.0),
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.faceGrinWink,color: Colors.grey,),
                        SizedBox(height: 10,),
                        Text("Add some workouts to get started",style: TextStyle(color: Colors.grey),)
                      ],
                    ),
                  ),
                ),
              ],
              Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            SizedBox(
                              width: 180,
                              child: ElevatedButton(
                              onPressed: () {},
                              style: addFromButtonDecor,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(FontAwesomeIcons.plus,color: Colors.grey,size: 15,),
                                  ),
                                  Text("Add From Routines"),
                                ],
                              ),
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 180,
                              child: ElevatedButton(
                              onPressed: () {handleAddWorkout();},
                              style: addFromButtonDecor,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(FontAwesomeIcons.plus,color: Colors.grey,size: 15,),
                                  ),
                                  Text("Add From Workout"),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  handleAddWorkout()
  {
   showBottomSheet(context: context, builder: (BuildContext context)=>SelectWorkout()); 
  }
}
