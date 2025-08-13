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
import 'package:performance_tracker/src/features/Coach/models/chat.models.dart';
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
  bool isTyping = false;
  ChatDTO? latestChatDto;
  Timer? refreshTimer;
  bool isLoaded = false;

  setUpUi() async {
    latestChatDto = null;
    coachIconImg = avatarService.getMaleAvatar();
    olderChats = await trainerService.getOlderChat();
    setUpConversationWindow();
    refreshState();
    Future.delayed(Duration(milliseconds: 200), () {
      scrollToEnd();
    });
    await Future.delayed(Duration(milliseconds: WAITING_PERIOD_PAGE_SWITCH_MS));
    isLoaded = true;
    refreshState();
  }

  setUpConversationWindow() {
    chats = [];
    chats.addAll(olderChats!.contents);
  }

  @override
  void initState() {
    super.initState();
    setUpUi();
  }

  scrollToEnd() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
        // duration: Duration(milliseconds: 250),
        // curve: Curves.bounceIn,
      );
    }
  }

  handleSendMessage() async {
    if (isTyping || msgController.text.isEmpty) return;
    var message = msgController.text;
    msgController.text = "";
    isTyping = true;
    chats.add(
      AiChatSegment(
        role: ChatRoles.user,
        parts: [ChatPart(text: message)],
      ),
    );
    refreshState();
    scrollToEnd();
    var response = await trainerService.chatWithCoach(message);
    latestChatDto = response;
    if (response == null) {
      Fluttertoast.showToast(msg: "An error has occur");
      isTyping = false;
      refreshState();
      return;
    }
    chats.add(
      AiChatSegment(
        role: ChatRoles.model,
        parts: [ChatPart(text: response.data)],
      ),
    );

    isTyping = false;
    refreshState();
  }

  refreshState() {
    if (!mounted) return;
    setState(() {});
  }

  void handleClearAllChats(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SURFACE2,
        title: Text("Confirm Clear"),
        content: Text(
          "Are you sure you want to clear all chats? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Clear", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      await trainerService.clearAllChats();
      setUpUi();
      Fluttertoast.showToast(msg: "All chats have been cleared");
    }
  }

  controlledRefresh() {
    if (refreshTimer == null || !refreshTimer!.isActive) {
      refreshTimer = Timer(Duration(milliseconds: 250), () {
        refreshState();
      });
    } else {
      refreshTimer?.cancel();
      refreshTimer = Timer(Duration(milliseconds: 250), () {
        refreshState();
      });
    }
  }

  handleViewAdvices() {}

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
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: SURFACE2,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SizedBox(
                    height: 50.h,
                    child: DrawerHeader(
                      child: Text(
                        'Coach settings',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Container with TextButton (Reports)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: BORDER_PRIMARY)),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        foregroundColor: TEXT_PRIMARY,
                        iconColor: TEXT_SECONDARY,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ReportsPage(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.book, size: 18.sp),
                          SizedBox(width: 20.w),
                          Text("Reports", style: TextStyle(fontSize: 12.sp)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: BORDER_PRIMARY)),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        foregroundColor: TEXT_PRIMARY,
                        iconColor: TEXT_SECONDARY,
                      ),
                      onPressed: () async {},
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.brain, size: 18.sp),
                          SizedBox(width: 20.w),
                          Text("Memory", style: TextStyle(fontSize: 12.sp)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: BORDER_PRIMARY),
                  top: BorderSide(color: BORDER_PRIMARY),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  foregroundColor: TEXT_PRIMARY,
                  iconColor: Colors.redAccent.shade100,
                ),
                onPressed: () async {
                  handleClearAllChats(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, size: 18.sp),
                    SizedBox(width: 20.w),
                    Text("Clear All Chats", style: TextStyle(fontSize: 12.sp)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5.h),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
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
                    physics: AlwaysScrollableScrollPhysics(),
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
                          (chatContent) => chatContent.parts.first.text.isEmpty
                              ? SizedBox.shrink()
                              : Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 8.0.h,
                                  ),
                                  child: ChatBubble(
                                    data: chatContent.parts.first.text,
                                    type: chatContent.role!,
                                  ),
                                ),
                        ),
                        if (isTyping)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.0.w,
                              vertical: 5.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: BORDER_PRIMARY,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Typing",
                                            style: TextStyle(
                                              color: TEXT_SECONDARY,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          SpinKitThreeBounce(
                                            color: TEXT_SECONDARY,
                                            size: 22.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(flex: 2, child: SizedBox()),
                              ],
                            ),
                          ),
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
                            maxLines: null,
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
          if (!isLoaded) Container(color: BACKGROUND, child: LoadingPage()),
        ],
      ),
    );
  }
}
