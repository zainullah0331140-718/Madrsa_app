import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'strings.dart';

class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  final nameCtrl = TextEditingController();
  final sectionCtrl = TextEditingController();
  final roomCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  List<Map<String, dynamic>> classes = [];
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    sectionCtrl.dispose();
    roomCtrl.dispose();
    capacityCtrl.dispose();
    descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClasses() async {
    setState(() => loading = true);
    try {
      final list = await DatabaseHelper.instance.getClasses();
      if (!mounted) return;
      setState(() {
        classes = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showSnack('${Strings.current.loadFailed}: $e', Colors.red);
    }
  }

  Future<void> _saveClass() async {
    final s = Strings.current;
    if (nameCtrl.text.trim().isEmpty) {
      _showSnack(s.classNameRequired, Colors.red);
      return;
    }

    setState(() => saving = true);
    try {
      await DatabaseHelper.instance.insertClass({
        'class_name': nameCtrl.text.trim(),
        'section': sectionCtrl.text.trim(),
        'room': roomCtrl.text.trim(),
        'capacity': int.tryParse(capacityCtrl.text.trim()) ?? 0,
        'description': descriptionCtrl.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;

      _showSnack(s.classSaved, Colors.green);
      nameCtrl.clear();
      sectionCtrl.clear();
      roomCtrl.clear();
      capacityCtrl.clear();
      descriptionCtrl.clear();
      await _loadClasses();
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _deleteClass(int id) async {
    await DatabaseHelper.instance.deleteClass(id);
    if (!mounted) return;
    _showSnack(Strings.current.deleted, Colors.red);
    _loadClasses();
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
        appBar: AppBar(title: Text(s.newClassTitle), centerTitle: true),
        body: AbsorbPointer(
          absorbing: saving,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(s.newClassTitle),
                _fieldLabel(s.className),
                _textField(nameCtrl, hint: s.className),
                _fieldLabel(s.section),
                _textField(sectionCtrl, hint: s.section),
                _fieldLabel(s.room),
                _textField(roomCtrl, hint: s.room),
                _fieldLabel(s.capacity),
                _textField(capacityCtrl, isNumber: true, hint: s.capacity),
                _fieldLabel(s.description),
                _textField(descriptionCtrl, maxLines: 3),
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
                    onPressed: saving ? null : _saveClass,
                    icon: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label: Text(s.saveClass, style: const TextStyle(fontSize: 17)),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle(s.classList),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (classes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(s.noClasses,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color)),
                    ),
                  )
                else
                  ...classes.map((c) => _classTile(s, c)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _classTile(Strings s, Map<String, dynamic> c) {
    final section = '${c['section'] ?? ''}'.trim();
    final room = '${c['room'] ?? ''}'.trim();
    final capacity = '${c['capacity'] ?? ''}'.trim();
    final bits = <String>[];
    if (section.isNotEmpty) bits.add('${s.section}: $section');
    if (room.isNotEmpty) bits.add('${s.room}: $room');
    if (capacity.isNotEmpty && capacity != '0') bits.add('${s.capacity}: $capacity');

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
            backgroundColor: Colors.green,
            child: Icon(Icons.meeting_room, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${c['class_name'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                if (bits.isNotEmpty)
                  Text(bits.join('  |  '),
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteClass(c['id'] as int),
          ),
        ],
      ),
    );
  }

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
