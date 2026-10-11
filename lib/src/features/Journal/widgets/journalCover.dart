import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/src/features/Journal/widgets/journalTheme.dart';

/// Front cover of the diary. Tapping it or swiping right-to-left opens the book.
class JournalCover extends StatelessWidget {
  final int entryCount;
  final DateTime? firstEntryDate;
  final DateTime? lastEntryDate;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  const JournalCover({
    super.key,
    required this.entryCount,
    required this.firstEntryDate,
    required this.lastEntryDate,
    required this.onOpen,
    required this.onClose,
  });

  String get _subtitle {
    if (firstEntryDate == null || lastEntryDate == null) {
      return 'A fresh start';
    }
    var first = firstEntryDate!.year;
    var last = lastEntryDate!.year;
    return first == last ? '$first' : '$first — $last';
  }

  @override
  Widget build(BuildContext context) {
    const accent = JournalTheme.coverAccent;
    return GestureDetector(
      onTap: onOpen,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [JournalTheme.coverNight, JournalTheme.coverNightLight],
              ),
              image: DecorationImage(
                image: AssetImage(JournalTheme.coverImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Spine
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 26.w,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Bookmark ribbon
          Positioned(
            top: 0,
            right: 56.w,
            child: ClipPath(
              clipper: _RibbonClipper(),
              child: Container(
                width: 20.w,
                height: 110.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [JournalTheme.ribbonDark, JournalTheme.ribbonLight],
                  ),
                ),
              ),
            ),
          ),
          // Title sits above the emblem in the artwork...
          Align(
            alignment: const Alignment(0, -0.68),
            child: Text(
              'Journal',
              style: JournalTheme.serif(
                fontSize: 44.sp,
                fontStyle: FontStyle.italic,
                color: accent,
                letterSpacing: 1,
              ).copyWith(
                shadows: [
                  Shadow(
                    color: accent.withValues(alpha: 0.55),
                    blurRadius: 18,
                  ),
                ],
              ),
            ),
          ),
          // ...and the details below it, above the waves.
          Align(
            alignment: const Alignment(0, 0.17),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _subtitle.toUpperCase(),
                  style: JournalTheme.serif(
                    fontSize: 12.sp,
                    letterSpacing: 4,
                    color: accent.withValues(alpha: 0.85),
                  ),
                ),
                if (entryCount > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '$entryCount ${entryCount == 1 ? 'page' : 'pages'}',
                    style: JournalTheme.serif(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                      color: accent.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 48.h,
            child: const _SwipeHint(),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 24.w),
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  color: accent.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatefulWidget {
  const _SwipeHint();

  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var color = JournalTheme.coverAccent.withValues(alpha: 0.8);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.translate(
            offset: Offset(-10 * Curves.easeInOut.transform(_controller.value), 0),
            child: child,
          ),
          child: Icon(Icons.chevron_left, color: color),
        ),
        SizedBox(width: 4.w),
        Text(
          'Swipe to open',
          style: JournalTheme.serif(
            fontSize: 14.sp,
            fontStyle: FontStyle.italic,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 12)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
