import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'database_helper.dart';
import 'lesson_pdf.dart';
import 'strings.dart';

class DailyLessonPage extends StatefulWidget {
  const DailyLessonPage({super.key});

  @override
  State<DailyLessonPage> createState() => _DailyLessonPageState();
}

class _DailyLessonPageState extends State<DailyLessonPage> {
  final subjectCtrl = TextEditingController();
  final bookCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final detailsCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  List<String> classNames = [];
  List<Map<String, dynamic>> teachers = [];
  List<Map<String, dynamic>> lessons = [];

  String? selectedClass;
  String? selectedTeacherId;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    dateCtrl.text = DateFormat('MM/dd/yyyy').format(DateTime.now());
    _loadData();
  }

  @override
  void dispose() {
    subjectCtrl.dispose();
    bookCtrl.dispose();
    titleCtrl.dispose();
    detailsCtrl.dispose();
    dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final classes = await DatabaseHelper.instance.getClassNames();
      final staff = await DatabaseHelper.instance.getActiveTeachers();
      final list = await DatabaseHelper.instance.getDailyLessons();
      if (!mounted) return;
      setState(() {
        classNames = classes;
        teachers = staff;
        lessons = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showSnack('${Strings.current.loadFailed}: $e', Colors.red);
    }
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.now();
    try {
      initial = DateFormat('MM/dd/yyyy').parseStrict(dateCtrl.text);
    } catch (_) {}
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (!mounted || picked == null) return;
    setState(() => dateCtrl.text = DateFormat('MM/dd/yyyy').format(picked));
  }

  Future<void> _saveLesson() async {
    final s = Strings.current;
    if (titleCtrl.text.trim().isEmpty) {
      _showSnack(s.lessonTitleRequired, Colors.red);
      return;
    }

    setState(() => saving = true);
    try {
      await DatabaseHelper.instance.insertDailyLesson({
        'class_id': null,
        'teacher_id':
            selectedTeacherId == null ? null : int.tryParse(selectedTeacherId!),
        'lesson_date': dateCtrl.text.trim(),
        'subject': subjectCtrl.text.trim().isEmpty ? selectedClass ?? '' : subjectCtrl.text.trim(),
        'book': bookCtrl.text.trim(),
        'lesson_title': titleCtrl.text.trim(),
        'details': detailsCtrl.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;

      _showSnack(s.lessonSaved, Colors.green);
      subjectCtrl.clear();
      bookCtrl.clear();
      titleCtrl.clear();
      detailsCtrl.clear();
      setState(() {
        selectedClass = null;
        selectedTeacherId = null;
      });
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _deleteLesson(int id) async {
    await DatabaseHelper.instance.deleteDailyLesson(id);
    if (!mounted) return;
    _showSnack(Strings.current.deleted, Colors.red);
    _loadData();
  }

  Future<void> _printLessons() async {
    final s = Strings.current;
    if (lessons.isEmpty) {
      _showSnack(s.noRecordsToPrint, Colors.red);
      return;
    }
    try {
      final data = lessons
          .map((l) => LessonData(
                date: '${l['lesson_date'] ?? ''}',
                className: _classNameOf(l),
                subject: '${l['subject'] ?? ''}',
                book: '${l['book'] ?? ''}',
                title: '${l['lesson_title'] ?? ''}',
                details: '${l['details'] ?? ''}',
              ))
          .toList();
      await LessonPdfService.printLessons(context: context, lessons: data);
      if (!mounted) return;
      _showSnack(s.reportReady, Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.printProblem(e), Colors.red);
    }
  }

  String _classNameOf(Map<String, dynamic> l) {
    final cid = l['class_id'];
    if (cid == null) return '${l['subject'] ?? ''}';
    return '${l['subject'] ?? ''}';
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
            title: Text(s.dailyLessonTitle),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: s.printLesson,
                icon: const Icon(Icons.print),
                onPressed: _printLessons,
              ),
            ],
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: s.addLesson),
                Tab(text: s.lessonList),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildForm(s),
              _buildList(s),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(Strings s) {
    return AbsorbPointer(
      absorbing: saving,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(s.addLesson),
            _fieldLabel(s.lessonDate),
            _dateField(),
            _fieldLabel(s.selectClass),
            _classDropdown(s),
            _fieldLabel(s.teachers),
            _teacherDropdown(s),
            _fieldLabel(s.subject),
            _textField(subjectCtrl, hint: s.subject),
            _fieldLabel(s.lessonBook),
            _textField(bookCtrl, hint: s.lessonBook),
            _fieldLabel(s.lessonTitleField),
            _textField(titleCtrl, hint: s.lessonTitleField),
            _fieldLabel(s.lessonDetails),
            _textField(detailsCtrl, maxLines: 3, hint: s.lessonDetails),
            const SizedBox(height: 20),
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
                onPressed: saving ? null : _saveLesson,
                icon: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(s.saveLesson, style: const TextStyle(fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(Strings s) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (lessons.isEmpty) {
      return Center(
        child: Text(s.noLessons,
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: lessons.length,
      itemBuilder: (context, i) => _lessonTile(s, lessons[i]),
    );
  }

  Widget _lessonTile(Strings s, Map<String, dynamic> l) {
    final bits = <String>[];
    if ('${l['lesson_date'] ?? ''}'.trim().isNotEmpty) {
      bits.add('${l['lesson_date']}');
    }
    if ('${l['subject'] ?? ''}'.trim().isNotEmpty) bits.add('${l['subject']}');
    if ('${l['book'] ?? ''}'.trim().isNotEmpty) {
      bits.add('${s.lessonBook}: ${l['book']}');
    }
    if ('${l['teacher_name'] ?? ''}'.trim().isNotEmpty) {
      bits.add('${l['teacher_name']}');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.purple,
            child: Icon(Icons.menu_book, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l['lesson_title'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                if (bits.isNotEmpty)
                  Text(bits.join('  |  '),
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color)),
                if ('${l['details'] ?? ''}'.trim().isNotEmpty)
                  Text('${l['details']}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteLesson(l['id'] as int),
          ),
        ],
      ),
    );
  }

  Widget _classDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: _dec(),
      hint: Text(s.selectClass),
      initialValue: selectedClass,
      isExpanded: true,
      items: classNames
          .map((c) => DropdownMenuItem<String>(
                value: c,
                child: Text(c, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (v) => setState(() => selectedClass = v),
    );
  }

  Widget _teacherDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: _dec(),
      hint: Text(s.selectHintShort),
      initialValue: selectedTeacherId,
      isExpanded: true,
      items: teachers
          .map((t) => DropdownMenuItem<String>(
                value: '${t['id']}',
                child:
                    Text('${t['name'] ?? ''}', overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (v) => setState(() => selectedTeacherId = v),
    );
  }

  Widget _dateField() {
    return TextField(
      controller: dateCtrl,
      readOnly: true,
      textAlign: TextAlign.right,
      onTap: _pickDate,
      decoration: InputDecoration(
        hintText: 'mm/dd/yyyy',
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }

  InputDecoration _dec() => InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      );

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.green[800],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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

  Widget _textField(TextEditingController ctrl,
      {bool isNumber = false, int maxLines = 1, String? hint}) {
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
}
