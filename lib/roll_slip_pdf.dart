import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_preview.dart';

/// طلبہ کے رول نمبر سلپ پرنٹ کرنے کی سروس
class RollSlipPdfService {
  RollSlipPdfService._();

  static const String _urduFontAsset =
      'assets/fonts/NotoNaskhArabic-Regular.ttf';

  static pw.Font? _urduFont;

  static final PdfColor _headerColor = PdfColor.fromInt(0xFF1B5E20);
  static final PdfColor _borderColor = PdfColors.grey500;

  static Future<pw.Font> _loadFont() async {
    if (_urduFont != null) return _urduFont!;
    final data = await rootBundle.load(_urduFontAsset);
    _urduFont = pw.Font.ttf(data);
    return _urduFont!;
  }

  static Future<Uint8List> buildBytes({
    required List<RollStudent> students,
    String? className,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final font = await _loadFont();
    final doc = pw.Document(
      title: 'رول نمبر سلپ',
      author: 'مدرسہ مینجمنٹ سسٹم',
      creator: 'Madarsa Management System',
    );

    const perPage = 4; // ایک صفحے پر 4 سلپ

    for (var i = 0; i < students.length; i += perPage) {
      final chunk = students.sublist(
        i,
        (i + perPage) > students.length ? students.length : i + perPage,
      );

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(base: font, bold: font),
          textDirection: pw.TextDirection.rtl,
          build: (context) => pw.Column(
            children: [
              for (var j = 0; j < chunk.length; j++) ...[
                _buildSlip(chunk[j], instituteName, className),
                if (j != chunk.length - 1) pw.SizedBox(height: 16),
              ],
            ],
          ),
        ),
      );
    }

    return doc.save();
  }

  static Future<bool> printSlips({
    required BuildContext context,
    required List<RollStudent> students,
    String? className,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final bytes = await buildBytes(
      students: students,
      className: className,
      instituteName: instituteName,
    );
    if (!context.mounted) return false;
    return showPdfPreview(
      context,
      bytes: bytes,
      fileName: 'roll_slips.pdf',
    );
  }

  static pw.Widget _buildSlip(
      RollStudent student, String instituteName, String? className) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor, width: 0.8),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // سرخی
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: pw.BoxDecoration(
              color: _headerColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(7),
                topRight: pw.Radius.circular(7),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'رول نمبر سلپ',
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  instituteName,
                  textDirection: pw.TextDirection.rtl,
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
                ),
              ],
            ),
          ),

          pw.Padding(
            padding: const pw.EdgeInsets.all(14),
            child: pw.Directionality(
              textDirection: pw.TextDirection.ltr,
              child: pw.Row(
                children: [
                  // بڑا رول نمبر باکس
                  pw.Container(
                    width: 110,
                    height: 90,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: _headerColor, width: 1),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(
                          'رول نمبر',
                          textDirection: pw.TextDirection.rtl,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          student.rollNo.isEmpty ? '—' : student.rollNo,
                          textDirection: pw.TextDirection.ltr,
                          style: pw.TextStyle(
                            fontSize: 26,
                            color: _headerColor,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // تفصیل
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _infoLine('نام', student.name),
                        pw.SizedBox(height: 5),
                        _infoLine('والد کا نام', student.fatherName),
                        if ((className ?? student.className).trim().isNotEmpty) ...[
                          pw.SizedBox(height: 5),
                          _infoLine('درجہ',
                              (className ?? student.className).trim()),
                        ],
                        if (student.regNo.trim().isNotEmpty) ...[
                          pw.SizedBox(height: 5),
                          _infoLine('رجسٹریشن نمبر', student.regNo),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _infoLine(String label, String value) {
    final text = value.trim().isEmpty ? '—' : value.trim();
    final isAscii = text.runes.every((r) => r < 0x80);
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 100,
          child: pw.Text(
            label,
            textDirection: pw.TextDirection.rtl,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          ':',
          textDirection: pw.TextDirection.rtl,
          style: const pw.TextStyle(fontSize: 11),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            text,
            textDirection: isAscii ? pw.TextDirection.ltr : pw.TextDirection.rtl,
            textAlign: pw.TextAlign.left,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// رول سلپ کے لیے طالب علم
class RollStudent {
  RollStudent({
    required this.rollNo,
    required this.name,
    required this.fatherName,
    required this.className,
    required this.regNo,
  });

  final String rollNo;
  final String name;
  final String fatherName;
  final String className;
  final String regNo;
}
