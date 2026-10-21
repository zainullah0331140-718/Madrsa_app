import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:intl/intl.dart' show DateFormat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_preview.dart';

/// کسی درجے کے تمام طلبہ کا خلاصہ نتیجہ (نتیجہ شیٹ) بنانے کی سروس
class ClassResultPdfService {
  ClassResultPdfService._();

  static const String _urduFontAsset =
      'assets/fonts/NotoNaskhArabic-Regular.ttf';

  static pw.Font? _urduFont;

  static final PdfColor _headerColor = PdfColor.fromInt(0xFF1B5E20);
  static final PdfColor _sectionColor = PdfColor.fromInt(0xFF2E7D32);
  static final PdfColor _borderColor = PdfColors.grey400;
  static final PdfColor _stripColor = PdfColors.grey100;

  static Future<pw.Font> _loadFont() async {
    if (_urduFont != null) return _urduFont!;
    final data = await rootBundle.load(_urduFontAsset);
    _urduFont = pw.Font.ttf(data);
    return _urduFont!;
  }

  static Future<Uint8List> buildBytes({
    required String className,
    required String examType,
    required List<ClassResultRow> rows,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final font = await _loadFont();
    final doc = pw.Document(
      title: 'نتیجہ - $className',
      author: 'مدرسہ مینجمنٹ سسٹم',
      creator: 'Madarsa Management System',
    );

    // فی صد کے حساب سے پوزیشن (پہلے سے ترتیب شدہ قطاریں)
    final ranked = [...rows]
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 28, 24, 28),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        textDirection: pw.TextDirection.rtl,
        header: (context) => _buildHeader(instituteName, className, examType),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 8),
          _buildTable(ranked),
        ],
      ),
    );

    return doc.save();
  }

  static Future<bool> printResult({
    required BuildContext context,
    required String className,
    required String examType,
    required List<ClassResultRow> rows,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final bytes = await buildBytes(
      className: className,
      examType: examType,
      rows: rows,
      instituteName: instituteName,
    );
    final safeClass =
        className.replaceAll(RegExp(r'[^0-9A-Za-z؀-ۿ]'), '');
    if (!context.mounted) return false;
    return showPdfPreview(
      context,
      bytes: bytes,
      fileName: 'class_result_${safeClass.isEmpty ? 'class' : safeClass}.pdf',
    );
  }

  // ------------------------- widgets -------------------------

  static pw.Widget _buildHeader(
      String instituteName, String className, String examType) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _borderColor, width: 1)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            instituteName,
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              fontSize: 16,
              color: _headerColor,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'نتیجہ شیٹ    |    درجہ: $className    |    امتحان: $examType',
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey800),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _borderColor, width: 0.5)),
      ),
      child: pw.Directionality(
        textDirection: pw.TextDirection.ltr,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              textDirection: pw.TextDirection.ltr,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Row(
              children: [
                pw.Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  textDirection: pw.TextDirection.ltr,
                  style:
                      const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  'تاریخِ اجراء:',
                  textDirection: pw.TextDirection.rtl,
                  style:
                      const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTable(List<ClassResultRow> rows) {
    final headers = [
      'پوزیشن',
      'رول نمبر',
      'نام',
      'والد کا نام',
      'کل نمبر',
      'حاصل کردہ',
      'فی صد',
      'نتیجہ',
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor, width: 0.8),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Directionality(
            textDirection: pw.TextDirection.ltr,
            child: pw.Container(
              color: _sectionColor,
              padding: const pw.EdgeInsets.symmetric(vertical: 6),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 1, child: _head(headers[0])),
                  pw.Expanded(flex: 2, child: _head(headers[1])),
                  pw.Expanded(flex: 4, child: _head(headers[2])),
                  pw.Expanded(flex: 4, child: _head(headers[3])),
                  pw.Expanded(flex: 2, child: _head(headers[4])),
                  pw.Expanded(flex: 2, child: _head(headers[5])),
                  pw.Expanded(flex: 2, child: _head(headers[6])),
                  pw.Expanded(flex: 2, child: _head(headers[7])),
                ],
              ),
            ),
          ),
          for (var i = 0; i < rows.length; i++) _row(rows[i], i, i.isOdd),
        ],
      ),
    );
  }

  static pw.Widget _head(String text) {
    return pw.Text(
      text,
      textDirection: pw.TextDirection.rtl,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: 9,
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  static pw.Widget _row(ClassResultRow r, int index, bool striped) {
    final passed = r.percentage >= 33;
    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Container(
        color: striped ? _stripColor : null,
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: pw.Row(
          children: [
            pw.Expanded(flex: 1, child: _center('${index + 1}')),
            pw.Expanded(flex: 2, child: _center(r.rollNo)),
            pw.Expanded(flex: 4, child: _cell(r.name)),
            pw.Expanded(flex: 4, child: _cell(r.fatherName)),
            pw.Expanded(flex: 2, child: _center('${r.totalMarks}')),
            pw.Expanded(flex: 2, child: _center('${r.obtainedMarks}')),
            pw.Expanded(flex: 2, child: _center('${r.percentage.toStringAsFixed(1)}%')),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                passed ? 'کامیاب' : 'ناکام',
                textDirection: pw.TextDirection.rtl,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: passed ? PdfColors.green700 : PdfColors.red700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _cell(String value) {
    final text = value.trim().isEmpty ? '—' : value.trim();
    final isAscii = text.runes.every((r) => r < 0x80);
    return pw.Text(
      text,
      textDirection: isAscii ? pw.TextDirection.ltr : pw.TextDirection.rtl,
      textAlign: pw.TextAlign.right,
      style: const pw.TextStyle(fontSize: 9),
    );
  }

  static pw.Widget _center(String value) {
    return pw.Text(
      value,
      textDirection: pw.TextDirection.ltr,
      textAlign: pw.TextAlign.center,
      style: const pw.TextStyle(fontSize: 9),
    );
  }
}

/// نتیجہ شیٹ کی ایک قطار (فی طالب علم)
class ClassResultRow {
  ClassResultRow({
    required this.rollNo,
    required this.name,
    required this.fatherName,
    required this.totalMarks,
    required this.obtainedMarks,
  });

  final String rollNo;
  final String name;
  final String fatherName;
  final int totalMarks;
  final int obtainedMarks;

  double get percentage =>
      totalMarks > 0 ? (obtainedMarks / totalMarks) * 100 : 0;
}
