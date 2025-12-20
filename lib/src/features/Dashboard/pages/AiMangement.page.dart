import 'package:flutter/material.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Dashboard/widgets/AiKeyCard.dart';
import 'package:performance_tracker/src/features/Dashboard/widgets/logs.view.dart';

class AimangementPage extends StatefulWidget {

  const AimangementPage({super.key, });

  @override
  State<AimangementPage> createState() => _AimangementPageState();
}

class _AimangementPageState extends State<AimangementPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journals'),
        backgroundColor: BACKGROUND,
        actions: [
        ],
      ),
      backgroundColor: BACKGROUND,
      body: Column(
        children: [
          ApiKeyWidget(),
          Expanded(child: LogViewWidget()),
        ],
      ),
    );
  }
}