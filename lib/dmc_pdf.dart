import 'dart:typed_data';

import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' show DateFormat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_preview.dart';

/// کسی درجے کے تمام طلبہ کا ڈی ایم سی (DMC / Result Sheet) سرٹیفکیٹ بنانے اور پرنٹ کرنے کی سروس
class DmcPdfService {
  DmcPdfService._();

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

  /// ایک طالب علم کے لیے ایک ریکارڈ (نتائج کی قطاریں)
  static Future<pw.Document> buildDocument({
    required String className,
    required String examType,
    required List<DmcStudentData> students,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final font = await _loadFont();
    final doc = pw.Document(
      title: 'ڈی ایم سی - $className',
      author: 'مدرسہ مینجمنٹ سسٹم',
      creator: 'Madarsa Management System',
    );

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
          for (var i = 0; i < students.length; i++)
            _buildStudentCard(students[i], i + 1),
        ],
      ),
    );

    return doc;
  }

  static Future<Uint8List> buildBytes({
    required String className,
    required String examType,
    required List<DmcStudentData> students,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final doc = await buildDocument(
      className: className,
      examType: examType,
      students: students,
      instituteName: instituteName,
    );
    return doc.save();
  }

  static Future<bool> printDmc({
    required BuildContext context,
    required String className,
    required String examType,
    required List<DmcStudentData> students,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final bytes = await buildBytes(
      className: className,
      examType: examType,
      students: students,
      instituteName: instituteName,
    );
    final safeClass = className.replaceAll(RegExp(r'[^0-9A-Za-z؀-ۿ]'), '');
    if (!context.mounted) return false;
    return showPdfPreview(
      context,
      bytes: bytes,
      fileName: 'dmc_${safeClass.isEmpty ? 'class' : safeClass}.pdf',
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
            'درجہ: $className    |    امتحان: $examType',
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
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  'تاریخِ اجراء:',
                  textDirection: pw.TextDirection.rtl,
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildStudentCard(DmcStudentData student, int index) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderColor, width: 0.8),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // سرخی: نمبر، نام، والد کا نام
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: pw.BoxDecoration(
              color: _headerColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(5),
                topRight: pw.Radius.circular(5),
              ),
            ),
            child: pw.Directionality(
              textDirection: pw.TextDirection.ltr,
              child: pw.Row(
                children: [
                  // نمبر (بائیں جانب)
                  pw.Container(
                    padding:
                        const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      '$index',
                      textDirection: pw.TextDirection.ltr,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: _headerColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'نام: ${student.name}',
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 13,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'والد کا نام: ${student.fatherName}',
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(
                              fontSize: 11, color: PdfColors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // تفصیل: نمبر، نام، والد، درجہ، شہر
          pw.Directionality(
            textDirection: pw.TextDirection.ltr,
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    pw.Expanded(child: _infoCell('نمبر', '$index')),
                    _vDivider(),
                    pw.Expanded(
                        flex: 2, child: _infoCell('نام', student.name)),
                    _vDivider(),
                    pw.Expanded(
                        flex: 2, child: _infoCell('والد کا نام', student.fatherName)),
                  ],
                ),
                pw.Container(
                  height: 0.5,
                  color: _borderColor,
                ),
                pw.Row(
                  children: [
                    pw.Expanded(child: _infoCell('درجہ', student.className)),
                    _vDivider(),
                    pw.Expanded(
                        child: _infoCell(
                            'شہر', student.city.isEmpty ? '—' : student.city)),
                    _vDivider(),
                    pw.Expanded(
                        child: _infoCell(
                            'رول نمبر', student.rollNo.isEmpty ? '—' : student.rollNo)),
                  ],
                ),
              ],
            ),
          ),

          // مضامین کی میز
          _subjectTable(student),
        ],
      ),
    );
  }

  static pw.Widget _infoCell(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            textDirection: pw.TextDirection.rtl,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 2),
          _valueText(value, fontSize: 11, bold: true),
        ],
      ),
    );
  }

  static pw.Widget _subjectTable(DmcStudentData student) {
    final rows = student.subjects;
    final headers = ['مضمون', 'کل نمبر', 'حاصل کردہ', 'فی صد'];

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _borderColor, width: 0.5)),
      ),
      child: pw.Column(
        children: [
          // ہیڈر قطار
          pw.Directionality(
            textDirection: pw.TextDirection.ltr,
            child: pw.Container(
              color: _sectionColor,
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Row(
                children: [
                  pw.Expanded(
                      flex: 3,
                      child: _tableHead(headers[0])),
                  pw.Expanded(child: _tableHead(headers[1])),
                  pw.Expanded(child: _tableHead(headers[2])),
                  pw.Expanded(child: _tableHead(headers[3])),
                ],
              ),
            ),
          ),
          for (var i = 0; i < rows.length; i++) _tableRow(rows[i], i.isOdd),

          // کل نمبروں کی قطار
          _totalRow(student),
        ],
      ),
    );
  }

  static pw.Widget _tableHead(String text) {
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

  static pw.Widget _tableRow(DmcSubjectData row, bool striped) {
    final pct = row.totalMarks > 0
        ? ((row.obtainedMarks / row.totalMarks) * 100).toStringAsFixed(1)
        : '0';
    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Container(
        color: striped ? _stripColor : null,
        padding: const pw.EdgeInsets.symmetric(vertical: 5),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                child: _valueText(row.subject, fontSize: 10),
              ),
            ),
            pw.Expanded(child: _centerText('${row.totalMarks}')),
            pw.Expanded(child: _centerText('${row.obtainedMarks}')),
            pw.Expanded(child: _centerText('$pct%')),
          ],
        ),
      ),
    );
  }

  static pw.Widget _totalRow(DmcStudentData student) {
    final total = student.totalMarks;
    final obtained = student.obtainedMarks;
    final pct =
        total > 0 ? ((obtained / total) * 100).toStringAsFixed(1) : '0';

    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Container(
        decoration: pw.BoxDecoration(
          color: PdfColors.green50,
          border: pw.Border(top: pw.BorderSide(color: _borderColor, width: 0.5)),
        ),
        padding: const pw.EdgeInsets.symmetric(vertical: 6),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 3,
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6),
                child: pw.Text(
                  'کل مجموعہ',
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: _headerColor),
                ),
              ),
            ),
            pw.Expanded(child: _centerText('$total', bold: true)),
            pw.Expanded(child: _centerText('$obtained', bold: true)),
            pw.Expanded(child: _centerText('$pct%', bold: true)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _vDivider() {
    return pw.Container(
      width: 0.5,
      height: 25,
      color: _borderColor,
    );
  }

  static pw.Widget _centerText(String text, {bool bold = false}) {
    return pw.Text(
      text,
      textDirection: pw.TextDirection.ltr,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: bold ? _headerColor : PdfColors.black,
      ),
    );
  }

  static pw.Widget _valueText(String value,
      {double fontSize = 11, bool bold = false}) {
    final text = value.trim().isEmpty ? '—' : value.trim();
    final isAscii = text.runes.every((r) => r < 0x80);
    return pw.Text(
      text,
      textDirection: isAscii ? pw.TextDirection.ltr : pw.TextDirection.rtl,
      textAlign: pw.TextAlign.right,
      style: pw.TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    );
  }
}

/// ایک طالب علم کے ڈی ایم سی کے لیے ڈیٹا ماڈل
class DmcStudentData {
  DmcStudentData({
    required this.name,
    required this.fatherName,
    required this.className,
    required this.rollNo,
    required this.city,
    required this.subjects,
  });

  final String name;
  final String fatherName;
  final String className;
  final String rollNo;
  final String city;
  final List<DmcSubjectData> subjects;

  int get totalMarks => subjects.fold(0, (sum, s) => sum + s.totalMarks);
  int get obtainedMarks => subjects.fold(0, (sum, s) => sum + s.obtainedMarks);
}

class DmcSubjectData {
  DmcSubjectData(this.subject, this.totalMarks, this.obtainedMarks);

  final String subject;
  final int totalMarks;
  final int obtainedMarks;
}
