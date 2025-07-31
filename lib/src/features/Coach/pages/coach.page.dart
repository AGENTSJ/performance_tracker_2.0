import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/src/components/loading.component.dart';
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
  AiChatContent? chats;
  bool isStreaming = false;
  String resp = "";
  List<String> events = [];
  bool isLoading = true;
  setUpUi() async {
    chats = await trainerService.getOlderChat();
    isLoading = false;
    refreshState();
    // print(chats);
  }
  @override
  void initState()
  {
    super.initState();
    setUpUi();
  }
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
          TextButton(
            onPressed: ()async {
              await trainerService.clearAllChats();
              setUpUi();
            },
            child: Icon(Icons.warning_rounded),
          ),
        ],
      ),
      body:isLoading? LoadingPage() : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                child: Column(
                  children: [
                    Container(
                      child: Column(
                        children: [...events.map((event) => Text(event))],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    ...chats!.contents.map(
                      (chatContent) =>
                          MarkdownWidget(data: chatContent.parts.first.text,shrinkWrap: true,),
                    ),
                    MarkdownWidget(data: resp, shrinkWrap: true),
                  ],
                ),
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
