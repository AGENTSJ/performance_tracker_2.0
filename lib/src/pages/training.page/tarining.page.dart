import 'package:flutter/material.dart';

class TrainingModulePage extends StatefulWidget {
  const TrainingModulePage({Key? key}) : super(key: key);

  @override
  State<TrainingModulePage> createState() => _TrainingModulePageState();
}

class _TrainingModulePageState extends State<TrainingModulePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Page'),
      ),
      body: const Center(
        child: Text('Welcome to the Training Page!'),
      ),
    );
  }
}