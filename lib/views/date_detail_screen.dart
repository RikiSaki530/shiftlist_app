import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule_entry.dart';
import '../models/student_list.dart';
import 'edit_student_screen.dart';

class DateDetailScreen extends StatelessWidget {
  final int date;
  final String weekday;

  DateDetailScreen({required this.date, required this.weekday});

  List<ScheduleEntry> getTodayList(
      List<ScheduleEntry> entries, String weekday, int date) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, date);
    return entries
        .where((i) {
          final isScheduledForThisDay = (i.continuous && i.weekday == weekday) ||
                                        (!i.continuous && i.day == date && i.month == today.month && i.year == today.year);

          if (!isScheduledForThisDay) {
            return false; // その日にスケジュールされていない
          }

          // この特定のエントリが今日欠席としてマークされているかチェック
          final isAbsentForToday = i.absentDates.any((ad) =>
              ad.year == today.year &&
              ad.month == today.month &&
              ad.day == today.day);

          return !isAbsentForToday; // 欠席ではない場合のみ含める
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: StudentList.instance,
      child: Consumer<StudentList>(
        builder: (context, studentList, child) {
          final todayList = getTodayList(studentList.all, weekday, date);
          return Scaffold(
            appBar: AppBar(
              title: Text(
                '$date日 ($weekday) のシフト',
                style: TextStyle(fontSize: 30),
              ),
            ),
            body: ListView.builder(
              itemCount: todayList.length,
              itemBuilder: (context, index) {
                final item = todayList[index];
                return ListTile(
                  title: Text(
                    item.timeshift!,
                    style: TextStyle(fontSize: 25),
                  ),
                  subtitle: Text(
                    '${item.grade}  ${item.studentName}',
                    style: TextStyle(fontSize: 25),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditStudentScreen(student: item, selectedDate: DateTime(DateTime.now().year, DateTime.now().month, date)),
                      ),
                    );
                  },
                  // onLongPress は削除し、編集画面に欠席/削除のボタンを集約
                );
              },
            ),
          );
        },
      ),
    );
  }
}
