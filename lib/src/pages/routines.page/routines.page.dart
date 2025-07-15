import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/routine.service.dart';
import 'package:performance_tracker/src/pages/routine.details.page/routine.details.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoutinesPage extends StatefulWidget {
  const RoutinesPage({super.key});
  @override
  State<StatefulWidget> createState() => RoutinesPageState();
}

class RoutinesPageState extends State<RoutinesPage> {
  var routineService = locator<RoutineService>();
  List<Routine> routines = [];
  List<Routine> customRoutines = [];
  @override
  void initState() {
    setRoutineUi();
    super.initState();
  }

  setRoutineUi() async {
    routines = routineService.getAllRoutines();
    customRoutines = routineService.getAllCustomRoutines();
  }

  handleAddRoutine() async {
    String? name = await showRoutineNamePopUp();
    if (name == null || name.isEmpty) {
      return;
    }
    var key = await routineService.addRoutine(
      Routine(
        name: name,
        workoutsIds: [],
        createdAt: DateTime.now(),
        isCustom: true,
        desc: ''
      ),
    );
    setRoutineUi();
    setState(() {});
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
      body: Padding(
        padding: EdgeInsets.all(14.r),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (customRoutines.isNotEmpty) ...[
                Row(children: [Text("Your workouts")]),
                SizedBox(height: 20.h),
              ],
              ...customRoutines.map(
                (routine) => Padding(
                  padding: EdgeInsets.only(bottom: 5.0.r),
                  child: Material(
                    color: SURFACE2,
                    borderRadius: BorderRadius.circular(8.r),
                    child: InkWell(
                      onTap: () {
                        handleShowRoutine(routine);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20.r,
                          horizontal: 15.r,
                        ),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.layerGroup),
                            SizedBox(width: 20.w),
                            Text(
                              "${routine.name} (${routine.workoutsIds.length})",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(children: [Text("Previous workouts")]),
              SizedBox(height: 20.h),
              ...routines.map(
                (routine) => Padding(
                  padding: EdgeInsets.only(bottom: 5.0.r),
                  child: Material(
                    color: SURFACE2,
                    borderRadius: BorderRadius.circular(8.r),
                    child: InkWell(
                      onTap: () {
                        handleShowRoutine(routine);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20.r,
                          horizontal: 15.r,
                        ),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.layerGroup),
                            SizedBox(width: 20.w),
                            Text(
                              "${routine.name} (${routine.workoutsIds.length})",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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

  handleShowRoutine(Routine routine) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RoutineDetails(routine: routine, isCreateMode: false),
      ),
    );
    setRoutineUi();
    refreshState();
  }
}
