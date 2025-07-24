// lib/views/pdf_preview_screen.dart
import 'dart:typed_data';
import 'dart:io';
import 'package:pdf/pdf.dart';  
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:file_selector/file_selector.dart';
import '../services/create_pdf.dart';

class PdfPreviewScreen extends StatelessWidget {
  final int year, month;
  const PdfPreviewScreen({Key? key, required this.year, required this.month}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$year年 $month月 シフト表プレビュー')),
      body: PdfPreview(
        build: (format) => PdfGenerator.generatePdfBytes(year, month, format),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '保存',
        child: Icon(Icons.save),
        onPressed: () async {
            print('▶ PDF保存ボタンが押されました');
            try {
                final bytes = await PdfGenerator.generatePdfBytes(year, month, PdfPageFormat.a4);
                print('  ・バイト列生成 OK (${bytes.length} bytes)');
                final path = await getSavePath(
                suggestedName: 'shift_schedule_${year}-${month}.pdf',
                acceptedTypeGroups: [ XTypeGroup(label: 'PDF', extensions: ['pdf']) ],
                );
                print('  ・getSavePath 返却: $path');
                if (path != null) {
                await File(path).writeAsBytes(bytes);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF を保存しました: $path')),
                );
                }
            } catch (e, st) {
                print('★★ 保存処理で例外: $e\n$st');
            }
            },
      ),
    );
  }
}