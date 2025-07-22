class ScheduleEntry {
  final String studentName;
  final String grade;
  final String weekday;   // 例: "月","火"
  final String timeshift; //例: "A"
  final bool continuous;     //例: 毎週なら"true" / 一回のみなら"false"
  final int day;            //もし一回なら日付保存
  final int month;
  final String ownerId;

  ScheduleEntry({
    required this.studentName,
    required this.grade,
    required this.weekday,
    required this.timeshift,
    required this.continuous,
    required this.day,
    required this.month,
    required this.ownerId,
  });

  // JSONからデコードするファクトリ
  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      studentName: json['studentName'] as String,
      grade: json ['grade'] as String,
      weekday: json['weekday'] as String,
      timeshift: json['timeshift'] as String,
      continuous: json['continuous'] as bool,
      day: json ['day'] as int,
      month: json ['month'] as int,
      ownerId: json['ownerId'] as String,
    );
  }

  // JSONへエンコード
  Map<String, dynamic> toJson() {
    return {
      'studentName': studentName,
      'grade': grade,
      'timeshift': timeshift,
      'weekday': weekday,
      'continuous': continuous,
      'day' : day,
      'month' :  month,
      'ownerId': ownerId,
    };
  }
}