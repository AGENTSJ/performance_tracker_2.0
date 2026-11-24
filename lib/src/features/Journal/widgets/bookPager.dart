import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lets a parent flip pages of a [BookPager] programmatically.
class BookPagerController {
  _BookPagerState? _state;

  int get page => _state?.currentPage ?? 0;

  Future<void> animateToPage(int page) {
    return _state?._animateTo(page.toDouble()) ?? Future.value();
  }

  Future<void> nextPage() => animateToPage(page + 1);

  Future<void> previousPage() => animateToPage(page - 1);
}

/// A horizontal pager that turns pages like a book.
///
/// Swiping right-to-left lifts the current page off its left edge (the spine)
/// and reveals the next page underneath; swiping left-to-right brings the
/// previous page back down on top.
class BookPager extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final int initialPage;
  final bool swipeEnabled;
  final ValueChanged<int>? onPageChanged;
  final BookPagerController? controller;

  const BookPager({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.initialPage = 0,
    this.swipeEnabled = true,
    this.onPageChanged,
    this.controller,
  });

  @override
  State<BookPager> createState() => _BookPagerState();
}

class _BookPagerState extends State<BookPager>
    with SingleTickerProviderStateMixin {
  static const double _flingVelocity = 0.6; // pages per second
  static const double _perspective = 0.0008;

  // Continuous page position: 2.3 means page 2 is 30% turned towards page 3.
  late final AnimationController _position;
  late int _reportedPage;
  double _width = 1;

  int get currentPage => _clamp(_position.value).round();

  double get _maxPosition => math.max(0, widget.itemCount - 1).toDouble();

  double _clamp(double value) => value.clamp(0.0, _maxPosition).toDouble();

  @override
  void initState() {
    super.initState();
    _reportedPage = widget.initialPage;
    _position = AnimationController.unbounded(
      vsync: this,
      value: widget.initialPage.toDouble(),
    )..addListener(_onTick);
    widget.controller?._state = this;
  }

  @override
  void didUpdateWidget(covariant BookPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
    // Pages were removed: settle back onto the last page after this frame.
    if (_position.value > _maxPosition) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _position.value = _clamp(_position.value);
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) {
      widget.controller?._state = null;
    }
    _position.dispose();
    super.dispose();
  }

  void _onTick() {
    var value = _position.value;
    if (value != value.roundToDouble()) {
      return;
    }
    var page = value.round();
    if (page != _reportedPage) {
      _reportedPage = page;
      widget.onPageChanged?.call(page);
    }
  }

  Future<void> _animateTo(double target) {
    target = _clamp(target);
    var distance = (target - _position.value).abs();
    if (distance == 0) {
      _onTick();
      return Future.value();
    }
    var ms = 200 + (320 * math.min(distance, 1.0)).round();
    return _position.animateTo(
      target,
      duration: Duration(milliseconds: ms),
      curve: Curves.easeOutCubic,
    );
  }

  void _onDragStart(DragStartDetails details) {
    _position.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _position.value = _clamp(
      _position.value - (details.primaryDelta ?? 0) / _width,
    );
  }

  void _onDragEnd(DragEndDetails details) {
    var velocity = -(details.primaryVelocity ?? 0) / _width;
    var position = _position.value;
    double target;
    if (velocity > _flingVelocity) {
      target = position.floorToDouble() + 1;
    } else if (velocity < -_flingVelocity) {
      target = position.ceilToDouble() - 1;
    } else {
      target = position.roundToDouble();
    }
    _animateTo(target);
  }

  @override
  Widget build(BuildContext context) {
    var swipeEnabled = widget.swipeEnabled && widget.itemCount > 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = math.max(1, constraints.maxWidth);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: swipeEnabled ? _onDragStart : null,
          onHorizontalDragUpdate: swipeEnabled ? _onDragUpdate : null,
          onHorizontalDragEnd: swipeEnabled ? _onDragEnd : null,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _position,
              builder: (context, _) => _buildPages(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPages(BuildContext context) {
    if (widget.itemCount == 0) {
      return const SizedBox.shrink();
    }
    var position = _clamp(_position.value);
    var index = position.floor();
    var turn = position - index;

    var pages = <Widget>[];
    if (turn > 0 && index + 1 < widget.itemCount) {
      // The page being revealed sits flat underneath, in the turning page's shadow.
      pages.add(_buildPage(context, index + 1, angle: 0, shade: (1 - turn) * 0.35));
    }
    pages.add(
      _buildPage(context, index, angle: turn * math.pi / 2, shade: turn * 0.3),
    );
    return Stack(fit: StackFit.expand, children: pages);
  }

  Widget _buildPage(
    BuildContext context,
    int index, {
    required double angle,
    required double shade,
  }) {
    // Every page keeps the same widget shape so its state survives moving
    // between the "turning" and "underneath" slots.
    return KeyedSubtree(
      key: ValueKey(index),
      child: Transform(
        alignment: Alignment.centerLeft,
        transform: Matrix4.identity()
          ..setEntry(3, 2, _perspective)
          ..rotateY(angle),
        child: Stack(
          fit: StackFit.expand,
          children: [
            widget.itemBuilder(context, index),
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: shade * 0.5),
                      Colors.black.withValues(alpha: shade),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
