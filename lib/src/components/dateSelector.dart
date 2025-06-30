import 'package:flutter/material.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:performance_tracker/models/day.model.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });
  @override
  State<StatefulWidget> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  final int BACK_WINDOW_LIMIT = 30;
  final int FORWARD_WINDOW_LIMIT = 7;
  List<DateTime> dates = [];

  @override
  void initState() {
    super.initState();
    _getPreviousDays(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...dates.map(
            (date) => DateCube(
              date: date,
              selectedDate: widget.selectedDate,
              onDateChanged: (value) {
                widget.onDateChanged(value);
                setState(() {});  
              },
            ),
          ),
        ],
      ),
    );
  }

  _getPreviousDays(DateTime date) {
    var year = date.year;
    var month = date.month;
    var day = date.day;
    var currentDate = DateTime(year, month, day);

    for (var i = 0; i <= BACK_WINDOW_LIMIT; i++) {
      var tempDate = currentDate.subtract(
        Duration(days: (BACK_WINDOW_LIMIT - i)),
      );
      dates.add(tempDate);
    }
    for (var i = 0; i <= FORWARD_WINDOW_LIMIT; i++) {
      var tempDate = currentDate.add(Duration(days: (i + 1)));
      dates.add(tempDate);
    }
  }
}

class DateCube extends StatefulWidget {
  final DateTime date;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  @override
  State<StatefulWidget> createState() => _DateCubeState();
  const DateCube({
    super.key,
    required this.date,
    required this.onDateChanged,
    required this.selectedDate,
  });
}

class _DateCubeState extends State<DateCube> {
  var selected = false;
  @override
  void initState() {
    if (widget.selectedDate.year == widget.date.year &&
        widget.selectedDate.month == widget.date.month &&
        widget.selectedDate.day == widget.date.day) {
      selected = true;
    } else {
      selected = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onDateChanged(widget.date);
      },
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromARGB(255, 220, 220, 220)
              : CONT_BACKGROUND,
        ),
        width: 50,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                widget.date.day.toString(),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Text(
                Weekday.values[widget.date.weekday - 1].name.substring(0, 2),
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
