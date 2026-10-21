import 'package:flutter/material.dart';
import 'add_student.dart';
import 'database_helper.dart';
import 'edit_student.dart';
import 'image_store.dart';
import 'student_pdf.dart';
import 'strings.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  State<StudentListPage> createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<Map<String, dynamic>> students = [];
  final Set<int> _printing = {};

  @override
  void initState() {
    super.initState();
    _refreshStudents();
  }

  Future<void> _refreshStudents() async {
    final data = await DatabaseHelper.instance.getStudents();
    if (!mounted) return;
    setState(() {
      students = data;
    });
  }

  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);

    if (!mounted) return; // BuildContext کی وارننگ دور کرنے کے لیے

    _refreshStudents();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Strings.current.recordDeleted, textAlign: TextAlign.right),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _printStudent(Map<String, dynamic> student) async {
    final id = student['id'] as int;
    setState(() => _printing.add(id));
    try {
      await StudentPdfService.printProfile(context, student);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Strings.current.profileReady, textAlign: TextAlign.right),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Strings.current.printProblem(e), textAlign: TextAlign.right),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _printing.remove(id));
    }
  }

  Future<void> _addNewStudent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStudentPage()),
    );
    if (!mounted) return;
    _refreshStudents();
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(Strings.current.dataSaved, textAlign: TextAlign.right),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.current;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.studentList),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: s.mNewAdmission,
            icon: const Icon(Icons.person_add),
            onPressed: _addNewStudent,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewStudent,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: Text(s.mNewAdmission),
      ),
      body: students.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.noStudentsYet,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _addNewStudent,
                    icon: const Icon(Icons.person_add),
                    label: Text(s.mNewAdmission),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final imageProvider = ImageStore.provider(student['photo']?.toString());
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? Text(
                              student['reg_no']?.toString() ?? '-',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            )
                          : null,
                    ),
                    title: Text(student['name'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text('${s.father}${student['fname'] ?? ''}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _printing.contains(student['id'])
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                tooltip: s.print,
                                icon: const Icon(Icons.print, color: Colors.green),
                                onPressed: () => _printStudent(student),
                              ),
                        IconButton(
                          tooltip: s.edit,
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditStudentPage(student: student),
                              ),
                            );

                            if (result == true) {
                              _refreshStudents();
                            }
                          },
                        ),
                        IconButton(
                          tooltip: s.delete,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(s.deleteTitle,
                                    textAlign: TextAlign.right),
                                content: Text(s.deleteMessage,
                                    textAlign: TextAlign.right),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(s.no)),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteStudent(student['id']);
                                    },
                                    child: Text(s.yesDelete,
                                        style:
                                            const TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
