import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.only(
            top: 3.0,
            bottom: 3.0,
            left: 8,
            right: 8,
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
                      Icon(Icons.circle,color: Colors.grey,size: 14,),
                      SizedBox(width: 10,),
                      SizedBox(
                        width: 110,
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
                    width: 40,
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
                    width: 100,
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
