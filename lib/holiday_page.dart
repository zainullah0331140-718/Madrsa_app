import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'database_helper.dart';
import 'strings.dart';

class HolidayPage extends StatefulWidget {
  const HolidayPage({super.key});

  @override
  State<HolidayPage> createState() => _HolidayPageState();
}

class _HolidayPageState extends State<HolidayPage> {
  final titleCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final startCtrl = TextEditingController();
  final endCtrl = TextEditingController();

  String? holidayType;
  List<Map<String, dynamic>> holidays = [];
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    remarksCtrl.dispose();
    startCtrl.dispose();
    endCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHolidays() async {
    setState(() => loading = true);
    try {
      final list = await DatabaseHelper.instance.getHolidays();
      if (!mounted) return;
      setState(() {
        holidays = list;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showSnack('${Strings.current.loadFailed}: $e', Colors.red);
    }
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    DateTime initial = DateTime.now();
    try {
      initial = DateFormat('MM/dd/yyyy').parseStrict(ctrl.text);
    } catch (_) {}
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() => ctrl.text = DateFormat('MM/dd/yyyy').format(picked));
    }
  }

  Future<void> _saveHoliday() async {
    final s = Strings.current;
    if (titleCtrl.text.trim().isEmpty) {
      _showSnack(s.titleRequired, Colors.red);
      return;
    }

    setState(() => saving = true);
    try {
      await DatabaseHelper.instance.insertHoliday({
        'title': titleCtrl.text.trim(),
        'start_date': startCtrl.text.trim(),
        'end_date': endCtrl.text.trim(),
        'holiday_type': holidayType ?? '',
        'remarks': remarksCtrl.text.trim(),
      });
      if (!mounted) return;

      _showSnack(s.holidaySaved, Colors.green);
      titleCtrl.clear();
      remarksCtrl.clear();
      startCtrl.clear();
      endCtrl.clear();
      setState(() => holidayType = null);
      await _loadHolidays();
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _deleteHoliday(int id) async {
    await DatabaseHelper.instance.deleteHoliday(id);
    if (!mounted) return;
    _showSnack(Strings.current.deleted, Colors.red);
    _loadHolidays();
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
        appBar: AppBar(title: Text(s.holidaysTitle), centerTitle: true),
        body: AbsorbPointer(
          absorbing: saving,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(s.addHoliday),
                _fieldLabel(s.holidayTitle),
                _textField(titleCtrl, hint: s.holidayTitle),
                _fieldLabel(s.holidayType),
                _typeDropdown(s),
                _fieldLabel(s.startDate),
                _dateField(startCtrl),
                _fieldLabel(s.endDate),
                _dateField(endCtrl),
                _fieldLabel(s.remarks),
                _textField(remarksCtrl, maxLines: 2),
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
                    onPressed: saving ? null : _saveHoliday,
                    icon: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save),
                    label:
                        Text(s.saveHoliday, style: const TextStyle(fontSize: 17)),
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle(s.holidayList),
                if (loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (holidays.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(s.noHolidays,
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color)),
                    ),
                  )
                else
                  ...holidays.map((h) => _holidayTile(s, h)),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _holidayTile(Strings s, Map<String, dynamic> h) {
    final start = '${h['start_date'] ?? ''}'.trim();
    final end = '${h['end_date'] ?? ''}'.trim();
    final range = (start.isEmpty && end.isEmpty)
        ? ''
        : '${start.isEmpty ? '—' : start}  →  ${end.isEmpty ? '—' : end}';

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
            backgroundColor: Colors.deepOrange,
            child: Icon(Icons.beach_access, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${h['title'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                if (range.isNotEmpty)
                  Text(range,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).textTheme.bodySmall?.color)),
                if ('${h['holiday_type'] ?? ''}'.trim().isNotEmpty)
                  Text('${h['holiday_type']}',
                      style: const TextStyle(fontSize: 12, color: Colors.deepOrange)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteHoliday(h['id'] as int),
          ),
        ],
      ),
    );
  }

  Widget _typeDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
      hint: Text(s.selectHintShort),
      initialValue: holidayType,
      items: s.holidayTypes
          .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) => setState(() => holidayType = v),
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

  Widget _dateField(TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      textAlign: TextAlign.right,
      onTap: () => _pickDate(ctrl),
      decoration: InputDecoration(
        hintText: 'mm/dd/yyyy',
        suffixIcon: const Icon(Icons.calendar_today, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
