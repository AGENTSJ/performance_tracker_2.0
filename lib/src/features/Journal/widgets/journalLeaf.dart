import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/src/features/Journal/models/journalBook.model.dart';
import 'package:performance_tracker/src/features/Journal/models/journalPageStyle.model.dart';
import 'package:performance_tracker/src/features/Journal/services/journal.service.dart';
import 'package:performance_tracker/src/features/Journal/widgets/journalTheme.dart';

/// One page of the diary: shows a single entry and lets it be edited.
class JournalLeaf extends StatefulWidget {
  final Journal journal;
  final int pageNumber;
  final bool startEditing;
  final ValueChanged<bool> onEditingChanged;
  final VoidCallback onDeleted;
  final VoidCallback onBackToIndex;

  const JournalLeaf({
    super.key,
    required this.journal,
    required this.pageNumber,
    required this.onEditingChanged,
    required this.onDeleted,
    required this.onBackToIndex,
    this.startEditing = false,
  });

  @override
  State<JournalLeaf> createState() => _JournalLeafState();
}

class _JournalLeafState extends State<JournalLeaf> {
  final jService = locator<JournalService>();
  final commonService = locator<CommonService>();
  late TextEditingController _markdownController;
  late TextEditingController _titleEditController;
  var bodyPadding = EdgeInsets.only(left: 28.w, right: 16.w);

  var beautiFying = false;
  var isEditingMode = false;
  double opacity = 0;

  Journal get journal => widget.journal;

  @override
  void initState() {
    super.initState();
    _markdownController = TextEditingController(text: journal.journalData);
    _titleEditController = TextEditingController(text: journal.title);
    opacity = journal.opacity;
    isEditingMode = widget.startEditing;
  }

  @override
  void dispose() {
    // Leaving the page mid-edit (e.g. back button) keeps what was written.
    if (isEditingMode) {
      journal.title = _titleEditController.text;
      journal.journalData = _markdownController.text;
      jService.updateJournal(journal);
    }
    _markdownController.dispose();
    _titleEditController.dispose();
    super.dispose();
  }

  refreshState() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _setEditing(bool editing) {
    isEditingMode = editing;
    widget.onEditingChanged(editing);
    refreshState();
  }

  showAddImageSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Attach images'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit background image'),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Change background image'),
                              onTap: () {
                                Navigator.pop(context);
                                _handleChangeBackground();
                              },
                            ),
                            SizedBox(height: 10.h),
                            ListTile(
                              leading: Icon(FontAwesomeIcons.circleXmark),
                              title: Text('Remove Background image'),
                              onTap: () {
                                Navigator.pop(context);
                                _handleRemoveBackgroundImage();
                              },
                            ),
                            SizedBox(height: 10.h),
                            if (journal.backgroundImageUrl != null) ...[
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 20.w),
                                    child: Text(
                                      "Opacity",
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: opacity,
                                min: 0.0,
                                max: 1.0,
                                divisions: 100,
                                label: opacity.toStringAsFixed(1),
                                onChanged: (newValue) {
                                  setModalState(() {
                                    opacity = newValue;
                                    journal.opacity = newValue;
                                    setState(() {});
                                  });
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _handleChangeBackground() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        journal.backgroundImageUrl = pickedFile.path;
      });

      // Save the image to app's documents directory for permanence
      final appDir = await Directory(
        '${(await getApplicationDocumentsDirectory()).path}/journal_images',
      ).create(recursive: true);

      final fileName = pickedFile.name;
      final savedImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');
      journal.opacity = 0.5;
      journal.backgroundImageUrl = savedImage.path;
      await jService.updateJournal(journal);

      opacity = 0.5;
      refreshState();
      Fluttertoast.showToast(msg: "Background updated");
    }
  }

  _handleRemoveBackgroundImage() async {
    journal.backgroundImageUrl = null;
    journal.opacity = 0;
    await jService.updateJournal(journal);
    refreshState();
    Fluttertoast.showToast(msg: "Background image removed");
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        journal.imagePaths.add(pickedFile.path);
      });
    }
  }

  _beautify() async {
    if (beautiFying) {
      return;
    }
    beautiFying = true;
    refreshState();
    try {
      journal.journalData = _markdownController.text;
      var resp = await jService.beautifyJournal(journal);
      _markdownController.text = resp;
    } catch (_) {
      Fluttertoast.showToast(msg: "An error has occur");
    } finally {
      beautiFying = false;
      refreshState();
    }
  }

  Future<bool> showRemoveConfirmationDialog(BuildContext context) async {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Tear out this page?'),
              content: Text('This entry will be removed permanently.'),
              actions: [
                CupertinoDialogAction(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Remove'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog dismissed without choosing
  }

  void _onRemoveEntryPressed() async {
    bool confirm = await showRemoveConfirmationDialog(context);
    if (!confirm) {
      return;
    }
    if (journal.backgroundImageUrl != null) {
      var backgroundFile = File(journal.backgroundImageUrl!);
      if (await backgroundFile.exists()) {
        await backgroundFile.delete();
      }
    }
    await jService.removeJournal(journal);
    widget.onDeleted();
  }

  _saveJournal() async {
    journal.title = _titleEditController.text.trim();
    journal.journalData = _markdownController.text;
    await jService.updateJournal(journal);
    Fluttertoast.showToast(msg: "Saved");
    _setEditing(false);
  }

  _showImageViewer(int index) {
    var pageController = PageController(initialPage: index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: TEXT_PRIMARY,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PageView(
                  controller: pageController,
                  children: [
                    ...journal.imagePaths.map((url) => Image.file(File(url))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var style = JournalTheme.pageStyleOf(context);
    return JournalPaper(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (journal.backgroundImageUrl != null)
            Opacity(
              opacity: opacity,
              child: Image.file(
                File(journal.backgroundImageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildToolbar(),
                _buildHeading(),
                SizedBox(height: 10.h),
                const JournalOrnament(),
                SizedBox(height: 10.h),
                if (journal.imagePaths.isNotEmpty) ...[
                  _buildImageStrip(),
                  SizedBox(height: 12.h),
                ],
                Expanded(child: _buildBody()),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Text(
                    '— ${widget.pageNumber} —',
                    textAlign: TextAlign.center,
                    style: JournalTheme.serif(
                      fontSize: 13.sp,
                      color: style.inkFaded,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    var style = JournalTheme.pageStyleOf(context);
    var iconColor = style.inkFaded;
    return Row(
      children: [
        IconButton(
          onPressed: widget.onBackToIndex,
          icon: const Icon(Icons.format_list_bulleted),
          color: iconColor,
          tooltip: 'Index',
        ),
        const Spacer(),
        if (isEditingMode) ...[
          IconButton(
            onPressed: showAddImageSheet,
            icon: const Icon(Icons.add_a_photo_outlined),
            color: iconColor,
            tooltip: 'Images',
          ),
          IconButton(
            onPressed: _beautify,
            icon: Icon(
              beautiFying
                  ? FontAwesomeIcons.hourglassHalf
                  : FontAwesomeIcons.wandMagicSparkles,
              size: 18,
            ),
            color: iconColor,
            tooltip: 'Format',
          ),
          IconButton(
            onPressed: _saveJournal,
            icon: const Icon(Icons.check),
            color: style.ink,
            tooltip: 'Save',
          ),
        ] else ...[
          IconButton(
            onPressed: _onRemoveEntryPressed,
            icon: const Icon(FontAwesomeIcons.trashCan, size: 18),
            color: iconColor,
            tooltip: 'Remove',
          ),
          IconButton(
            onPressed: () => _setEditing(true),
            icon: const Icon(Icons.edit_outlined),
            color: style.ink,
            tooltip: 'Edit',
          ),
        ],
      ],
    );
  }

  Widget _buildHeading() {
    var style = JournalTheme.pageStyleOf(context);
    var date = journal.dateOfJournal;
    var title = journal.title.trim();
    return Padding(
      padding: bodyPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${journalWeekday(date).toUpperCase()}  ·  ${commonService.getTimeString(date)}',
            style: JournalTheme.serif(
              fontSize: 11.sp,
              letterSpacing: 2,
              color: style.inkFaded,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            journalLongDate(date),
            style: JournalTheme.serif(fontSize: 26.sp),
          ),
          if (isEditingMode)
            TextField(
              controller: _titleEditController,
              style: JournalTheme.serif(
                fontSize: 17.sp,
                fontStyle: FontStyle.italic,
                color: style.ink,
              ),
              cursorColor: style.ink,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Give this day a title',
                hintStyle: JournalTheme.serif(
                  fontSize: 17.sp,
                  fontStyle: FontStyle.italic,
                  color: style.inkFaded.withValues(alpha: 0.6),
                ),
              ),
            )
          else if (title.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                title,
                style: JournalTheme.serif(
                  fontSize: 17.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageStrip() {
    var style = JournalTheme.pageStyleOf(context);
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: journal.imagePaths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => _showImageViewer(index),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(journal.imagePaths[index]),
                    width: 90.w,
                    height: 90.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isEditingMode)
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        journal.imagePaths.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: style.ink,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: style.paper, size: 18),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    var style = JournalTheme.pageStyleOf(context);
    if (isEditingMode) {
      return Padding(
        padding: bodyPadding,
        child: TextField(
          controller: _markdownController,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          cursorColor: style.ink,
          style: JournalTheme.serif(fontSize: 16.sp, height: 1.6, color: style.ink),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Dear diary…',
            hintStyle: JournalTheme.serif(
              fontSize: 16.sp,
              fontStyle: FontStyle.italic,
              color: style.inkFaded.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }
    if (journal.journalData.isEmpty) {
      return GestureDetector(
        onTap: () => _setEditing(true),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 150.h, child: Image.asset('assets/glaring.png')),
            SizedBox(height: 10.h),
            Text(
              "Spill your heart ❤️",
              textAlign: TextAlign.center,
              style: JournalTheme.serif(
                fontSize: 15.sp,
                fontStyle: FontStyle.italic,
                color: style.inkFaded,
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: bodyPadding,
      child: MarkdownWidget(
        data: journal.journalData,
        config: _markdownConfig(style),
      ),
    );
  }

  MarkdownConfig _markdownConfig(JournalPageStyle style) {
    TextStyle heading(double size) => JournalTheme.serif(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: style.ink,
      height: 1.3,
    );
    var base = style.isDark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;
    return base.copy(
      configs: [
        PConfig(
          textStyle: JournalTheme.serif(
            fontSize: 16.sp,
            height: 1.6,
            color: style.ink,
          ),
        ),
        H1Config(style: heading(28.sp)),
        H2Config(style: heading(23.sp)),
        H3Config(style: heading(19.sp)),
        BlockquoteConfig(sideColor: style.rule, textColor: style.inkFaded),
        HrConfig(height: 1, color: style.rule),
      ],
    );
  }
}
