import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  var scrollController = ScrollController();
  Widget? coachIconImg;
  AiChatContent? olderChats;
  List<AiChatSegment> chats = [];
  bool isStreaming = false;
  bool isGettingContext = false;
  String resp = "";
  List<String> events = [];
  bool isLoading = true;
  AiChatSegment? activeChatResp;
  Timer? refreshTimer;

  setUpUi() async {
    coachIconImg = avatarService.getMaleAvatar();
    olderChats = await trainerService.getOlderChat();
    chats = [];
    chats.addAll(olderChats!.contents);
    isLoading = false;
    Future.delayed(Duration(milliseconds: 200,),(){
      scrollToEnd();
    });
    refreshState();
  }

  @override
  void initState() {
    listenToAnyActiveStreams();
    super.initState();
    setUpUi();
  }

  scrollToEnd() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 250),
        curve: Curves.bounceIn,
      );
    }
  }

  listenToAnyActiveStreams() {
    if (trainerService.pipeLineActive) {
      isStreaming = true;
      isGettingContext = false;
      if (trainerService.chatStreamExternal != null) {
        resp = trainerService.chatRespData;
        activeChatResp = AiChatSegment(
          role: ChatRoles.model,
          parts: [ChatPart(text: resp)],
        );
        trainerService.chatStreamExternal?.stream.listen(
          (data) {
            activeChatResp!.parts.first.text += data.message;
            chats.add(activeChatResp!);
            controlledRefresh();
          },
          onDone: () {
            isStreaming = false;
            refreshState();
            scrollToEnd();
          },
        );
      }
    }
  }

  handleSendMessage() async {
    if (isStreaming || msgController.text.isEmpty) return;
    var message = msgController.text;
    msgController.text = "";
    isStreaming = true;
    isGettingContext = true;
    refreshState();
    scrollToEnd();
    await Future.delayed(Duration(seconds: 4));
    chats.add(
      AiChatSegment(
        role: ChatRoles.user,
        parts: [ChatPart(text: message)],
      ),
    );
    ChatStreamDTO chatStream = await trainerService.chatWithCoach(message);
    resp = chatStream.streamData;
    isGettingContext = false;
    refreshState();
    activeChatResp = AiChatSegment(
      role: ChatRoles.model,
      parts: [ChatPart(text: resp)],
    );
    chats.add(activeChatResp!);
    chatStream.stream.stream.listen(
      (data) {
        activeChatResp!.parts.first.text += data.message;
        controlledRefresh();
      },
      onDone: () {
        isStreaming = false;
        refreshState();
        scrollToEnd();
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

  controlledRefresh() {
    if (refreshTimer == null || !refreshTimer!.isActive) {
      refreshTimer = Timer(Duration(milliseconds: 250), () {
        refreshState();
        scrollToEnd();
      });
    } else {
      refreshTimer?.cancel();
      refreshTimer = Timer(Duration(milliseconds: 250), () {
        refreshState();
        scrollToEnd();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              height: 40.h,
              width: 40.h,
              child: Stack(
                children: [
                  Positioned(
                    bottom: -10.h,
                    child: Icon(Icons.circle, color: PRIMARY, size: 50),
                  ),
                  coachIconImg!,
                ],
              ),
            ),
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
                      controller: scrollController,
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
                          if (isGettingContext)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.0.w,
                                vertical: 12.h,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: SURFACE2,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SpinKitSpinningLines(
                                        size: 30,
                                        color: PRIMARY,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Thinking...."),
                                    ],
                                  ),
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
                          SizedBox(width: 10.w),
                          TextButton(
                            onPressed: () {
                              handleSendMessage();
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: PRIMARY,
                              shape: CircleBorder(),
                              minimumSize: Size(40.h, 40.h),
                            ),
                            child: Icon(
                              FontAwesomeIcons.paperPlane,
                              color: SURFACE2,
                              size: 20,
                            ),
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
