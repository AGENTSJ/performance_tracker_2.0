import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/src/components/loading.component.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/pages/reports.page.dart';
import 'package:performance_tracker/src/features/Coach/widgets/chat_bubble.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  var trainerService = locator<TrainerAgentService>();
  var avatarService = locator<AvatarService>();
  var msgController = TextEditingController();
  Widget? coachIconImg;
  AiChatContent? olderChats;
  List<AiChatSegment> chats = [];
  bool isStreaming = false;
  String resp = "";
  List<String> events = [];
  bool isLoading = true;
  AiChatSegment? activeChatResp;
  setUpUi() async {
    coachIconImg = avatarService.getMaleAvatar();
    olderChats = await trainerService.getOlderChat();
    chats = [];
    chats.addAll(olderChats!.contents);
    isLoading = false;
    refreshState();
  }

  @override
  void initState() {
    super.initState();
    setUpUi();
  }

  handleSendMessage() async {
    isStreaming = true;
    chats.add(
      AiChatSegment(
        role: ChatRoles.user,
        parts: [ChatPart(text: msgController.text)],
      ),
    );
    refreshState();
    ChatStreamDTO chatStream = await trainerService.chatWithCoach(
      msgController.text,
    );
    activeChatResp = AiChatSegment(
      role: ChatRoles.model,
      parts: [ChatPart(text: resp)],
    );
    chats.add(activeChatResp!);
    chatStream.stream.stream.listen(
      (data) {
        activeChatResp!.parts.first.text += data.message;
        refreshState();
      },
      onDone: () {
        isStreaming = false;
        refreshState();
      },
      onError: (err) {
        isStreaming = false;
        Fluttertoast.showToast(msg: "An error has occur");
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
        title: Row(
          children: [
            SizedBox(height: 40.h,width: 40.h,child: Stack(
              children: [
                Positioned(bottom: -10.h,child: Icon(Icons.circle,color: PRIMARY,size: 50,)),
                coachIconImg!,
              ],
            ),),
            Text('Coach'),
          ],
        ),
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
            onPressed: () async {
              await trainerService.clearAllChats();
              setUpUi();
            },
            child: Icon(Icons.warning_rounded),
          ),
        ],
      ),
      body: isLoading
          ? LoadingPage()
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: backgroundDoodles,
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ).withOpacity(0.3), // adjust opacity to control strength
                    BlendMode.modulate, // or try BlendMode.modulate / overlay
                  ),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 30.h),
                          if (chats.isEmpty)
                            ChatBubble(
                              data:
                                  "Hello there let me guide you !! and make you see progress by optimising your workout and other things",
                              type: ChatRoles.model,
                            ),
                          ...chats.map(
                            (chatContent) => Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0.h),
                              child: ChatBubble(
                                data: chatContent.parts.first.text,
                                type: chatContent.role!,
                              ),
                            ),
                          ),
                          // MarkdownWidget(data: resp, shrinkWrap: true),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: BACKGROUND,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: msgController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: SURFACE2,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Your message ..",
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w,),
                          TextButton(
                            onPressed: () {
                              handleSendMessage();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: PRIMARY,
                              shape: CircleBorder(),
                              minimumSize: Size(40.h, 40.h),
                            ),
                            child: Icon(FontAwesomeIcons.paperPlane, color: SURFACE2,size: 20,),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
