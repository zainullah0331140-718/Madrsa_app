import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection; // RTL ایرر سے بچنے کے لیے

import 'database_helper.dart';
import 'student_pdf.dart';
import 'student_photo_picker.dart';
import 'strings.dart';

class EditStudentPage extends StatefulWidget {
  final Map<String, dynamic> student; // پرانا ڈیٹا اس پیج میں لانے کے لیے

  const EditStudentPage({super.key, required this.student});

  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final nameCtrl = TextEditingController();
  final fnameCtrl = TextEditingController();
  final casteCtrl = TextEditingController();
  final cnicCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final ageCtrl = TextEditingController();
  final admissionDateCtrl = TextEditingController();
  final regNoCtrl = TextEditingController();
  final currentAddressCtrl = TextEditingController();
  final currentDistrictCtrl = TextEditingController();
  final permanentAddressCtrl = TextEditingController();
  final permanentDistrictCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final modernEduCtrl = TextEditingController();
  final otherCoursesCtrl = TextEditingController();
  final dischargeDateCtrl = TextEditingController();
  final classNameCtrl = TextEditingController();

  String? gender;
  String? residentialStatus;
  String? supportStatus;
  String? federalStatus;
  String? dischargeReason;
  String? photoPath;
  bool isGraduate = false;

  bool _printing = false;

  @override
  void initState() {
    super.initState();
    final s = widget.student;

    // جیسے ہی پیج کھلے گا، پرانا ڈیٹا خانوں میں بھر جائے گا
    nameCtrl.text = _str(s['name']);
    fnameCtrl.text = _str(s['fname']);
    casteCtrl.text = _str(s['caste']);
    cnicCtrl.text = _str(s['cnic']);
    dobCtrl.text = _str(s['dob']);
    ageCtrl.text = _str(s['age']);
    admissionDateCtrl.text = _str(s['admission_date']);
    regNoCtrl.text = _str(s['reg_no']);
    currentAddressCtrl.text = _str(s['current_address']);
    currentDistrictCtrl.text = _str(s['current_district']);
    permanentAddressCtrl.text = _str(s['permanent_address']);
    permanentDistrictCtrl.text = _str(s['permanent_district']);
    phoneCtrl.text = _str(s['phone']);
    modernEduCtrl.text = _str(s['modern_education']);
    otherCoursesCtrl.text = _str(s['other_courses']);
    dischargeDateCtrl.text = _str(s['discharge_date']);
    photoPath = normalizePhoto(s['photo']?.toString());
    classNameCtrl.text = _str(s['class_name']);

    gender = _validValue(_genderValues, s['gender']);
    residentialStatus = _validValue(_resValues, s['residential_status']);
    supportStatus = _validValue(_supportValues, s['support_status']);
    federalStatus = _validValue(_federalValues, s['federal_status']);
    dischargeReason = _validValue(_dischargeValues, s['discharge_reason']);
    isGraduate = s['is_graduate'] == 1 ||
        s['is_graduate'] == true ||
        s['is_graduate'].toString() == '1';
  }

  // درست اقدار (ڈیٹا بیس میں اردو قدر محفوظ ہوتی ہے)
  final _genderValues = ['مرد', 'عورت'];
  final _resValues = ['رہائشی', 'غیر رہائشی'];
  final _supportValues = ['امدادی', 'غیر امدادی'];
  final _federalValues = ['وفاقی', 'غیر وفاقی'];
  final _dischargeValues = ['تکمیل تعلیم', 'غیر حاضری', 'دیگر'];

  @override
  void dispose() {
    nameCtrl.dispose();
    fnameCtrl.dispose();
    casteCtrl.dispose();
    cnicCtrl.dispose();
    dobCtrl.dispose();
    ageCtrl.dispose();
    admissionDateCtrl.dispose();
    regNoCtrl.dispose();
    currentAddressCtrl.dispose();
    currentDistrictCtrl.dispose();
    permanentAddressCtrl.dispose();
    permanentDistrictCtrl.dispose();
    phoneCtrl.dispose();
    modernEduCtrl.dispose();
    otherCoursesCtrl.dispose();
    dischargeDateCtrl.dispose();
    classNameCtrl.dispose();
    super.dispose();
  }

  String _str(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    return text.toLowerCase() == 'null' ? '' : text;
  }

  String? _validValue(List<String> options, dynamic value) {
    final text = _str(value);
    return options.contains(text) ? text : null;
  }

  /// موجودہ فارم کا ڈیٹا (پرنٹ اور اپڈیٹ دونوں کے لیے)
  Map<String, dynamic> _currentData() {
    return {
      'id': widget.student['id'],
      'name': nameCtrl.text.trim(),
      'fname': fnameCtrl.text.trim(),
      'caste': casteCtrl.text.trim(),
      'gender': gender ?? '',
      'cnic': cnicCtrl.text.trim(),
      'dob': dobCtrl.text.trim(),
      'age': ageCtrl.text.trim(),
      'admission_date': admissionDateCtrl.text.trim(),
      'reg_no': regNoCtrl.text.trim(),
      'current_address': currentAddressCtrl.text.trim(),
      'current_district': currentDistrictCtrl.text.trim(),
      'permanent_address': permanentAddressCtrl.text.trim(),
      'permanent_district': permanentDistrictCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'modern_education': modernEduCtrl.text.trim(),
      'other_courses': otherCoursesCtrl.text.trim(),
      'residential_status': residentialStatus ?? '',
      'support_status': supportStatus ?? '',
      'federal_status': federalStatus ?? '',
      'is_graduate': isGraduate ? 1 : 0,
      'discharge_date': dischargeDateCtrl.text.trim(),
      'discharge_reason': dischargeReason ?? '',
      'photo': photoPath ?? '',
      'class_name': classNameCtrl.text.trim(),
    };
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime initial = DateTime.now();
    try {
      initial = DateFormat('MM/dd/yyyy').parseStrict(controller.text);
    } catch (_) {
      initial = DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1980),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _updateStudent() async {
    final s = Strings.current;
    if (nameCtrl.text.trim().isEmpty || fnameCtrl.text.trim().isEmpty) {
      _showSnack(s.nameFatherRequired, Colors.red);
      return;
    }

    try {
      await DatabaseHelper.instance.updateStudent(_currentData());
      if (!mounted) return;

      _showSnack(s.recordUpdated, Colors.green);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
    }
  }

  Future<void> _printProfile() async {
    final s = Strings.current;
    if (nameCtrl.text.trim().isEmpty || fnameCtrl.text.trim().isEmpty) {
      _showSnack(s.printBeforeName, Colors.red);
      return;
    }

    setState(() => _printing = true);
    try {
      await StudentPdfService.printProfile(context, _currentData());
      if (!mounted) return;
      _showSnack(s.profileReady, Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.printProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => _printing = false);
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
    final s = Strings.current;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.editStudentTitle),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: s.printProfile,
              icon: const Icon(Icons.print),
              onPressed: _printing ? null : _printProfile,
            ),
          ],
        ),
        body: AbsorbPointer(
          absorbing: _printing,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StudentPhotoPicker(
                  photoPath: photoPath,
                  onChanged: (path) => setState(() => photoPath = path),
                ),
                _sectionTitle(s.secPersonal),
                _fieldLabel(s.lName),
                _textField(nameCtrl),
                _fieldLabel(s.lFatherName),
                _textField(fnameCtrl),
                _fieldLabel(s.lCaste),
                _textField(casteCtrl, hint: s.lCaste),
                _fieldLabel(s.lGender),
                _dropdown(s.genderOptions, gender, (v) => setState(() => gender = v)),
                _fieldLabel(s.lCnic),
                _textField(cnicCtrl, isNumber: true),
                _fieldLabel(s.lDob),
                _dateField(dobCtrl),
                _fieldLabel(s.lAge),
                _textField(ageCtrl, isNumber: true),

                _sectionTitle(s.secAdmission),
                _fieldLabel(s.lAdmissionDate),
                _dateField(admissionDateCtrl),
                _fieldLabel(s.lRegNo),
                _textField(regNoCtrl),
                _fieldLabel(s.lClassName),
                _textField(classNameCtrl, hint: s.lClassName),

                _sectionTitle(s.secContact),
                _fieldLabel(s.lCurrentAddress),
                _textField(currentAddressCtrl),
                _fieldLabel(s.lCurrentDistrict),
                _textField(currentDistrictCtrl),
                _fieldLabel(s.lPermanentAddress),
                _textField(permanentAddressCtrl),
                _fieldLabel(s.lPermanentDistrict),
                _textField(permanentDistrictCtrl),
                _fieldLabel(s.lPhone),
                _textField(phoneCtrl, isNumber: true),

                _sectionTitle(s.secEducation),
                _fieldLabel(s.lModernEdu),
                _textField(modernEduCtrl),
                _fieldLabel(s.lOtherCourses),
                _textField(otherCoursesCtrl),

                _sectionTitle(s.secLiving),
                _fieldLabel(s.lResidential),
                _dropdown(s.resOptions, residentialStatus,
                    (v) => setState(() => residentialStatus = v)),
                _fieldLabel(s.lSupport),
                _dropdown(s.supportOptions, supportStatus,
                    (v) => setState(() => supportStatus = v)),
                _fieldLabel(s.lFederal),
                _dropdown(s.federalOptions, federalStatus,
                    (v) => setState(() => federalStatus = v)),
                CheckboxListTile(
                  title: Text(s.graduateTitle,
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                  subtitle: Text(s.graduateSubtitle,
                      style: const TextStyle(fontSize: 12)),
                  value: isGraduate,
                  onChanged: (val) => setState(() => isGraduate = val ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),

                _sectionTitle(s.secDischarge),
                _fieldLabel(s.lDischargeDate),
                _dateField(dischargeDateCtrl),
                _fieldLabel(s.lDischargeReason),
                _dropdown(s.dischargeOptions, dischargeReason,
                    (v) => setState(() => dischargeReason = v),
                    hint: s.selectDischargeHint),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.blue[800]!),
                        ),
                        onPressed: _printing ? null : _printProfile,
                        icon: const Icon(Icons.print),
                        label: Text(s.printProfile, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: _printing ? null : _updateStudent,
                        icon: const Icon(Icons.save),
                        label: Text(s.update, style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.only(top: 20, bottom: 4),
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
      child: Text(text,
          style: TextStyle(
              fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  Widget _dropdown(
    List<Opt> items,
    String? selectedValue,
    Function(String?) onChanged, {
    String? hint,
  }) {
    final valid = items.any((o) => o.value == selectedValue) ? selectedValue : null;
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      hint: Text(hint ?? Strings.current.selectHint),
      initialValue: valid,
      icon: const Icon(Icons.unfold_more, size: 20),
      items: items.map((Opt opt) {
        return DropdownMenuItem<String>(value: opt.value, child: Text(opt.ur));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _dateField(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      textAlign: TextAlign.right,
      onTap: () => _selectDate(context, ctrl),
      decoration: InputDecoration(
        hintText: 'mm/dd/yyyy',
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
