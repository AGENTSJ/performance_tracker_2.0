import 'package:flutter/material.dart';
import 'package:performance_tracker/constants.ui.dart';

class AdvicesPage extends StatefulWidget {
  const AdvicesPage({Key? key}) : super(key: key);

  @override
  State<AdvicesPage> createState() => _AdvicesPageState();
}

class _AdvicesPageState extends State<AdvicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        title: const Text('Advices Page'),
      ),
      body: const Center(
        child: Text('Advices Page Content'),
      ),
    );
  }
}