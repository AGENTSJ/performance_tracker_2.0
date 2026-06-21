import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:performance_tracker/constants.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/routine.model.dart';

class AddVolumeDialog extends StatefulWidget {
  const AddVolumeDialog({super.key});

  @override
  State<AddVolumeDialog> createState() => _AddVolumeDialogState();
}

class _AddVolumeDialogState extends State<AddVolumeDialog> {
  final volController = TextEditingController();

  String? selectedMuscle = TRAINABLE_MUSCLES[0];

  @override
  void dispose() {
    volController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: TEXT_SECONDARY,
    );
    return Dialog(
      backgroundColor: SURFACE2,
      insetPadding: EdgeInsets.symmetric(horizontal: 28.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: PRIMARY.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    FontAwesomeIcons.dumbbell,
                    size: 16.sp,
                    color: PRIMARY,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Volume',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w700,
                          color: TEXT_PRIMARY,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Log sets for a muscle group',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: TEXT_SECONDARY,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
            // Muscle group field
            Text('Muscle group', style: labelStyle),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: SURFACE,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: BORDER_PRIMARY),
              ),
              child: DropdownButton2<String>(
                isExpanded: true,
                isDense: true,
                value: selectedMuscle,
                hint: Text(
                  'Select an option',
                  style: TextStyle(color: TEXT_SECONDARY),
                ),
                items: TRAINABLE_MUSCLES.map((String muscle) {
                  return DropdownMenuItem<String>(
                    value: muscle,
                    child: Text(
                      muscle,
                      style: TextStyle(fontSize: 14.sp, color: TEXT_PRIMARY),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMuscle = newValue;
                  });
                },
                buttonStyleData: ButtonStyleData(
                  height: 48.h,
                  padding: EdgeInsets.zero,
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(
                    FontAwesomeIcons.chevronDown,
                    size: 12.sp,
                    color: TEXT_SECONDARY,
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 280.h,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: SURFACE2,
                  ),
                ),
                underline: const SizedBox.shrink(),
                menuItemStyleData: MenuItemStyleData(
                  height: 44.h,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Volume field
            Text('Volume (sets)', style: labelStyle),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: SURFACE,
                border: Border.all(color: BORDER_PRIMARY),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: TextField(
                controller: volController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: TEXT_PRIMARY, fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: 'e.g. 1',
                  hintStyle: TextStyle(color: TEXT_SECONDARY),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: BORDER_PRIMARY),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: TEXT_SECONDARY,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final vol = WorkoutVolume(
                        muscleName: selectedMuscle ?? '',
                        volume: double.tryParse(volController.text) ?? 0,
                      );
                      Navigator.of(context).pop(vol);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
