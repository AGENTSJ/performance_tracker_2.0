import 'package:flutter/material.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/pages/advices.page/advices.page.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({Key? key}) : super(key: key);

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: BACKGROUND,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("coach"),
            TextButton(onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AdvicesPage()));
            }, child: Text("Advices")),
          ],
        ),
      ),
      body: const Center(child: Text('Welcome to the Coach Page!')),
    );
  }
}
