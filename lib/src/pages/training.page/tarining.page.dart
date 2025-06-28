import 'package:flutter/material.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/pages/training.page/widgets/exercise.dart';

class TrainingModulePage extends StatefulWidget {
  const TrainingModulePage({super.key});

  @override
  State<TrainingModulePage> createState() => _TrainingModulePageState();
}

class _TrainingModulePageState extends State<TrainingModulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        title: const Text('Training Page'),
      ),
      body:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ExerciseWidget(name: "Bench")
            ],
          ),
        ),
      )
    );
  }
}
