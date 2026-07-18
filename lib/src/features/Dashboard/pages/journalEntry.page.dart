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
import 'package:performance_tracker/models/journalBook.model.dart';
import 'package:performance_tracker/services/jorunal.service.dart';

class JournalEntryPage extends StatefulWidget {
  final Journal journal;

  const JournalEntryPage({super.key, required this.journal});

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  var jService = locator<JournalService>();
  late TextEditingController _markdownController;
  late TextEditingController _titleEditController;
  late FocusNode _focusNode;
  final ButtonStyle actionBtnStyle = ElevatedButton.styleFrom(
    iconColor: TEXT_PRIMARY,
    backgroundColor: SURFACE,
    foregroundColor: TEXT_PRIMARY,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadiusGeometry.circular(8.r),
    ),
    elevation: 0,
    shadowColor: Colors.transparent
  );
  var beautiFying = false;
  var isEditingMode = false;
  final TextStyle titleStyle = TextStyle(
    fontSize: 20,
    color: TEXT_PRIMARY,
    fontWeight: FontWeight.w600,
    overflow: TextOverflow.ellipsis,
  );
  double opacity = 0;
  @override
  void initState() {
    super.initState();
    _markdownController = TextEditingController(
      text: widget.journal.journalData,
    );
    _titleEditController = TextEditingController(text: widget.journal.title);
    _focusNode = FocusNode();
    opacity = widget.journal.opacity;
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
                            if (widget.journal.backgroundImageUrl != null) ...[
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
                                    widget.journal.opacity = newValue;
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
        widget.journal.backgroundImageUrl = pickedFile.path;
      });

      // Save the image to app's documents directory for permanence
      final appDir = await Directory(
        '${(await getApplicationDocumentsDirectory()).path}/journal_images',
      ).create(recursive: true);

      final fileName = pickedFile.name;
      final savedImage = await File(
        pickedFile.path,
      ).copy('${appDir.path}/$fileName');
      widget.journal.opacity = 0.5;
      await jService.updateJournal(widget.journal);

      setState(() {
        opacity = 0.5;
        widget.journal.backgroundImageUrl = savedImage.path;
      });
      Fluttertoast.showToast(msg: "Background updated");
    }
  }

  _handleRemoveBackgroundImage() async {
    widget.journal.backgroundImageUrl = null;
    widget.journal.opacity = 0;
    await jService.updateJournal(widget.journal);
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
        widget.journal.imagePaths.add(pickedFile.path);
      });
    }
  }

  _beautify() async {
    beautiFying = true;
    refreshState();
    try {
      var resp = await jService.beautifyJournal(widget.journal);
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
              title: Text('Confirm Removal'),
              content: Text('Are you sure you want to remove?'),
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
    if (confirm) {
      if (widget.journal.backgroundImageUrl != null) {
        var backgroundFile = File(widget.journal.backgroundImageUrl!);
        if (await backgroundFile.exists()) {
          await backgroundFile.delete();
        }
      }
      await jService.removeJournal(widget.journal);
      Navigator.pop(context);
    }
  }

  _saveJournal() async {
    if (isEditingMode) {
      widget.journal.title = _titleEditController.text;
      widget.journal.journalData = _markdownController.text;
      await jService.updateJournal(widget.journal);
      Fluttertoast.showToast(msg: "Saved");
      isEditingMode = false;
      refreshState();
    } else {
      isEditingMode = true;
      refreshState();
    }
  }

  refreshState() {
    if (!mounted) {
      return;
    }
    setState(() {});
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
                    ...widget.journal.imagePaths
                        .map((url) => Image.file(File(url)))
                        .toList(),
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
  void dispose() {
    _markdownController.dispose();
    _titleEditController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SURFACE2,
      appBar: AppBar(
        foregroundColor: TEXT_PRIMARY,
        title: isEditingMode
            ? EditableText(
                controller: _titleEditController,
                focusNode: _focusNode,
                style: titleStyle,
                cursorColor: TEXT_PRIMARY,
                backgroundCursorColor: BACKGROUND,
              )
            : Text(widget.journal.title, style: titleStyle),
        backgroundColor: SURFACE2,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: _onRemoveEntryPressed,
              icon: Icon(FontAwesomeIcons.trashCan, size: 20,color: TEXT_PRIMARY,),
              style: IconButton.styleFrom(backgroundColor: SURFACE),
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.journal.backgroundImageUrl != null)
            Opacity(
              opacity: opacity,
              child: Image.file(
                File(widget.journal.backgroundImageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Images preview
                if (widget.journal.imagePaths.isNotEmpty)
                  SizedBox(
                    height: 100.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.journal.imagePaths.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showImageViewer(index);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(widget.journal.imagePaths[index]),
                                  width: 100.w,
                                  height: 100.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    widget.journal.imagePaths.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: TEXT_PRIMARY,
                                    shape: BoxShape.circle,
                                  ),
                                  child:  Icon(
                                    Icons.close,
                                    color: TEXT_SECONDARY,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                SizedBox(height: 20.h),
                if (isEditingMode) ...[
                  Expanded(
                    child: TextField(
                      controller: _markdownController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: "Journal",
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      onChanged: (value) {
                        setState(() {
                          widget.journal.journalData = value;
                        });
                      },
                    ),
                  ),
                ] else ...[
                  if (widget.journal.journalData.isEmpty) ...[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 150.h,
                            child: Image.asset('assets/glaring.png'),
                          ),
                          SizedBox(height: 10.h,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text("Spill your heart ❤️",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w400,color: TEXT_TERTIARY),)],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: MarkdownWidget(data: widget.journal.journalData),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                // Add images button
                Row(
                  children: [
                    if (isEditingMode) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: showAddImageSheet,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Add'),
                          style: actionBtnStyle,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      if (!beautiFying)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _beautify,
                            icon: const Icon(FontAwesomeIcons.star),
                            label: const Text('Format'),
                            style: actionBtnStyle,
                          ),
                        ),
                      if (beautiFying)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _beautify,
                            icon: const Icon(FontAwesomeIcons.hourglassHalf),
                            label: const Text('Wait'),
                            style: actionBtnStyle,
                          ),
                        ),
                    ],
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveJournal,
                        icon: isEditingMode ? Icon(Icons.save) : Icon(Icons.edit),
                        label: Text(isEditingMode ? 'Save' : 'Edit'),
                        style: actionBtnStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
