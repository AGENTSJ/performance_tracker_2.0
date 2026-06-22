import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';
import 'package:performance_tracker/services/common.service.dart';

class ProgressChart extends StatefulWidget {
  final WorkSet set;
  final bool isFatigueAdjusted;
  final Workout workout;
  const ProgressChart({
    super.key,
    required this.set,
    required this.workout,
    required this.isFatigueAdjusted,
  });
  @override
  State<StatefulWidget> createState() => ProgressChartState();
}

class ProgressChartState extends State<ProgressChart> {
  var commonService = locator<CommonService>();

  /// Horizontal space allocated per attempt. The plot grows wider than the
  /// viewport when there are many points, and the user scrolls through them
  /// while the Y-axis stays pinned.
  static const double _widthPerPoint = 46;
  static const double _yAxisWidth = 34;
  static const double _bottomReserved = 22;

  final ScrollController _scrollController = ScrollController();
  List<FlSpot> dataPoints = [];
  double _minY = 0;
  double _maxY = 10;
  double _yInterval = 1;

  @override
  void initState() {
    super.initState();
    _buildData();
    // Start at the most recent attempt (right edge).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _buildData() {
    dataPoints = [];
    for(var j = 0; j < 1000;j++)
    {
      final random = Random();
      final value = (random.nextInt(22 - 5 + 1) + 5).toDouble();
      dataPoints.add(FlSpot(j.toDouble(), value));
    }
    for (var i = 0; i < widget.set.history.length; i++) {
      final entry = widget.set.history[i];
      final raw = widget.isFatigueAdjusted
          ? widget.workout.getFatigueAdjustedReps(
              entry.fatigueContext,
              entry.value,
            )
          : entry.value.toDouble();
      // Guard against NaN/Infinity (e.g. fatigue adjustment divides by a
      // total volume of zero when no volumes are configured).
      final value = raw.isFinite ? raw : entry.value.toDouble();
      dataPoints.add(FlSpot(i.toDouble(), value));
    }
    _computeRange();
  }

  /// Derive the visible Y range from the actual data (plus the PR) so points
  /// never get clipped above/below the chart, with a little breathing room.
  void _computeRange() {
    if (dataPoints.isEmpty) {
      _minY = 0;
      _maxY = 10;
      _yInterval = 2;
      return;
    }
    var lo = dataPoints.first.y;
    var hi = dataPoints.first.y;
    for (final p in dataPoints) {
      lo = min(lo, p.y);
      hi = max(hi, p.y);
    }
    hi = max(hi, widget.set.pr.toDouble());

    final span = hi - lo;
    final pad = span == 0 ? max(hi.abs() * 0.2, 2) : span * 0.2;
    _minY = max(0, (lo - pad).floorToDouble());
    _maxY = (hi + pad).ceilToDouble();
    if (_maxY <= _minY) _maxY = _minY + 1;
    _yInterval = _niceInterval(_maxY - _minY);
  }

  /// Pick a "nice" rounded axis step for the given range.
  double _niceInterval(double range) {
    if (range <= 0) return 1;
    final raw = range / 4;
    if (raw <= 1) return 1;
    if (raw <= 2) return 2;
    if (raw <= 5) return 5;
    return (raw / 5).ceil() * 5;
  }

  @override
  Widget build(BuildContext context) {
    final count = dataPoints.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pinned Y-axis: shares the exact same Y range / bottom inset as the
        // scrolling plot so the rep labels line up with the gridlines.
        SizedBox(
          width: _yAxisWidth,
          child: LineChart(_axisData()),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final plotWidth = max(
                constraints.maxWidth,
                _widthPerPoint * count,
              );
              return SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: plotWidth,
                  child: LineChart(_plotData()),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// The fixed left axis: only labels + a shared bottom inset, no data line.
  LineChartData _axisData() {
    return LineChartData(
      minX: 0,
      maxX: 1,
      minY: _minY,
      maxY: _maxY,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _yAxisWidth,
            interval: _yInterval,
            getTitlesWidget: (value, meta) {
              if (value == meta.max) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(color: TEXT_SECONDARY, fontSize: 10),
                ),
              );
            },
          ),
        ),
        // Reserve the same bottom space as the plot so both align vertically.
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: _bottomReserved),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: const [],
    );
  }

  /// The scrollable plot: the line, dots, gridlines and attempt labels.
  LineChartData _plotData() {
    final count = dataPoints.length;
    return LineChartData(
      minX: 0,
      maxX: max(0, count - 1).toDouble(),
      minY: _minY,
      maxY: _maxY,
      clipData: const FlClipData.all(),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          tooltipBorderRadius: BorderRadius.circular(8),
          tooltipBorder: BorderSide(color: BORDER_PRIMARY),
          getTooltipColor: (_) => SURFACE2,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final x = touchedSpot.x.toInt();
              final date = (x >= 0 && x < widget.set.history.length)
                  ? commonService.getDateString(
                      widget.set.history[x].entryDate,
                    )
                  : null;
              final reps = widget.isFatigueAdjusted
                  ? touchedSpot.y.toStringAsFixed(1)
                  : touchedSpot.y.toStringAsFixed(0);
              return LineTooltipItem(
                '',
                const TextStyle(),
                children: [
                  if (date != null)
                    TextSpan(
                      text: '$date\n',
                      style: TextStyle(
                        color: TEXT_SECONDARY,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  TextSpan(
                    text: '$reps reps',
                    style: TextStyle(
                      color: TEXT_PRIMARY,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _yInterval,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: BORDER_SECONDARY, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _bottomReserved,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${value.toInt() + 1}',
                  style: TextStyle(color: TEXT_SECONDARY, fontSize: 10),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: dataPoints,
          isCurved: true,
          curveSmoothness: 0.25,
          preventCurveOverShooting: true,
          barWidth: 2.5,
          color: PRIMARY,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 3,
              color: SURFACE2,
              strokeWidth: 2,
              strokeColor: PRIMARY,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PRIMARY.withValues(alpha: 0.25),
                PRIMARY.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
