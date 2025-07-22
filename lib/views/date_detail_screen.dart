import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';

class DateDetailScreen extends StatelessWidget {
  final int date;
  final String weekday;

  DateDetailScreen({required this.date, required this.weekday});

  final List<ScheduleEntry> sampleSchedule = [
  // 毎週担当
  ScheduleEntry(
    studentName: "佐藤花子",
    weekday: "月", // 毎週月曜
    timeshift: "A",
    continuous: true,
    day: 0, // 毎週の場合は day は無視される
    ownerId: "001",
  ),
  ScheduleEntry(
    studentName: "鈴木一郎",
    weekday: "水",
    timeshift: "B",
    continuous: true,
    day: 0,
    ownerId: "001",
  ),
  ScheduleEntry(
    studentName: "高橋美咲",
    weekday: "金",
    timeshift: "A",
    continuous: true,
    day: 0,
    ownerId: "001",
  ),

  // 単発シフト
  ScheduleEntry(
    studentName: "田中太郎",
    weekday: "月", // 2025年7月7日が日曜だった場合
    timeshift: "B",
    continuous: false,
    day: 7, // 7月7日
    ownerId: "001",
  ),
  ScheduleEntry(
    studentName: "小林優子",
    weekday: "水",
    timeshift: "A",
    continuous: false,
    day: 16, // 7月16日
    ownerId: "001",
  ),
  ScheduleEntry(
    studentName: "佐々木健",
    weekday: "金",
    timeshift: "B",
    continuous: false,
    day: 25, // 7月25日
    ownerId: "001",
  ),
];



List<ScheduleEntry> getTodayList(List<ScheduleEntry> entries, String weekday , int date) {
  return entries
      .where((i) => i.weekday == weekday && (i.continuous || i.day == date))
      .toList();
}

  @override
  Widget build(BuildContext context) {
    final todayList = getTodayList(sampleSchedule, weekday, date);
    return Scaffold(
      appBar: AppBar(title: Text('$date日 ($weekday) のシフト')),
      body: ListView.builder( //縦スクロール
        itemCount: todayList.length,
        itemBuilder: (context, index) {
          final item = todayList[index];
          return ListTile(
            title: Text(item.timeshift!),
            subtitle: Text('${item.studentName} - ${item.timeshift}'),
          );
        },
      ),
    );
  }
}