import 'package:flutter/material.dart';
import '../models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// シンプルな講師名編集画面。
/// ・教員の名前一覧を表示
/// ・右下＋ボタンで追加ダイアログ
/// ・タップで編集、長押しで削除確認
class UserSettingView extends StatefulWidget {
  const UserSettingView({super.key});

  @override
  State<UserSettingView> createState() => _UserSettingViewState();
}

class _UserSettingViewState extends State<UserSettingView> {
  static const _kTeacherNameKey = 'teacher_name';

  /// 単一の講師
  Teacher? _teacher;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadSavedName();
  }

  Future<void> _loadSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kTeacherNameKey) ?? '講師名';
    setState(() {
      _teacher = Teacher(id: 'self', name: saved);
      _nameController.text = saved;
    });
  }

  Future<void> _saveName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTeacherNameKey, name);
    setState(() {
      _teacher = Teacher(id: 'self', name: name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('講師 編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('講師名', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _saveName(),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}