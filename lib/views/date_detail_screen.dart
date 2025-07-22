import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';

class DateDetailScreen extends StatelessWidget {
  final int date;
  final String weekday;
  final List<ScheduleEntry> sampleSchedule;

  DateDetailScreen({required this.date, required this.weekday , required this.sampleSchedule});


List<ScheduleEntry> getTodayList(List<ScheduleEntry> entries, String weekday , int date) {
  return entries
      .where((i) => i.weekday == weekday && (i.continuous || i.day == date))
      .toList();
}

  @override
  Widget build(BuildContext context) {
    final todayList = getTodayList(sampleSchedule, weekday, date);
    return Scaffold(
      appBar: AppBar(title: Text('$date日 ($weekday) のシフト',
        style: TextStyle(fontSize: 30), // ← タイトルのフォントサイズ大きく
        )),
      body: ListView.builder( //縦スクロール
        itemCount: todayList.length,
        itemBuilder: (context, index) {
          final item = todayList[index];
          return ListTile(
            title: Text(item.timeshift!,
            style: TextStyle(fontSize: 25), // ← タイトルのフォントサイズ大きく
            ),
            subtitle: Text('${item.grade}  ${item.studentName}',
            style: TextStyle(fontSize: 25), // ← タイトルのフォントサイズ大きく
            ),
          );
        },
      ),
    );
  }
}