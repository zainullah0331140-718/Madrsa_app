import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection; // یہاں hide TextDirection کا اضافہ کیا ہے تاکہ rtl کا ایرر نہ آئے
import 'database_helper.dart';
import 'strings.dart';
import 'student_photo_picker.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
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
  bool isGraduate = false;
  String? photoPath;

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<void> _saveStudent() async {
    final s = Strings.current;
    if (nameCtrl.text.isEmpty || fnameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.nameFatherRequired), backgroundColor: Colors.red),
      );
      return;
    }

    Map<String, dynamic> row = {
      'name': nameCtrl.text,
      'fname': fnameCtrl.text,
      'caste': casteCtrl.text,
      'gender': gender ?? '',
      'cnic': cnicCtrl.text,
      'dob': dobCtrl.text,
      'age': ageCtrl.text,
      'admission_date': admissionDateCtrl.text,
      'reg_no': regNoCtrl.text,
      'current_address': currentAddressCtrl.text,
      'current_district': currentDistrictCtrl.text,
      'permanent_address': permanentAddressCtrl.text,
      'permanent_district': permanentDistrictCtrl.text,
      'phone': phoneCtrl.text,
      'modern_education': modernEduCtrl.text,
      'other_courses': otherCoursesCtrl.text,
      'residential_status': residentialStatus ?? '',
      'support_status': supportStatus ?? '',
      'federal_status': federalStatus ?? '',
      'is_graduate': isGraduate ? 1 : 0,
      'discharge_date': dischargeDateCtrl.text,
      'discharge_reason': dischargeReason ?? '',
      'photo': photoPath ?? '',
      'class_name': classNameCtrl.text.trim(),
    };

    try {
      await DatabaseHelper.instance.insertStudent(row);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.dataSaved), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.current;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(s.studentForm),
            centerTitle: true,
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: s.tabPrevSchools),
                Tab(text: s.tabCurrentClass),
                Tab(text: s.tabLessonTrack),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildMainForm(s),
              Center(child: Text(s.currentClassPlaceholder)),
              Center(child: Text(s.lessonTrackPlaceholder)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainForm(Strings s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudentPhotoPicker(
            photoPath: photoPath,
            onChanged: (path) => setState(() => photoPath = path),
          ),
          const SizedBox(height: 12),

          _buildFieldLabel(s.lName),
          _buildTextField(nameCtrl),

          _buildFieldLabel(s.lFatherName),
          _buildTextField(fnameCtrl),

          _buildFieldLabel(s.lCaste),
          _buildTextField(casteCtrl, hint: s.lCaste),

          _buildFieldLabel(s.lGender),
          _buildDropdown(s.genderOptions, gender, (val) => setState(() => gender = val)),

          _buildFieldLabel(s.lCnic),
          _buildTextField(cnicCtrl, isNumber: true),

          _buildFieldLabel(s.lDob),
          _buildDatePickerField(dobCtrl),

          _buildFieldLabel(s.lAge),
          _buildTextField(ageCtrl, isNumber: true),

          _buildFieldLabel(s.lAdmissionDate),
          _buildDatePickerField(admissionDateCtrl),

          _buildFieldLabel(s.lRegNo),
          _buildTextField(regNoCtrl),

          _buildFieldLabel(s.lClassName),
          _buildTextField(classNameCtrl, hint: s.lClassName),

          _buildFieldLabel(s.lCurrentAddress),
          _buildTextField(currentAddressCtrl),

          _buildFieldLabel(s.lCurrentDistrict),
          _buildTextField(currentDistrictCtrl),

          _buildFieldLabel(s.lPermanentAddress),
          _buildTextField(permanentAddressCtrl),

          _buildFieldLabel(s.lPermanentDistrict),
          _buildTextField(permanentDistrictCtrl),

          _buildFieldLabel(s.lPhone),
          _buildTextField(phoneCtrl, isNumber: true),

          _buildFieldLabel(s.lModernEdu),
          _buildTextField(modernEduCtrl),

          _buildFieldLabel(s.lOtherCourses),
          _buildTextField(otherCoursesCtrl),

          _buildFieldLabel(s.lResidential),
          _buildDropdown(s.resOptions, residentialStatus, (val) => setState(() => residentialStatus = val)),

          _buildFieldLabel(s.lSupport),
          _buildDropdown(s.supportOptions, supportStatus, (val) => setState(() => supportStatus = val)),

          _buildFieldLabel(s.lFederal),
          _buildDropdown(s.federalOptions, federalStatus, (val) => setState(() => federalStatus = val)),

          CheckboxListTile(
            title: Text(s.graduateTitle, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            subtitle: Text(s.graduateSubtitle, style: const TextStyle(fontSize: 12)),
            value: isGraduate,
            onChanged: (val) => setState(() => isGraduate = val!),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),

          _buildFieldLabel(s.lDischargeDate),
          _buildDatePickerField(dischargeDateCtrl),

          _buildFieldLabel(s.lDischargeReason),
          _buildDropdown(s.dischargeOptions, dischargeReason, (val) => setState(() => dischargeReason = val), hint: s.selectDischargeHint),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: _saveStudent,
              child: Text(s.save, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4, right: 5),
      child: Text(text, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, {bool isNumber = false, String? hint}) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<Opt> items, String? selectedValue, Function(String?) onChanged, {String hint = '-- منتخب کریں --'}) {
    final valid = items.any((o) => o.value == selectedValue) ? selectedValue : null;
    return SizedBox(
      height: 40,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
        hint: Text(hint),
        initialValue: valid,
        icon: const Icon(Icons.unfold_more, size: 20),
        items: items.map((Opt opt) {
          return DropdownMenuItem(value: opt.value, child: Text(opt.ur));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePickerField(TextEditingController ctrl) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: ctrl,
        readOnly: true,
        onTap: () => _selectDate(context, ctrl),
        decoration: InputDecoration(
          hintText: 'mm/dd/yyyy',
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }
}
