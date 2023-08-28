import 'package:flutter/material.dart';
import 'package:myflutterproject/Setting/Body/CalendarProvider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now(); // 현재 날짜
  DateTime? _selectedDay; // 선택한 날짜

  @override
  Widget build(BuildContext context) {
    var calendarMemo = Provider.of<CalendarMemo>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[300],
        title: Text('Calendar'),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) async {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          final controller =
              TextEditingController(text: calendarMemo.getMemo(_selectedDay!));
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('[ 메모 ]'),
              content: TextField(
                controller: controller,
                onChanged: (value) {
                  calendarMemo.addOrUpdateMemo(_selectedDay!, value);
                },
              ),
            ),
          );
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
