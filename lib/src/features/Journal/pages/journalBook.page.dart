import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Journal/models/journalBook.model.dart';
import 'package:performance_tracker/src/features/Journal/models/journalPageStyle.model.dart';
import 'package:performance_tracker/src/features/Journal/pages/journalReader.page.dart';
import 'package:performance_tracker/src/features/Journal/services/journal.service.dart';
import 'package:performance_tracker/src/features/Journal/widgets/bookPager.dart';
import 'package:performance_tracker/src/features/Journal/widgets/journalCover.dart';
import 'package:performance_tracker/src/features/Journal/widgets/journalIndex.dart';
import 'package:performance_tracker/src/features/Journal/widgets/journalTheme.dart';

/// The diary itself: the front cover, which turns over to the index.
class JournalBookPage extends StatefulWidget {
  final String pass;
  const JournalBookPage({super.key, required this.pass});

  @override
  State<JournalBookPage> createState() => _JournalBookPageState();
}

class _JournalBookPageState extends State<JournalBookPage> {
  static const int _coverPage = 0;
  static const int _indexPage = 1;

  final journalService = locator<JournalService>();
  final _pager = BookPagerController();
  int _page = _coverPage;

  /// Oldest first, i.e. book order.
  List<Journal> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
    journalService.loadPageStyle();
  }

  void _loadEntries() {
    _entries = journalService.getEntriesChronological();
  }

  Future<void> _openEntry(Journal entry, {bool startEditing = false}) async {
    await Navigator.push(
      context,
      JournalReaderPage.route(
        entries: _entries,
        initialIndex: _entries.indexOf(entry),
        startEditing: startEditing,
      ),
    );
    if (mounted) {
      setState(_loadEntries);
    }
  }

  /// Opens the entry for [day], creating it (and starting in edit mode) if
  /// that day has no entry yet.
  Future<void> _openOrCreateEntry(DateTime day) async {
    var isNew = journalService.getEntryForDay(day) == null;
    var entry = await journalService.getOrCreateEntryForDay(day);
    if (entry == null || !mounted) {
      return;
    }
    setState(_loadEntries);
    await _openEntry(entry, startEditing: isNew);
  }

  Future<void> _addNewEntry() async {
    var today = DateTime.now();
    var style = journalService.pageStyle.value;
    var picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),
      lastDate: today,
      helpText: 'Which day are you writing about?',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: style.isDark
              ? ColorScheme.dark(
                  primary: style.ink,
                  onPrimary: style.paper,
                  surface: style.paper,
                  onSurface: style.ink,
                )
              : ColorScheme.light(
                  primary: style.ink,
                  onPrimary: style.paper,
                  surface: style.paper,
                  onSurface: style.ink,
                ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: style.paper,
            headerBackgroundColor: style.paper,
            headerForegroundColor: style.ink,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) {
      return;
    }
    await _openOrCreateEntry(picked);
  }

  Future<void> _openToday() => _openOrCreateEntry(DateTime.now());

  void _showSettingPage() {
    var _passContl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18.0.r,
                right: 18.0.r,
                top: 18.0.r,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18.0.r,
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Settings",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 10),
                      _buildPageStylePicker(),
                      ExpansionTile(
                        title: Text(
                          'Change password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _passContl,
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (_passContl.text.length < 5) {
                                      Fluttertoast.showToast(
                                        msg: "Invalid new password",
                                      );
                                      return;
                                    }
                                    journalService.updatePassword(
                                      _passContl.text,
                                    );
                                    Fluttertoast.showToast(
                                      msg: "Password updated",
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: Text("Update"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Swatches of the preset paper/ink pairs; picking one restyles the diary
  /// straight away.
  Widget _buildPageStylePicker() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Page colour',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          ValueListenableBuilder<JournalPageStyle>(
            valueListenable: journalService.pageStyle,
            builder: (context, current, _) => Wrap(
              spacing: 14.w,
              runSpacing: 14.h,
              children: [
                for (var style in JournalPageStyle.presets)
                  _PageStyleSwatch(
                    style: style,
                    selected: style.id == current.id,
                    onTap: () => journalService.setPageStyle(style),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return JournalStyled(
      builder: (context, style) => _buildBook(context, style),
    );
  }

  Widget _buildBook(BuildContext context, JournalPageStyle style) {
    return PopScope(
      // Back from the index closes the book onto its cover first.
      canPop: _page == _coverPage,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _pager.animateToPage(_coverPage);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _page == _coverPage
            ? SystemUiOverlayStyle.light
            : JournalTheme.overlayFor(style),
        child: Scaffold(
          backgroundColor: JournalTheme.desk,
          body: BookPager(
            controller: _pager,
            itemCount: 2,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              if (index == _coverPage) {
                return JournalCover(
                  entryCount: _entries.length,
                  firstEntryDate: _entries.firstOrNull?.dateOfJournal,
                  lastEntryDate: _entries.lastOrNull?.dateOfJournal,
                  onOpen: () => _pager.animateToPage(_indexPage),
                  onClose: () => Navigator.pop(context),
                );
              }
              return JournalIndex(
                entries: _entries,
                onEntryTap: _openEntry,
                onAddEntry: _addNewEntry,
                onOpenToday: _openToday,
                onSettings: _showSettingPage,
                onBack: () => _pager.animateToPage(_coverPage),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// A miniature page showing a preset's paper with "Aa" in its ink.
class _PageStyleSwatch extends StatelessWidget {
  final JournalPageStyle style;
  final bool selected;
  final VoidCallback onTap;

  const _PageStyleSwatch({
    required this.style,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 58.w,
            height: 76.h,
            decoration: BoxDecoration(
              color: style.paper,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: selected ? PRIMARY : BORDER_PRIMARY,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Aa',
                        style: JournalTheme.serif(fontSize: 20.sp, color: style.ink),
                      ),
                      SizedBox(height: 6.h),
                      for (var width in [30.0, 24.0])
                        Container(
                          width: width.w,
                          height: 1.5,
                          margin: EdgeInsets.only(bottom: 4.h),
                          color: style.inkFaded.withValues(alpha: 0.6),
                        ),
                    ],
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(Icons.check_circle, size: 16, color: PRIMARY),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            style.name,
            style: TextStyle(
              fontSize: 12.sp,
              color: TEXT_PRIMARY,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
