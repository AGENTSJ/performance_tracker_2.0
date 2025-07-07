import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/pages/routine.details.page/routine.details.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});
  @override
  State<StatefulWidget> createState() => RoutinesPageState();
}

class RoutinesPageState extends State<RoutinesPage> {
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
      body: ReorderableListView(
        onReorder: (int oldIndex, int newIndex) {
          // Adjust for removing the item before inserting
          if (newIndex > oldIndex) newIndex -= 1;

          final item = routines.removeAt(oldIndex);
          routines.insert(newIndex, item);

          setState(() {}); // Rebuild with new order
        },
        children: [
          for (int index = 0; index < routines.length; index++)
            GestureDetector(
              key: ValueKey(routines[index]),
              onTap: () {
                handleShowRoutine(routines[index]);
              },
              child: ListTile(
                title: Text(routines[index].name),
                // leading: Icon(Icons.drag_handle),
              ),
            ),
        ],
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

  handleShowRoutine(Routine routine) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RoutineDetails(routine: routine, isCreateMode: false),
      ),
    );
    routines = routineService.getAllRoutines();
    refreshState();
  }
}
