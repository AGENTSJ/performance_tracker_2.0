import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  State<WorkoutDetailsPage> createState() => WorkoutDetailsPageState();
}

class WorkoutDetailsPageState extends State<WorkoutDetailsPage> {
  var routineService = locator<RoutineService>();
  var workNameController = TextEditingController();
  bool isEditModeOn = false;
  Workout? workout;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      workNameController.text = widget.workout.name;
      if (widget.isCreateMode) {
        workout = await routineService.addWorkout(widget.workout);
      } else {
        workout = widget.workout;
      }
      refreshState();
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: isEditModeOn
                            ? TextField(
                                controller: workNameController,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      workout?.name ?? '',
                                      softWrap: true,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        this.isEditModeOn = true;
                                        refreshState();
                                      },
                                      child: Icon(FontAwesomeIcons.penToSquare),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // sets
              SetDetailsComponent(
                workout: widget.workout,
                onSetUpdated: (updated) {
                  handleSetUpdated();
                },
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
                      Row(
                        children: [
                          Text(
                            "Workout Journal",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      TextField(
                        minLines: 3,
                        maxLines: null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromARGB(53, 202, 202, 202),
                          hintText: "Add some notes about this workout",
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        handleRemove();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(148, 255, 91, 91),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(color: const Color.fromARGB(148, 255, 91, 91))
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.trash,color: const Color.fromARGB(189, 255, 82, 82),size: 12,),
                          SizedBox(width: 10,),
                          Text("Remove",style: TextStyle(color: const Color.fromARGB(189, 255, 82, 82)),),
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
      bottomNavigationBar: isEditModeOn
          ? Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  handleUpdateWorkout();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: PRIMARY,
                ),
                child: Text("Update", style: TextStyle(color: Colors.white)),
              ),
            )
          : null,
    );
  }

  void handleSetUpdated() {
    refreshState();
  }

  handleUpdateWorkout() {
    workout?.name = workNameController.text;
    routineService.updateWorkout(workout!);
    isEditModeOn = false;
    refreshState();
  }
  handleRemove() async
  {
    bool remove =await showConfirmation(context ) ?? false;
    if(remove)
    {
      routineService.removeWorkout(workout!);
      Navigator.of(context).pop(true);
    }
  }
    Future<bool?> showConfirmation(BuildContext context) async {

    return showDialog<bool>(
      barrierColor: const Color.fromARGB(87, 90, 90, 90),
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure ?'),
          content: Text("All the data will be lost"),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }
}
