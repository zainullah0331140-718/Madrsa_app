import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'dmc_pdf.dart';
import 'strings.dart';

/// تمام نتائج دیکھنے کا صفحہ (درجہ و امتحان کے حساب سے)
class ResultViewPage extends StatefulWidget {
  const ResultViewPage({super.key});

  @override
  State<ResultViewPage> createState() => _ResultViewPageState();
}

class _ResultViewPageState extends State<ResultViewPage> {
  List<Map<String, dynamic>> rows = [];
  bool loading = true;
  bool printing = false;
  String? examFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final data = await DatabaseHelper.instance
          .getAllResultsWithStudent(examType: examFilter);
      if (!mounted) return;
      setState(() {
        rows = data;
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

  // درجہ کے حساب سے گروپ
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final r in rows) {
      final cls = '${r['class_name'] ?? ''}'.trim();
      final key = cls.isEmpty ? Strings.current.allClasses : cls;
      map.putIfAbsent(key, () => []).add(r);
    }
    return map;
  }

  // ======================= منو: پرنٹ / تازہ کریں =======================

  Future<void> _onMenuSelected(String value) async {
    switch (value) {
      case 'refresh':
        await _load();
        break;
      case 'print_all':
        await _printAllResults();
        break;
    }
  }

  Future<void> _printAllResults() async {
    final s = Strings.current;
    if (rows.isEmpty) {
      _showSnack(s.noRecordsToPrint, Colors.red);
      return;
    }
    if (printing) return;
    setState(() => printing = true);
    try {
      await DmcPdfService.printDmc(
        context: context,
        className: examFilter ?? s.allClasses,
        examType: examFilter == null
            ? s.allClasses
            : s.examTypeLabel(examFilter!),
        students: _groupByStudent(rows, className: examFilter ?? s.allClasses),
      );
      if (!mounted) return;
      _showSnack(s.profileReady, Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.printProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => printing = false);
    }
  }

  List<DmcStudentData> _groupByStudent(List<Map<String, dynamic>> source,
      {required String className}) {
    final map = <int, List<Map<String, dynamic>>>{};
    for (final r in source) {
      final sid = int.tryParse('${r['student_id']}') ?? 0;
      map.putIfAbsent(sid, () => []).add(r);
    }
    return map.entries.map((entry) {
      final first = entry.value.first;
      return DmcStudentData(
        name: '${first['student_name'] ?? ''}',
        fatherName: '${first['father_name'] ?? ''}',
        className: className,
        rollNo: '${first['reg_no'] ?? ''}',
        city: _cityOf(first),
        subjects: entry.value
            .map((r) => DmcSubjectData(
                  '${r['subject'] ?? ''}',
                  int.tryParse('${r['total_marks']}') ?? 0,
                  int.tryParse('${r['obtained_marks']}') ?? 0,
                ))
            .toList(),
      );
    }).toList();
  }

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

  // ======================= ایک نتیجہ: پرنٹ =======================

  Future<void> _printSingleResult(Map<String, dynamic> r) async {
    final s = Strings.current;
    if (printing) return;
    setState(() => printing = true);
    try {
      final studentId = int.tryParse('${r['student_id']}') ?? 0;
      final className = '${r['class_name'] ?? ''}';
      final examType = '${r['exam_type'] ?? ''}';
      // اسی طالب علم کے اسی درجے و امتحان کے تمام مضامین اکٹھے کریں
      final sameStudent = rows.where((x) =>
          (int.tryParse('${x['student_id']}') ?? 0) == studentId &&
          '${x['class_name'] ?? ''}' == className &&
          '${x['exam_type'] ?? ''}' == examType);
      final source = sameStudent.isEmpty ? [r] : sameStudent.toList();

      await DmcPdfService.printDmc(
        context: context,
        className: className.isEmpty ? s.allClasses : className,
        examType: examType.isEmpty ? s.allClasses : s.examTypeLabel(examType),
        students: _groupByStudent(source, className: className),
      );
      if (!mounted) return;
      _showSnack(s.profileReady, Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.printProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => printing = false);
    }
  }

  // ======================= ایک نتیجہ: ڈیلیٹ =======================

  Future<void> _deleteResult(Map<String, dynamic> r) async {
    final s = Strings.current;
    final id = int.tryParse('${r['id']}');
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
      await DatabaseHelper.instance.deleteResult(id);
      if (!mounted) return;
      _showSnack(s.recordDeleted, Colors.red);
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
    }
  }

  // ======================= ایک نتیجہ: تبدیلی =======================

  Future<void> _editResult(Map<String, dynamic> r) async {
    final s = Strings.current;
    final id = int.tryParse('${r['id']}');
    if (id == null) return;

    final subjectCtrl = TextEditingController(text: '${r['subject'] ?? ''}');
    final totalCtrl = TextEditingController(text: '${r['total_marks'] ?? ''}');
    final obtainedCtrl =
        TextEditingController(text: '${r['obtained_marks'] ?? ''}');
    final remarksCtrl = TextEditingController(text: '${r['remarks'] ?? ''}');
    final rawExam = '${r['exam_type'] ?? ''}';
    String? examType =
        rawExam.isEmpty || !s.examTypes.contains(rawExam) ? null : rawExam;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(s.editResultTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${r['student_name'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Text(s.examType,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: examType,
                  isExpanded: true,
                  items: s.examTypes
                      .map((t) => DropdownMenuItem<String>(
                          value: t, child: Text(s.examTypeLabel(t))))
                      .toList(),
                  onChanged: (v) => setDialogState(() => examType = v),
                ),
                const SizedBox(height: 10),
                _dialogField(ctx, subjectCtrl, s.subject),
                _dialogField(ctx, totalCtrl, s.totalMarks, isNumber: true),
                _dialogField(ctx, obtainedCtrl, s.obtainedMarks,
                    isNumber: true),
                _dialogField(ctx, remarksCtrl, s.remarks, maxLines: 2),
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

    if (saved != true) {
      subjectCtrl.dispose();
      totalCtrl.dispose();
      obtainedCtrl.dispose();
      remarksCtrl.dispose();
      return;
    }

    // دوبارہ والیڈیشن اور فی صد
    final subject = subjectCtrl.text.trim();
    final total = int.tryParse(totalCtrl.text.trim());
    final obtained = int.tryParse(obtainedCtrl.text.trim());
    if (subject.isEmpty) {
      _showSnack(s.subjectRequired, Colors.red);
    } else if (total == null || total <= 0) {
      _showSnack(s.totalMarksInvalid, Colors.red);
    } else if (obtained == null || obtained < 0) {
      _showSnack(s.obtainedMarksInvalid, Colors.red);
    } else if (obtained > total) {
      _showSnack(s.obtainedTooHigh, Colors.red);
    } else {
      try {
        await DatabaseHelper.instance.updateResult({
          'id': id,
          'exam_type': examType ?? '',
          'subject': subject,
          'total_marks': total,
          'obtained_marks': obtained,
          'percentage': '${((obtained / total) * 100).toStringAsFixed(1)}%',
          'remarks': remarksCtrl.text.trim(),
        });
        if (!mounted) return;
        _showSnack(s.resultUpdated, Colors.green);
        await _load();
      } catch (e) {
        if (!mounted) return;
        _showSnack(s.recordProblem(e), Colors.red);
      }
    }

    subjectCtrl.dispose();
    totalCtrl.dispose();
    obtainedCtrl.dispose();
    remarksCtrl.dispose();
  }

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
          title: Text(s.mResults),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: s.refresh,
              onPressed: loading ? null : _load,
            ),
            PopupMenuButton<String>(
              tooltip: s.menu,
              icon: const Icon(Icons.more_vert),
              onSelected: _onMenuSelected,
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'print_all',
                  child: Row(
                    children: [
                      const Icon(Icons.print, size: 20),
                      const SizedBox(width: 8),
                      Text(s.printAllResults),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      const Icon(Icons.refresh, size: 20),
                      const SizedBox(width: 8),
                      Text(s.refresh),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                hint: Text(s.examType),
                initialValue: examFilter,
                items: [
                  DropdownMenuItem<String>(
                      value: null, child: Text(s.allClasses)),
                  ...s.examTypes.map((t) => DropdownMenuItem<String>(
                        value: t,
                        child: Text(s.examTypeLabel(t)),
                      )),
                ],
                onChanged: (v) {
                  setState(() => examFilter = v);
                  _load();
                },
              ),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : rows.isEmpty
                      ? Center(
                          child: Text(s.noResults,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color)),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            for (final entry in _grouped.entries) ...[
                              _classHeader(entry.key),
                              ...entry.value.map((r) => _resultTile(s, r)),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classHeader(String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.meeting_room, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(name,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
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
                Text('${r['student_name'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  '${s.subject}: ${r['subject'] ?? ''}  |  ${s.examType}: ${s.examTypeLabel('${r['exam_type'] ?? ''}')}',
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
              Text('${r['obtained_marks']}/${r['total_marks']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Text('${r['percentage'] ?? ''}',
                  style: TextStyle(fontSize: 12, color: Colors.green[700])),
            ],
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: s.menu,
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (v) {
              switch (v) {
                case 'edit':
                  _editResult(r);
                  break;
                case 'delete':
                  _deleteResult(r);
                  break;
                case 'print':
                  _printSingleResult(r);
                  break;
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  const Icon(Icons.edit, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(s.edit),
                ]),
              ),
              PopupMenuItem(
                value: 'print',
                child: Row(children: [
                  const Icon(Icons.print, size: 20),
                  const SizedBox(width: 8),
                  Text(s.print),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  const Icon(Icons.delete, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(s.delete, style: const TextStyle(color: Colors.red)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
