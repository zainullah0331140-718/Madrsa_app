import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'dmc_pdf.dart';
import 'strings.dart';

class AddResultPage extends StatefulWidget {
  const AddResultPage({super.key});

  @override
  State<AddResultPage> createState() => _AddResultPageState();
}

class _AddResultPageState extends State<AddResultPage> {
  final subjectCtrl = TextEditingController();
  final totalMarksCtrl = TextEditingController();
  final obtainedMarksCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();

  List<Map<String, dynamic>> students = [];
  List<String> classNames = [];

  String? selectedStudentId;
  String? examType;
  String? selectedClass;

  bool loadingStudents = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _loadClassNames();
  }

  @override
  void dispose() {
    subjectCtrl.dispose();
    totalMarksCtrl.dispose();
    obtainedMarksCtrl.dispose();
    remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    try {
      final list = await DatabaseHelper.instance.getActiveStudents();
      if (!mounted) return;
      setState(() {
        students = list;
        loadingStudents = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingStudents = false);
      _showSnack('${Strings.current.loadFailed}: $e', Colors.red);
    }
  }

  Future<void> _loadClassNames() async {
    try {
      final list = await DatabaseHelper.instance.getClassNames();
      if (!mounted) return;
      setState(() => classNames = list);
    } catch (_) {}
  }

  // منتخب طالب علم سے اس کا درجہ معلوم کریں
  String get _selectedStudentClass {
    if (selectedStudentId == null) return '';
    final s = students.firstWhere(
      (st) => '${st['id']}' == selectedStudentId,
      orElse: () => <String, dynamic>{},
    );
    return (s['class_name'] ?? '').toString().trim();
  }

  // فی صد خودکار حساب ہوتا ہے
  String? get _percentage {
    final total = int.tryParse(totalMarksCtrl.text.trim());
    final obtained = int.tryParse(obtainedMarksCtrl.text.trim());
    if (total == null || total <= 0) return null;
    if (obtained == null || obtained < 0 || obtained > total) return null;
    return ((obtained / total) * 100).toStringAsFixed(1);
  }

  Future<void> _saveResult() async {
    final s = Strings.current;
    if (selectedStudentId == null) {
      _showSnack(s.selectStudentHint, Colors.red);
      return;
    }
    if (examType == null) {
      _showSnack(s.selectExamHint, Colors.red);
      return;
    }
    if (subjectCtrl.text.trim().isEmpty) {
      _showSnack(s.subjectRequired, Colors.red);
      return;
    }

    final total = int.tryParse(totalMarksCtrl.text.trim());
    if (total == null || total <= 0) {
      _showSnack(s.totalMarksInvalid, Colors.red);
      return;
    }

    final obtained = int.tryParse(obtainedMarksCtrl.text.trim());
    if (obtained == null || obtained < 0) {
      _showSnack(s.obtainedMarksInvalid, Colors.red);
      return;
    }
    if (obtained > total) {
      _showSnack(s.obtainedTooHigh, Colors.red);
      return;
    }

    setState(() => saving = true);
    try {
      final result = {
        'student_id': int.parse(selectedStudentId!),
        'class_name': _selectedStudentClass,
        'exam_type': examType ?? '',
        'subject': subjectCtrl.text.trim(),
        'total_marks': total,
        'obtained_marks': obtained,
        'percentage': '${_percentage ?? '0'}%',
        'remarks': remarksCtrl.text.trim(),
      };

      await DatabaseHelper.instance.insertResult(result);
      if (!mounted) return;

      _showSnack(s.resultSaved, Colors.green);
      subjectCtrl.clear();
      totalMarksCtrl.clear();
      obtainedMarksCtrl.clear();
      remarksCtrl.clear();
      setState(() {});
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
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(s.resultTitle),
            centerTitle: true,
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: s.addResultTitle),
                Tab(text: s.classWiseResults),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildAddForm(s),
              _buildClassResults(s),
            ],
          ),
        ),
      ),
    );
  }

  // ======================= پہلا ٹیب: نتیجہ شامل کریں =======================

  Widget _buildAddForm(Strings s) {
    return AbsorbPointer(
      absorbing: saving,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(s.examType),

            _fieldLabel(s.students),
            _studentDropdown(s),

            _fieldLabel(s.examType),
            _examDropdown(s),

            _sectionTitle(s.subject),

            _fieldLabel(s.subject),
            _textField(
              subjectCtrl,
              hint: s.subjectHint,
              onChanged: (v) => setState(() {}),
            ),

            _fieldLabel(s.totalMarks),
            _textField(
              totalMarksCtrl,
              isNumber: true,
              hint: 'مثلاً 100',
              onChanged: (v) => setState(() {}),
            ),

            _fieldLabel(s.obtainedMarks),
            _textField(
              obtainedMarksCtrl,
              isNumber: true,
              hint: 'مثلاً 85',
              onChanged: (v) => setState(() {}),
            ),

            if (_percentage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 5),
                child: Text(
                  '${s.percentage}: $_percentage%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),

            _fieldLabel('${s.remarks} (اختیاری)'),
            _textField(
              remarksCtrl,
              hint: s.remarksHint,
              maxLines: 2,
            ),

            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: saving ? null : _saveResult,
                icon: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  s.saveResult,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ======================= دوسرا ٹیب: درجہ وار نتائج / DMC =======================

  Widget _buildClassResults(Strings s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(s.selectClass),
          _classDropdown(s),
          _fieldLabel(s.examType),
          _examDropdown(s),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: selectedClass == null || examType == null
                  ? null
                  : _showDmcSheet,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(s.printDmc, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          _ClassResultsView(
            className: selectedClass,
            examType: examType,
          ),
        ],
      ),
    );
  }

  Future<void> _showDmcSheet() async {
    final s = Strings.current;
    if (selectedClass == null || examType == null) {
      _showSnack(s.selectClassExamFirst, Colors.red);
      return;
    }

    final rows = await DatabaseHelper.instance
        .getResultsByClassAndExam(selectedClass!, examType!);
    if (!mounted) return;

    if (rows.isEmpty) {
      _showSnack(s.noResults, Colors.red);
      return;
    }

    // طالب علم کے حساب سے گروپ بنائیں
    final grouped = _groupByStudent(rows);

    try {
      await DmcPdfService.printDmc(
        context: context,
        className: selectedClass!,
        examType: Strings.current.examTypeLabel(examType!),
        students: grouped,
      );
      if (!mounted) return;
      _showSnack(s.profileReady, Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.printProblem(e), Colors.red);
    }
  }

  List<DmcStudentData> _groupByStudent(List<Map<String, dynamic>> rows) {
    final map = <int, List<Map<String, dynamic>>>{};
    for (final r in rows) {
      final sid = int.tryParse('${r['student_id']}') ?? 0;
      map.putIfAbsent(sid, () => []).add(r);
    }

    final list = <DmcStudentData>[];
    for (final entry in map.entries) {
      final first = entry.value.first;
      final city = _cityOf(first);
      list.add(DmcStudentData(
        name: '${first['student_name'] ?? ''}',
        fatherName: '${first['father_name'] ?? ''}',
        className: selectedClass ?? '',
        rollNo: '${first['reg_no'] ?? ''}',
        city: city,
        subjects: entry.value
            .map((r) => DmcSubjectData(
                  '${r['subject'] ?? ''}',
                  int.tryParse('${r['total_marks']}') ?? 0,
                  int.tryParse('${r['obtained_marks']}') ?? 0,
                ))
            .toList(),
      ));
    }
    return list;
  }

  // شہر کے لیے پہلے مستقل ضلع، ورنہ موجودہ ضلع استعمال ہوتا ہے
  String _cityOf(Map<String, dynamic> resultRow) {
    final permanent = '${resultRow['permanent_district'] ?? ''}'.trim();
    if (permanent.isNotEmpty && permanent.toLowerCase() != 'null') {
      return permanent;
    }
    final current = '${resultRow['current_district'] ?? ''}'.trim();
    if (current.isNotEmpty && current.toLowerCase() != 'null') {
      return current;
    }
    return '';
  }

  // ======================= مددگار ویجٹس =======================

  Widget _studentDropdown(Strings s) {
    if (loadingStudents) {
      return const Padding(
        padding: EdgeInsets.all(8),
        child: LinearProgressIndicator(),
      );
    }
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(),
      hint: Text(s.selectStudentHint),
      initialValue: selectedStudentId,
      icon: const Icon(Icons.unfold_more, size: 20),
      isExpanded: true,
      items: students
          .map((st) => DropdownMenuItem<String>(
                value: '${st['id']}',
                child: Text(
                  '${st['name'] ?? ''} (${st['reg_no'] ?? '-'})',
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (val) => setState(() => selectedStudentId = val),
    );
  }

  Widget _classDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(),
      hint: Text(s.selectClass),
      initialValue: selectedClass,
      icon: const Icon(Icons.unfold_more, size: 20),
      isExpanded: true,
      items: classNames
          .map((c) => DropdownMenuItem<String>(
                value: c,
                child: Text(c, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (val) => setState(() => selectedClass = val),
    );
  }

  Widget _examDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: _inputDecoration(),
      hint: Text(s.selectExamHint),
      initialValue: examType,
      icon: const Icon(Icons.unfold_more, size: 20),
      items: s.examTypes
          .map((t) => DropdownMenuItem<String>(
                value: t,
                child: Text(s.examTypeLabel(t)),
              ))
          .toList(),
      onChanged: (val) => setState(() => examType = val),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
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
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}

/// منتخب درجے و امتحان کے نتائج دکھانے والا ویجٹ
class _ClassResultsView extends StatefulWidget {
  const _ClassResultsView({required this.className, required this.examType});

  final String? className;
  final String? examType;

  @override
  State<_ClassResultsView> createState() => _ClassResultsViewState();
}

class _ClassResultsViewState extends State<_ClassResultsView> {
  List<Map<String, dynamic>> rows = [];
  bool loading = false;

  @override
  void didUpdateWidget(covariant _ClassResultsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.className != widget.className ||
        oldWidget.examType != widget.examType) {
      _load();
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.className == null || widget.examType == null) {
      setState(() => rows = []);
      return;
    }
    setState(() => loading = true);
    final data = await DatabaseHelper.instance
        .getResultsByClassAndExam(widget.className!, widget.examType!);
    if (!mounted) return;
    setState(() {
      rows = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.current;
    if (widget.className == null || widget.examType == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            s.selectClassExamFirst,
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
      );
    }
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(
          child: Text(
            s.noResults,
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows.map((r) => _resultTile(s, r)).toList(),
    );
  }

  Widget _resultTile(Strings s, Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${r['student_name'] ?? ''}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${s.subject}: ${r['subject'] ?? ''}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${r['obtained_marks']}/${r['total_marks']}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                '${r['percentage'] ?? ''}',
                style: TextStyle(fontSize: 12, color: Colors.green[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
