import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:intl/intl.dart' show DateFormat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_preview.dart';

/// تنخواہ رجسٹر اور تنخواہ پرچی (Pay Slip) پرنٹ کرنے کی سروس
class SalaryPdfService {
  SalaryPdfService._();

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

  // ------------------------- تنخواہ رجسٹر (فہرست) -------------------------

  static Future<bool> printRegister({
    required BuildContext context,
    required List<SalaryRow> rows,
    String? month,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final font = await _loadFont();
    final doc = pw.Document(
      title: 'تنخواہ رجسٹر',
      author: 'مدرسہ مینجمنٹ سسٹم',
      creator: 'Madarsa Management System',
    );

    final title = month == null || month.trim().isEmpty
        ? 'تنخواہ رجسٹر'
        : 'تنخواہ رجسٹر - $month';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(24, 28, 24, 28),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        textDirection: pw.TextDirection.rtl,
        header: (context) => _buildHeader(instituteName, title),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 8),
          _buildRegisterSummary(rows),
          pw.SizedBox(height: 10),
          _buildRegisterTable(rows),
        ],
      ),
    );

    final bytes = await doc.save();
    if (!context.mounted) return false;
    return showPdfPreview(
      context,
      bytes: bytes,
      fileName: 'salary_register.pdf',
    );
  }

  // ------------------------- ایک تنخواہ کا پرچی (Pay Slip) -------------------------

  static Future<bool> printPaySlip({
    required BuildContext context,
    required SalaryRow row,
    String instituteName = 'مدرسہ مینجمنٹ سسٹم',
  }) async {
    final font = await _loadFont();
    final doc = pw.Document(
      title: 'تنخواہ پرچی - ${row.teacherName}',
      author: 'مدرسہ مینجمنٹ سسٹم',
      creator: 'Madarsa Management System',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.fromLTRB(24, 28, 24, 28),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          _buildHeader(instituteName, 'تنخواہ پرچی'),
          pw.SizedBox(height: 12),
          _buildPaySlipBody(row),
        ],
      ),
    );

    final bytes = await doc.save();
    final safeName = row.teacherName.replaceAll(RegExp(r'[^0-9A-Za-z؀-ۿ]'), '');
    if (!context.mounted) return false;
    return showPdfPreview(
      context,
      bytes: bytes,
      fileName: 'pay_slip_${safeName.isEmpty ? 'salary' : safeName}.pdf',
    );
  }

  // ------------------------- widgets -------------------------

  static pw.Widget _buildHeader(String instituteName, String title) {
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
            title,
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

  static pw.Widget _buildRegisterSummary(List<SalaryRow> rows) {
    int totalNet = 0;
    int paid = 0;
    int pending = 0;
    for (final r in rows) {
      totalNet += r.netPay;
      if (r.status == 'ادا شدہ') {
        paid++;
      } else {
        pending++;
      }
    }

    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          _summaryChip('کل: ${rows.length}', _headerColor),
          pw.SizedBox(width: 6),
          _summaryChip('ادا شدہ: $paid', PdfColors.green700),
          pw.SizedBox(width: 6),
          _summaryChip('غیر ادا شدہ: $pending', PdfColors.red700),
          pw.SizedBox(width: 6),
          _summaryChip('کل خالص: $totalNet', PdfColors.teal800),
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

  static pw.Widget _buildRegisterTable(List<SalaryRow> rows) {
    final headers = [
      'نمبر',
      'نام',
      'عہدہ',
      'مہینہ',
      'بنیادی',
      'الاؤنس',
      'کٹوتی',
      'خالص',
      'حالت',
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
                  pw.Expanded(flex: 4, child: _head(headers[1])),
                  pw.Expanded(flex: 3, child: _head(headers[2])),
                  pw.Expanded(flex: 2, child: _head(headers[3])),
                  pw.Expanded(flex: 2, child: _head(headers[4])),
                  pw.Expanded(flex: 2, child: _head(headers[5])),
                  pw.Expanded(flex: 2, child: _head(headers[6])),
                  pw.Expanded(flex: 2, child: _head(headers[7])),
                  pw.Expanded(flex: 2, child: _head(headers[8])),
                ],
              ),
            ),
          ),
          for (var i = 0; i < rows.length; i++)
            _registerRow(rows[i], i, i.isOdd),
        ],
      ),
    );
  }

  static pw.Widget _registerRow(SalaryRow r, int index, bool striped) {
    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Container(
        color: striped ? _stripColor : null,
        padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: pw.Row(
          children: [
            pw.Expanded(flex: 1, child: _center('${index + 1}')),
            pw.Expanded(flex: 4, child: _cell(r.teacherName)),
            pw.Expanded(flex: 3, child: _cell(r.designation)),
            pw.Expanded(flex: 2, child: _center(r.month)),
            pw.Expanded(flex: 2, child: _center('${r.basic}')),
            pw.Expanded(flex: 2, child: _center('${r.allowance}')),
            pw.Expanded(flex: 2, child: _center('${r.deduction}')),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                '${r.netPay}',
                textDirection: pw.TextDirection.ltr,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal800),
              ),
            ),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                r.status.isEmpty ? '—' : r.status,
                textDirection: pw.TextDirection.rtl,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: r.status == 'ادا شدہ'
                      ? PdfColors.green700
                      : PdfColors.red700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------- پرچی کی جسم -------------------------

  static pw.Widget _buildPaySlipBody(SalaryRow r) {
    pw.Widget field(String label, String value, {bool highlight = false}) {
      return pw.Container(
        padding:
            const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: pw.BoxDecoration(
          border:
              pw.Border(bottom: pw.BorderSide(color: _borderColor, width: 0.5)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey800,
                fontWeight: highlight
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal,
              ),
            ),
            pw.Text(
              value.trim().isEmpty ? '—' : value,
              textDirection: _isRtl(value)
                  ? pw.TextDirection.rtl
                  : pw.TextDirection.ltr,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: highlight ? _headerColor : PdfColors.black,
              ),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _headerColor, width: 1.2),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          field('نام', r.teacherName, highlight: true),
          field('عہدہ', r.designation),
          field('مہینہ', r.month, highlight: true),
          field('بنیادی تنخواہ', '${r.basic}'),
          field('الاؤنس', '${r.allowance}'),
          field('کٹوتی', '${r.deduction}'),
          pw.SizedBox(height: 6),
          field('خالص تنخواہ', '${r.netPay}', highlight: true),
          field('حالت', r.status),
          if (r.paymentDate.isNotEmpty)
            field('ادائیگی کی تاریخ', r.paymentDate),
          if (r.remarks.isNotEmpty) field('کیفیت', r.remarks),
          pw.SizedBox(height: 22),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'دستخطِ آمین:',
                textDirection: pw.TextDirection.rtl,
                style: const pw.TextStyle(
                    fontSize: 11, color: PdfColors.grey800),
              ),
              pw.Text(
                'دستخطِ منتقل کنندہ:',
                textDirection: pw.TextDirection.rtl,
                style: const pw.TextStyle(
                    fontSize: 11, color: PdfColors.grey800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static bool _isRtl(String text) {
    if (text.trim().isEmpty) return true;
    return text.runes.any((r) => r >= 0x0600 && r <= 0x06FF);
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

  static pw.Widget _cell(String value) {
    final text = value.trim().isEmpty ? '—' : value.trim();
    return pw.Text(
      text,
      textDirection: _isRtl(text) ? pw.TextDirection.rtl : pw.TextDirection.ltr,
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

/// تنخواہ رپورٹ کی ایک قطار
class SalaryRow {
  SalaryRow({
    required this.teacherName,
    required this.designation,
    required this.month,
    required this.basic,
    required this.allowance,
    required this.deduction,
    required this.netPay,
    required this.status,
    required this.paymentDate,
    required this.remarks,
  });

  final String teacherName;
  final String designation;
  final String month;
  final int basic;
  final int allowance;
  final int deduction;
  final int netPay;
  final String status;
  final String paymentDate;
  final String remarks;
}
