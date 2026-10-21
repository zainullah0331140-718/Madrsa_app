import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'strings.dart';

class FeePage extends StatefulWidget {
  const FeePage({super.key});

  @override
  State<FeePage> createState() => _FeePageState();
}

class _FeePageState extends State<FeePage> {
  final amountCtrl = TextEditingController();
  final paidCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> fees = [];

  String? selectedStudentId;
  String? feeMonth;
  String? feeType;
  String? status;

  bool loading = true;
  bool saving = false;

  final List<String> months = [
    'جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون',
    'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    paidCtrl.dispose();
    remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final st = await DatabaseHelper.instance.getActiveStudents();
      final fs = await DatabaseHelper.instance.getFees();
      if (!mounted) return;
      setState(() {
        students = st;
        fees = fs;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showSnack('${Strings.current.loadFailed}: $e', Colors.red);
    }
  }

  Future<void> _saveFee() async {
    final s = Strings.current;
    if (selectedStudentId == null) {
      _showSnack(s.studentRequired, Colors.red);
      return;
    }
    if (feeMonth == null) {
      _showSnack(s.selectHintShort, Colors.red);
      return;
    }
    final amount = int.tryParse(amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _showSnack(s.amountRequired, Colors.red);
      return;
    }
    final paid = int.tryParse(paidCtrl.text.trim()) ?? 0;

    setState(() => saving = true);
    try {
      await DatabaseHelper.instance.insertFee({
        'student_id': int.parse(selectedStudentId!),
        'fee_month': feeMonth ?? '',
        'fee_type': feeType ?? '',
        'amount': amount,
        'paid_amount': paid,
        'status': paid >= amount ? 'ادا شدہ' : (paid > 0 ? 'جزوی' : 'غیر ادا شدہ'),
        'payment_date': DateTime.now().toIso8601String(),
        'remarks': remarksCtrl.text.trim(),
      });
      if (!mounted) return;

      _showSnack(s.feeSaved, Colors.green);
      amountCtrl.clear();
      paidCtrl.clear();
      remarksCtrl.clear();
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _markPaid(Map<String, dynamic> f) async {
    try {
      await DatabaseHelper.instance.updateFee({
        'id': f['id'],
        'student_id': f['student_id'],
        'fee_month': f['fee_month'],
        'fee_type': f['fee_type'],
        'amount': f['amount'],
        'paid_amount': f['amount'],
        'status': 'ادا شدہ',
        'payment_date': DateTime.now().toIso8601String(),
        'remarks': f['remarks'],
      });
      if (!mounted) return;
      _showSnack(Strings.current.feeSaved, Colors.green);
      _loadData();
    } catch (e) {
      if (!mounted) return;
      _showSnack(Strings.current.recordProblem(e), Colors.red);
    }
  }

  Future<void> _deleteFee(int id) async {
    await DatabaseHelper.instance.deleteFee(id);
    if (!mounted) return;
    _showSnack(Strings.current.deleted, Colors.red);
    _loadData();
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
            title: Text(s.feesTitle),
            centerTitle: true,
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: s.addFee),
                Tab(text: s.feeList),
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
            _sectionTitle(s.addFee),
            _fieldLabel(s.students),
            _studentDropdown(s),
            _fieldLabel(s.feeMonth),
            _monthDropdown(s),
            _fieldLabel(s.feeType),
            _textField(remarksCtrl, hint: s.feeType),
            _fieldLabel(s.amount),
            _textField(amountCtrl, isNumber: true, hint: 'مثلاً 1500'),
            _fieldLabel(s.paidAmount),
            _textField(paidCtrl, isNumber: true, hint: 'مثلاً 1000'),
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
                onPressed: saving ? null : _saveFee,
                icon: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(s.saveFee, style: const TextStyle(fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(Strings s) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (fees.isEmpty) {
      return Center(
        child: Text(s.noFees,
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: fees.length,
      itemBuilder: (context, i) => _feeTile(s, fees[i]),
    );
  }

  Widget _feeTile(Strings s, Map<String, dynamic> f) {
    final amount = int.tryParse('${f['amount']}') ?? 0;
    final paid = int.tryParse('${f['paid_amount']}') ?? 0;
    final remaining = amount - paid;
    final statusText = '${f['status'] ?? ''}';
    final isPaid = statusText == 'ادا شدہ';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isPaid ? Colors.green : Colors.orange,
            child: Icon(isPaid ? Icons.check : Icons.pending,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${f['student_name'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  '${s.feeMonth}: ${f['fee_month'] ?? ''}  |  ${s.amount}: $amount  |  ${s.paidAmount}: $paid',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                ),
                if (remaining > 0)
                  Text('${s.remaining}: $remaining',
                      style: const TextStyle(fontSize: 12, color: Colors.red)),
              ],
            ),
          ),
          if (!isPaid)
            IconButton(
              tooltip: s.paid,
              icon: const Icon(Icons.done_all, color: Colors.green),
              onPressed: () => _markPaid(f),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteFee(f['id'] as int),
          ),
        ],
      ),
    );
  }

  Widget _studentDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: _dec(),
      hint: Text(s.selectStudentHint),
      initialValue: selectedStudentId,
      isExpanded: true,
      items: students
          .map((st) => DropdownMenuItem<String>(
                value: '${st['id']}',
                child: Text('${st['name'] ?? ''} (${st['reg_no'] ?? '-'})',
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (v) => setState(() => selectedStudentId = v),
    );
  }

  Widget _monthDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: _dec(),
      hint: Text(s.selectHintShort),
      initialValue: feeMonth,
      items: months
          .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
          .toList(),
      onChanged: (v) => setState(() => feeMonth = v),
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
