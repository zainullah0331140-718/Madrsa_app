import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // ورسن 6: طلبہ کے ٹیبل میں درجہ (class_name) اور نتائج میں درجہ شامل ہوئے
  static const int _dbVersion = 6;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('madarsa_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await _createStudentTable(db);
    await _createModuleTables(db);
  }

  // پرانے ڈیٹا بیس کو اپ گریڈ کرتے وقت صرف نئے ٹیبل/کالم لگائے جاتے ہیں
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createModuleTables(db);
    }
    if (oldVersion < 3) {
      // نتائج کے ٹیبل میں امتحان کی قسم (ماہانہ/ششماہی/سالانہ) شامل کی گئی ہے
      await _addColumnIfMissing(db, 'results', 'exam_type', 'TEXT');
    }
    if (oldVersion < 4) {
      // نتائج کے ٹیبل میں مضمون (subject) شامل کیا گیا ہے
      await _addColumnIfMissing(db, 'results', 'subject', 'TEXT');
    }
    if (oldVersion < 5) {
      // طلبہ کے ٹیبل میں تصویر (photo) شامل کی گئی ہے
      await _addColumnIfMissing(db, 'students', 'photo', 'TEXT');
    }
    if (oldVersion < 6) {
      // طلبہ کے ٹیبل میں موجودہ درجہ (class_name) شامل کیا گیا ہے
      await _addColumnIfMissing(db, 'students', 'class_name', 'TEXT');
      // نتائج کے ٹیبل میں درجہ (class_name) شامل کیا گیا ہے
      await _addColumnIfMissing(db, 'results', 'class_name', 'TEXT');
    }
  }

  // اگر کالم پہلے سے موجود نہ ہو تو ہی شامل کیا جاتا ہے
  Future _addColumnIfMissing(
      Database db, String table, String column, String type) async {
    try {
      final info = await db.rawQuery('PRAGMA table_info($table)');
      final exists = info.any((c) => c['name'] == column);
      if (!exists) {
        await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
      }
    } catch (_) {
      // ٹیبل ابھی موجود نہ ہو تو نظر انداز کریں
    }
  }

  // ------------------------- طلبہ کا ٹیبل -------------------------

  Future _createStudentTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      fname TEXT,
      caste TEXT,
      gender TEXT,
      cnic TEXT,
      dob TEXT,
      age TEXT,
      admission_date TEXT,
      reg_no TEXT,
      current_address TEXT,
      current_district TEXT,
      permanent_address TEXT,
      permanent_district TEXT,
      phone TEXT,
      modern_education TEXT,
      other_courses TEXT,
      residential_status TEXT,
      support_status TEXT,
      federal_status TEXT,
      is_graduate INTEGER,
      discharge_date TEXT,
      discharge_reason TEXT,
      photo TEXT,
      class_name TEXT
    )
    ''');
  }

  // ------------- آئندہ ماڈیولز کے ٹیبل (اساتذہ، کلاس، حاضری، فیس وغیرہ) -------------

  Future _createModuleTables(Database db) async {
    // 1) اساتذہ و عملہ (Teachers & Staff)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS teachers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      fname TEXT,
      gender TEXT,
      cnic TEXT,
      dob TEXT,
      phone TEXT,
      address TEXT,
      district TEXT,
      designation TEXT,
      category TEXT,
      subject TEXT,
      qualification TEXT,
      joining_date TEXT,
      salary INTEGER,
      is_active INTEGER DEFAULT 1
    )
    ''');

    // 2) کلاسز (Classes)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS classes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      class_name TEXT,
      section TEXT,
      teacher_id INTEGER,
      room TEXT,
      capacity INTEGER,
      description TEXT,
      created_at TEXT
    )
    ''');

    // 3) طلبہ کی حاضری (Student Attendance)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS student_attendance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id INTEGER,
      attend_date TEXT,
      status TEXT,
      remarks TEXT,
      recorded_at TEXT
    )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_student_attendance_date ON student_attendance(attend_date)');

    // 4) اساتذہ و عملہ کی حاضری (Staff Attendance)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS staff_attendance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      teacher_id INTEGER,
      attend_date TEXT,
      status TEXT,
      remarks TEXT,
      recorded_at TEXT
    )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_staff_attendance_date ON staff_attendance(attend_date)');

    // 5) فیس (Fees)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS fees (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id INTEGER,
      fee_month TEXT,
      fee_type TEXT,
      amount INTEGER,
      paid_amount INTEGER DEFAULT 0,
      status TEXT,
      payment_date TEXT,
      remarks TEXT
    )
    ''');

    // 6) تنخواہ (Salary)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS salaries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      teacher_id INTEGER,
      salary_month TEXT,
      basic INTEGER,
      allowance INTEGER DEFAULT 0,
      deduction INTEGER DEFAULT 0,
      net_pay INTEGER,
      status TEXT,
      payment_date TEXT,
      remarks TEXT
    )
    ''');

    // 7) رجسٹر آمدن و خرچ (Income & Expense Register)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entry_date TEXT,
      entry_type TEXT,
      category TEXT,
      title TEXT,
      amount INTEGER,
      payment_method TEXT,
      remarks TEXT,
      recorded_at TEXT
    )
    ''');

    // 8) نتائج (Results)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS results (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id INTEGER,
      class_id INTEGER,
      class_name TEXT,
      exam_type TEXT,
      subject TEXT,
      exam_name TEXT,
      exam_date TEXT,
      total_marks INTEGER,
      obtained_marks INTEGER,
      percentage TEXT,
      grade TEXT,
      remarks TEXT
    )
    ''');

    // 9) روز کا سبق (Daily Lesson)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS daily_lessons (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      class_id INTEGER,
      teacher_id INTEGER,
      lesson_date TEXT,
      subject TEXT,
      book TEXT,
      lesson_title TEXT,
      details TEXT,
      created_at TEXT
    )
    ''');

    // 10) چھٹیاں (Holidays)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS holidays (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      start_date TEXT,
      end_date TEXT,
      holiday_type TEXT,
      remarks TEXT
    )
    ''');

    // 11) عبادات و اخلاقیات (Worship & Ethics)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS ethics (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      student_id INTEGER,
      record_date TEXT,
      category TEXT,
      topic TEXT,
      score TEXT,
      remarks TEXT
    )
    ''');

    // 12) رجسٹر تجاویز و شکایات (Suggestions & Complaints)
    await db.execute('''
    CREATE TABLE IF NOT EXISTS complaints (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      submit_date TEXT,
      person_name TEXT,
      contact TEXT,
      subject TEXT,
      details TEXT,
      status TEXT,
      reply TEXT,
      resolved_at TEXT
    )
    ''');
  }

  // ------------------------- طلبہ کے فنکشن -------------------------

  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await instance.database;
    return await db.insert('students', student);
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final db = await instance.database;
    return await db.query('students');
  }

  Future<int> updateStudent(Map<String, dynamic> student) async {
    final db = await instance.database;
    int id = student['id'];
    return await db.update('students', student, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteStudent(int id) async {
    final db = await instance.database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------- اساتذہ و عملہ کے فنکشن -------------------------

  Future<int> insertTeacher(Map<String, dynamic> teacher) async {
    final db = await instance.database;
    return await db.insert('teachers', teacher);
  }

  Future<List<Map<String, dynamic>>> getTeachers() async {
    final db = await instance.database;
    return await db.query('teachers', orderBy: 'id DESC');
  }

  Future<int> updateTeacher(Map<String, dynamic> teacher) async {
    final db = await instance.database;
    int id = teacher['id'];
    return await db.update('teachers', teacher, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTeacher(int id) async {
    final db = await instance.database;
    return await db.delete('teachers', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------- حاضری کے فنکشن (طلبہ) -------------------------

  // صرف ان طلبہ کی فہرست جو ابھی مدرسے میں موجود ہیں (خارج شدہ نہیں)
  Future<List<Map<String, dynamic>>> getActiveStudents() async {
    final db = await instance.database;
    return await db.query(
      'students',
      where: "LOWER(TRIM(COALESCE(discharge_date, ''))) IN ('', 'null')",
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getStudentAttendanceByDate(
      String date) async {
    final db = await instance.database;
    return await db.query(
      'student_attendance',
      where: 'attend_date = ?',
      whereArgs: [date],
    );
  }

  // مخصوص تاریخ کی حاضری محفوظ کرتے وقت پرانا ریکارڈ ہٹا کر نیا ریکارڈ لکھا جاتا ہے
  Future<void> saveStudentAttendance(
      String date, Map<int, String> statuses) async {
    final db = await instance.database;
    final recordedAt = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.delete(
        'student_attendance',
        where: 'attend_date = ?',
        whereArgs: [date],
      );
      final batch = txn.batch();
      for (final entry in statuses.entries) {
        batch.insert('student_attendance', {
          'student_id': entry.key,
          'attend_date': date,
          'status': entry.value,
          'recorded_at': recordedAt,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  // ------------------------- حاضری کے فنکشن (اساتذہ و عملہ) -------------------------

  Future<int> insertStaffAttendance(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('staff_attendance', row);
  }

  Future<List<Map<String, dynamic>>> getStaffAttendanceByDate(
      String date) async {
    final db = await instance.database;
    return await db.query(
      'staff_attendance',
      where: 'attend_date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
  }

  // کسی تاریخ کی حاضری کے حساب (حاضر / غائب / رخصت) — ڈیش بورڈ کے لیے
  Future<Map<String, int>> getAttendanceCounts(
      String table, String date) async {
    if (table != 'student_attendance' && table != 'staff_attendance') {
      throw ArgumentError('Invalid attendance table: $table');
    }
    final db = await instance.database;
    final rows = await db.rawQuery(
      'SELECT status, COUNT(*) AS c FROM $table '
      'WHERE attend_date = ? GROUP BY status',
      [date],
    );
    final counts = <String, int>{};
    for (final row in rows) {
      final status = '${row['status'] ?? ''}';
      final value = row['c'];
      counts[status] = value is int ? value : int.tryParse('$value') ?? 0;
    }
    return counts;
  }

  // فعال اساتذہ و عملہ (is_active = 1)
  Future<List<Map<String, dynamic>>> getActiveTeachers() async {
    final db = await instance.database;
    return await db.query(
      'teachers',
      where: 'is_active = 1',
      orderBy: 'id ASC',
    );
  }

  // مخصوص تاریخ کی اساتذہ حاضری محفوظ کرتے وقت پرانا ریکارڈ ہٹا کر نیا لکھا جاتا ہے
  Future<void> saveStaffAttendance(
      String date, Map<int, String> statuses) async {
    final db = await instance.database;
    final recordedAt = DateTime.now().toIso8601String();

    await db.transaction((txn) async {
      await txn.delete(
        'staff_attendance',
        where: 'attend_date = ?',
        whereArgs: [date],
      );
      final batch = txn.batch();
      for (final entry in statuses.entries) {
        batch.insert('staff_attendance', {
          'teacher_id': entry.key,
          'attend_date': date,
          'status': entry.value,
          'recorded_at': recordedAt,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  // ------------------------- درجات (Classes) -------------------------

  // تمام درجات کی فہرست (ادارے کے طلبہ سے) ایک منفرد فہرست کے طور پر
  Future<List<String>> getClassNames() async {
    final db = await instance.database;
    final set = <String>{};
    try {
      final rows = await db.rawQuery(
        "SELECT DISTINCT class_name FROM students "
        "WHERE class_name IS NOT NULL AND TRIM(class_name) <> '' "
        "AND LOWER(TRIM(class_name)) <> 'null'",
      );
      for (final r in rows) {
        final name = '${r['class_name']}'.trim();
        if (name.isNotEmpty) set.add(name);
      }
    } catch (_) {}
    try {
      final rows = await db.rawQuery(
        "SELECT DISTINCT class_name FROM classes "
        "WHERE class_name IS NOT NULL AND TRIM(class_name) <> '' "
        "AND LOWER(TRIM(class_name)) <> 'null'",
      );
      for (final r in rows) {
        final name = '${r['class_name']}'.trim();
        if (name.isNotEmpty) set.add(name);
      }
    } catch (_) {}
    final list = set.toList()..sort();
    return list;
  }

  // ایک مخصوص درجے کے تمام طلبہ (خارج شدہ شامل نہیں)
  Future<List<Map<String, dynamic>>> getStudentsByClass(String className) async {
    final db = await instance.database;
    return await db.query(
      'students',
      where:
          "class_name = ? AND LOWER(TRIM(COALESCE(discharge_date, ''))) IN ('', 'null')",
      whereArgs: [className],
      orderBy: 'id ASC',
    );
  }

  // ایک مخصوص درجے اور امتحان کی قسم کے نتائج (طالب علم کی تفصیل کے ساتھ)
  Future<List<Map<String, dynamic>>> getResultsByClassAndExam(
      String className, String examType) async {
    final db = await instance.database;
    return await db.rawQuery(
      "SELECT r.*, s.name AS student_name, s.fname AS father_name, "
      "s.reg_no AS reg_no, s.current_district AS current_district, "
      "s.permanent_district AS permanent_district, "
      "s.current_address AS current_address FROM results r "
      "LEFT JOIN students s ON s.id = r.student_id "
      "WHERE r.class_name = ? AND r.exam_type = ? "
      "ORDER BY r.student_id ASC, r.id ASC",
      [className, examType],
    );
  }

  // ------------------------- نتائج کے فنکشن -------------------------

  Future<int> insertResult(Map<String, dynamic> result) async {
    final db = await instance.database;
    return await db.insert('results', result);
  }

  Future<int> updateResult(Map<String, dynamic> result) async {
    final db = await instance.database;
    final id = result['id'];
    return await db.update('results', result, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteResult(int id) async {
    final db = await instance.database;
    return await db.delete('results', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getResults() async {
    final db = await instance.database;
    return await db.query('results', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getResultsForStudent(
      int studentId) async {
    final db = await instance.database;
    return await db.query(
      'results',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'id DESC',
    );
  }

  // کسی بھی درجے کے تمام نتائج، ایک امتحان کی قسم کے لیے (طالب علم کی تفصیل کے ساتھ)
  Future<List<Map<String, dynamic>>> getAllResultsWithStudent({
    String? examType,
  }) async {
    final db = await instance.database;
    final where = examType == null ? '' : 'WHERE r.exam_type = ?';
    final args = examType == null ? <Object?>[] : <Object?>[examType];
    return await db.rawQuery(
      "SELECT r.*, s.name AS student_name, s.fname AS father_name, "
      "s.reg_no AS reg_no FROM results r "
      "LEFT JOIN students s ON s.id = r.student_id "
      "$where ORDER BY r.class_name ASC, r.student_id ASC, r.id ASC",
      args,
    );
  }

  // ------------------------- درجات (Classes) بنانا -------------------------

  Future<int> insertClass(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('classes', row);
  }

  Future<List<Map<String, dynamic>>> getClasses() async {
    final db = await instance.database;
    return await db.query('classes', orderBy: 'id ASC');
  }

  Future<int> deleteClass(int id) async {
    final db = await instance.database;
    return await db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------- فیس (Fees) -------------------------

  Future<int> insertFee(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('fees', row);
  }

  Future<List<Map<String, dynamic>>> getFees() async {
    final db = await instance.database;
    return await db.rawQuery(
      "SELECT f.*, s.name AS student_name, s.fname AS father_name, "
      "s.reg_no AS reg_no, s.class_name AS class_name FROM fees f "
      "LEFT JOIN students s ON s.id = f.student_id "
      "ORDER BY f.id DESC",
    );
  }

  Future<int> updateFee(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('fees', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFee(int id) async {
    final db = await instance.database;
    return await db.delete('fees', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------- تنخواہ (Salaries) -------------------------

  Future<int> insertSalary(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('salaries', row);
  }

  Future<List<Map<String, dynamic>>> getSalaries() async {
    final db = await instance.database;
    return await db.rawQuery(
      "SELECT sa.*, t.name AS teacher_name, t.designation AS designation "
      "FROM salaries sa LEFT JOIN teachers t ON t.id = sa.teacher_id "
      "ORDER BY sa.id DESC",
    );
  }

  Future<int> updateSalary(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('salaries', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteSalary(int id) async {
    final db = await instance.database;
    return await db.delete('salaries', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------- چھٹیاں (Holidays) -------------------------

  Future<int> insertHoliday(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('holidays', row);
  }

  Future<List<Map<String, dynamic>>> getHolidays() async {
    final db = await instance.database;
    return await db.query('holidays', orderBy: 'start_date DESC, id DESC');
  }

  Future<int> deleteHoliday(int id) async {
    final db = await instance.database;
    return await db.delete('holidays', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------- روز کا سبق (Daily Lesson) -------------------------

  Future<int> insertDailyLesson(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('daily_lessons', row);
  }

  Future<List<Map<String, dynamic>>> getDailyLessons() async {
    final db = await instance.database;
    return await db.rawQuery(
      "SELECT dl.*, t.name AS teacher_name FROM daily_lessons dl "
      "LEFT JOIN teachers t ON t.id = dl.teacher_id "
      "ORDER BY dl.id DESC",
    );
  }

  Future<int> deleteDailyLesson(int id) async {
    final db = await instance.database;
    return await db.delete('daily_lessons', where: 'id = ?', whereArgs: [id]);
  }

  // ------------------------- حاضری کی رپورٹ (پرنٹ کے لیے) -------------------------

  // مخصوص تاریخ کی تمام طلبہ حاضری، طالب علم کی تفصیل کے ساتھ
  Future<List<Map<String, dynamic>>> getStudentAttendanceReport(
      String date) async {
    final db = await instance.database;
    return await db.rawQuery(
      "SELECT sa.*, s.name AS student_name, s.fname AS father_name, "
      "s.reg_no AS reg_no, s.class_name AS class_name, "
      "s.current_district AS current_district, "
      "s.permanent_district AS permanent_district FROM student_attendance sa "
      "LEFT JOIN students s ON s.id = sa.student_id "
      "WHERE sa.attend_date = ? ORDER BY s.class_name ASC, sa.id ASC",
      [date],
    );
  }

  // ایک مخصوص درجے اور تاریخ کی طلبہ حاضری
  Future<List<Map<String, dynamic>>> getClassAttendanceByDate(
      String className, String date) async {
    final db = await instance.database;
    return await db.rawQuery(
      "SELECT sa.*, s.name AS student_name, s.fname AS father_name, "
      "s.reg_no AS reg_no, s.class_name AS class_name FROM student_attendance sa "
      "LEFT JOIN students s ON s.id = sa.student_id "
      "WHERE s.class_name = ? AND sa.attend_date = ? ORDER BY sa.id ASC",
      [className, date],
    );
  }
}
