import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'schedule_entry.dart';

class StudentList {
  StudentList._privateConstructor();
  static final StudentList instance = StudentList._privateConstructor();

  static const _kPrefsKey = 'schedule_entries';

  final List<ScheduleEntry> sampleSchedule = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_kPrefsKey) ?? [];
    sampleSchedule
      ..clear()
      ..addAll(data.map((e) => ScheduleEntry.fromJson(jsonDecode(e))));
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kPrefsKey,
      sampleSchedule.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> addEntry(ScheduleEntry entry) async {
    sampleSchedule.add(entry);
    await _save();
  }

  Future<void> removeEntry(ScheduleEntry entry) async {
    sampleSchedule.remove(entry);
    await _save();
  }
  List<ScheduleEntry> get all => List.unmodifiable(sampleSchedule);
}