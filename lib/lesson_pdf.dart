import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:intl/intl.dart' show DateFormat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_preview.dart';

/// روز کے سبق کی فہرست پرنٹ کرنے کی سروس
class LessonPdfService {
  LessonPdfService._();

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
    required List<LessonData> lessons,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final font = await _loadFont();
    final doc = pw.Document(
      title: 'روز کا سبق',
      author: 'مدرسہ مینجمنٹ سسٹم',
      creator: 'Madarsa Management System',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 28, 24, 28),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        textDirection: pw.TextDirection.rtl,
        header: (context) => _buildHeader(instituteName),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 8),
          _buildTable(lessons),
        ],
      ),
    );

    return doc.save();
  }

  static Future<bool> printLessons({
    required BuildContext context,
    required List<LessonData> lessons,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final bytes =
        await buildBytes(lessons: lessons, instituteName: instituteName);
    if (!context.mounted) return false;
    return showPdfPreview(
      context,
      bytes: bytes,
      fileName: 'daily_lessons.pdf',
    );
  }

  // ------------------------- widgets -------------------------

  static pw.Widget _buildHeader(String instituteName) {
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
            'روز کا سبق',
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

  static pw.Widget _buildTable(List<LessonData> lessons) {
    final headers = ['نمبر', 'تاریخ', 'درجہ', 'مضمون', 'کتاب', 'سبق کا عنوان', 'تفصیل'];

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
                  pw.Expanded(flex: 2, child: _head(headers[2])),
                  pw.Expanded(flex: 2, child: _head(headers[3])),
                  pw.Expanded(flex: 2, child: _head(headers[4])),
                  pw.Expanded(flex: 3, child: _head(headers[5])),
                  pw.Expanded(flex: 3, child: _head(headers[6])),
                ],
              ),
            ),
          ),
          for (var i = 0; i < lessons.length; i++) _row(lessons[i], i, i.isOdd),
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

  static pw.Widget _row(LessonData l, int index, bool striped) {
    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Container(
        color: striped ? _stripColor : null,
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(flex: 1, child: _cell('${index + 1}', center: true)),
            pw.Expanded(flex: 2, child: _cell(l.date, center: true)),
            pw.Expanded(flex: 2, child: _cell(l.className)),
            pw.Expanded(flex: 2, child: _cell(l.subject)),
            pw.Expanded(flex: 2, child: _cell(l.book)),
            pw.Expanded(flex: 3, child: _cell(l.title)),
            pw.Expanded(flex: 3, child: _cell(l.details)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _cell(String value, {bool center = false}) {
    final text = value.trim().isEmpty ? '—' : value.trim();
    final isAscii = text.runes.every((r) => r < 0x80);
    return pw.Text(
      text,
      textDirection: isAscii ? pw.TextDirection.ltr : pw.TextDirection.rtl,
      textAlign: center ? pw.TextAlign.center : pw.TextAlign.right,
      style: const pw.TextStyle(fontSize: 9),
    );
  }
}

/// ایک سبق کے لیے ڈیٹا ماڈل
class LessonData {
  LessonData({
    required this.date,
    required this.className,
    required this.subject,
    required this.book,
    required this.title,
    required this.details,
  });

  final String date;
  final String className;
  final String subject;
  final String book;
  final String title;
  final String details;
}
