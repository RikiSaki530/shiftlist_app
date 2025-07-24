import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'user_settingview.dart';

/// アプリ下部に 2 つのタブを持つトップページ
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // ここにタブごとの画面ウィジェットを並べる
  static const _pages = [
    CalendarScreen(),
    UserSettingView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'カレンダー'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: '講師設定'),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}