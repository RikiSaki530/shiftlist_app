import 'package:flutter/material.dart';
import 'date_detail_screen.dart';
import '../models/schedule_entry.dart';
import 'add_student_screen.dart';
import '../models/student_list.dart';
import '../services/create_pdf.dart';
import 'package:flutter/material.dart';
import 'pdf_preview_screen.dart';


class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();

  static const weekdays = ['日', '月', '火', '水', '木', '金', '土'];
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _displayedMonthOffset = 0;

  List<ScheduleEntry> get sampleSchedule => StudentList.instance.sampleSchedule;

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime firstDay = DateTime(today.year, today.month + _displayedMonthOffset, 1);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true, 
        title: Text('${firstDay.month}月'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'PDFを作成',
            onPressed: () {
              final now = DateTime.now();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfPreviewScreen(year: now.year, month: now.month),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            tooltip: '生徒追加',
            onPressed: () {
              showModalBottomSheet<ScheduleEntry>(
                context: context,
                isScrollControlled: true,
                builder: (_) => AddStudentScreen(),
              ).then((entry) {
                if (entry != null) {
                  setState(() {
                    StudentList.instance.addEntry(entry);
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CalendarScreen.weekdays
                .map((day) => Expanded(
                      child: Center(child: Text(day, style: TextStyle(fontWeight: FontWeight.bold))),
                    ))
                .toList(),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: 4, // from -1 to +2 months = 4 pages
              controller: PageController(initialPage: 1),
              onPageChanged: (index) {
                setState(() {
                  _displayedMonthOffset = index - 1;
                });
              },
              itemBuilder: (context, pageIndex) {
                final monthOffset = pageIndex - 1;
                final DateTime pageFirstDay = DateTime(today.year, today.month + monthOffset, 1);

                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10.0), // ← ここ追加
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemCount: 42, // 6 weeks (7*6)
                  itemBuilder: (context, index) {
                    final startWeekday = pageFirstDay.weekday % 7; // 日曜=0
                    final dayNumber = index - startWeekday + 1;

                    final daysInMonth = DateTime(pageFirstDay.year, pageFirstDay.month + 1, 0).day;

                    if (dayNumber < 1 || dayNumber > daysInMonth) {
                      return Container(
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          color: Colors.grey.shade100,
                        ),
                      ); // プレースホルダーセル
                    }

                    final currentDate = DateTime(pageFirstDay.year, pageFirstDay.month, dayNumber);
                    final weekday = CalendarScreen.weekdays[currentDate.weekday % 7];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DateDetailScreen(date: dayNumber, weekday: weekday , sampleSchedule: sampleSchedule),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: sampleSchedule.any((entry) =>
                                  entry.continuous && entry.weekday == weekday ||
                                  (!entry.continuous && entry.day == dayNumber && currentDate.month == entry.month))
                              ? Colors.blue.shade100
                              : Colors.white,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$dayNumber', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}