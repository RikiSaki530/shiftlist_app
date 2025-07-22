import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';

class AddStudentScreen extends StatefulWidget {
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final List<String> grades = ['小1','小2','小3','小4','小5','小6','中1', '中2', '中3', '高1', '高2', '高3'];
  final List<String> weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  final List<String> timeshift = [
    '9:30～11:00',
    '11:10～12:40',
    '13:30～15:00',
    '15:10～16:40',
    '17:00～18:30',
    '18:40～20:10',
    '20:20～21:50',
  ];
  late String selectedGrade;
  late String selectedWeekday;
  late String selectedtimeshift;
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController timeshiftController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedGrade = grades.first;
    selectedWeekday = weekdays.first;
    selectedtimeshift = timeshift.first;
  }

  void saveEntry() {
    final newEntry = ScheduleEntry(
      studentName: studentNameController.text,
      grade: selectedGrade,
      weekday: selectedWeekday,
      timeshift: selectedtimeshift,
      continuous: true,
      day: 15,
      month: 7,
      ownerId: "user1234",
    );
    // TODO: Implement saving logic for newEntry
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しいシフト追加'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: studentNameController,
              decoration: const InputDecoration(
                labelText: '生徒名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
                value: selectedGrade,
                decoration: const InputDecoration(
                    labelText: '学年',
                    border: OutlineInputBorder(),
                ),
                items: grades.map((grade) {
                    return DropdownMenuItem<String>(
                    value: grade,
                    child: Text(grade),
                    );
                }).toList(),
                onChanged: (value) {
                    setState(() {
                      selectedGrade = value!;
                    });
                },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
                value: selectedWeekday,
                decoration: const InputDecoration(
                    labelText: '曜日',
                    border: OutlineInputBorder(),
                ),
                items: weekdays.map((day) {
                    return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                    );
                }).toList(),
                onChanged: (value) {
                    setState(() {
                      selectedWeekday = value!;
                    });
                },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
                value: selectedtimeshift,
                decoration: const InputDecoration(
                    labelText: '時間',
                    border: OutlineInputBorder(),
                ),
                items: timeshift.map((timeshift) {
                  return DropdownMenuItem<String>(
                    value: timeshift,
                    child: Text(timeshift),
                  );
                }).toList(),
                onChanged: (value) {
                    setState(() {
                      selectedtimeshift = value!;
                    });
                },
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          saveEntry();
          Navigator.pop(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}