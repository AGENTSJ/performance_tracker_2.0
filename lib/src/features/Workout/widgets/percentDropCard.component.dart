import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/src/features/Workout/models/routine.model.dart';

enum _InputMode { percentage, reps }

/// Shows how much capacity this exercise loses after one hard set (the
/// workout's percentDrop, 0 -> 100) and lets the user set it, either directly
/// as a percentage or from two 0 RIR sets: a fresh one and the next one.
class PercentDropCard extends StatefulWidget {
  final Workout workout;

  /// Called with the new percent drop, or null to fall back to the default.
  final ValueChanged<double?> onChanged;

  const PercentDropCard({
    super.key,
    required this.workout,
    required this.onChanged,
  });

  @override
  State<PercentDropCard> createState() => _PercentDropCardState();
}

class _PercentDropCardState extends State<PercentDropCard> {
  final _percentController = TextEditingController();
  final _freshRepsController = TextEditingController();
  final _nextRepsController = TextEditingController();
  _InputMode _mode = _InputMode.percentage;

  @override
  void initState() {
    super.initState();
    _percentController.addListener(_refresh);
    _freshRepsController.addListener(_refresh);
    _nextRepsController.addListener(_refresh);
  }

  @override
  void dispose() {
    _percentController.dispose();
    _freshRepsController.dispose();
    _nextRepsController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  bool get _isCustom => widget.workout.percentDrop != null;

  double get _currentDrop =>
      widget.workout.percentDrop ?? PERCENTAGE_DROP_PER_SET;

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  /// The percent drop the current input describes, or null when it's not
  /// usable yet. [_inputError] explains why.
  double? get _inputDrop {
    if (_mode == _InputMode.percentage) {
      final value = double.tryParse(_percentController.text);
      if (value == null || value < 0 || value >= 100) return null;
      return value;
    }
    final fresh = int.tryParse(_freshRepsController.text);
    final next = int.tryParse(_nextRepsController.text);
    if (fresh == null || next == null) return null;
    if (fresh <= 0 || next <= 0 || next > fresh) return null;
    return (1 - next / fresh) * 100;
  }

  String? get _inputError {
    if (_mode == _InputMode.percentage) {
      if (_percentController.text.isEmpty) return null;
      final value = double.tryParse(_percentController.text);
      if (value == null) return "Enter a number";
      if (value >= 100) return "Must be below 100%";
      return null;
    }
    if (_freshRepsController.text.isEmpty ||
        _nextRepsController.text.isEmpty) {
      return null;
    }
    final fresh = int.tryParse(_freshRepsController.text);
    final next = int.tryParse(_nextRepsController.text);
    if (fresh == null || next == null) return "Enter whole reps";
    if (fresh <= 0) return "Fresh set needs at least 1 rep";
    if (next <= 0) return "Next set needs at least 1 rep";
    if (next > fresh) return "Next set can't beat the fresh set";
    return null;
  }

  void _save() {
    final drop = _inputDrop;
    if (drop == null) return;
    widget.onChanged(drop);
    _percentController.clear();
    _freshRepsController.clear();
    _nextRepsController.clear();
    FocusScope.of(context).unfocus();
  }

  void _resetToDefault() {
    widget.onChanged(null);
    FocusScope.of(context).unfocus();
  }

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
                Text(
                  "Capacity lost after one hard set of this exercise. "
                  "Used to work out fatigue-adjusted reps.",
                  style: TextStyle(fontSize: 12.sp, color: TEXT_SECONDARY),
                ),
                SizedBox(height: 14.h),
                _modeToggle(),
                SizedBox(height: 14.h),
                if (_mode == _InputMode.percentage)
                  _percentInput()
                else
                  _repsInput(),
                SizedBox(height: 8.h),
                _feedback(),
                SizedBox(height: 14.h),
                _actions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: BORDER_SECONDARY)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.r),
        child: Row(
          children: [
            Icon(FontAwesomeIcons.fireFlameCurved, size: 14.sp, color: ACCENT),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                "Drop per set",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15.sp),
              ),
            ),
            if (!_isCustom) ...[
              Text(
                "default",
                style: TextStyle(fontSize: 11.sp, color: TEXT_TERTIARY),
              ),
              SizedBox(width: 6.w),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: ACCENT.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                "${_fmt(_currentDrop)}%",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: ACCENT,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeToggle() {
    Widget option(_InputMode mode, String label) {
      final selected = _mode == mode;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _mode = mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: selected ? PRIMARY.withValues(alpha: 0.12) : null,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: selected ? PRIMARY : Colors.transparent,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? PRIMARY : TEXT_SECONDARY,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: SURFACE,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: BORDER_PRIMARY),
      ),
      child: Row(
        children: [
          option(_InputMode.percentage, "Percentage"),
          SizedBox(width: 4.w),
          option(_InputMode.reps, "From reps"),
        ],
      ),
    );
  }

  Widget _percentInput() {
    return _field(
      label: "Drop after one set",
      controller: _percentController,
      hint: "e.g. ${_fmt(_currentDrop)}",
      suffix: "%",
      decimal: true,
    );
  }

  Widget _repsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _field(
                label: "Fresh set reps",
                controller: _freshRepsController,
                hint: "e.g. 10",
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _field(
                label: "Next set reps",
                controller: _nextRepsController,
                hint: "e.g. 8",
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          "Same weight, both to failure (0 RIR), with your usual rest in "
          "between. The first set should be your first of the day for these "
          "muscles.",
          style: TextStyle(fontSize: 11.sp, color: TEXT_TERTIARY),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? suffix,
    bool decimal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: TEXT_SECONDARY,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: SURFACE,
            border: Border.all(color: BORDER_PRIMARY),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            inputFormatters: [
              decimal
                  ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextStyle(color: TEXT_PRIMARY, fontSize: 15.sp),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: TEXT_SECONDARY),
              suffixText: suffix,
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Error for bad input, otherwise a preview of what will be saved.
  Widget _feedback() {
    final error = _inputError;
    if (error != null) {
      return Text(error, style: TextStyle(fontSize: 12.sp, color: ACCENT));
    }
    final drop = _inputDrop;
    if (drop == null) return const SizedBox.shrink();
    return Text(
      "New drop per set: ${_fmt(drop)}%",
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: PRIMARY,
      ),
    );
  }

  Widget _actions() {
    final canSave = _inputDrop != null;
    return Row(
      children: [
        if (_isCustom) ...[
          Expanded(
            child: TextButton(
              onPressed: _resetToDefault,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(color: BORDER_PRIMARY),
                ),
              ),
              child: Text(
                "Use default (${_fmt(PERCENTAGE_DROP_PER_SET)}%)",
                style: TextStyle(
                  color: TEXT_SECONDARY,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: canSave ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY,
              foregroundColor: Colors.white,
              disabledBackgroundColor: BORDER_PRIMARY,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              "Save",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
