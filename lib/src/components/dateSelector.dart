import 'package:flutter/material.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  const DateSelector({super.key ,required this.selectedDate,required this.onDateChanged});
  @override
  State<StatefulWidget> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  final int WINDOW_LIMIT = 30;
  List<DateTime> dates = [];
  
  @override
  void initState() {
    super.initState();
    _getPreviousDays(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color.fromARGB(169, 56, 56, 56),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [...dates.map((date) => DateCube(date: date,onDateChanged: (value) {
                widget.onDateChanged(value);
              },))],
            ),
          ),
          Expanded(child: GestureDetector(
            onTap: (){widget.onDateChanged(widget.selectedDate);},
          ))
        ],
      ),
    );
  }

  _getPreviousDays(DateTime date) {
    var year = date.year;
    var month = date.month;
    var day = date.day;
    var currentDate = DateTime(year, month, day);

    for (var i = 0; i <= WINDOW_LIMIT; i++) {
      var tempDate = currentDate.subtract(Duration(days: (WINDOW_LIMIT - i)));
      dates.add(tempDate);
    }
  }
}

class DateCube extends StatefulWidget
{
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;
  @override
  State<StatefulWidget> createState()=> _DateCubeState();
  const DateCube({required this.date,required this.onDateChanged});
}

class _DateCubeState extends State<DateCube>
{
  var selected = false; 
  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: () {
        widget.onDateChanged(widget.date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected? const Color.fromARGB(255, 220, 220, 220): CONT_BACKGROUND,
        ),
        width: 50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(widget.date.day.toString(),style: TextStyle(fontWeight: FontWeight.w600),),
              SizedBox(height: 10,),
              Text(Weekday.values[widget.date.weekday-1].name.substring(0,2),style: TextStyle(fontWeight: FontWeight.w500),),
            ],
          ),
        ),
      ),
    );
  }
}