import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'schedule_entry.dart';

class StudentList extends ChangeNotifier {
  StudentList._privateConstructor();
  static final StudentList instance = StudentList._privateConstructor();

  static const _kPrefsKey = 'schedule_entries';

  final List<ScheduleEntry> _students = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_kPrefsKey) ?? [];
    _students
      ..clear()
      ..addAll(data.map((e) => ScheduleEntry.fromJson(jsonDecode(e))));
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kPrefsKey,
      _students.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> addEntry(ScheduleEntry entry) async {
    _students.add(entry);
    await _save();
    notifyListeners();
  }

  Future<void> removeEntry(ScheduleEntry entry) async {
    _students.remove(entry);
    await _save();
    notifyListeners();
  }

  Future<void> updateStudent(ScheduleEntry updatedEntry) async {
    final index = _students.indexWhere((student) => student.id == updatedEntry.id);
    if (index != -1) {
      _students[index] = updatedEntry;
      await _save();
      notifyListeners();
    }
  }

  // 欠席日を追加するメソッド
  Future<void> markAsAbsent(String entryId, DateTime date) async {
    final entryIndex = _students.indexWhere((entry) => entry.id == entryId);
    if (entryIndex != -1) {
      final entry = _students[entryIndex];
      // 日付部分のみを比較するために、日付部分だけを抽出して比較
      final normalizedDate = DateTime(date.year, date.month, date.day);
      // 既に欠席リストに含まれていない場合のみ追加
      if (!entry.absentDates.any((ad) =>
          ad.year == normalizedDate.year &&
          ad.month == normalizedDate.month &&
          ad.day == normalizedDate.day)) {
        entry.absentDates.add(normalizedDate);
        await _save();
        notifyListeners();
      }
    }
  }

  // 単一のエントリを削除するメソッド（欠席とは異なる「完全削除」）
  Future<void> deleteSingleEntry(String id) async {
    _students.removeWhere((student) => student.id == id);
    await _save();
    notifyListeners();
  }

  // 特定の生徒の全エントリを削除するメソッド
  Future<void> deleteAllEntriesForStudent(String studentName, String grade, DateTime fromDate) async {
    _students.removeWhere((entry) {
      final isMatchingStudent = entry.studentName == studentName && entry.grade == grade;
      if (!isMatchingStudent) {
        return false; // 該当生徒ではない
      }

      // fromDate の日付部分のみを正規化
      final normalizedFromDate = DateTime(fromDate.year, fromDate.month, fromDate.day);

      if (entry.continuous) {
        // 毎週繰り返すシフトは、該当生徒であれば常に削除対象
        return true;
      } else {
        // 単発シフトの場合、そのシフトの日付が fromDate 以降であるかチェック
        final entryDateTime = DateTime(entry.year, entry.month, entry.day);
        return entryDateTime.isAfter(normalizedFromDate) || entryDateTime.isAtSameMomentAs(normalizedFromDate);
      }
    });
    await _save();
    notifyListeners();
  }

  List<ScheduleEntry> get all => List.unmodifiable(_students);
}