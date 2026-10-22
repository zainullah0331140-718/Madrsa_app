import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'add_result.dart';
import 'add_student.dart';
import 'app_settings.dart';
import 'class_page.dart';
import 'daily_lesson.dart';
import 'database_helper.dart';
import 'fee_page.dart';
import 'holiday_page.dart';
import 'notification_service.dart';
import 'result_view.dart';
import 'salary_page.dart';
import 'staff_list.dart';
import 'settings.dart';
import 'staff_attendance.dart';
import 'student_attendance.dart';
import 'student_list.dart';
import 'strings.dart';

Future<void> main() async {
  ErrorWidget.builder = (details) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: const Color(0xFFB00020),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Text(
                'UI ERROR:\n${details.exceptionAsString()}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } catch (_) {}

    try {
      await AppSettings.instance.load().timeout(const Duration(seconds: 5));
    } catch (_) {}

    if (Platform.isAndroid) {
      try {
        await NotificationService.instance
            .init()
            .timeout(const Duration(seconds: 5));
        if (AppSettings.instance.notificationsEnabled) {
          await NotificationService.instance
              .scheduleDailyReminder(AppSettings.instance.reminderMinutes);
        }
      } catch (_) {}
    }

    runApp(const MadarsaApp());
  }, (error, stack) {
    debugPrint('FATAL ERROR: $error\n$stack');
  });
}

// ============================================================================
//                       3D گرے اسکیل ڈیزائن کے رنگ
// ============================================================================

class App3D {
  App3D._();

  static const Color bg = Color(0xFFE3E3E3);
  static const Color bgLight = Color(0xFFEDEDED);

  static const Color greenDeep = Color(0xFF1B4332);
  static const Color greenDarker = Color(0xFF081C15);
  static const Color greenMid = Color(0xFF2D6A4F);
  static const Color greenBannerTop = Color(0xFF1E4620);
  static const Color greenBannerBottom = Color(0xFF0E2910);

  static const Color charcoal = Color(0xFF2B2B2B);
  static const Color charcoalMid = Color(0xFF3C3C3C);
  static const Color ash = Color(0xFF555555);

  static List<BoxShadow> heavy({double y = 10, double blur = 18}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      offset: Offset(0, y),
      blurRadius: blur,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.18),
      offset: Offset(0, y * 0.4),
      blurRadius: blur * 0.4,
    ),
  ];

  static List<BoxShadow> soft({double y = 6, double blur = 12}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.22),
      offset: Offset(0, y),
      blurRadius: blur,
    ),
  ];

  static const List<BoxShadow> bevel = [
    BoxShadow(
      color: Color(0x66FFFFFF),
      offset: Offset(0, -1.5),
      blurRadius: 0,
    ),
  ];

  static const Color textDark = Color(0xFF2B2B2B);
  static const Color textMuted = Color(0xFF6B6B6B);
}

class MadarsaApp extends StatelessWidget {
  const MadarsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final isUrdu = settings.isUrdu;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Madarsa Management System',
          themeMode: settings.flutterThemeMode,
          theme: _lightTheme(),
          darkTheme: _darkTheme(),
          locale: Locale(isUrdu ? 'ur' : 'en'),
          supportedLocales: const [Locale('ur'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const HomePage(),
        );
      },
    );
  }

  static const TextStyle _baseHints = TextStyle(height: 1.8);

  ThemeData _lightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: App3D.greenDeep),
      scaffoldBackgroundColor: App3D.bg,
      fontFamily: 'UrduNastaleeq',
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: App3D.greenDarker,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: Color(0xFFEDEDED)),
      textTheme: base.textTheme.apply(
        fontFamily: 'UrduNastaleeq',
        bodyColor: App3D.textDark,
        displayColor: App3D.textDark,
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(textStyle: _baseHints)),
      dialogTheme: const DialogThemeData(backgroundColor: Color(0xFFEDEDED)),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: App3D.charcoal,
        contentTextStyle:
        TextStyle(color: Colors.white, fontFamily: 'UrduNastaleeq'),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(Colors.black38),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(7),
        interactive: true,
      ),
    );
  }

  ThemeData _darkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: App3D.greenMid,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: 'UrduNastaleeq',
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2A22),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
      textTheme: base.textTheme.apply(fontFamily: 'UrduNastaleeq'),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white38),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(7),
        interactive: true,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ڈیشبورڈ ہمیشہ خلاصہ دکھاتا ہے — نیویگیشن navbar کے دروپ سے ہوتی ہے

  // اعداد و شمار
  int totalStudents = 0;
  int activeStudents = 0;
  int dischargedStudents = 0;
  int graduateStudents = 0;
  int totalStaff = 0;
  bool loading = true;

  // آج کی حاضری (طلبہ و اساتذہ)
  Map<String, int> studentAttendanceToday = {};
  Map<String, int> staffAttendanceToday = {};
  String todayLabel = '';

  // حالیہ داخلے
  List<Map<String, dynamic>> recentStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final students = await DatabaseHelper.instance.getStudents();

      int active = 0;
      int discharged = 0;
      int graduates = 0;

      for (final s in students) {
        final dischargeDate = (s['discharge_date'] ?? '').toString().trim();
        final isDischarged =
            dischargeDate.isNotEmpty && dischargeDate.toLowerCase() != 'null';

        if (isDischarged) {
          discharged++;
        } else {
          active++;
        }

        if (s['is_graduate'] == 1 || s['is_graduate'].toString() == '1') {
          graduates++;
        }
      }

      final sorted = [...students]
        ..sort((a, b) =>
            (b['id'] as int? ?? 0).compareTo(a['id'] as int? ?? 0));
      final recent = sorted.take(5).toList();

      final staff = await _safeCount('teachers');

      // آج کی حاضری
      final today = DateFormat('MM/dd/yyyy').format(DateTime.now());
      Map<String, int> studentAtt = {};
      Map<String, int> staffAtt = {};
      try {
        studentAtt = await DatabaseHelper.instance
            .getAttendanceCounts('student_attendance', today);
        staffAtt = await DatabaseHelper.instance
            .getAttendanceCounts('staff_attendance', today);
      } catch (_) {
        // حاضری نہ ہونے پر خالی ہی رہے گی
      }

      if (!mounted) return;
      setState(() {
        totalStudents = students.length;
        activeStudents = active;
        dischargedStudents = discharged;
        graduateStudents = graduates;
        totalStaff = staff;
        recentStudents = recent;
        studentAttendanceToday = studentAtt;
        staffAttendanceToday = staffAtt;
        todayLabel = today;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(Strings.current.statsLoadError(e),
              textAlign: TextAlign.right),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<int> _safeCount(String table) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
      if (result.isEmpty) return 0;
      final value = result.first['c'];
      return value is int ? value : int.tryParse('$value') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _refresh() async {
    setState(() => loading = true);
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings.current;

    return Scaffold(
      backgroundColor: App3D.bg,
      appBar: _build3DAppBar(s),
      // PC پر مواد کو درمیانی حدد تک محدود رکھتا ہے تاکہ وائیڈ اسکرین پر
      // کارڈز پوری سکرین پر پھیل نہ جائیں — موبائل پر کوئی فرق نہیں آتا
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [App3D.bgLight, App3D.bg],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              children: [
                // ===== Section A: اعداد و شمار کے کارڈ =====
                _buildStatsSection(),

                // ===== باقی مواد: صرف خلاصہ — نیویگیشن navbar کے مینو سے =====
                Expanded(
                  child: _buildSummaryTab(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------- 3D AppBar -------------------------

  PreferredSizeWidget _build3DAppBar(Strings s) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: App3D.greenDarker,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 8,
      shadowColor: Colors.black,
      leadingWidth: 64,
      leading: Center(
        child: _appBarIcon(
          Icons.refresh,
          s.refresh,
          _refresh,
        ),
      ),
      title: Text(
        s.appTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.5,
          shadows: [
            Shadow(
              color: Color(0xB3000000),
              offset: Offset(0, 2.5),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      actions: [
        Center(
          child: _appBarIcon(
            Icons.menu,
            s.menu,
            _showNavMenu,
          ),
        ),
        Center(
          child: _appBarIcon(
            Icons.settings,
            s.settings,
                () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              if (mounted) setState(() {});
            },
          ),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [App3D.greenDeep, App3D.greenDarker],
          ),
        ),
      ),
    );
  }

  // ------------------------- navbar دروپ مینو (تمام نیویگیشن) -------------------------

  Future<void> _showNavMenu() async {
    final s = Strings.current;
    final sections = <_Tab, String>{
      _Tab.entry: s.tabNewEntry,
      _Tab.students: s.tabAllStudents,
      _Tab.misc: s.tabMisc,
      _Tab.reports: s.tabReports,
    };

    final selected = await showMenu<_DashboardModule>(
      context: context,
      position: RelativeRect.fromDirectional(
        textDirection: TextDirection.rtl,
        top: 64,
        start: 16,
        bottom: 0,
        end: 16,
      ),
      items: [
        PopupMenuItem<_DashboardModule>(
          enabled: false,
          height: 34,
          child: Text(
            s.quickNav,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: App3D.greenDeep,
            ),
          ),
        ),
        for (final entry in sections.entries) ...[
          PopupMenuItem<_DashboardModule>(
            enabled: false,
            height: 30,
            child: Text(
              '— ${entry.value} —',
              style: const TextStyle(fontSize: 12, color: App3D.textMuted),
            ),
          ),
          for (final m in _allModules.where((m) => m.tabs.contains(entry.key)))
            PopupMenuItem<_DashboardModule>(
              value: m,
              child: Row(
                children: [
                  Icon(m.icon, size: 20, color: m.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
    if (selected != null) {
      await _onModuleTap(selected);
    }
  }

  Widget _appBarIcon(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3A5A47), Color(0xFF14261B)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.35), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  // ------------------------- Section A: 3D اعداد و شمار -------------------------

  Widget _buildStatsSection() {
    final s = Strings.current;
    return Center(
      // PC پر دو کارڈ بہت چوڑے نہ ہوں — موبائل پر کوئی فرق نہیں
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          // یہاں سے CrossAxisAlignment.stretch ہٹا دیا گیا ہے جس نے ایپ کریش کی تھی!
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _stat3DCard(
                  title: s.studentsCount,
                  icon: Icons.groups,
                  accent: const Color(0xFF3E5C8A),
                  borderColor: const Color(0xFF2B4C7E),
                  child: loading
                      ? _loadingIndicator()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _embossedNumber(
                          '$totalStudents', const Color(0xFF2E4A73)),
                      Text(s.totalStudents,
                          style: const TextStyle(
                              fontSize: 12, color: App3D.textMuted)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _embossedChip(s.active, activeStudents,
                              const Color(0xFF2E7D32)),
                          _embossedChip(s.discharged, dischargedStudents,
                              const Color(0xFFB23A3A)),
                          _embossedChip(s.graduates, graduateStudents,
                              const Color(0xFF3949AB)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _stat3DCard(
                  title: s.staffTitle,
                  icon: Icons.supervisor_account,
                  accent: const Color(0xFFC77B1E),
                  borderColor: const Color(0xFFE0A24A),
                  child: loading
                      ? _loadingIndicator()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _embossedNumber(
                          '$totalStaff', const Color(0xFF9C5D0F)),
                      Text(s.totalMembers,
                          style: const TextStyle(
                              fontSize: 12, color: App3D.textMuted)),
                      const SizedBox(height: 10),
                      _embossedChip(
                          s.members, totalStaff, const Color(0xFFEF6C00)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat3DCard({
    required String title,
    required IconData icon,
    required Color accent,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F4F4), Color(0xFFDCDCDC)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: App3D.heavy(y: 8, blur: 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, accent.withValues(alpha: 0.65)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: App3D.soft(y: 4, blur: 6),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: App3D.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _embossedNumber(String value, Color color) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        color: color,
        height: 1.1,
        shadows: [
          Shadow(
            color: Colors.white.withValues(alpha: 0.9),
            offset: const Offset(0, -2),
            blurRadius: 1,
          ),
          Shadow(
            color: Colors.black.withValues(alpha: 0.35),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _embossedChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.10)
          ],
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Text(
        '$label: $value',
        style:
        TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _loadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }

  // ------------------------- خلاصہ (Summary) ٹیب -------------------------

  Widget _buildSummaryTab() {
    final s = Strings.current;
    return RefreshIndicator(
      color: App3D.greenDeep,
      onRefresh: _loadStats,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _build3DWelcomeBanner(s),
          const SizedBox(height: 20),

          _sectionHeader(s.quickOverview),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _overview3DTile(s.students, totalStudents, Icons.groups,
                  const Color(0xFF3E5C8A)),
              _overview3DTile(s.active, activeStudents, Icons.check_circle,
                  const Color(0xFF2E7D32)),
              _overview3DTile(s.discharged, dischargedStudents, Icons.logout,
                  const Color(0xFFB23A3A)),
              _overview3DTile(s.teachers, totalStaff, Icons.supervisor_account,
                  const Color(0xFFEF6C00)),
            ],
          ),
          const SizedBox(height: 24),

          _sectionHeader(s.todayAttendance),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 8),
            child: Text(
              todayLabel,
              style: const TextStyle(fontSize: 12, color: App3D.textMuted),
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            _buildAttendanceCard(s),
          const SizedBox(height: 24),

          _sectionHeader(s.recentAdmissions),
          const SizedBox(height: 12),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recentStudents.isEmpty)
            _emptyRecentCard(s)
          else
            ...recentStudents.map((st) => _recentStudentCard(st)),
        ],
      ),
    );
  }

  // آج کی حاضری کا کارڈ (طلبہ + اساتذہ)
  Widget _buildAttendanceCard(Strings s) {
    final studentMarked = studentAttendanceToday.values.fold(0, (a, b) => a + b);
    final staffMarked = staffAttendanceToday.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4F4F4), Color(0xFFDCDCDC)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32), width: 3),
        boxShadow: App3D.heavy(y: 8, blur: 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: App3D.soft(y: 4, blur: 6),
                ),
                child: const Icon(Icons.how_to_reg,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  s.markedCount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: App3D.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (studentMarked == 0 && staffMarked == 0)
            Text(s.attendanceNotMarked,
                style: const TextStyle(color: App3D.textMuted))
          else ...[
            Text(s.attendanceTitle,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: App3D.textDark)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _embossedChip(
                    s.present, studentAttendanceToday['حاضر'] ?? 0,
                    const Color(0xFF2E7D32)),
                _embossedChip(
                    s.absent, studentAttendanceToday['غائب'] ?? 0,
                    const Color(0xFFB23A3A)),
                _embossedChip(
                    s.leave, studentAttendanceToday['رخصت'] ?? 0,
                    const Color(0xFFF9A825)),
              ],
            ),
            const SizedBox(height: 10),
            Text(s.staffAttendanceTitle,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: App3D.textDark)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _embossedChip(
                    s.present, staffAttendanceToday['حاضر'] ?? 0,
                    const Color(0xFF2E7D32)),
                _embossedChip(
                    s.absent, staffAttendanceToday['غائب'] ?? 0,
                    const Color(0xFFB23A3A)),
                _embossedChip(
                    s.leave, staffAttendanceToday['رخصت'] ?? 0,
                    const Color(0xFFF9A825)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: App3D.textDark,
        ),
      ),
    );
  }

  Widget _build3DWelcomeBanner(Strings s) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [App3D.greenBannerTop, App3D.greenBannerBottom],
        ),
        borderRadius: BorderRadius.circular(18),
        border:
        Border.all(color: Colors.white.withValues(alpha: 0.28), width: 2.5),
        boxShadow: App3D.heavy(y: 12, blur: 20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Colors.white, Color(0xFFD8E8D8)],
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  offset: const Offset(0, 6),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.school, color: App3D.greenDeep, size: 34),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.welcome,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.tagline,
                  style: const TextStyle(
                    color: Color(0xFFE9F5E9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 13, color: Color(0xFFCDE7CD)),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM/yyyy').format(DateTime.now()),
                      style: const TextStyle(
                          color: Color(0xFFCDE7CD), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overview3DTile(
      String label, int value, IconData icon, Color color) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6F6F6), Color(0xFFDFDFDF)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: App3D.heavy(y: 8, blur: 14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withValues(alpha: 0.65)],
              ),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: App3D.soft(y: 4, blur: 6),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: color,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: App3D.textMuted,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyRecentCard(Strings s) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: App3D.soft(y: 8, blur: 12),
      ),
      child: Center(
        child: Text(s.noStudentsYet,
            style: const TextStyle(color: App3D.textMuted)),
      ),
    );
  }

  Widget _recentStudentCard(Map<String, dynamic> student) {
    final s = Strings.current;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: App3D.heavy(y: 8, blur: 14),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [App3D.greenMid, App3D.greenDeep],
              ),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: App3D.heavy(y: 5, blur: 8),
            ),
            child: Text(
              '${student['reg_no'] ?? '-'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${student['name'] ?? ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: App3D.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${s.father}${student['fname'] ?? ''}',
                  style:
                  const TextStyle(fontSize: 13, color: App3D.textMuted),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(11),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentListPage()),
              );
              await _refresh();
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4A4A4A), Color(0xFF232323)],
                ),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3), width: 1.8),
                boxShadow: App3D.heavy(y: 5, blur: 8),
              ),
              child: Text(
                s.view,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onModuleTap(_DashboardModule module) async {
    switch (module.action) {
      case _Action.addStudent:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddStudentPage()),
        );
        await _refresh();
        break;
      case _Action.students:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentListPage()),
        );
        await _refresh();
        break;
      case _Action.teachers:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StaffListPage()),
        );
        await _refresh();
        break;
      case _Action.newClass:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ClassPage()),
        );
        await _refresh();
        break;
      case _Action.dailyLesson:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DailyLessonPage()),
        );
        await _refresh();
        break;
      case _Action.studentAttendance:
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const StudentAttendancePage()),
        );
        await _refresh();
        break;
      case _Action.staffAttendance:
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const StaffAttendancePage()),
        );
        await _refresh();
        break;
      case _Action.results:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddResultPage()),
        );
        await _refresh();
        break;
      case _Action.viewResults:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultViewPage()),
        );
        await _refresh();
        break;
      case _Action.fees:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FeePage()),
        );
        await _refresh();
        break;
      case _Action.salary:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SalaryPage()),
        );
        await _refresh();
        break;
      case _Action.holidays:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HolidayPage()),
        );
        await _refresh();
        break;
    }
  }

  // ------------------------- ماڈیولز کی فہرست -------------------------

  List<_DashboardModule> get _allModules => [
    _DashboardModule(
      label: Strings.current.mNewAdmission,
      icon: Icons.person_add,
      background: const Color(0xFFC8E6C9),
      accent: const Color(0xFF2E7D32),
      tabs: {_Tab.entry, _Tab.students},
      action: _Action.addStudent,
    ),
    _DashboardModule(
      label: Strings.current.mStudents,
      icon: Icons.groups,
      background: const Color(0xFFBBD3F0),
      accent: const Color(0xFF1565C0),
      tabs: {_Tab.entry, _Tab.students},
      action: _Action.students,
    ),
    _DashboardModule(
      label: Strings.current.mTeachersStaff,
      icon: Icons.supervisor_account,
      background: const Color(0xFFF4D9B0),
      accent: const Color(0xFFEF6C00),
      tabs: {_Tab.entry, _Tab.misc},
      action: _Action.teachers,
    ),
    _DashboardModule(
      label: Strings.current.mNewClass,
      icon: Icons.meeting_room,
      background: const Color(0xFFC4E3C6),
      accent: const Color(0xFF2E7D32),
      tabs: {_Tab.entry},
      action: _Action.newClass,
    ),
    _DashboardModule(
      label: Strings.current.mDailyLesson,
      icon: Icons.menu_book,
      background: const Color(0xFFDCC7E6),
      accent: const Color(0xFF6A1B9A),
      tabs: {_Tab.entry, _Tab.misc},
      action: _Action.dailyLesson,
    ),
    _DashboardModule(
      label: Strings.current.mStudentAttendance,
      icon: Icons.how_to_reg,
      background: const Color(0xFFB8E2E8),
      accent: const Color(0xFF00838F),
      tabs: {_Tab.entry, _Tab.students},
      action: _Action.studentAttendance,
    ),
    _DashboardModule(
      label: Strings.current.mStaffAttendance,
      icon: Icons.co_present,
      background: const Color(0xFFF0C2C6),
      accent: const Color(0xFFC62828),
      tabs: {_Tab.entry},
      action: _Action.staffAttendance,
    ),
    _DashboardModule(
      label: Strings.current.mFees,
      icon: Icons.payments,
      background: const Color(0xFFF2E6A8),
      accent: const Color(0xFFF9A825),
      tabs: {_Tab.entry, _Tab.reports},
      action: _Action.fees,
    ),
    _DashboardModule(
      label: Strings.current.mSalary,
      icon: Icons.account_balance_wallet,
      background: const Color(0xFFC6C9E8),
      accent: const Color(0xFF283593),
      tabs: {_Tab.entry, _Tab.reports},
      action: _Action.salary,
    ),
    _DashboardModule(
      label: Strings.current.mResults,
      icon: Icons.emoji_events,
      background: const Color(0xFFB9E0DC),
      accent: const Color(0xFF00695C),
      tabs: {_Tab.entry, _Tab.reports, _Tab.students},
      action: _Action.results,
    ),
    _DashboardModule(
      label: Strings.current.mViewResults,
      icon: Icons.assessment,
      background: const Color(0xFFB9E0DC),
      accent: const Color(0xFF00796B),
      tabs: {_Tab.reports, _Tab.students},
      action: _Action.viewResults,
    ),
    _DashboardModule(
      label: Strings.current.mHolidays,
      icon: Icons.beach_access,
      background: const Color(0xFFF0CBB8),
      accent: const Color(0xFFD84315),
      tabs: {_Tab.entry, _Tab.misc},
      action: _Action.holidays,
    ),
  ];
}

enum _Tab { entry, students, misc, reports }

enum _Action {
  addStudent,
  students,
  teachers,
  newClass,
  dailyLesson,
  studentAttendance,
  staffAttendance,
  fees,
  salary,
  results,
  viewResults,
  holidays,
}

class _DashboardModule {
  const _DashboardModule({
    required this.label,
    required this.icon,
    required this.background,
    required this.accent,
    required this.tabs,
    required this.action,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color accent;
  final Set<_Tab> tabs;
  final _Action action;
}
