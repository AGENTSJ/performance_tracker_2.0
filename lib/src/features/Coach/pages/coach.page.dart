import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/services/ai.service.dart';
import 'package:performance_tracker/services/avatar.service.dart';
import 'package:performance_tracker/services/trainer.agent.service.dart';
import 'package:performance_tracker/src/components/loading.component.dart';
import 'package:performance_tracker/src/components/model_picker.dialog.dart';
import 'package:performance_tracker/src/features/Coach/models/AiResponse.model.dart';
import 'package:performance_tracker/src/features/Coach/pages/reports.page.dart';
import 'package:performance_tracker/src/features/Coach/usecases/coach_client_mcp.dart';
import 'package:performance_tracker/src/features/Coach/widgets/chat_bubble.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  var trainerService = locator<TrainerAgentService>();
  var avatarService = locator<AvatarService>();
  var aiService = locator<AiService>();
  var coachClient = locator<CoachClientMcp>();
  var msgController = TextEditingController();
  var scrollController = ScrollController();
  Widget? coachIconImg;
  AiChatContent? olderChats;
  List<AiChatSegment> chats = [];
  Timer? refreshTimer;
  bool isLoaded = false;
  String? _selectedModel;
  String? _selectedActModel;
  // Tracks the previous responding state so we can detect when a reply just
  // finished (and pull the committed exchange into the conversation window).
  bool _wasResponding = false;

  String _modelLabel() =>
      (_selectedModel ?? AiService.defaultModel).replaceFirst('models/', '');

  String _actModelLabel() =>
      (_selectedActModel ?? AiService.defaultModel).replaceFirst('models/', '');

  Future<void> _changeModel() async {
    var selected = await showDialog<String>(
      context: context,
      builder: (context) => ModelPickerDialog(currentModel: _selectedModel),
    );
    if (selected != null) {
      await aiService.setSelectedModel(selected);
      if (mounted) setState(() => _selectedModel = selected);
    }
  }

  Future<void> _changeActModel() async {
    var selected = await showDialog<String>(
      context: context,
      builder: (context) => ModelPickerDialog(currentModel: _selectedActModel),
    );
    if (selected != null) {
      await aiService.setSelectedActModel(selected);
      if (mounted) setState(() => _selectedActModel = selected);
    }
  }

  setUpUi() async {
    _wasResponding = trainerService.isResponding;
    coachIconImg = avatarService.getMaleAvatar();
    _selectedModel = await aiService.getSelectedModel();
    _selectedActModel = await aiService.getSelectedActModel();
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
    // Reflect the centralised act + chat progress (which keep running even
    // while this page is gone) whenever they change.
    coachClient.actProgress.addListener(_onActProgress);
    trainerService.chatProgress.addListener(_onChatProgress);
    setUpUi();
  }

  @override
  void dispose() {
    coachClient.actProgress.removeListener(_onActProgress);
    trainerService.chatProgress.removeListener(_onChatProgress);
    refreshTimer?.cancel();
    super.dispose();
  }

  void _onActProgress() => refreshState();

  void _onChatProgress() {
    final responding = trainerService.chatProgress.value.isResponding;
    // Reply just finished: pull the committed exchange into the window.
    if (_wasResponding && !responding) {
      _reloadChats();
    }
    _wasResponding = responding;
    controlledRefresh();
  }

  Future<void> _reloadChats() async {
    olderChats = await trainerService.getOlderChat();
    setUpConversationWindow();
    refreshState();
    Future.delayed(Duration(milliseconds: 100), scrollToEnd);
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

  handleSendMessage() {
    if (trainerService.isResponding || msgController.text.isEmpty) return;
    var message = msgController.text;
    msgController.text = "";
    // Fire and forget: progress is centralised in TrainerAgentService, so the
    // reply keeps streaming (and is restored) across navigation. The pending
    // user message is shown from chatProgress until the exchange is committed.
    trainerService.sendCoachMessage(message);
    // sendCoachMessage sets the pending-message state synchronously, so show
    // it (and the thinking indicator) immediately rather than waiting for the
    // throttled progress tick.
    refreshState();
    scrollToEnd();
  }

  handleStopGeneration() {
    trainerService.cancelChat();
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

  Widget _buildThinkingIndicator() {
    final thinkingText = trainerService.chatProgress.value.thinking;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 5.h),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: SURFACE2,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: BORDER_PRIMARY),
        ),
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  thinkingText.isEmpty ? "Typing" : "Thinking…",
                  style: TextStyle(color: TEXT_SECONDARY, fontSize: 12.sp),
                ),
                SizedBox(width: 6.w),
                SpinKitThreeBounce(color: TEXT_SECONDARY, size: 16.sp),
                const Spacer(),
                InkWell(
                  onTap: handleStopGeneration,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    child: Text(
                      "Stop",
                      style: TextStyle(
                        color: Colors.redAccent.shade100,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (thinkingText.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 160.h),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    thinkingText,
                    style: TextStyle(
                      color: TEXT_SECONDARY,
                      fontSize: 11.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Persistent panel showing the live progress of a coach "act" (advice
  /// application). Reads the centralised [CoachClientMcp.actProgress] so it
  /// reflects work that continued while the user was on another page.
  Widget _buildActIndicator() {
    final progress = coachClient.actProgress.value;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 5.h),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: SURFACE2,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: PRIMARY),
        ),
        padding: EdgeInsets.all(10.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.gears, color: PRIMARY, size: 14.sp),
                SizedBox(width: 6.w),
                Text(
                  "Applying advice…",
                  style: TextStyle(
                    color: TEXT_PRIMARY,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 6.w),
                SpinKitThreeBounce(color: TEXT_SECONDARY, size: 16.sp),
                const Spacer(),
                InkWell(
                  onTap: coachClient.cancelAct,
                  borderRadius: BorderRadius.circular(4.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    child: Text(
                      "Stop",
                      style: TextStyle(
                        color: Colors.redAccent.shade100,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (progress.adviceDesc.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                progress.adviceDesc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: TEXT_TERTIARY, fontSize: 11.sp),
              ),
            ],
            if (progress.thinking.isNotEmpty) ...[
              SizedBox(height: 8.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 160.h),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Text(
                    progress.thinking,
                    style: TextStyle(
                      color: TEXT_SECONDARY,
                      fontSize: 11.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        foregroundColor: TEXT_PRIMARY,
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
                      onPressed: _changeModel,
                      child: Row(
                        children: [
                          Icon(Icons.memory, size: 18.sp),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Model",
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                Text(
                                  _modelLabel(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: TEXT_SECONDARY,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                      onPressed: _changeActModel,
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.gears, size: 18.sp),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Act model",
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                Text(
                                  _actModelLabel(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: TEXT_SECONDARY,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                        if (chats.isEmpty && !trainerService.isResponding)
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
                        if (trainerService
                            .chatProgress
                            .value
                            .pendingUserMessage
                            .isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0.h),
                            child: ChatBubble(
                              data: trainerService
                                  .chatProgress
                                  .value
                                  .pendingUserMessage,
                              type: ChatRoles.user,
                            ),
                          ),
                        if (trainerService.isResponding)
                          _buildThinkingIndicator(),
                        if (coachClient.actProgress.value.isActing)
                          _buildActIndicator(),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: BACKGROUND,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(maxHeight: 200.h),
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
