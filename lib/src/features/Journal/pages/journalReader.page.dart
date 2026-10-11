import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performance_tracker/src/features/Journal/models/journalBook.model.dart';
import 'package:performance_tracker/src/features/Journal/models/journalPageStyle.model.dart';
import 'package:performance_tracker/src/features/Journal/widgets/bookPager.dart';
import 'package:performance_tracker/src/features/Journal/widgets/journalLeaf.dart';
import 'package:performance_tracker/src/features/Journal/widgets/journalTheme.dart';

/// Reads the diary one entry per page. Pages are in book order (oldest first),
/// so swiping left-to-right turns back to the next entry down the index
/// (older), and right-to-left turns forward to the newer one.
class JournalReaderPage extends StatefulWidget {
  final List<Journal> entries;
  final int initialIndex;
  final bool startEditing;

  const JournalReaderPage({
    super.key,
    required this.entries,
    required this.initialIndex,
    this.startEditing = false,
  });

  static Route<void> route({
    required List<Journal> entries,
    required int initialIndex,
    bool startEditing = false,
  }) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) => JournalReaderPage(
        entries: entries,
        initialIndex: initialIndex,
        startEditing: startEditing,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<JournalReaderPage> createState() => _JournalReaderPageState();
}

class _JournalReaderPageState extends State<JournalReaderPage> {
  late final List<Journal> _entries = [...widget.entries];
  late bool _editing = widget.startEditing;
  late Journal? _autoEditEntry = widget.startEditing
      ? widget.entries[widget.initialIndex]
      : null;

  void _onEditingChanged(bool editing) {
    setState(() {
      _editing = editing;
      if (!editing) {
        _autoEditEntry = null;
      }
    });
  }

  void _onDeleted(Journal entry) {
    setState(() {
      _entries.remove(entry);
      _editing = false;
      _autoEditEntry = null;
    });
    if (_entries.isEmpty) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return JournalStyled(
      builder: (context, style) => _buildReader(context, style),
    );
  }

  Widget _buildReader(BuildContext context, JournalPageStyle style) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: JournalTheme.overlayFor(style),
      child: Scaffold(
        backgroundColor: JournalTheme.desk,
        body: BookPager(
          itemCount: _entries.length,
          initialPage: widget.initialIndex,
          swipeEnabled: !_editing,
          itemBuilder: (context, index) {
            var entry = _entries[index];
            return JournalLeaf(
              key: ObjectKey(entry),
              journal: entry,
              pageNumber: index + 1,
              startEditing: identical(entry, _autoEditEntry),
              onEditingChanged: _onEditingChanged,
              onDeleted: () => _onDeleted(entry),
              onBackToIndex: () => Navigator.pop(context),
            );
          },
        ),
      ),
    );
  }
}
