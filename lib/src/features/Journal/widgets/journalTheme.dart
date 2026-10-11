import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/src/features/Journal/models/journalPageStyle.model.dart';
import 'package:performance_tracker/src/features/Journal/services/journal.service.dart';

class JournalTheme {
  /// Background image for the diary cover.
  static const String coverImage = 'assets/JournalCoverPage.png';

  static const Color desk = Color(0xFF04100D);

  // Cover palette, picked from the cover artwork.
  static const Color coverNight = Color(0xFF03110E);
  static const Color coverNightLight = Color(0xFF0A2A23);
  static const Color coverAccent = Color(0xFF6FE3C1);
  static const Color ribbonDark = Color(0xFF0B4D3F);
  static const Color ribbonLight = Color(0xFF168066);

  /// Serif text. Without a [color] it takes the surrounding text colour,
  /// which on a [JournalPaper] is the page style's ink.
  static TextStyle serif({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontFamily: 'serif',
      fontFamilyFallback: const ['Georgia', 'Times New Roman'],
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  /// The page style in effect for [context]'s part of the diary.
  static JournalPageStyle pageStyleOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_JournalStyleScope>()
            ?.style ??
        JournalPageStyle.ivory;
  }

  /// Status bar icons that stay visible on [style]'s paper.
  static SystemUiOverlayStyle overlayFor(JournalPageStyle style) {
    return style.isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
  }
}

/// Makes the user's chosen page style available below it and rebuilds
/// when that choice changes.
class JournalStyled extends StatelessWidget {
  final Widget Function(BuildContext context, JournalPageStyle style) builder;

  const JournalStyled({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<JournalPageStyle>(
      valueListenable: locator<JournalService>().pageStyle,
      builder: (context, style, _) => _JournalStyleScope(
        style: style,
        child: Builder(builder: (context) => builder(context, style)),
      ),
    );
  }
}

class _JournalStyleScope extends InheritedWidget {
  final JournalPageStyle style;

  const _JournalStyleScope({required this.style, required super.child});

  @override
  bool updateShouldNotify(_JournalStyleScope oldWidget) {
    return oldWidget.style != style;
  }
}

const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "11 October 2026"
String journalLongDate(DateTime date) {
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// "Sunday"
String journalWeekday(DateTime date) => _weekdays[date.weekday - 1];

/// "Sun, 11 Oct"
String journalShortDay(DateTime date) {
  return '${_weekdays[date.weekday - 1].substring(0, 3)}, '
      '${date.day} ${_months[date.month - 1].substring(0, 3)}';
}

/// A sheet of diary paper with a soft shadow along the spine.
class JournalPaper extends StatelessWidget {
  final Widget child;

  const JournalPaper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    var style = JournalTheme.pageStyleOf(context);
    return ColoredBox(
      color: style.paper,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: style.ink),
        child: _buildSheet(),
      ),
    );
  }

  Widget _buildSheet() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 28,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.black.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Thin rule with a fleuron in the middle, used as a section divider.
class JournalOrnament extends StatelessWidget {
  const JournalOrnament({super.key});

  @override
  Widget build(BuildContext context) {
    var style = JournalTheme.pageStyleOf(context);
    return Row(
      children: [
        Expanded(child: Divider(color: style.rule, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '❦',
            style: JournalTheme.serif(fontSize: 16, color: style.inkFaded),
          ),
        ),
        Expanded(child: Divider(color: style.rule, thickness: 1)),
      ],
    );
  }
}
