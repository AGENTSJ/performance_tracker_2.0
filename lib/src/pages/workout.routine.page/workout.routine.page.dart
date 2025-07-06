import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/pages/workout.routine.page/widgets/routine.component.dart';

class WorkoutRoutinePage extends StatefulWidget {
  const WorkoutRoutinePage({super.key});
  @override
  State<StatefulWidget> createState() => WorkoutRoutinePageState();
}

class WorkoutRoutinePageState extends State<WorkoutRoutinePage> {
  var routineService = locator<RoutineService>();
  List<Routine> routines = [];
  @override
  void initState() {
    routines = routineService.getAllRoutines();
    super.initState();
  }

  handleAddRoutine() async {
    String? name = await showRoutineNamePopUp();
    if (name == null || name.isEmpty) {
      return;
    }
    var key = await routineService.addRoutine(
      Routine(name: name, workoutsIds: []),
    );
    var routine = await routineService.getRoutineById(key);
    if (routine != null) {
      routines.add(routine);
      refreshState();
    }
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  showRoutineNamePopUp() {
    return showDialog(
      context: context,
      builder: (context) {
        var nameController = TextEditingController();
        return AlertDialog(
          backgroundColor: SURFACE2,
          title: Text("Routine name", style: TextStyle(fontSize: 20)),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hint: Text("Routine name"),
              border: OutlineInputBorder(
                gapPadding: 0,
                borderSide: BorderSide(color: PRIMARY),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(nameController.text);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Routines"), backgroundColor: BACKGROUND),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ...routines.map((routine) => RoutineComponent(routine: routine)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: PRIMARY,
        onPressed: () {
          handleAddRoutine();
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
