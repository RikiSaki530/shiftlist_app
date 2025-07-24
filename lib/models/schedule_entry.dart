import 'package:uuid/uuid.dart';

class ScheduleEntry {
  String id;
  String studentName;
  String grade;
  String weekday;   // 例: "月","火"
  String timeshift; //例: "A"
  bool continuous;     //例: 毎週なら"true" / 一回のみなら"false"
  int day;            //もし一回なら日付保存
  int month;
  int year;           // 追加: 年情報
  bool isSpecialWork; // 特別な仕事かどうか
  String specialwork; // 特別な仕事の内容
  bool isOfficeWork; // 事務仕事かどうか
  String officework;  // 事務仕事の内容
  String officeworktimeString;  // 事務仕事の時間
  double officeworktime; // 事務仕事の時間（例: 1.5時間）
  String ownerId;
  List<DateTime> absentDates; // 追加: 欠席した日付のリスト

  ScheduleEntry({
    String? id,
    required this.studentName,
    required this.grade,
    required this.weekday,
    required this.timeshift,
    required this.continuous,
    required this.day,
    required this.month,
    this.year = 0, // year を追加し、デフォルト値を設定
    required this.isSpecialWork,
    required this.specialwork,
    required this.isOfficeWork,
    required this.officework,
    required this.officeworktimeString,
    required this.officeworktime,
    required this.ownerId,
    List<DateTime>? absentDates, // コンストラクタにも追加
  })  : id = id ?? Uuid().v4(),
        this.absentDates = absentDates ?? []; // 初期化

  // JSONからデコードするファクトリ
  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'] as String?,
      studentName: json['studentName'] as String,
      grade: json['grade'] as String,
      weekday: json['weekday'] as String,
      timeshift: json['timeshift'] as String,
      continuous: json['continuous'] as bool,
      day: json['day'] as int,
      month: json['month'] as int,
      year: json['year'] as int? ?? 0, // year のデコード
      isSpecialWork: json['isSpecialWork'] as bool? ?? false,
      specialwork: json['specialwork'] as String? ?? '',
      isOfficeWork: json['isOfficeWork'] as bool? ?? false,
      officework: json['officework'] as String? ?? '',
      officeworktimeString: json['officeworktimeString'] as String? ?? '',
      officeworktime: (json['officeworktime'] as num?)?.toDouble() ?? 0.0,
      ownerId: json['ownerId'] as String,
      // absentDates のデコード
      absentDates: (json['absentDates'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList() ??
          [],
    );
  }

  // JSONへエンコード
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'grade': grade,
      'timeshift': timeshift,
      'weekday': weekday,
      'continuous': continuous,
      'day': day,
      'month': month,
      'year': year, // year のエンコード
      'isSpecialWork': isSpecialWork,
      'specialwork': specialwork,
      'isOfficeWork': isOfficeWork,
      'officework': officework,
      'officeworktimeString': officeworktimeString,
      'officeworktime': officeworktime,
      'ownerId': ownerId,
      // absentDates のエンコード
      'absentDates': absentDates.map((e) => e.toIso8601String()).toList(),
    };
  }
}