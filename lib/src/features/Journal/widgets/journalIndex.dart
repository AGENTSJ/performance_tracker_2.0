import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Journal/models/journalBook.model.dart';
import 'package:performance_tracker/src/features/Journal/models/journalPageStyle.model.dart';
import 'package:performance_tracker/src/features/Journal/widgets/journalTheme.dart';

/// The diary's index page: years as chapters, each listing its entries by day
/// with the page number they sit on in the book.
class JournalIndex extends StatefulWidget {
  /// Entries in book order (oldest first); page number = position + 1.
  final List<Journal> entries;
  final ValueChanged<Journal> onEntryTap;
  final VoidCallback onAddEntry;
  final VoidCallback onOpenToday;
  final VoidCallback onSettings;
  final VoidCallback onBack;

  const JournalIndex({
    super.key,
    required this.entries,
    required this.onEntryTap,
    required this.onAddEntry,
    required this.onOpenToday,
    required this.onSettings,
    required this.onBack,
  });

  @override
  State<JournalIndex> createState() => _JournalIndexState();
}

class _JournalIndexState extends State<JournalIndex> {
  final Set<int> _openYears = {};

  @override
  void initState() {
    super.initState();
    if (widget.entries.isNotEmpty) {
      _openYears.add(widget.entries.last.dateOfJournal.year);
    }
  }

  void _toggleYear(int year) {
    setState(() {
      if (!_openYears.remove(year)) {
        _openYears.add(year);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var style = JournalTheme.pageStyleOf(context);
    var pageNumbers = Map<Journal, int>.identity();
    var byYear = <int, List<Journal>>{};
    for (var i = 0; i < widget.entries.length; i++) {
      var entry = widget.entries[i];
      pageNumbers[entry] = i + 1;
      byYear.putIfAbsent(entry.dateOfJournal.year, () => []).add(entry);
    }
    var years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return JournalPaper(
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.chevron_left),
                  color: style.inkFaded,
                  tooltip: 'Cover',
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onSettings,
                  icon: const Icon(Icons.settings_outlined),
                  color: style.inkFaded,
                  tooltip: 'Settings',
                ),
              ],
            ),
            Text(
              'Index',
              style: JournalTheme.serif(
                fontSize: 34.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 6.h),
            const JournalOrnament(),
            SizedBox(height: 8.h),
            Expanded(
              child: years.isEmpty
                  ? _buildEmpty(style)
                  : ListView(
                      padding: EdgeInsets.only(bottom: 16.h),
                      children: [
                        for (var year in years)
                          _YearChapter(
                            year: year,
                            entries: byYear[year]!.reversed.toList(),
                            pageNumbers: pageNumbers,
                            isOpen: _openYears.contains(year),
                            onToggle: () => _toggleYear(year),
                            onEntryTap: widget.onEntryTap,
                          ),
                      ],
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: OutlinedButton.icon(
                      onPressed: widget.onOpenToday,
                      icon: const Icon(Icons.today_outlined, size: 18),
                      label: Text(
                        'Today',
                        style: JournalTheme.serif(fontSize: 16.sp),
                      ),
                      style: _buttonStyle(style, filled: false),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 3,
                    child: OutlinedButton.icon(
                      onPressed: widget.onAddEntry,
                      icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                      label: Text(
                        'Previous',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: JournalTheme.serif(fontSize: 16.sp),
                      ),
                      style: _buttonStyle(style, filled: true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle(JournalPageStyle style, {required bool filled}) {
    return OutlinedButton.styleFrom(
      foregroundColor: filled ? style.paper : style.ink,
      backgroundColor: filled ? style.ink : Colors.transparent,
      side: BorderSide(color: style.ink),
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
    );
  }

  Widget _buildEmpty(JournalPageStyle style) {
    return Center(
      child: Text(
        'No pages yet.\nStart with today.',
        textAlign: TextAlign.center,
        style: JournalTheme.serif(
          fontSize: 16.sp,
          fontStyle: FontStyle.italic,
          color: style.inkFaded,
          height: 1.6,
        ),
      ),
    );
  }
}

class _YearChapter extends StatelessWidget {
  final int year;

  /// Newest first.
  final List<Journal> entries;
  final Map<Journal, int> pageNumbers;
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<Journal> onEntryTap;

  const _YearChapter({
    required this.year,
    required this.entries,
    required this.pageNumbers,
    required this.isOpen,
    required this.onToggle,
    required this.onEntryTap,
  });

  @override
  Widget build(BuildContext context) {
    var style = JournalTheme.pageStyleOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 32.w, right: 20.w),
          child: Column(
            children: [
              InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$year',
                        style: JournalTheme.serif(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Expanded(child: _DottedLeader()),
                      Text(
                        '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                        style: JournalTheme.serif(
                          fontSize: 13.sp,
                          fontStyle: FontStyle.italic,
                          color: style.inkFaded,
                        ),
                      ),
                      AnimatedRotation(
                        turns: isOpen ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(Icons.chevron_right, color: style.inkFaded),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: isOpen
                    ? Padding(
                        padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
                        child: Column(
                          children: [
                            for (var entry in entries)
                              _EntryLine(
                                entry: entry,
                                pageNumber: pageNumbers[entry]!,
                                onTap: () => onEntryTap(entry),
                              ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
        Divider(color: style.rule, height: 1),
      ],
    );
  }
}

class _EntryLine extends StatelessWidget {
  final Journal entry;
  final int pageNumber;
  final VoidCallback onTap;

  const _EntryLine({
    required this.entry,
    required this.pageNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var style = JournalTheme.pageStyleOf(context);
    var title = entry.title.trim();
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SizedBox(
            //   child: Text(
            //     journalShortDay(entry.dateOfJournal),
            //     style: JournalTheme.serif(
            //       fontSize: 13.sp,
            //       color: style.inkFaded,
            //     ),
            //   ),
            // ),
            Expanded(
              // flex: 3,
              child: SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? 'Untitled' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: JournalTheme.serif(
                        fontSize: 15.sp,
                        fontStyle: title.isEmpty ? FontStyle.italic : null,
                        color: title.isEmpty ? style.inkFaded : style.ink,
                      ),
                    ),
                    Text(
                      journalShortDay(entry.dateOfJournal),
                      style: JournalTheme.serif(
                        fontSize: 10.sp,
                        color: style.inkFaded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // const Expanded(child: _DottedLeader()),
            Text('$pageNumber', style: JournalTheme.serif(fontSize: 15.sp)),
          ],
        ),
      ),
    );
  }
}

/// The row of dots that leads from an index heading to its page number.
class _DottedLeader extends StatelessWidget {
  const _DottedLeader();

  @override
  Widget build(BuildContext context) {
    var style = JournalTheme.pageStyleOf(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: CustomPaint(
        size: const Size(double.infinity, 14),
        painter: _DotsPainter(style.inkFaded),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;

  _DotsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color.withValues(alpha: 0.6);
    for (double x = 1; x < size.width; x += 6) {
      canvas.drawCircle(Offset(x, size.height - 3), 0.9, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
