import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection; // RTL ایرر سے بچنے کے لیے

import 'database_helper.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({super.key});

  @override
  State<AddTeacherPage> createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
  final nameCtrl = TextEditingController();
  final fnameCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final salaryCtrl = TextEditingController();
  final joiningDateCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  String? designation;
  bool saving = false;

  final List<String> designations = [
    'ناظم',
    'مہتمم',
    'استاد',
    'معاون استاد',
    'حافظ',
    'قاری',
    'عملہ',
  ];

  @override
  void dispose() {
    nameCtrl.dispose();
    fnameCtrl.dispose();
    cnicCtrl.dispose();
    phoneCtrl.dispose();
    salaryCtrl.dispose();
    joiningDateCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        joiningDateCtrl.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveTeacher() async {
    if (nameCtrl.text.trim().isEmpty) {
      _showSnack('استاد کا نام لکھنا ضروری ہے!', Colors.red);
      return;
    }

    setState(() => saving = true);
    try {
      final teacher = {
        'name': nameCtrl.text.trim(),
        'fname': fnameCtrl.text.trim(),
        'cnic': cnicCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'designation': designation ?? '',
        'salary': int.tryParse(salaryCtrl.text.trim()) ?? 0,
        'joining_date': joiningDateCtrl.text.trim(),
        'address': addressCtrl.text.trim(),
        'is_active': 1,
      };

      await DatabaseHelper.instance.insertTeacher(teacher);
      if (!mounted) return;

      _showSnack('نیا استاد / عملہ کامیابی سے محفوظ ہو گیا!', Colors.green);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack('مسئلہ آ رہا ہے: $e', Colors.red);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          title: const Text('نیا استاد / عملہ شامل کریں',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green[800],
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: AbsorbPointer(
          absorbing: saving,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('ذاتی معلومات'),

                _fieldLabel('نام'),
                _textField(nameCtrl, hint: 'استاد / عملہ کا مکمل نام'),

                _fieldLabel('والد کا نام'),
                _textField(fnameCtrl),

                _fieldLabel('شناختی کارڈ نمبر'),
                _textField(cnicCtrl, isNumber: true),

                _fieldLabel('فون نمبر'),
                _textField(phoneCtrl, isNumber: true),

                _sectionTitle('ملازمت کی معلومات'),

                _fieldLabel('عہدہ'),
                _dropdown(),

                _fieldLabel('تنخواہ (ماہانہ)'),
                _textField(salaryCtrl, isNumber: true, hint: 'مثلاً 25000'),

                _fieldLabel('تاریخِ تقرری'),
                _dateField(),

                _fieldLabel('پتہ'),
                _textField(addressCtrl, maxLines: 3),

                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: saving ? null : _saveTeacher,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'محفوظ کریں',
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 4),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.green[800],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4, right: 5),
      child:
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
    );
  }

  Widget _textField(
    TextEditingController ctrl, {
    bool isNumber = false,
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  Widget _dropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      hint: const Text('-- عہدہ منتخب کریں --'),
      initialValue: designation,
      icon: const Icon(Icons.unfold_more, size: 20),
      items: designations
          .map((val) => DropdownMenuItem<String>(value: val, child: Text(val)))
          .toList(),
      onChanged: (val) => setState(() => designation = val),
    );
  }

  Widget _dateField() {
    return TextField(
      controller: joiningDateCtrl,
      readOnly: true,
      textAlign: TextAlign.right,
      onTap: _selectDate,
      decoration: InputDecoration(
        hintText: 'mm/dd/yyyy',
        filled: true,
        fillColor: Colors.white,
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
