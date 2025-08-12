import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:performance_tracker/DI.dart';
import 'package:performance_tracker/models/food.model.dart';
import 'package:performance_tracker/services/common.service.dart';

class microNutrientList extends StatelessWidget {
  microNutrientList({
    super.key,
    required this.totalConsumed,
    required this.allowScroll,
  });

  final Map<String, MeasuredUnit?> totalConsumed;
  final bool allowScroll;
  final CommonService _commonService = locator<CommonService>();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: allowScroll ? AlwaysScrollableScrollPhysics() :NeverScrollableScrollPhysics(),
      children: totalConsumed.entries.map((entry) {
        final MeasuredUnit? microNutrient = entry.value;
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: 10.h,
            horizontal: 14.w
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (){},
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                children: [
    
                  Row(
                    children: [
                      Icon(Icons.circle,color: Colors.grey,size: 14.w,),
                      SizedBox(width: 10.w,),
                      SizedBox(
                        width: 110.w,
                        child: Text(
                          entry.key,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 40.w,
                    child: Text(
                      microNutrient != null
                          ? '${_commonService.getPercentage(MicroNutrients.microRDA[entry.key]!.value, microNutrient.value).round()}%'
                          : '-',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          microNutrient != null
                              ? '${microNutrient.value.toStringAsFixed(1)} '
                              : '0',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(microNutrient?.unit ?? 'mg',style: TextStyle(color: const Color.fromARGB(255, 131, 131, 131)),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
