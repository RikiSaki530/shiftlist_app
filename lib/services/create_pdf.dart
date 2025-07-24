/// lib/services/create_pdf.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/schedule_entry.dart';
import '../models/student_list.dart';

// Helper: normalize timeshift slot string (unify wave/dash etc.)
String _normSlot(String s) => s.replaceAll('〜', '-').replaceAll('～', '-').trim();

class PdfGenerator {
  static int ps1add = 0;
  static int ps2add = 0;
  static double workTimeadd = 0.0;
  static int syuudannadd = 0;
  static int mokutatuadd = 0;
  static int omcadd = 0;
  static int kousyuuadd = 0;
  static int officeAdd = 0; // 月次の事務作業回数
  static double officeHoursAdd = 0.0; // 月次 事務作業時間(h)

  // キャッシュ用日本語フォント
  static pw.Font? _jpFont;

  /// コア授業枠（ABC のみ）
  static const abcSlots = [
    'A(17:00～18:30)',
    'B(18:40～20:10)',
    'C(20:20～21:50)',
  ];
  /// すべての時間帯
  static const fullSlots = [
    '9:30-11:00',
    '11:10-12:40',
    '13:30-15:00',
    '15:10-16:40',
    'A(17:00～18:30)',
    'B(18:40～20:10)',
    'C(20:20～21:50)',
  ];

  /// 日本語フォントを一度だけ読み込む
  static Future<void> _loadJapaneseFont() async {
    if (_jpFont != null) return;
    final data = await rootBundle.load('assets/font/NotoSansJP-Regular.ttf');
    PdfGenerator._jpFont = pw.Font.ttf(data);
  }

  /// 指定した年月日または曜日に該当するエントリのみを返す
  static List<ScheduleEntry> daytimecard(
    List<ScheduleEntry> studentList,
    int year,
    int month,
    int day,
  ) {
    // 曜日の文字列リスト
    const weekdayNames = ['日','月','火','水','木','金','土'];
    // 対象日の曜日を求める
    final String targetWeekday = weekdayNames[
      DateTime(year, month, day).weekday % 7
    ];

    // 単発 or 毎週判定してフィルタ
    return studentList.where((entry) {
      if (entry.continuous) {
        // 毎週登録されたエントリの場合
        return entry.weekday == targetWeekday;
      } else {
        // 単発登録されたエントリの場合
        return entry.year == year && entry.month == month && entry.day == day; // year も比較
      }
    }).toList();
  }

  // Build a TableRow for a given day. Returns null if no entries.
  static pw.TableRow? _buildDayRow(
    List<ScheduleEntry> entries,
    List<String> slots,
    int year,
    int month,
    int day,
  ) {
    final jpFont = PdfGenerator._jpFont!;
    final weekdayNames = ['日','月','火','水','木','金','土'];
    final entriesForDate = PdfGenerator.daytimecard(entries, year, month, day);
    if (entriesForDate.isEmpty) {
      return null;
    }
    final weekday = weekdayNames[DateTime(year, month, day).weekday % 7];
    final currentDate = DateTime(year, month, day);

    // 欠席者を除外したエントリリストを作成
    final presentEntriesForDate = entriesForDate.where((e) =>
        !e.absentDates.any((ad) =>
            ad.year == currentDate.year &&
            ad.month == currentDate.month &&
            ad.day == currentDate.day)).toList();

    if (presentEntriesForDate.isEmpty) {
      return null;
    }

    int ps1 = 0;
    int ps2 = 0;
    double workTime = 0.0;

    // ─── 特別業務カウント ───────────────────────────
    int syuudann = presentEntriesForDate.where((e) => e.isSpecialWork && e.specialwork == '集団').length;
    int mokutatu = presentEntriesForDate.where((e) => e.isSpecialWork && e.specialwork == '目達').length;
    int omc      = presentEntriesForDate.where((e) => e.isSpecialWork && e.specialwork == 'OMC').length;
    int kousyuu  = presentEntriesForDate.where((e) => e.isSpecialWork && e.specialwork == '講習準備').length;

    // 日次→月次の合計へ加算
    PdfGenerator.syuudannadd += syuudann;
    PdfGenerator.mokutatuadd += mokutatu;
    PdfGenerator.omcadd     += omc;
    PdfGenerator.kousyuuadd += kousyuu;

    // ---- 特別業務ぶん勤務時間を加算 -------------------
    final int specialWorkTotal = syuudann + mokutatu + omc + kousyuu;
    if (specialWorkTotal > 0) {
      workTime += specialWorkTotal * 1.5;        // 1.5h × 件数
      PdfGenerator.workTimeadd += specialWorkTotal * 1.5;
    }


    // ─── 事務作業カウント ───
    final officeCount = presentEntriesForDate.where((e) => e.isOfficeWork).length;
    PdfGenerator.officeAdd += officeCount;
    // 事務作業時間合計
    final double officeHours = presentEntriesForDate
        .where((e) => e.isOfficeWork)
        .fold(0.0, (prev, e) => prev + (e.officeworktime));
    // 日次 → 月次加算
    PdfGenerator.officeHoursAdd += officeHours;
    // 勤務時間に加算
    workTime += officeHours;
    PdfGenerator.workTimeadd += officeHours;

    // ─── PS1 / PS2 判定 (すべての時間帯)────────────────────
    for (final slot in slots) {
      final count = presentEntriesForDate
          .where((e) => _normSlot(e.timeshift) == _normSlot(slot) && !e.isSpecialWork && !e.isOfficeWork)
          .length;
      if (count == 1) {
        ps1 += 1;
        workTime += 1.5;
        PdfGenerator.ps1add += 1;
        PdfGenerator.workTimeadd += 1.5;
      } else if (count == 2) {
        ps2 += 1;
        workTime += 1.5;
        PdfGenerator.ps2add += 1;
        PdfGenerator.workTimeadd += 1.5;
      }
    }

  return pw.TableRow(
    children: [
      pw.Text('$month/$day', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 12)),
      pw.Text(weekday, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 12)),
      pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 12)),
      // --- dynamic timeslot columns ---
      ...slots.map((slot) => pw.SizedBox(
        height: 40.0, // 固定の高さ
        child: pw.Column(
          children: [
            for (var e in presentEntriesForDate.where((e) =>
                _normSlot(e.timeshift) == _normSlot(slot)))
              pw.Text(
                e.studentName,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 10),
              ),
          ],
        ),
      )),
      pw.Text(ps1.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 12)),
      pw.Text(ps2.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 12)),
      pw.Text(syuudann.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 12)),
      pw.Text(mokutatu.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 12)),
      pw.Text(omc.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 10)),
      pw.Text(kousyuu.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 10)),
      pw.SizedBox(
        height: 40.0, // 固定の高さ
        child: pw.Column(
          children: [
            for (var e in presentEntriesForDate.where((e)=>e.isOfficeWork)) ...[
              pw.Text(e.officework, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 10)),
              pw.Text(e.officeworktimeString, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 9)),
            ],
            if (officeCount==0) pw.Text('-', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 10)),
          ],
        ),
      ),
      pw.SizedBox(
        height: 40.0, // 固定の高さ
        child: pw.Column(
          children: [
            // 総労働時間ラベル(空白でもOK)
            pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 10)),
            // 実際の数値を下の行に
            pw.Text(workTime.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 10)),
          ],
        ),
      ),
    ],
  );
}

  /// PDF をビルドしてバイト列で返す（プレビュー用）
  static Future<Uint8List> generatePdfBytes(int year, int month, PdfPageFormat format) async {
    // 1) 日本語フォント（あれば）ロード
    await _loadJapaneseFont();
    // 0) 講師名を読み込む (SharedPreferences に保存されている想定)
    final prefs = await SharedPreferences.getInstance();
    final String teacherName = prefs.getString('teacher_name') ?? '';

    // リセット集計用カウンタ
    PdfGenerator.ps1add = 0;
    PdfGenerator.ps2add = 0;
    PdfGenerator.workTimeadd = 0.0;
    PdfGenerator.syuudannadd = 0;
    PdfGenerator.mokutatuadd = 0;
    PdfGenerator.omcadd = 0;
    PdfGenerator.kousyuuadd = 0;
    PdfGenerator.officeAdd = 0;
    PdfGenerator.officeHoursAdd = 0.0;

    // 2) ドキュメント生成
    final doc = pw.Document();

    // 1) ヘッダー(日付)
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0).day;
    final weekdayNames = ['日','月','火','水','木','金','土'];

    // 2) 時間帯リスト（ここは実際の運用に合わせて増やして下さい）
    final timeSlots = [
      '9:30-11:00',
      '11:10-12:40',
      '13:30-15:00',
      '15:10-16:40',
      'A(17:00～18:30)',
      'B(18:40～20:10)',
      'C(20:20～21:50)',
    ];

    // 3) 全エントリ取得
    final entries = StudentList.instance.all;

    // 追加時間帯が含まれているか判定 (ABC 以外)
    final hasExtra = entries.any((e) => !abcSlots.contains(e.timeshift));
    final activeSlots = hasExtra ? fullSlots : abcSlots;

    // Build all day rows
    final dayRows = <pw.TableRow>[];
    for (var i = 1; i <= lastDay; i++) {
      final row = _buildDayRow(entries, activeSlots, year, month, i);
      if (row != null) {
        dayRows.add(row);
      }
    }

    // ---- 各時間帯の月次合計を算出 ---------------------------
    final Map<String,int> slotTotals = {
      for (final s in activeSlots) s : 0,
    };
    for (final e in entries) {
      final key = activeSlots.firstWhere(
        (s) => _normSlot(s) == _normSlot(e.timeshift),
        orElse: () => '',
      );
      if (key.isNotEmpty) slotTotals[key] = slotTotals[key]! + 1;
    }

    // 合計行（summary row）を作成
    final summaryChildren = <pw.Widget>[];
    // (0) 月/日 列
    summaryChildren.add(pw.Text('合計', textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 12)));
    // (1) 曜列
    summaryChildren.add(pw.Text('', textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 12, fontWeight: pw.FontWeight.bold)));
    // (2) その他列
    summaryChildren.add(pw.Text('', textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 12)));
    // (3..n) 動的スロット列
    // 時間帯列の合計セルは空白にする（合計は PS 列以降で表示）
    for (final _ in activeSlots) {
      summaryChildren.add(pw.Text('', textAlign: pw.TextAlign.center,
          style: pw.TextStyle(font: _jpFont, fontSize: 12)));
    }
    // PS1
    summaryChildren.add(pw.Text(PdfGenerator.ps1add.toString(), textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 12, fontWeight: pw.FontWeight.bold)));
    // PS2
    summaryChildren.add(pw.Text(PdfGenerator.ps2add.toString(), textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 12, fontWeight: pw.FontWeight.bold)));
    // 特別業務列
    summaryChildren.add(pw.Text(PdfGenerator.syuudannadd.toString(), textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 12, fontWeight: pw.FontWeight.bold)));
    summaryChildren.add(pw.Text(PdfGenerator.mokutatuadd.toString(), textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 12, fontWeight: pw.FontWeight.bold)));
    summaryChildren.add(pw.Text(PdfGenerator.omcadd.toString(), textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 12, fontWeight: pw.FontWeight.bold)));
    summaryChildren.add(pw.Text(PdfGenerator.kousyuuadd.toString(), textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 10, fontWeight: pw.FontWeight.bold)));
    // 事務作業列 (時間のみ)
    summaryChildren.add(pw.Text(PdfGenerator.officeHoursAdd.toStringAsFixed(1), textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: _jpFont, fontSize: 10, fontWeight: pw.FontWeight.bold)));
    // 勤務時間合計列
    summaryChildren.add(pw.SizedBox(
      height: 40.0, // 固定の高さ
      child: pw.Column(children:[
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10)),
        pw.Text(PdfGenerator.workTimeadd.toString(), textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: _jpFont, fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ]),
    ));

    final summaryRow = pw.TableRow(children: summaryChildren);

  // 4) ページを追加
  doc.addPage(pw.MultiPage(
    pageFormat: format,
    margin: const pw.EdgeInsets.all(20),
    header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // タイトルと講師名（右上に配置）
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '$year年$month月 シフト表',
                style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              if (teacherName.isNotEmpty)
                pw.Text(
                  teacherName,
                  style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 14),
                ),
            ],
          ),
          pw.SizedBox(height: 12),
        ],
      ),
    build: (ctx) {
      return [
          // テーブル本体
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            columnWidths: () {
              // 動的スロット数に応じて列総数を決定
              final totalCols = 3                       // 月/日・曜・その他
                              + activeSlots.length     // 授業枠列
                              + 8;                     // PS1,PS2,集団,目達,OMC,講習準備,事務作業,勤務時間
              return {
                // index0 は自動幅（Date 列）。他は均等幅 = Flex(1)
                for (var i = 1; i < totalCols; i++) i: const pw.FlexColumnWidth(1),
              };
            }(),
            children: [
              // ─── ヘッダ行 ──────────────────────────────
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  // 左上は空白
                  pw.Text(
                    '月/日',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    '曜',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    'その他',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 12,
                    ),
                  ),
                  ...activeSlots.map((slot) {
                    if (slot.contains('(')) {
                      // A/B/C コマ → 1行目: A など, 2行目: 時間帯
                      return pw.Column(children:[
                        pw.Text(
                          slot.substring(0,1), // A or B or C
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 12),
                        ),
                        pw.Text(
                          slot.replaceAll(RegExp(r'^\w\((.*)\)'), r'$1'), // 時間帯のみ
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: PdfGenerator._jpFont!, fontSize: 10),
                        ),
                      ]);
                    } else {
                      // 通常時間帯 → 1行目: 開始時刻~、2行目: 終了時刻
                      final parts = slot.split('-');
                      final start = parts.first.trim();
                      final end   = parts.length > 1 ? parts.last.trim() : '';
                      return pw.Column(children:[
                        pw.Text(
                          '$start~',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: _jpFont, fontSize: 11),
                        ),
                        pw.Text(
                          end,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: _jpFont, fontSize: 11),
                        ),
                      ]);
                    }
                  }),
                  pw.Text(
                    'PS1',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    'PS2',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    '集団',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    '目達',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    'OMC',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 12,
                    ),
                  ),
                  pw.Text(
                    '講習準備',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    '事務作業',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: PdfGenerator._jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.SizedBox(
                    height: 40.0, // 固定の高さ
                    child: pw.Column(
                      children: [
                        pw.Text(
                          '勤務時間',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: PdfGenerator._jpFont!,                     // 日本語フォント
                            fontSize: 10,
                          ),
                        ),
                        pw.Text(
                          '合計',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            font: PdfGenerator._jpFont!,                     // 日本語フォント
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ...dayRows,
              summaryRow,
            ],
          ),
        ];
    },
  ));

  return doc.save();
}
}