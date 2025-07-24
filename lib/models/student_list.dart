import 'schedule_entry.dart';

class StudentList {
  StudentList._privateConstructor();
  static final StudentList instance = StudentList._privateConstructor();

  final List<ScheduleEntry> sampleSchedule = [];

  void addEntry(ScheduleEntry entry) => sampleSchedule.add(entry);
  void removeEntry(ScheduleEntry entry) => sampleSchedule.remove(entry);
  List<ScheduleEntry> get all => List.unmodifiable(sampleSchedule);
}