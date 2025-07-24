class ScheduleEntry {
  final String studentName;
  final String grade;
  final String weekday;   // 例: "月","火"
  final String timeshift; //例: "A"
  final bool continuous;     //例: 毎週なら"true" / 一回のみなら"false"
  final int day;            //もし一回なら日付保存
  final int month;
  final bool isSpecialWork; // 特別な仕事かどうか
  final String specialwork; // 特別な仕事の内容
  final bool isOfficeWork; // 事務仕事かどうか
  final String officework;  // 事務仕事の内容
  final String officeworktimeString;  // 事務仕事の時間
  final double officeworktime; // 事務仕事の時間（例: 1.5時間）
  final String ownerId;

  ScheduleEntry({
    required this.studentName,
    required this.grade,
    required this.weekday,
    required this.timeshift,
    required this.continuous,
    required this.day,
    required this.month,
    required this.isSpecialWork,
    required this.specialwork,
    required this.isOfficeWork,
    required this.officework,
    required this.officeworktimeString,
    required this.officeworktime,
    required this.ownerId,
  });

  // JSONからデコードするファクトリ
  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      studentName: json['studentName'] as String,
      grade: json['grade'] as String,
      weekday: json['weekday'] as String,
      timeshift: json['timeshift'] as String,
      continuous: json['continuous'] as bool,
      day: json['day'] as int,
      month: json['month'] as int,
      isSpecialWork: json['isSpecialWork'] as bool? ?? false,
      specialwork: json['specialwork'] as String? ?? '',
      isOfficeWork: json['isOfficeWork'] as bool? ?? false,
      officework: json['officework'] as String? ?? '',
      officeworktimeString: json['officeworktimeString'] as String? ?? '',
      officeworktime: (json['officeworktime'] as num?)?.toDouble() ?? 0.0,
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
      'day': day,
      'month': month,
      'isSpecialWork': isSpecialWork,
      'specialwork': specialwork,
      'isOfficeWork': isOfficeWork,
      'officework': officework,
      'officeworktimeString': officeworktimeString,
      'officeworktime': officeworktime,
      'ownerId': ownerId,
    };
  }
}