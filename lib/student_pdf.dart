import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:intl/intl.dart' show DateFormat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'image_store.dart';
import 'pdf_preview.dart';

/// طالب علم کے مکمل پروفائل کا PDF بنانے اور پرنٹ کرنے کی سروس
class StudentPdfService {
  StudentPdfService._();

  static const String _urduFontAsset =
      'assets/fonts/NotoNaskhArabic-Regular.ttf';

  static pw.Font? _urduFont;

  static final PdfColor _headerColor = PdfColor.fromInt(0xFF1B5E20);
  static final PdfColor _sectionColor = PdfColor.fromInt(0xFF2E7D32);
  static final PdfColor _borderColor = PdfColors.grey400;
  static final PdfColor _stripColor = PdfColors.grey100;

  /// اردو فونٹ صرف ایک بار لوڈ کیا جاتا ہے
  static Future<pw.Font> _loadFont() async {
    if (_urduFont != null) return _urduFont!;
    final data = await rootBundle.load(_urduFontAsset);
    _urduFont = pw.Font.ttf(data);
    return _urduFont!;
  }

  /// طالب علم کا ڈیٹا لے کر مکمل PDF ڈاکیومنٹ تیار کرنا
  static Future<pw.Document> buildDocument(Map<String, dynamic> student) async {
    final font = await _loadFont();
    final photo = await ImageStore.loadPdfImage(_str(student['photo']));
    final doc = pw.Document(
      title: 'طالب علم کا ریکارڈ',
      author: 'مدرسہ مینجمنٹ سسٹم',
      creator: 'Madarsa Management System',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 28, 28, 32),
        theme: pw.ThemeData.withFont(base: font, bold: font),
        textDirection: pw.TextDirection.rtl,
        header: (context) => _buildHeader(),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildTitle(student, photo),
          pw.SizedBox(height: 12),
          ..._buildSection('ذاتی معلومات', [
            _Field('نام', _str(student['name'])),
            _Field('والد کا نام', _str(student['fname'])),
            _Field('قوم', _str(student['caste'])),
            _Field('جنس', _str(student['gender'])),
            _Field('شناختی کارڈ نمبر', _str(student['cnic'])),
            _Field('تاریخ پیدائش', _str(student['dob'])),
            _Field('عمر', _str(student['age'])),
          ]),
          pw.SizedBox(height: 14),
          ..._buildSection('داخلہ و رجسٹریشن', [
            _Field('رجسٹریشن نمبر', _str(student['reg_no'])),
            _Field('داخلہ کی تاریخ', _str(student['admission_date'])),
          ]),
          pw.SizedBox(height: 14),
          ..._buildSection('رابطہ و پتہ', [
            _Field('موجودہ پتہ', _str(student['current_address'])),
            _Field('موجودہ ضلع', _str(student['current_district'])),
            _Field('مستقل پتہ', _str(student['permanent_address'])),
            _Field('مستقل ضلع', _str(student['permanent_district'])),
            _Field('فون نمبر', _str(student['phone'])),
          ]),
          pw.SizedBox(height: 14),
          ..._buildSection('تعلیمی معلومات', [
            _Field('عصری تعلیم', _str(student['modern_education'])),
            _Field('دیگر کورسز', _str(student['other_courses'])),
          ]),
          pw.SizedBox(height: 14),
          ..._buildSection('رہائش و امداد', [
            _Field('رہائشی حیثیت', _str(student['residential_status'])),
            _Field('امدادی حیثیت', _str(student['support_status'])),
            _Field('وفاقی حیثیت', _str(student['federal_status'])),
            _Field('فاضل التحصیل', _graduateText(student['is_graduate'])),
          ]),
          pw.SizedBox(height: 14),
          ..._buildSection('اخراج کی معلومات', [
            _Field('اخراج کی تاریخ', _str(student['discharge_date'])),
            _Field('اخراج کی وجہ', _str(student['discharge_reason'])),
          ]),
          pw.SizedBox(height: 40),
          _buildSignature(),
        ],
      ),
    );

    return doc;
  }

  /// PDF کے بائٹس تیار کرنا
  static Future<Uint8List> buildBytes(Map<String, dynamic> student) async {
    final doc = await buildDocument(student);
    return doc.save();
  }

  /// پیش‌نظارہ دکھاتا ہے (پرنٹ/سیو شیئر کے بٹن پیش‌نظارہ میں ہی ہیں)
  static Future<bool> printProfile(
      BuildContext context, Map<String, dynamic> student) async {
    final bytes = await buildBytes(student);
    final regNo = _str(student['reg_no']).replaceAll(RegExp(r'[^0-9A-Za-z]'), '');
    final fileName =
        'student_${regNo.isEmpty ? student['id'] ?? '' : regNo}.pdf';

    if (!context.mounted) return false;
    return showPdfPreview(context, bytes: bytes, fileName: fileName);
  }

  // ------------------------- مددگار widgets -------------------------

  static pw.Widget _buildHeader() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _borderColor, width: 1)),
      ),
      child: pw.Directionality(
        textDirection: pw.TextDirection.ltr,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _ltrText('Madarsa Management System', fontSize: 9, color: PdfColors.grey700),
            pw.Text(
              'مدرسہ مینجمنٹ سسٹم',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
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
            _ltrText(
              'Page ${context.pageNumber} / ${context.pagesCount}',
              fontSize: 9,
              color: PdfColors.grey700,
            ),
            pw.Row(
              children: [
                _ltrText(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
                pw.SizedBox(width: 4),
                pw.Text(
                  'تاریخِ اجراء:',
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTitle(Map<String, dynamic> student, pw.MemoryImage? photo) {
    final name = _str(student['name']);
    final titleColumn = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          'طالب علم کا مکمل ریکارڈ',
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(
            fontSize: 20,
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (name.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            name,
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(fontSize: 14, color: PdfColors.white),
          ),
        ],
      ],
    );

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: _headerColor,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: photo == null
          ? titleColumn
          : pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 70,
                  height: 70,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.white, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.ClipRRect(
                    horizontalRadius: 4,
                    verticalRadius: 4,
                    child: pw.Image(photo, fit: pw.BoxFit.cover),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(child: titleColumn),
              ],
            ),
    );
  }

  static List<pw.Widget> _buildSection(String title, List<_Field> fields) {
    final widgets = <pw.Widget>[
      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        decoration: pw.BoxDecoration(
          color: _sectionColor,
          borderRadius: const pw.BorderRadius.only(
            topLeft: pw.Radius.circular(5),
            topRight: pw.Radius.circular(5),
          ),
        ),
        child: pw.Text(
          title,
          textDirection: pw.TextDirection.rtl,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            fontSize: 13,
            color: PdfColors.white,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    ];

    for (var i = 0; i < fields.length; i++) {
      widgets.add(_buildFieldRow(fields[i], i.isOdd));
    }

    return widgets;
  }

  static pw.Widget _buildFieldRow(_Field field, bool striped) {
    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: pw.BoxDecoration(
          color: striped ? _stripColor : null,
          border: pw.Border(
            left: pw.BorderSide(color: _borderColor, width: 0.5),
            right: pw.BorderSide(color: _borderColor, width: 0.5),
            bottom: pw.BorderSide(color: _borderColor, width: 0.5),
          ),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(child: _valueText(field.value)),
            pw.Container(
              width: 0.5,
              height: 16,
              color: _borderColor,
              margin: const pw.EdgeInsets.symmetric(horizontal: 8),
            ),
            pw.SizedBox(
              width: 130,
              child: pw.Text(
                field.label,
                textDirection: pw.TextDirection.rtl,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSignature() {
    return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _signatureBox('دستخط ناظم'),
          _signatureBox('دستخط مدرس'),
        ],
      ),
    );
  }

  static pw.Widget _signatureBox(String label) {
    return pw.SizedBox(
      width: 180,
      child: pw.Column(
        children: [
          pw.Container(
            height: 30,
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black, width: 0.7)),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            textDirection: pw.TextDirection.rtl,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// اگر قدر صرف انگریزی/ہندسے ہوں تو اُنہیں بائیں سے دائیں لکھا جاتا ہے
  static pw.Widget _valueText(String value) {
    final text = value.trim().isEmpty ? '—' : value.trim();
    final isAscii = text.runes.every((r) => r < 0x80);

    return pw.Text(
      text,
      textDirection: isAscii ? pw.TextDirection.ltr : pw.TextDirection.rtl,
      textAlign: pw.TextAlign.right,
      style: const pw.TextStyle(fontSize: 12),
    );
  }

  static pw.Widget _ltrText(
    String text, {
    double fontSize = 10,
    PdfColor color = PdfColors.black,
  }) {
    return pw.Text(
      text,
      textDirection: pw.TextDirection.ltr,
      style: pw.TextStyle(fontSize: fontSize, color: color),
    );
  }

  static String _str(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return '';
    return text;
  }

  static String _graduateText(dynamic value) {
    final isGraduate = value == 1 || value == true || value.toString() == '1';
    return isGraduate ? 'ہاں' : 'نہیں';
  }
}

class _Field {
  const _Field(this.label, this.value);

  final String label;
  final String value;
}
