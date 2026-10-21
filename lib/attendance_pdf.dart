import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:intl/intl.dart' show DateFormat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_preview.dart';

/// حاضری رجسٹر پرنٹ کرنے کی سروس
class AttendancePdfService {
  AttendancePdfService._();

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
    required List<AttendanceRow> rows,
    required String date,
    String? className,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final font = await _loadFont();
    final doc = pw.Document(
      title: 'حاضری - $date',
      author: 'مدرسہ مینجمنٹ سسٹم',
      creator: 'Madarsa Management System',
    );

    final title = className == null || className.trim().isEmpty
        ? 'حاضری رجسٹر'
        : 'حاضری رجسٹر - $className';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 28, 24, 28),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        textDirection: pw.TextDirection.rtl,
        header: (context) => _buildHeader(instituteName, title, date),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 8),
          _buildSummary(rows),
          pw.SizedBox(height: 10),
          _buildTable(rows),
        ],
      ),
    );

    return doc.save();
  }

  static Future<bool> printAttendance({
    required BuildContext context,
    required List<AttendanceRow> rows,
    required String date,
    String? className,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final bytes = await buildBytes(
      rows: rows,
      date: date,
      className: className,
      instituteName: instituteName,
    );
    if (!context.mounted) return false;
    return showPdfPreview(
      context,
      bytes: bytes,
      fileName: 'attendance_${date.replaceAll(RegExp(r'[^0-9]'), '_')}.pdf',
    );
  }

  // ------------------------- widgets -------------------------

  static pw.Widget _buildHeader(
      String instituteName, String title, String date) {
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
            '$title    |    تاریخ: $date',
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

  static pw.Widget _buildSummary(List<AttendanceRow> rows) {
    int present = 0, absent = 0, leave = 0;
    for (final r in rows) {
      if (r.status == 'حاضر') {
        present++;
      } else if (r.status == 'غائب') {
        absent++;
      } else if (r.status == 'رخصت') {
        leave++;
      }
    }

    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          _summaryChip('کل: ${rows.length}', _headerColor),
          pw.SizedBox(width: 6),
          _summaryChip('حاضر: $present', PdfColors.green700),
          pw.SizedBox(width: 6),
          _summaryChip('غائب: $absent', PdfColors.red700),
          pw.SizedBox(width: 6),
          _summaryChip('رخصت: $leave', PdfColors.amber800),
        ],
      ),
    );
  }

  static pw.Widget _summaryChip(String label, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 0.7),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        label,
        textDirection: pw.TextDirection.rtl,
        style: pw.TextStyle(
            fontSize: 9, color: color, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildTable(List<AttendanceRow> rows) {
    final headers = ['نمبر', 'رول نمبر', 'نام', 'والد کا نام', 'درجہ', 'حالت'];

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
        fontSize: 10,
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
    );
  }

  static pw.Widget _row(AttendanceRow r, int index, bool striped) {
    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Container(
        color: striped ? _stripColor : null,
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: pw.Row(
          children: [
            pw.Expanded(flex: 1, child: _center('${index + 1}')),
            pw.Expanded(flex: 2, child: _center(r.regNo)),
            pw.Expanded(flex: 4, child: _cell(r.name)),
            pw.Expanded(flex: 4, child: _cell(r.fatherName)),
            pw.Expanded(flex: 2, child: _cell(r.className)),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                r.status.isEmpty ? '—' : r.status,
                textDirection: pw.TextDirection.rtl,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: r.status == 'غائب'
                      ? PdfColors.red700
                      : (r.status == 'رخصت'
                          ? PdfColors.amber800
                          : PdfColors.green700),
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
      style: const pw.TextStyle(fontSize: 10),
    );
  }

  static pw.Widget _center(String value) {
    return pw.Text(
      value,
      textDirection: pw.TextDirection.ltr,
      textAlign: pw.TextAlign.center,
      style: const pw.TextStyle(fontSize: 10),
    );
  }
}

/// حاضری رپورٹ کی ایک قطار
class AttendanceRow {
  AttendanceRow({
    required this.regNo,
    required this.name,
    required this.fatherName,
    required this.className,
    required this.status,
  });

  final String regNo;
  final String name;
  final String fatherName;
  final String className;
  final String status;
}
