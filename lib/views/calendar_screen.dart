import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ← intlパッケージを入れてね
import 'date_detail_screen.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  static const weekdays = ['日', '月', '火', '水', '木', '金', '土'];

  @override
  Widget build(BuildContext context) {
    final DateTime firstDay = DateTime(2025, 7, 1); // ここはOK

    return Scaffold(
      appBar: AppBar(title: Text('シフトカレンダー')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays
                .map((day) => Expanded(
                      child: Center(child: Text(day, style: TextStyle(fontWeight: FontWeight.bold))),
                    ))
                .toList(),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
              ),
              itemCount: 42, // 6 weeks (7*6)
              itemBuilder: (context, index) {
                final startWeekday = firstDay.weekday % 7; // 日曜=0
                final dayNumber = index - startWeekday + 1;

                if (dayNumber < 1 || dayNumber > 31) {
                  return Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade100,
                    ),
                  ); // プレースホルダーセル
                }

                final currentDate = DateTime(2025, 7, dayNumber);
                final weekday = weekdays[currentDate.weekday % 7];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DateDetailScreen(date: dayNumber, weekday: weekday),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: dayNumber % 7 == 0 ? Colors.blue.shade100 : Colors.white, // 仮
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$dayNumber', style: TextStyle(fontSize: 16)),
                          Text(weekday, style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}