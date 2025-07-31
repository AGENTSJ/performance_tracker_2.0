import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
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
  handleSendMessage() async {
    isStreaming = true;
    StreamController<AiResponse>? controller = await trainerService.chatWithCoach(msgController.text);
    if (controller == null) {
      Fluttertoast.showToast(msg: "An Error has occur");
      isStreaming = false;
      refreshState();
      return;
    }
    controller.stream.listen(
      (data) {
        resp += data.message;
        refreshState();
      },
      onDone: () {
        isStreaming = false;
        refreshState();
      },
    );
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
          TextButton(onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ReportsPage()));
          }, child: Icon(Icons.book))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [MarkdownWidget(data: resp, shrinkWrap: true)],
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
