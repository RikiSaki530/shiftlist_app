/// lib/services/create_pdf.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/schedule_entry.dart';
import '../models/student_list.dart';

class PdfGenerator {
  static int ps1add = 0;
  static int ps2add = 0;
  static double workTimeadd = 0.0;

  // キャッシュ用日本語フォント
  static pw.Font? _jpFont;

  /// 日本語フォントを一度だけ読み込む
  static Future<void> _loadJapaneseFont() async {
    if (_jpFont != null) return;
    final data = await rootBundle.load('assets/font/NotoSansJP-Regular.ttf');
    _jpFont = pw.Font.ttf(data);
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
        return entry.month == month && entry.day == day;
      }
    }).toList();
  }

  // Build a TableRow for a given day. Returns null if no entries.
  static pw.TableRow? _buildDayRow(
    List<ScheduleEntry> entries,
    int year,
    int month,
    int day,
    pw.Font jpFont,
  ) {
    final weekdayNames = ['日','月','火','水','木','金','土'];
    final entriesForDate = PdfGenerator.daytimecard(entries, year, month, day);
    if (entriesForDate.isEmpty) {
      return null;
    }
    final weekday = weekdayNames[DateTime(year, month, day).weekday % 7];

    final aCount = entriesForDate.where((e) => e.timeshift == 'A(17:00～18:30)').length;
    final bCount = entriesForDate.where((e) => e.timeshift == 'B(18:40～20:10)').length;
    final cCount = entriesForDate.where((e) => e.timeshift == 'C(20:20～21:50)').length;

    int ps1 = 0;
    int ps2 = 0;
    double workTime = 0.0;

    if (aCount == 1){
      ps1 += 1;
      workTime += 1.5;
      PdfGenerator.ps1add += 1;
      PdfGenerator.workTimeadd += 1.5;
    }else if (aCount == 2){
      ps2 += 1;
      workTime += 1.5;
      PdfGenerator.ps2add += 1;
      PdfGenerator.workTimeadd += 1.5;
    }
    if (bCount == 1){
      ps1 += 1;
      workTime += 1.5;
      PdfGenerator.ps1add += 1;
      PdfGenerator.workTimeadd += 1.5;
    }else if (bCount == 2){
      ps2 += 1;
      workTime += 1.5;
      PdfGenerator.ps2add += 1;
      PdfGenerator.workTimeadd += 1.5;
    }
    if (cCount == 1){
      ps1 += 1;
      workTime += 1.5;
      PdfGenerator.ps1add += 1;
      PdfGenerator.workTimeadd += 1.5;
    }else if (cCount == 2){
      ps2 += 1;
      workTime += 1.5;
      PdfGenerator.ps2add += 1;
      PdfGenerator.workTimeadd += 1.5;
    }

  return pw.TableRow(
    children: [
      pw.Text('$month/$day', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 10)),
      pw.Text(weekday, textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 10)),
      pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 10)),
      pw.Column(
      // Aコマの担当者を縦にリスト表示
        children: [
          for (var e in entriesForDate.where((e) => e.timeshift == 'A(17:00～18:30)'))
            pw.Text(
              e.studentName,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: jpFont, fontSize: 10),
            ),
        ],
      ),
      pw.Column(
      // Bコマの担当者を縦にリスト表示
        children: [
          for (var e in entriesForDate.where((e) => e.timeshift == 'B(18:40～20:10)'))
            pw.Text(
              e.studentName,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: jpFont, fontSize: 10),
            ),
        ],
      ),
      pw.Column(
      // Cコマの担当者を縦にリスト表示
        children: [
          for (var e in entriesForDate.where((e) => e.timeshift == 'C(20:20～21:50)'))
            pw.Text(
              e.studentName,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(font: jpFont, fontSize: 10),
            ),
        ],
      ),
      pw.Text(ps1.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 10)),
      pw.Text(ps2.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 10)),
      pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 10)),
      pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 10)),
      pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 8)),
      pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 8)),
      pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 8)),
      pw.Column(
        children: [
          // 総労働時間ラベル(空白でもOK)
          pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 8)),
          // 実際の数値を下の行に
          pw.Text(workTime.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: jpFont, fontSize: 8)),
        ],
      ),
    ],
  );
}

  /// PDF をビルドしてバイト列で返す（プレビュー用）
  static Future<Uint8List> generatePdfBytes(int year, int month, PdfPageFormat format) async {
    // 1) 日本語フォント（あれば）ロード
    await _loadJapaneseFont();

    // リセット集計用カウンタ
    PdfGenerator.ps1add = 0;
    PdfGenerator.ps2add = 0;
    PdfGenerator.workTimeadd = 0.0;

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
    final entries = StudentList.instance.sampleSchedule;

    // Build all day rows
    final dayRows = <pw.TableRow>[];
    for (var i = 1; i <= lastDay; i++) {
      final row = _buildDayRow(entries, year, month, i, _jpFont!);
      if (row != null) {
        dayRows.add(row);
      }
    }

    // 合計行（summary row）を作成
    final summaryRow = pw.TableRow(
      children: [
        pw.Text('合計', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10)),
        pw.Text(PdfGenerator.ps1add.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text(PdfGenerator.ps2add.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 10)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 8)),
        pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 8)),
        pw.Column(
          children: [
            pw.Text('', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 8)),
            pw.Text(PdfGenerator.workTimeadd.toString(), textAlign: pw.TextAlign.center, style: pw.TextStyle(font: _jpFont, fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ],
    );

  // 4) ページを追加
  doc.addPage(pw.Page(
    pageFormat: format,
    margin: const pw.EdgeInsets.all(20),
    build: (ctx) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // タイトル
          pw.Text(
            '$year年$month月 シフト表',
            style: pw.TextStyle(font: _jpFont, fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),

          // テーブル本体
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey),
            columnWidths: {
              // 0列目（時間帯）は幅固定、あとは均等
              for (var i = 1; i <= 13; i++)
                i: const pw.FlexColumnWidth(1),
            },
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
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    '曜',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    'その他',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Aコマ',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: _jpFont,                     // 日本語フォント
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        '17:00-18:30',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: _jpFont,                     // 日本語フォント
                          fontSize: 5,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Bコマ',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: _jpFont,                     // 日本語フォント
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        '18:40-20:10',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: _jpFont,                     // 日本語フォント
                          fontSize: 5,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Cコマ',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: _jpFont,                     // 日本語フォント
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        '20:10-21:50',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: _jpFont,                     // 日本語フォント
                          fontSize: 5,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'PS1',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    'PS2',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    '集団',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    '目達',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    'OMC',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    '講習準備',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 8,
                    ),
                  ),
                  pw.Text(
                    '事務作業',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      font: _jpFont,                     // 日本語フォント
                      fontSize: 8,
                    ),
                  ),
                  pw.Column(
                    children: [
                      pw.Text(
                        '勤務時間',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: _jpFont,                     // 日本語フォント
                          fontSize: 8,
                        ),
                      ),
                      pw.Text(
                        '合計',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          font: _jpFont,                     // 日本語フォント
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ...dayRows,
              summaryRow,
            ],
          ),
        ],
      );
    },
  ));

  return doc.save();
}
}