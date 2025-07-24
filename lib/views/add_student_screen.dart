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
  final List<String> specialwork = ['集団', '目達', 'OMC', '講習準備'];
  late String selectedGrade;
  late String selectedWeekday;
  late String selectedtimeshift;
  late String selectedspesialwork;
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController officeWorkContentController = TextEditingController();
  final TextEditingController officeWorkTimeController = TextEditingController();
  final TextEditingController officeWorkHoursController = TextEditingController(text: '1.5');
  final TextEditingController memoController = TextEditingController();

  bool isContinuous = true;
  bool isSpecialWork = false;
  bool isOfficeWork = false;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedGrade = grades.first;
    selectedWeekday = weekdays.first;
    selectedtimeshift = timeshift.first;
    selectedspesialwork = specialwork.first;
    selectedDate = DateTime.now();
  }

  void saveEntry() {
    // ===== Business‑logic mapping based on current mode =====
    final bool entryIsOffice = isOfficeWork;

    // 1) Student name
    final String entryStudentName = entryIsOffice
        ? officeWorkContentController.text.trim() // use the office work content as the "name"
        : (isSpecialWork && selectedspesialwork == '集団'
            ? '集団'
            : studentNameController.text.trim());

    // 2) Grade (null equivalent → empty string)
    final String entryGrade = entryIsOffice ? '' : selectedGrade;

    // 2) Weekday: if office work, derive from selectedDate
    final String entryWeekday = entryIsOffice
        ? weekdays[selectedDate.weekday - 1]
        : selectedWeekday;

    // 3) Timeshift
    // Office work entries should have a fixed timeshift label "事務"
    final String entryTimeshift = entryIsOffice ? '事務' : selectedtimeshift;

    // 4) Repetition
    final bool entryContinuous = entryIsOffice ? false : isContinuous;

    // 5) Date handling
    final int entryDay  = entryIsOffice ? selectedDate.day : (entryContinuous ? 0 : selectedDate.day);
    final int entryMonth = entryIsOffice ? selectedDate.month : (entryContinuous ? 0 : selectedDate.month);

    final newEntry = ScheduleEntry(
      studentName: entryStudentName,
      grade: entryGrade,
      weekday: entryWeekday,
      timeshift: entryTimeshift,
      continuous: entryContinuous,
      day: entryDay,
      month: entryMonth,
      isSpecialWork: isSpecialWork,
      specialwork: isSpecialWork ? selectedspesialwork : '',
      isOfficeWork: entryIsOffice,
      officework: entryIsOffice ? officeWorkContentController.text.trim() : '',
      officeworktimeString: entryIsOffice ? officeWorkTimeController.text.trim() : '',
      officeworktime: entryIsOffice ? double.tryParse(officeWorkHoursController.text.trim()) ?? 0.0 : 0.0,
      ownerId: "user1234",
    );
    // TODO: Implement saving logic for newEntry
    Navigator.pop(context, newEntry);
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
        title: const Text('新しいシフト追加'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // モード切替：OFF = 通常入力, ON = 事務作業入力
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
              // Toggle for special work
              SwitchListTile(
                title: const Text('特別な仕事'),
                value: isSpecialWork,
                onChanged: (value) {
                  setState(() {
                    isSpecialWork = value;
                  });
                },
              ),

              // If special work, show dropdown for special work type
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

            // Toggle for single vs weekly
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

            // If single occurrence or office work, show date picker tile
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