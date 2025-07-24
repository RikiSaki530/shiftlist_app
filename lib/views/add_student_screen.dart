import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';
import 'calendar_screen.dart';

class AddStudentScreen extends StatefulWidget {
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final List<String> grades = ['小1','小2','小3','小4','小5','小6','中1', '中2', '中3', '高1', '高2', '高3'];
  final List<String> weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  final List<String> timeshift = [
    'A(17:00～18:30)',
    'B(18:40～20:10)',
    'C(20:20～21:50)',
    '9:30～11:00',
    '11:10～12:40',
    '13:30～15:00',
    '15:10～16:40',
  ];
  late String selectedGrade;
  late String selectedWeekday;
  late String selectedtimeshift;
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController timeshiftController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool isContinuous = true;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedGrade = grades.first;
    selectedWeekday = weekdays.first;
    selectedtimeshift = timeshift.first;
    selectedDate = DateTime.now();
  }

  void saveEntry() {
    final newEntry = ScheduleEntry(
      studentName: studentNameController.text,
      grade: selectedGrade,
      weekday: selectedWeekday,
      timeshift: selectedtimeshift,
      continuous: isContinuous,
      day: isContinuous ? 0 : selectedDate.day,
      month: isContinuous ? 0 : selectedDate.month,
      ownerId: "user1234",
    );
    // TODO: Implement saving logic for newEntry
    Navigator.pop(context, newEntry);
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

            // Toggle for single vs weekly
            SwitchListTile(
              title: const Text('毎週繰り返す'),
              value: isContinuous,
              onChanged: (value) {
                setState(() {
                  isContinuous = value;
                });
              },
            ),

            // If single occurrence, show date picker tile
            if (!isContinuous) ListTile(
              title: const Text('日付を選択'),
              subtitle: Text('${selectedDate.year}/${selectedDate.month}/${selectedDate.day}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                    selectedWeekday = weekdays[picked.weekday - 1];
                  });
                }
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
        onPressed: saveEntry,
        child: const Icon(Icons.save),
      ),
    );
  }
}