import 'package:flutter/material.dart';
import 'views/calender_screen.dart';
//import 'screens/settings_screen.dart';
//import 'screens/profile_screen.dart';

void main() {
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
      home: const CalendarScreen(), // デフォルト画面
      routes: {
        '/calendar': (context) => const CalendarScreen(),
        //'/settings': (context) => const SettingsScreen(),
        //'/profile': (context) => const ProfileScreen(),
      },
    );
  }
}