import 'package:flutter/material.dart';

import 'add_teacher.dart';
import 'database_helper.dart';
import 'strings.dart';

/// اساتذہ و عملہ کی فہرست (شامل کریں / تبدیل کریں / ڈیلیٹ کریں)
class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  List<Map<String, dynamic>> staff = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await DatabaseHelper.instance.getTeachers();
      if (!mounted) return;
      setState(() {
        staff = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showSnack('${Strings.current.loadFailed}: $e', Colors.red);
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

  Future<void> _addStaff() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTeacherPage()),
    );
    if (!mounted) return;
    await _load();
    if (result == true) {
      _showSnack(Strings.current.dataSaved, Colors.green);
    }
  }

  Future<void> _deleteStaff(Map<String, dynamic> t) async {
    final s = Strings.current;
    final id = int.tryParse('${t['id']}');
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteTitle),
        content: Text(s.deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.yesDelete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await DatabaseHelper.instance.deleteTeacher(id);
      if (!mounted) return;
      _showSnack(s.recordDeleted, Colors.red);
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
    }
  }

  // ======================= تبدیل کا ڈائیلاگ =======================

  Future<void> _editStaff(Map<String, dynamic> t) async {
    final s = Strings.current;
    final id = int.tryParse('${t['id']}');
    if (id == null) return;

    final nameCtrl = TextEditingController(text: '${t['name'] ?? ''}');
    final fnameCtrl = TextEditingController(text: '${t['fname'] ?? ''}');
    final cnicCtrl = TextEditingController(text: '${t['cnic'] ?? ''}');
    final phoneCtrl = TextEditingController(text: '${t['phone'] ?? ''}');
    final salaryCtrl = TextEditingController(text: '${t['salary'] ?? ''}');
    final addressCtrl = TextEditingController(text: '${t['address'] ?? ''}');
    final rawDesignation = '${t['designation'] ?? ''}';
    String? designation = rawDesignation.isEmpty ? null : rawDesignation;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(s.editStaffTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogField(ctx, nameCtrl, s.lName),
                _dialogField(ctx, fnameCtrl, s.lFatherName),
                _dialogField(ctx, cnicCtrl, s.lCnic, isNumber: true),
                _dialogField(ctx, phoneCtrl, s.lPhone, isNumber: true),
                const SizedBox(height: 4),
                Text(s.designation,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  initialValue: designation,
                  isExpanded: true,
                  items: _designations
                      .map((d) =>
                          DropdownMenuItem<String>(value: d, child: Text(d)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => designation = v),
                ),
                const SizedBox(height: 8),
                _dialogField(ctx, salaryCtrl, s.basicSalary, isNumber: true),
                _dialogField(ctx, addressCtrl, s.lAddress, maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );

    final name = nameCtrl.text.trim();
    final fname = fnameCtrl.text.trim();
    final cnic = cnicCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final salary = int.tryParse(salaryCtrl.text.trim()) ?? 0;
    final address = addressCtrl.text.trim();
    nameCtrl.dispose();
    fnameCtrl.dispose();
    cnicCtrl.dispose();
    phoneCtrl.dispose();
    salaryCtrl.dispose();
    addressCtrl.dispose();

    if (saved != true) return;
    if (name.isEmpty) {
      _showSnack(s.teacherNameRequired, Colors.red);
      return;
    }

    try {
      await DatabaseHelper.instance.updateTeacher({
        'id': id,
        'name': name,
        'fname': fname,
        'cnic': cnic,
        'phone': phone,
        'designation': designation ?? '',
        'salary': salary,
        'address': address,
      });
      if (!mounted) return;
      _showSnack(s.recordUpdated, Colors.green);
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
    }
  }

  static const List<String> _designations = [
    'ناظم',
    'مہتمم',
    'استاد',
    'معاون استاد',
    'حافظ',
    'قاری',
    'عملہ',
  ];

  Widget _dialogField(
    BuildContext ctx,
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }

  // ======================= بلڈ =======================

  @override
  Widget build(BuildContext context) {
    final s = Strings.current;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.staffList),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: s.addStaff,
              icon: const Icon(Icons.person_add),
              onPressed: _addStaff,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addStaff,
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add),
          label: Text(s.addStaff),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : staff.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.noActiveStaff,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _addStaff,
                          icon: const Icon(Icons.person_add),
                          label: Text(s.addStaff),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: staff.length,
                    itemBuilder: (context, index) {
                      final t = staff[index];
                      final designation = '${t['designation'] ?? ''}';
                      final salary = '${t['salary'] ?? '0'}';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange[800],
                            child: Text(
                              '${t['name'] ?? ''}'.isEmpty
                                  ? '-'
                                  : '${t['name']}'[0],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text('${t['name'] ?? ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (designation.isNotEmpty)
                                Text('${s.designation}: $designation',
                                    style: const TextStyle(fontSize: 12)),
                              Text(
                                '${s.lFather}: ${t['fname'] ?? ''}  |  ${s.basicSalary}: $salary',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: s.edit,
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () => _editStaff(t),
                              ),
                              IconButton(
                                tooltip: s.delete,
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteStaff(t),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
