import 'package:flutter/material.dart';
import '../models/schedule_entry.dart';
import '../models/student_list.dart';

class EditStudentScreen extends StatefulWidget {
  final ScheduleEntry student;
  final DateTime selectedDate; // DateDetailScreen から渡される日付

  const EditStudentScreen({Key? key, required this.student, required this.selectedDate}) : super(key: key);

  @override
  _EditStudentScreenState createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
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
  final List<String> specialwork = ['集団', '目達', 'OMC', '講習準備'];
  late String selectedGrade;
  late String selectedWeekday;
  late String selectedtimeshift;
  late String selectedspesialwork;
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController officeWorkContentController = TextEditingController();
  final TextEditingController officeWorkTimeController = TextEditingController();
  final TextEditingController officeWorkHoursController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  bool isContinuous = true;
  bool isSpecialWork = false;
  bool isOfficeWork = false;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    studentNameController.text = widget.student.studentName;
    selectedGrade = widget.student.grade.isNotEmpty ? widget.student.grade : grades.first;
    selectedWeekday = widget.student.weekday.isNotEmpty ? widget.student.weekday : weekdays.first;
    selectedtimeshift = widget.student.timeshift.isNotEmpty ? widget.student.timeshift : timeshift.first;
    isContinuous = widget.student.continuous;
    isSpecialWork = widget.student.isSpecialWork;
    selectedspesialwork = widget.student.specialwork.isNotEmpty ? widget.student.specialwork : specialwork.first;
    isOfficeWork = widget.student.isOfficeWork;
    officeWorkContentController.text = widget.student.officework;
    officeWorkTimeController.text = widget.student.officeworktimeString;
    officeWorkHoursController.text = widget.student.officeworktime.toString();
    selectedDate = widget.selectedDate; // DateDetailScreen から渡された日付を使用
  }

  void saveChanges() {
    final bool entryIsOffice = isOfficeWork;

    final String entryStudentName = entryIsOffice
        ? officeWorkContentController.text.trim()
        : (isSpecialWork && selectedspesialwork == '集団'
            ? '集団'
            : studentNameController.text.trim());

    final String entryGrade = entryIsOffice ? '' : selectedGrade;

    final String entryWeekday = entryIsOffice
        ? weekdays[selectedDate.weekday - 1]
        : selectedWeekday;

    final String entryTimeshift = entryIsOffice ? '事務' : selectedtimeshift;

    final bool entryContinuous = entryIsOffice ? false : isContinuous;

    final int entryDay = entryIsOffice ? selectedDate.day : (entryContinuous ? 0 : selectedDate.day);
    final int entryMonth = entryIsOffice ? selectedDate.month : (entryContinuous ? 0 : selectedDate.month);
    final int entryYear = entryIsOffice ? selectedDate.year : (entryContinuous ? 0 : selectedDate.year);

    final updatedEntry = ScheduleEntry(
      id: widget.student.id,
      studentName: entryStudentName,
      grade: entryGrade,
      weekday: entryWeekday,
      timeshift: entryTimeshift,
      continuous: entryContinuous,
      day: entryDay,
      month: entryMonth,
      year: entryYear,
      isSpecialWork: isSpecialWork,
      specialwork: isSpecialWork ? selectedspesialwork : '',
      isOfficeWork: entryIsOffice,
      officework: entryIsOffice ? officeWorkContentController.text.trim() : '',
      officeworktimeString: entryIsOffice ? officeWorkTimeController.text.trim() : '',
      officeworktime: entryIsOffice ? double.tryParse(officeWorkHoursController.text.trim()) ?? 0.0 : 0.0,
      ownerId: widget.student.ownerId,
      absentDates: widget.student.absentDates, // 既存の欠席日リストを保持
    );

    StudentList.instance.updateStudent(updatedEntry);
    Navigator.pop(context);
  }

  void _showAbsenceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('欠席の確認'),
          content: Text('この日のシフトを欠席としてマークしますか？（リストからは消えません）'),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('この日だけ欠席'),
              onPressed: () {
                StudentList.instance.markAsAbsent(widget.student.id, widget.selectedDate);
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('全シフト削除の確認'),
          content: Text(
            '「${widget.student.studentName}」さんの今後のシフトを全て削除します。この操作は元に戻せません。よろしいですか？',
            style: TextStyle(color: Colors.red),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('全て削除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                StudentList.instance.deleteAllEntriesForStudent(
                  widget.student.studentName,
                  widget.student.grade,
                  DateTime.now(), // 現在の日付を渡す
                );
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    studentNameController.dispose();
    officeWorkContentController.dispose();
    officeWorkTimeController.dispose();
    officeWorkHoursController.dispose();
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('シフトの編集'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('事務作業モード'),
              value: isOfficeWork,
              onChanged: (value) => setState(() => isOfficeWork = value),
            ),
            const SizedBox(height: 16),

            Visibility(
              visible: !isOfficeWork,
              child: Column(
                children: [
                  TextFormField(
                    controller: studentNameController,
                    decoration: const InputDecoration(
                      labelText: '生徒名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            Visibility(
              visible: !isOfficeWork,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedGrade,
                    decoration: const InputDecoration(
                      labelText: '学年',
                      border: OutlineInputBorder(),
                    ),
                    items: grades
                        .map((grade) => DropdownMenuItem(value: grade, child: Text(grade)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedGrade = value!),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            Visibility(
              visible: !isOfficeWork,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedWeekday,
                    decoration: const InputDecoration(
                      labelText: '曜日',
                      border: OutlineInputBorder(),
                    ),
                    items: weekdays
                        .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedWeekday = value!),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            Visibility(
              visible: !isOfficeWork,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedtimeshift,
                    decoration: const InputDecoration(
                      labelText: '時間',
                      border: OutlineInputBorder(),
                    ),
                    items: timeshift
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedtimeshift = value!),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            if (!isOfficeWork) ...[
              SwitchListTile(
                title: const Text('特別な仕事'),
                value: isSpecialWork,
                onChanged: (value) {
                  setState(() {
                    isSpecialWork = value;
                  });
                },
              ),

              if (isSpecialWork)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: selectedspesialwork,
                    decoration: const InputDecoration(
                      labelText: '特別な仕事',
                      border: OutlineInputBorder(),
                    ),
                    items: specialwork
                        .map((sw) => DropdownMenuItem(value: sw, child: Text(sw)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedspesialwork = value!),
                  ),
                ),
            ],

            if (isOfficeWork) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: officeWorkContentController,
                decoration: const InputDecoration(
                  labelText: '事務仕事の内容',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: officeWorkTimeController,
                decoration: const InputDecoration(
                  labelText: '事務仕事の時間 (例: 20:00~21:00)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: officeWorkHoursController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '事務仕事の時間 (h, 例: 1.5)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Visibility(
              visible: !isOfficeWork,
              child: SwitchListTile(
                title: const Text('毎週繰り返す'),
                value: isContinuous,
                onChanged: (value) {
                  setState(() {
                    isContinuous = value;
                  });
                },
              ),
            ),

            if (!isContinuous || isOfficeWork)
              ListTile(
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
              controller: memoController,
              decoration: const InputDecoration(
                labelText: 'メモ',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showAbsenceDialog,
              child: Text('この日だけ欠席にする'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _showDeleteAllDialog,
              child: Text('今後のシフトを全て削除'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveChanges,
        child: const Icon(Icons.save),
      ),
    );
  }
}