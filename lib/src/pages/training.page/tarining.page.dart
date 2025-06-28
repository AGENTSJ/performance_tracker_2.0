import 'package:flutter/material.dart';
import 'package:performance_tracker/constants.ui.dart';

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
      body:Container()
    );
  }
}
