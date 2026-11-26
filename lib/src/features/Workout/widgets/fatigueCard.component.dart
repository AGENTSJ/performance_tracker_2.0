import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Workout/models/fatigue.model.dart';
import 'package:performance_tracker/core/services/common.service.dart';
import 'package:performance_tracker/src/features/Workout/services/fatigue.service.dart';

/// Shows the muscle fatigue accumulated today plus a short history of past
/// training sessions. Reads straight from [FatigueService].
class FatigueCard extends StatefulWidget {
  const FatigueCard({super.key});

  @override
  State<FatigueCard> createState() => _FatigueCardState();
}

class _FatigueCardState extends State<FatigueCard> {
  final _fatigueService = locator<FatigueService>();
  final _commonService = locator<CommonService>();

  late Map<String, double> _today;
  late List<DailyFatigue> _past;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _today = _fatigueService.getDailyFatigue();
    _past = _fatigueService.getPastFatigueDays(limit: 5);
  }

  double _total(Map<String, double> map) =>
      map.values.fold(0.0, (sum, v) => sum + v);

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  /// Green (fresh) -> coral (heavily fatigued) based on intensity fraction.
  Color _intensityColor(double frac) =>
      Color.lerp(PRIMARY, ACCENT, frac.clamp(0.0, 1.0)) ?? PRIMARY;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SURFACE2,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel("Today"),
                SizedBox(height: 10.h),
                _todaySection(),
                SizedBox(height: 18.h),
                _sectionLabel("Past sessions"),
                SizedBox(height: 10.h),
                _pastSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    final total = _total(_today);
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: BORDER_SECONDARY)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.fireFlameCurved, size: 14.sp, color: ACCENT),
                SizedBox(width: 10.w),
                Text(
                  "Fatigue",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                  ),
                ),
              ],
            ),
            Text(
              "Today's load: ${_fmt(total)}",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: TEXT_SECONDARY,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
      color: TEXT_PRIMARY,
    ),
  );

  Widget _todaySection() {
    if (_today.isEmpty) {
      return _emptyHint("No fatigue logged yet today");
    }
    final entries = _today.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final max = entries.first.value;
    return Column(
      children: [
        for (final e in entries) ...[
          _muscleBar(e.key, e.value, max),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }

  Widget _muscleBar(String muscle, double value, double max) {
    final frac = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            muscle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.sp, color: TEXT_SECONDARY),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Stack(
              children: [
                Container(height: 10.h, color: SURFACE),
                FractionallySizedBox(
                  widthFactor: frac == 0 ? 0.02 : frac,
                  child: Container(
                    height: 10.h,
                    color: _intensityColor(frac),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 32.w,
          child: Text(
            _fmt(value),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: TEXT_PRIMARY,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pastSection() {
    if (_past.isEmpty) {
      return _emptyHint("No past sessions recorded");
    }
    final maxTotal = _past
        .map((d) => _total(d.muscleFatigue))
        .fold(0.0, (m, v) => v > m ? v : m);
    return Column(
      children: [
        for (final day in _past) ...[
          _pastRow(day, maxTotal),
          SizedBox(height: 10.h),
        ],
      ],
    );
  }

  Widget _pastRow(DailyFatigue day, double maxTotal) {
    final total = _total(day.muscleFatigue);
    final frac = maxTotal <= 0 ? 0.0 : (total / maxTotal).clamp(0.0, 1.0);
    final date = day.date;
    // Most-fatigued muscle that day, for a quick glance.
    final top = day.muscleFatigue.entries.isEmpty
        ? null
        : (day.muscleFatigue.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _commonService.getDateString(date),
                style: TextStyle(fontSize: 12.sp, color: TEXT_PRIMARY),
              ),
              if (top != null)
                Text(
                  "Most worked: $top",
                  style: TextStyle(fontSize: 10.sp, color: TEXT_TERTIARY),
                ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 90.w,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Stack(
              children: [
                Container(height: 8.h, color: SURFACE),
                FractionallySizedBox(
                  widthFactor: frac == 0 ? 0.02 : frac,
                  child: Container(
                    height: 8.h,
                    color: _intensityColor(frac),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        SizedBox(
          width: 32.w,
          child: Text(
            _fmt(total),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: TEXT_PRIMARY,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyHint(String text) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Text(
      text,
      style: TextStyle(fontSize: 12.sp, color: TEXT_TERTIARY),
    ),
  );
}
