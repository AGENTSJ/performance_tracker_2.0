import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/src/features/Coach/pages/reports.page.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  var trainerService = locator<TrainerAgentService>();
  var msgController = TextEditingController();
  bool isStreaming = false;
  String resp = "";
  List<String> events = [];

  handleSendMessage() async {
    isStreaming = true;
    ChatStreamDTO chatStream = await trainerService.chatWithCoach(
      msgController.text,
    );

    chatStream.stream.stream.listen(
      (data) {
        resp += data.message;
        refreshState();
      },
      onDone: () {
        isStreaming = false;
        refreshState();
      },
    );
    chatStream.eventStream.stream.listen((data) {
      events.add(data);
      refreshState();
    });
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        title: const Text('Coach Page'),
        backgroundColor: BACKGROUND,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => ReportsPage()));
            },
            child: Icon(Icons.book),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(child: Column(
                    children: [
                      ...events.map(
                        (event)=>Text(event)
                      )
                    ],
                  ),),
                  SizedBox(height: 30.h),
                  MarkdownWidget(data: resp, shrinkWrap: true),
                ],
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      handleSendMessage();
                    },
                    child: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
