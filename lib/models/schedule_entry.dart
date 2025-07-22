class ScheduleEntry {
  final String studentName;
  final String weekday;   // 例: "月","火"
  final String timeshift; //例: "A"
  final bool continuous;     //例: 毎週なら"true" / 一回のみなら"false"
  final int day;            //もし一回のみなら日付を保存。
  final String ownerId;

  ScheduleEntry({
    required this.studentName,
    required this.weekday,
    required this.timeshift,
    required this.continuous,
    required this.day,
    required this.ownerId,
  });

  // JSONからデコードするファクトリ
  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      studentName: json['studentName'] as String,
      weekday: json['weekday'] as String,
      timeshift: json['timeshift'] as String,
      continuous: json['continuous'] as bool,
      day: json ['day'] as int,
      ownerId: json['ownerId'] as String,
    );
  }

  // JSONへエンコード
  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'timeshift': timeshift,
      'weekday': weekday,
      'continuous': continuous,
      'day' : day,
      'ownerId': ownerId,
    };
  }
}