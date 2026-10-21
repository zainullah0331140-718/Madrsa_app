import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection; // RTL ایرر سے بچنے کے لیے

import 'database_helper.dart';
import 'strings.dart';

class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});

  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> students = [];

  // ہر طالب علم کی منتخب حاضری (student_id -> حاضر / غائب / رخصت)
  final Map<int, String> statuses = {};

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ڈیٹا بیس میں تاریخ ہمیشہ mm/dd/yyyy فارمیٹ میں محفوظ ہوتی ہے
  String get _dateKey => DateFormat('MM/dd/yyyy').format(selectedDate);

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final list = await DatabaseHelper.instance.getActiveStudents();
      final saved =
          await DatabaseHelper.instance.getStudentAttendanceByDate(_dateKey);

      if (!mounted) return;

      final newStatuses = <int, String>{};

      // پہلے سے محفوظ حاضری ہو تو وہ لوڈ کریں
      for (final row in saved) {
        final sid = int.tryParse('${row['student_id']}');
        if (sid != null) newStatuses[sid] = '${row['status']}';
      }

      // نئے طلبہ کے لیے ڈیفالٹ "حاضر"
      for (final s in list) {
        final sid = int.tryParse('${s['id']}');
        if (sid != null && !newStatuses.containsKey(sid)) {
          newStatuses[sid] = 'حاضر';
        }
      }

      setState(() {
        students = list;
        statuses
          ..clear()
          ..addAll(newStatuses);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showSnack('${Strings.current.loadFailed}: $e', Colors.red);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (!mounted || picked == null) return;
    setState(() => selectedDate = picked);
    // نئی تاریخ کی محفوظ حاضری دوبارہ لوڈ کریں
    await _loadData();
  }

  Future<void> _saveAttendance() async {
    final s = Strings.current;
    if (students.isEmpty) {
      _showSnack(s.noDataToSave, Colors.red);
      return;
    }

    setState(() => saving = true);
    try {
      await DatabaseHelper.instance.saveStudentAttendance(_dateKey, statuses);
      if (!mounted) return;
      _showSnack(s.attendanceSaved, Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
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
    final s = Strings.current;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(s.attendanceTitle),
          centerTitle: true,
        ),
        body: AbsorbPointer(
          absorbing: saving,
          child: Column(
            children: [
              _dateCard(s),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : students.isEmpty
                        ? _emptyMessage(s.noActiveStudents)
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemCount: students.length,
                            itemBuilder: (context, index) =>
                                _studentTile(s, students[index]),
                          ),
              ),
              _saveButton(s),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------- تاریخ + خلاصہ -------------------------

  Widget _dateCard(Strings s) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.green),
                  const SizedBox(width: 10),
                  Text(
                    '${s.dateLabel}: $_dateKey',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, size: 26),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _countChip(s, s.students, students.length, Colors.blue),
              _countChip(s, s.present, _count('حاضر'), Colors.green),
              _countChip(s, s.absent, _count('غائب'), Colors.red),
              _countChip(s, s.leave, _count('رخصت'), Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  int _count(String status) {
    int c = 0;
    for (final s in students) {
      final sid = int.tryParse('${s['id']}');
      if (sid != null && statuses[sid] == status) c++;
    }
    return c;
  }

  Widget _countChip(Strings s, String label, int value, MaterialColor color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? color[900]!.withValues(alpha: 0.4) : color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[isDark ? 700 : 200]!),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
            fontSize: 12,
            color: isDark ? color[100] : color[800],
            fontWeight: FontWeight.w600),
      ),
    );
  }

  // ------------------------- طالب علم کا ٹائل -------------------------

  Widget _studentTile(Strings s, Map<String, dynamic> student) {
    final id = int.tryParse('${student['id']}') ?? 0;
    final current = statuses[id] ?? 'حاضر';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green,
                child: Text(
                  '${student['reg_no'] ?? '-'}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${student['name'] ?? ''}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${s.father}${student['fname'] ?? ''}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statusButton(id, 'حاضر', s.present, Colors.green, current),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statusButton(id, 'غائب', s.absent, Colors.red, current),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statusButton(id, 'رخصت', s.leave, Colors.amber, current),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusButton(
      int studentId, String value, String label, Color fill, String current) {
    final selected = current == value;
    final lightBg = fill.computeLuminance() > 0.5;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => statuses[studentId] = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? fill
              : (isDark ? Colors.transparent : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? fill : Colors.grey.shade400),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: selected
                ? (lightBg ? Colors.black87 : Colors.white)
                : (isDark ? Colors.grey[300] : Colors.black87),
          ),
        ),
      ),
    );
  }

  // ------------------------- مددگار ویجٹس -------------------------

  Widget _emptyMessage(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _saveButton(Strings s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: saving ? null : _saveAttendance,
          icon: saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save),
          label: Text(
            s.saveAttendance,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ),
    );
  }
}
