class ScheduleEntry {
  final String studentName;
  final String recurrence;   // 例: "月"
  final bool continuous;     //例: 毎週なら"true" / 一回のみなら"false"
  final String ownerId;

  ScheduleEntry({
    required this.studentName,
    required this.slot,
    required this.recurrence,
    required this.continuous,
    required this.ownerId,
  });

  // JSONからデコードするファクトリ
  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      studentName: json['studentName'] as String,
      time: json['time'] as String,
      recurrence: json['recurrence'] as String,
      continuous: json['continuous'] as bool,
      ownerId: json['ownerId'] as String,
    );
  }

  // JSONへエンコード
  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'time': time,
      'recurrence': recurrence,
      'continuous': continuous,
      'ownerId': ownerId,
    };
  }
}