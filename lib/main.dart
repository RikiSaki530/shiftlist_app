import 'package:flutter/material.dart';
import 'views/calendar_screen.dart';
import 'views/user_settingview.dart';
import 'views/homepage.dart';   // ← 追加
import 'models/student_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StudentList.instance.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shift App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(),          // ← ここだけ残す
      routes: {
        '/calendar': (_) => const CalendarScreen(),
        '/settings': (_) => const UserSettingView(),
      },
    );
  }
}