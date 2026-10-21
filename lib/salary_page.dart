import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'salary_pdf.dart';
import 'strings.dart';

class SalaryPage extends StatefulWidget {
  const SalaryPage({super.key});

  @override
  State<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends State<SalaryPage> {
  final basicCtrl = TextEditingController();
  final allowanceCtrl = TextEditingController();
  final deductionCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();

  List<Map<String, dynamic>> staff = [];
  List<Map<String, dynamic>> salaries = [];

  String? selectedTeacherId;
  String? salaryMonth;
  String? status;

  bool loading = true;
  bool saving = false;
  bool printing = false;

  final List<String> months = [
    'جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون',
    'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر',
  ];
  final List<String> statuses = ['ادا شدہ', 'غیر ادا شدہ'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    basicCtrl.dispose();
    allowanceCtrl.dispose();
    deductionCtrl.dispose();
    remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final st = await DatabaseHelper.instance.getActiveTeachers();
      final sa = await DatabaseHelper.instance.getSalaries();
      if (!mounted) return;
      setState(() {
        staff = st;
        salaries = sa;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      _showSnack('${Strings.current.loadFailed}: $e', Colors.red);
    }
  }

  int get _netPay {
    final basic = int.tryParse(basicCtrl.text.trim()) ?? 0;
    final allowance = int.tryParse(allowanceCtrl.text.trim()) ?? 0;
    final deduction = int.tryParse(deductionCtrl.text.trim()) ?? 0;
    return basic + allowance - deduction;
  }

  Future<void> _saveSalary() async {
    final s = Strings.current;
    if (selectedTeacherId == null) {
      _showSnack(s.staffRequired, Colors.red);
      return;
    }
    if (salaryMonth == null) {
      _showSnack(s.selectHintShort, Colors.red);
      return;
    }
    final basic = int.tryParse(basicCtrl.text.trim());
    if (basic == null || basic <= 0) {
      _showSnack(s.amountRequired, Colors.red);
      return;
    }

    setState(() => saving = true);
    try {
      await DatabaseHelper.instance.insertSalary({
        'teacher_id': int.parse(selectedTeacherId!),
        'salary_month': salaryMonth ?? '',
        'basic': basic,
        'allowance': int.tryParse(allowanceCtrl.text.trim()) ?? 0,
        'deduction': int.tryParse(deductionCtrl.text.trim()) ?? 0,
        'net_pay': _netPay,
        'status': status ?? 'غیر ادا شدہ',
        'payment_date': DateTime.now().toIso8601String(),
        'remarks': remarksCtrl.text.trim(),
      });
      if (!mounted) return;

      _showSnack(s.salarySaved, Colors.green);
      basicCtrl.clear();
      allowanceCtrl.clear();
      deductionCtrl.clear();
      remarksCtrl.clear();
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.recordProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _deleteSalary(int id) async {
    await DatabaseHelper.instance.deleteSalary(id);
    if (!mounted) return;
    _showSnack(Strings.current.deleted, Colors.red);
    _loadData();
  }

  // ------------------------- پرنٹ -------------------------

  List<SalaryRow> _toRows(List<Map<String, dynamic>> source) {
    return source.map((sa) {
      // پیمنٹ ڈیٹ ISO سے پڑھ کر صاف فارمٹ میں لائیں
      var paymentDate = '${sa['payment_date'] ?? ''}';
      final parsed = DateTime.tryParse(paymentDate);
      if (parsed != null) {
        final formatted =
            '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
        paymentDate = formatted;
      }
      return SalaryRow(
        teacherName: '${sa['teacher_name'] ?? ''}',
        designation: '${sa['designation'] ?? ''}',
        month: '${sa['salary_month'] ?? ''}',
        basic: int.tryParse('${sa['basic']}') ?? 0,
        allowance: int.tryParse('${sa['allowance']}') ?? 0,
        deduction: int.tryParse('${sa['deduction']}') ?? 0,
        netPay: int.tryParse('${sa['net_pay']}') ?? 0,
        status: '${sa['status'] ?? ''}',
        paymentDate: paymentDate,
        remarks: '${sa['remarks'] ?? ''}',
      );
    }).toList();
  }

  Future<void> _printRegister() async {
    final s = Strings.current;
    if (printing) return;
    if (salaries.isEmpty) {
      _showSnack(s.noRecordsToPrint, Colors.red);
      return;
    }
    setState(() => printing = true);
    try {
      await SalaryPdfService.printRegister(
          context: context, rows: _toRows(salaries));
      if (!mounted) return;
      _showSnack(s.reportReady, Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.printProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => printing = false);
    }
  }

  Future<void> _printPaySlip(Map<String, dynamic> sa) async {
    final s = Strings.current;
    if (printing) return;
    setState(() => printing = true);
    try {
      await SalaryPdfService.printPaySlip(
          context: context, row: _toRows([sa]).first);
      if (!mounted) return;
      _showSnack(s.reportReady, Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showSnack(s.printProblem(e), Colors.red);
    } finally {
      if (mounted) setState(() => printing = false);
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
            title: Text(s.salaryTitle),
            centerTitle: true,
            actions: [
              IconButton(
                tooltip: s.printSalaryRegister,
                icon: printing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.print),
                onPressed: printing ? null : _printRegister,
              ),
            ],
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: s.addSalary),
                Tab(text: s.salaryList),
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
            _sectionTitle(s.addSalary),
            _fieldLabel(s.staffTitle),
            _staffDropdown(s),
            _fieldLabel(s.salaryMonth),
            _monthDropdown(s),
            _fieldLabel(s.basicSalary),
            _textField(basicCtrl, isNumber: true, hint: 'مثلاً 25000',
                onChanged: (_) => setState(() {})),
            _fieldLabel(s.allowance),
            _textField(allowanceCtrl, isNumber: true, hint: '0',
                onChanged: (_) => setState(() {})),
            _fieldLabel(s.deduction),
            _textField(deductionCtrl, isNumber: true, hint: '0',
                onChanged: (_) => setState(() {})),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 5),
              child: Text(
                '${s.netPay}: $_netPay',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800]),
              ),
            ),
            const SizedBox(height: 10),
            _fieldLabel(s.feeStatus),
            _statusDropdown(s),
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
                onPressed: saving ? null : _saveSalary,
                icon: saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(s.saveSalary, style: const TextStyle(fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(Strings s) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (salaries.isEmpty) {
      return Center(
        child: Text(s.noSalary,
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: salaries.length,
      itemBuilder: (context, i) => _salaryTile(s, salaries[i]),
    );
  }

  Widget _salaryTile(Strings s, Map<String, dynamic> sa) {
    final net = int.tryParse('${sa['net_pay']}') ?? 0;
    final isPaid = '${sa['status']}' == 'ادا شدہ';
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
            backgroundColor: isPaid ? Colors.green : Colors.deepOrange,
            child: Icon(isPaid ? Icons.check : Icons.pending,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${sa['teacher_name'] ?? ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  '${s.salaryMonth}: ${sa['salary_month'] ?? ''}  |  ${s.netPay}: $net',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: s.printPaySlip,
            icon: const Icon(Icons.print, color: Colors.green),
            onPressed: printing ? null : () => _printPaySlip(sa),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteSalary(sa['id'] as int),
          ),
        ],
      ),
    );
  }

  Widget _staffDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: _dec(),
      hint: Text(s.selectHintShort),
      initialValue: selectedTeacherId,
      isExpanded: true,
      items: staff
          .map((t) => DropdownMenuItem<String>(
                value: '${t['id']}',
                child: Text(
                    '${t['name'] ?? ''}${(t['designation'] ?? '').toString().isEmpty ? '' : ' - ${t['designation']}'}',
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (v) => setState(() => selectedTeacherId = v),
    );
  }

  Widget _monthDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: _dec(),
      hint: Text(s.selectHintShort),
      initialValue: salaryMonth,
      items: months
          .map((m) => DropdownMenuItem<String>(value: m, child: Text(m)))
          .toList(),
      onChanged: (v) => setState(() => salaryMonth = v),
    );
  }

  Widget _statusDropdown(Strings s) {
    return DropdownButtonFormField<String>(
      decoration: _dec(),
      hint: Text(s.selectHintShort),
      initialValue: status,
      items: statuses
          .map((t) => DropdownMenuItem<String>(value: t, child: Text(t)))
          .toList(),
      onChanged: (v) => setState(() => status = v),
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
      {bool isNumber = false,
      int maxLines = 1,
      String? hint,
      ValueChanged<String>? onChanged}) {
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
