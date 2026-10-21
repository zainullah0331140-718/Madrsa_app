import 'app_settings.dart';

/// ڈراپ ڈاؤن کے آپشن: اردو/انگلیزی نمایش، ڈیٹا بیس میں ہمیشہ اردو قدر محفوظ ہوتی ہے
class Opt {
  const Opt(this.ur, this.en, this.value);
  final String ur;
  final String en;
  final String value;
}

/// ایپ کے متن کی ترجمہ نظام (اردو / انگلیش)
class Strings {
  Strings._(this.lang);
  final String lang;

  static Strings get current => Strings._(AppSettings.instance.language);
  bool get _ur => lang == 'ur';

  // ------------------------- عمومی -------------------------
  String get appTitle =>
      _ur ? 'مدرسہ مینجمنٹ سسٹم' : 'Madarsa Management System';
  String get refresh => _ur ? 'تازہ کریں' : 'Refresh';
  String get settings => _ur ? 'ترتیبات' : 'Settings';
  String get view => _ur ? 'دیکھیں' : 'View';
  String get save => _ur ? 'محفوظ کریں' : 'Save';
  String get cancel => _ur ? 'منسوخ' : 'Cancel';
  String get yes => _ur ? 'ہاں' : 'Yes';
  String get no => _ur ? 'نہیں' : 'No';

  // ------------------------- ہوم ٹیبز -------------------------
  String get tabSummary => _ur ? 'خلاصہ' : 'Summary';
  String get tabNewEntry => _ur ? 'نیا اندراج' : 'New Entry';
  String get tabAllStudents => _ur ? 'تمام طلبہ' : 'All Students';
  String get tabMisc => _ur ? 'متفرق' : 'Misc';
  String get tabReports => _ur ? 'رپورٹس' : 'Reports';

  // ------------------------- اعداد و شمار -------------------------
  String get studentsCount => _ur ? 'طلبہ کی تعداد' : 'Students';
  String get totalStudents => _ur ? 'کل طلبہ' : 'Total Students';
  String get active => _ur ? 'فعال' : 'Active';
  String get discharged => _ur ? 'خارج' : 'Discharged';
  String get graduates => _ur ? 'فاضل' : 'Graduates';
  String get staffTitle => _ur ? 'اساتذہ و عملہ' : 'Teachers & Staff';
  String get totalMembers => _ur ? 'کل اراکین' : 'Total Members';
  String get members => _ur ? 'اراکین' : 'Members';
  String get quickOverview => _ur ? 'فوری جائزہ' : 'Quick Overview';
  String get students => _ur ? 'طلبہ' : 'Students';
  String get teachers => _ur ? 'اساتذہ' : 'Teachers';
  String get recentAdmissions => _ur ? 'حالیہ داخلے' : 'Recent Admissions';
  String get welcome => _ur ? 'خوش آمدید' : 'Welcome';
  String get tagline =>
      _ur ? 'دینی و عصری تعلیم کا مرکز' : 'Center of Religious & Modern Education';
  String get noStudentsYet => _ur
      ? 'ابھی تک کوئی طالب علم موجود نہیں ہے'
      : 'No students added yet';
  String get father => _ur ? 'ولد: ' : 'Father: ';
  String statsLoadError(Object e) =>
      _ur ? 'اعداد و شمار لوڈ نہیں ہو سکے: $e' : 'Could not load statistics: $e';
  String moduleSoon(String label) => _ur
      ? '«$label» ماڈیول جلد دستیاب ہوگا'
      : 'Module “$label” will be available soon';

  // ------------------------- ماڈیول لیبلز -------------------------
  String get mNewAdmission => _ur ? 'نیا داخلہ' : 'New Admission';
  String get mStudents => _ur ? 'طلبہ' : 'Students';
  String get mTeachersStaff =>
      _ur ? 'اساتذہ و عملہ اراکین' : 'Teachers & Staff';
  String get mNewClass => _ur ? 'نیا درجہ' : 'New Class';
  String get mDailyLesson => _ur ? 'روز کا سبق' : 'Daily Lesson';
  String get mStudentAttendance => _ur ? 'طلبہ کی حاضری' : 'Student Attendance';
  String get mStaffAttendance =>
      _ur ? 'حاضری اساتذہ و عملہ' : 'Staff Attendance';
  String get mFees => _ur ? 'فیس' : 'Fees';
  String get mSalary => _ur ? 'تنخواہ' : 'Salary';
  String get mResults => _ur ? 'نتائج' : 'Results';
  String get mViewResults => _ur ? 'نتائج دیکھیں' : 'View Results';
  String get mHolidays => _ur ? 'چھٹیاں' : 'Holidays';
  String get mWorship => _ur ? 'عبادات و اخلاقیات' : 'Worship & Ethics';
  String get mIncomeExpense =>
      _ur ? 'رجسٹر آمدن و خرچ' : 'Income & Expense';
  String get mComplaints =>
      _ur ? 'رجسٹر تجاویز و شکایات' : 'Suggestions & Complaints';
  String get mSettings => _ur ? 'ترتیبات' : 'Settings';

  // ------------------------- نیا اندراج / فارم -------------------------
  String get studentForm => _ur ? 'طالب علم کا فارم' : 'Student Form';
  String get tabPrevSchools => _ur ? 'سابقہ مدارس' : 'Previous Schools';
  String get tabCurrentClass => _ur ? 'موجودہ درجہ' : 'Current Class';
  String get tabLessonTrack => _ur ? 'سبق ٹریک' : 'Lesson Track';
  String get currentClassPlaceholder =>
      _ur ? 'موجودہ درجہ کا ڈیٹا یہاں آئے گا' : 'Current class data will appear here';
  String get lessonTrackPlaceholder =>
      _ur ? 'سبق ٹریک کا ڈیٹا یہاں آئے گا' : 'Lesson track data will appear here';

  String get lName => _ur ? 'نام' : 'Name';
  String get lFatherName => _ur ? 'والد کا نام' : 'Father Name';
  String get lCaste => _ur ? 'قوم' : 'Caste';
  String get lGender => _ur ? 'جنس' : 'Gender';
  String get lCnic => _ur ? 'شناختی کارڈ' : 'CNIC';
  String get lDob => _ur ? 'تاریخ پیدائش' : 'Date of Birth';
  String get lAge => _ur ? 'عمر' : 'Age';
  String get lAdmissionDate => _ur ? 'داخلہ کی تاریخ' : 'Admission Date';
  String get lRegNo => _ur ? 'رجسٹریشن نمبر' : 'Registration No';
  String get lClassName => _ur ? 'درجہ' : 'Class';
  String get lCurrentAddress => _ur ? 'موجودہ پتہ' : 'Current Address';
  String get lCurrentDistrict => _ur ? 'موجودہ ضلع' : 'Current District';
  String get lPermanentAddress => _ur ? 'مستقل پتہ' : 'Permanent Address';
  String get lPermanentDistrict => _ur ? 'مستقل ضلع' : 'Permanent District';
  String get lPhone => _ur ? 'فون' : 'Phone';
  String get lModernEdu => _ur ? 'عصری تعلیم' : 'Modern Education';
  String get lOtherCourses => _ur ? 'دیگر کورسز' : 'Other Courses';
  String get lResidential => _ur ? 'رہائشی / غیر رہائشی' : 'Residential Status';
  String get lSupport => _ur ? 'امدادی / غیر امدادی' : 'Support Status';
  String get lFederal => _ur ? 'وفاقی / غیر وفاقی' : 'Federal Status';
  String get lDischargeDate => _ur ? 'اخراج کی تاریخ' : 'Discharge Date';
  String get lDischargeReason => _ur ? 'اخراج کی وجہ' : 'Discharge Reason';
  String get selectHint => _ur ? '-- منتخب کریں --' : '-- Select --';
  String get selectDischargeHint =>
      _ur ? '-- وجہ اخراج منتخب کریں --' : '-- Select discharge reason --';
  String get graduateTitle => _ur ? 'فاضل التحصیل' : 'Graduated';
  String get graduateSubtitle => _ur
      ? 'صرف آخری سال کے جانے والے طلباء کے لئے'
      : 'Only for students who left after final year';
  String get nameFatherRequired =>
      _ur ? 'نام اور والد کا نام لکھنا ضروری ہے!' : 'Name and Father Name are required!';
  String get dataSaved =>
      _ur ? 'ڈیٹا کامیابی سے محفوظ ہو گیا!' : 'Data saved successfully!';

  // ------------------------- تصویر -------------------------
  String get addPhoto => _ur ? 'تصویر لگائیں' : 'Add Photo';
  String get photoOptions => _ur ? 'تصویر کیسے لگائیں؟' : 'How to add photo?';
  String get fromCamera => _ur ? 'کیمرہ سے' : 'Take Photo';
  String get fromGallery => _ur ? 'گیلری سے' : 'Choose from Gallery';
  String get removePhoto => _ur ? 'تصویر ہٹائیں' : 'Remove Photo';
  String get photoNotSupported =>
      _ur ? 'اس ڈیوائس پر تصویر دستیاب نہیں' : 'Images not available on this device';

  // ------------------------- ڈراپ ڈاؤن آپشنز -------------------------
  String get optMale => _ur ? 'مرد' : 'Male';
  String get optFemale => _ur ? 'عورت' : 'Female';
  String get optResidential => _ur ? 'رہائشی' : 'Residential';
  String get optNonResidential => _ur ? 'غیر رہائشی' : 'Non-Residential';
  String get optSupported => _ur ? 'امدادی' : 'Supported';
  String get optNotSupported => _ur ? 'غیر امدادی' : 'Not Supported';
  String get optFederal => _ur ? 'وفاقی' : 'Federal';
  String get optNonFederal => _ur ? 'غیر وفاقی' : 'Non-Federal';
  String get reasonComplete => _ur ? 'تکمیل تعلیم' : 'Completion of Studies';
  String get reasonAbsent => _ur ? 'غیر حاضری' : 'Absenteeism';
  String get reasonOther => _ur ? 'دیگر' : 'Other';

  List<Opt> get genderOptions => [
        const Opt('مرد', 'Male', 'مرد'),
        const Opt('عورت', 'Female', 'عورت'),
      ];
  List<Opt> get resOptions => [
        const Opt('رہائشی', 'Residential', 'رہائشی'),
        const Opt('غیر رہائشی', 'Non-Residential', 'غیر رہائشی'),
      ];
  List<Opt> get supportOptions => [
        const Opt('امدادی', 'Supported', 'امدادی'),
        const Opt('غیر امدادی', 'Not Supported', 'غیر امدادی'),
      ];
  List<Opt> get federalOptions => [
        const Opt('وفاقی', 'Federal', 'وفاقی'),
        const Opt('غیر وفاقی', 'Non-Federal', 'غیر وفاقی'),
      ];
  List<Opt> get dischargeOptions => [
        const Opt('تکمیل تعلیم', 'Completion of Studies', 'تکمیل تعلیم'),
        const Opt('غیر حاضری', 'Absenteeism', 'غیر حاضری'),
        const Opt('دیگر', 'Other', 'دیگر'),
      ];

  // ------------------------- طلباء کی فہرست -------------------------
  String get studentList => _ur ? 'طلباء کی فہرست' : 'Student List';
  String get deleteTitle => _ur ? 'ڈیلیٹ کریں؟' : 'Delete?';
  String get deleteMessage => _ur
      ? 'کیا آپ واقعی اس ریکارڈ کو ڈیلیٹ کرنا چاہتے ہیں؟'
      : 'Are you sure you want to delete this record?';
  String get yesDelete => _ur ? 'ہاں، ڈیلیٹ کریں' : 'Yes, Delete';
  String get recordDeleted =>
      _ur ? 'ریکارڈ ڈیلیٹ ہو گیا!' : 'Record deleted!';
  String get edit => _ur ? 'تبدیل کریں' : 'Edit';
  String get print => _ur ? 'پرنٹ کریں' : 'Print';
  String get delete => _ur ? 'ڈیلیٹ' : 'Delete';

  // ------------------------- تبدیلی / پرنٹ -------------------------
  String get editStudentTitle =>
      _ur ? 'طالب علم کا ڈیٹا تبدیل کریں' : 'Edit Student Record';
  String get printProfile => _ur ? 'پروفائل پرنٹ کریں' : 'Print Profile';
  String get update => _ur ? 'تبدیل کریں' : 'Update';
  String get recordUpdated =>
      _ur ? 'ریکارڈ کامیابی سے تبدیل ہو گیا!' : 'Record updated successfully!';
  String get profileReady =>
      _ur ? 'پروفائل پرنٹ کے لیے تیار ہے۔' : 'Profile is ready to print.';
  String get printBeforeName =>
      _ur ? 'پرنٹ سے پہلے نام اور والد کا نام لکھیں!' : 'Enter Name and Father Name before printing!';
  String printProblem(Object e) =>
      _ur ? 'پرنٹ میں مسئلہ آ رہا ہے: $e' : 'Print problem: $e';
  String recordProblem(Object e) =>
      _ur ? 'مسئلہ آ رہا ہے: $e' : 'Problem: $e';

  // ------------------------- سیکشن عنوانات -------------------------
  String get secPersonal => _ur ? 'ذاتی معلومات' : 'Personal Information';
  String get secAdmission => _ur ? 'داخلہ و رجسٹریشن' : 'Admission & Registration';
  String get secContact => _ur ? 'رابطہ و پتہ' : 'Contact & Address';
  String get secEducation => _ur ? 'تعلیمی معلومات' : 'Education';
  String get secLiving => _ur ? 'رہائش و امداد' : 'Living & Support';
  String get secDischarge => _ur ? 'اخراج کی معلومات' : 'Discharge Information';

  // ------------------------- ترتیبات -------------------------
  String get settingsTitle => _ur ? 'ترتیبات' : 'Settings';
  String get languageTitle => _ur ? 'زبان' : 'Language';
  String get languageSubtitle =>
      _ur ? 'ایپ کی زبان منتخب کریں' : 'Choose app language';
  String get urdu => _ur ? 'اردو' : 'Urdu';
  String get english => _ur ? 'انگلیش' : 'English';
  String get themeTitle => _ur ? 'تھیم' : 'Theme';
  String get themeSubtitle =>
      _ur ? 'ہلکا یا گہرا موڈ منتخب کریں' : 'Choose light or dark mode';
  String get light => _ur ? 'ہلکا (لائٹ)' : 'Light';
  String get dark => _ur ? 'گہرا (ڈارک)' : 'Dark';
  String get system => _ur ? 'سسٹم' : 'System';
  String get notificationsTitle => _ur ? 'اطلاعات' : 'Notifications';
  String get attendanceReminder =>
      _ur ? 'روزانہ حاضری کی یاد دہانی' : 'Daily attendance reminder';
  String get attendanceReminderSubtitle => _ur
      ? 'ہر روز طلبہ کی حاضری کی یاد دہانی ملے گی'
      : 'Get a daily reminder to mark student attendance';
  String get reminderTime => _ur ? 'یاد دہانی کا وقت' : 'Reminder Time';
  String get notificationsOff =>
      _ur ? 'اس ڈیوائس پر اطلاعات دستیاب نہیں ہیں' : 'Notifications not available on this device';

  // ------------------------- حاضری -------------------------
  String get attendanceTitle => _ur ? 'طلبہ کی حاضری' : 'Student Attendance';
  String get todayAttendance => _ur ? 'آج کی حاضری' : "Today's Attendance";
  String get attendanceNotMarked =>
      _ur ? 'آج کی حاضری ابھی محفوظ نہیں ہوئی' : 'Attendance not marked yet';
  String get markedCount =>
      _ur ? 'محفوظ شدہ حاضری' : 'Marked Attendance';
  String get staffAttendanceTitle =>
      _ur ? 'اساتذہ و عملہ کی حاضری' : 'Staff Attendance';
  String get dateLabel => _ur ? 'تاریخ' : 'Date';
  String get present => _ur ? 'حاضر' : 'Present';
  String get absent => _ur ? 'غائب' : 'Absent';
  String get leave => _ur ? 'رخصت' : 'Leave';
  String get saveAttendance =>
      _ur ? 'حاضری محفوظ کریں' : 'Save Attendance';
  String get attendanceSaved =>
      _ur ? 'حاضری کامیابی سے محفوظ ہو گئی!' : 'Attendance saved successfully!';
  String get noDataToSave =>
      _ur ? 'محفوظ کرنے کے لیے کوئی طالب علم موجود نہیں ہے' : 'No students to save';
  String get noActiveStudents => _ur
      ? 'ابھی تک کوئی فعال طالب علم موجود نہیں ہے'
      : 'No active students yet';
  String get noActiveStaff =>
      _ur ? 'ابھی تک کوئی فعال استاد / عملہ موجود نہیں' : 'No active staff yet';
  String get staffList => _ur ? 'اساتذہ و عملہ کی فہرست' : 'Staff List';
  String get addStaff => _ur ? 'نیا استاد / عملہ' : 'Add Staff';
  String get editStaffTitle =>
      _ur ? 'استاد / عملہ کی معلومات تبدیل کریں' : 'Edit Staff Record';
  String get designation => _ur ? 'عہدہ' : 'Designation';
  String get joiningDate => _ur ? 'تاریخِ تقرری' : 'Joining Date';
  String get teacherNameRequired =>
      _ur ? 'استاد کا نام لکھنا ضروری ہے!' : 'Teacher name is required!';
  String get lAddress => _ur ? 'پتہ' : 'Address';
  String get lFather => _ur ? 'ولد' : 'Father';
  String get loadFailed =>
      _ur ? 'ڈیٹا لوڈ نہیں ہو سکا' : 'Could not load data';

  // ------------------------- نتائج (DMC) -------------------------
  String get resultTitle => _ur ? 'نتیجہ (ڈی ایم سی)' : 'Result (DMC)';
  String get addResultTitle => _ur ? 'نتیجہ شامل کریں' : 'Add Result';
  String get selectClass => _ur ? 'درجہ منتخب کریں' : 'Select Class';
  String get examType => _ur ? 'امتحان کی قسم' : 'Exam Type';
  String get subject => _ur ? 'مضمون' : 'Subject';
  String get totalMarks => _ur ? 'کل نمبر' : 'Total Marks';
  String get obtainedMarks => _ur ? 'حاصل کردہ نمبر' : 'Obtained Marks';
  String get remarks => _ur ? 'کیفیت' : 'Remarks';
  String get percentage => _ur ? 'فی صد' : 'Percentage';
  String get grade => _ur ? 'درجہ (گریڈ)' : 'Grade';
  String get saveResult => _ur ? 'نتیجہ محفوظ کریں' : 'Save Result';
  String get resultSaved =>
      _ur ? 'نتیجہ کامیابی سے محفوظ ہو گیا!' : 'Result saved successfully!';
  String get printDmc => _ur ? 'ڈی ایم سی پرنٹ کریں' : 'Print DMC';
  String get noResults => _ur
      ? 'اس درجے اور امتحان کا کوئی نتیجہ موجود نہیں'
      : 'No results for this class and exam';
  String get selectClassExamFirst => _ur
      ? 'پہلے درجہ اور امتحان کی قسم منتخب کریں'
      : 'Select class and exam type first';
  String get position => _ur ? 'پوزیشن' : 'Position';
  String get rollNo => _ur ? 'رول نمبر' : 'Roll No';
  String get city => _ur ? 'شہر' : 'City';
  String get allClasses => _ur ? 'تمام درجات' : 'All Classes';
  String get classWiseResults =>
      _ur ? 'درجہ وار نتائج (ڈی ایم سی)' : 'Class-wise Results (DMC)';
  String get selectStudentHint =>
      _ur ? '-- طالب علم منتخب کریں --' : '-- Select student --';
  String get selectExamHint =>
      _ur ? '-- امتحان کی قسم منتخب کریں --' : '-- Select exam type --';
  String get subjectRequired => _ur ? 'مضمون لکھنا ضروری ہے!' : 'Subject is required!';
  String get totalMarksInvalid =>
      _ur ? 'کل نمبر درست طور پر لکھیں!' : 'Enter valid total marks!';
  String get obtainedMarksInvalid =>
      _ur ? 'حاصل کردہ نمبر درست طور پر لکھیں!' : 'Enter valid obtained marks!';
  String get obtainedTooHigh => _ur
      ? 'حاصل کردہ نمبر، کل نمبر سے زیادہ نہیں ہو سکتے!'
      : 'Obtained marks cannot exceed total marks!';
  String get subjectHint =>
      _ur ? 'مثلاً تجوید، حفظ القرآن، نحو' : 'e.g. Tajweed, Hifz, Nahw';
  String get remarksHint =>
      _ur ? 'مثلاً اچھی، درمیانہ، ضعیف' : 'e.g. Good, Average, Weak';

  // امتحان کی قسمیں
  String get examMonthly => _ur ? 'ماہانہ' : 'Monthly';
  String get examHalfYearly => _ur ? 'ششماہی' : 'Half-Yearly';
  String get examAnnual => _ur ? 'سالانہ' : 'Annual';
  List<String> get examTypes => ['ماہانہ', 'ششماہی', 'سالانہ'];
  String examTypeLabel(String value) {
    switch (value) {
      case 'ماہانہ':
        return examMonthly;
      case 'ششماہی':
        return examHalfYearly;
      case 'سالانہ':
        return examAnnual;
      default:
        return value;
    }
  }

  // ------------------------- نیا درجہ (Class) -------------------------
  String get newClassTitle => _ur ? 'نیا درجہ بنائیں' : 'Create Class';
  String get className => _ur ? 'درجہ کا نام' : 'Class Name';
  String get section => _ur ? 'سیکشن' : 'Section';
  String get room => _ur ? 'کمرہ' : 'Room';
  String get capacity => _ur ? 'گنجائش' : 'Capacity';
  String get description => _ur ? 'تفصیل' : 'Description';
  String get saveClass => _ur ? 'درجہ محفوظ کریں' : 'Save Class';
  String get classSaved => _ur ? 'درجہ کامیابی سے محفوظ ہو گیا!' : 'Class saved!';
  String get classNameRequired =>
      _ur ? 'درجہ کا نام لکھنا ضروری ہے!' : 'Class name is required!';
  String get classList => _ur ? 'موجودہ درجات' : 'Existing Classes';
  String get noClasses => _ur ? 'ابھی کوئی درجہ موجود نہیں' : 'No classes yet';
  String get deleted => _ur ? 'ریکارڈ ڈیلیٹ ہو گیا!' : 'Record deleted!';

  // ------------------------- فیس (Fee) -------------------------
  String get feesTitle => _ur ? 'فیس کا نظام' : 'Fee System';
  String get addFee => _ur ? 'فیس شامل کریں' : 'Add Fee';
  String get feeMonth => _ur ? 'مہینہ' : 'Month';
  String get feeType => _ur ? 'فیس کی قسم' : 'Fee Type';
  String get amount => _ur ? 'رقم' : 'Amount';
  String get paidAmount => _ur ? 'ادا شدہ رقم' : 'Paid Amount';
  String get remaining => _ur ? 'باقی' : 'Remaining';
  String get feeStatus => _ur ? 'حالت' : 'Status';
  String get saveFee => _ur ? 'فیس محفوظ کریں' : 'Save Fee';
  String get feeSaved => _ur ? 'فیس کامیابی سے محفوظ ہو گئی!' : 'Fee saved!';
  String get studentRequired =>
      _ur ? 'طالب علم منتخب کریں!' : 'Select a student!';
  String get amountRequired => _ur ? 'رقم درست لکھیں!' : 'Enter valid amount!';
  String get feeList => _ur ? 'فیس کا ریکارڈ' : 'Fee Records';
  String get noFees => _ur ? 'ابھی کوئی فیس کا ریکارڈ نہیں' : 'No fee records yet';
  String get paid => _ur ? 'ادا شدہ' : 'Paid';
  String get unpaid => _ur ? 'غیر ادا شدہ' : 'Unpaid';
  String get partial => _ur ? 'جزوی' : 'Partial';

  // ------------------------- تنخواہ (Salary) -------------------------
  String get salaryTitle => _ur ? 'تنخواہ کا نظام' : 'Salary System';
  String get addSalary => _ur ? 'تنخواہ شامل کریں' : 'Add Salary';
  String get salaryMonth => _ur ? 'مہینہ' : 'Month';
  String get basicSalary => _ur ? 'بنیادی تنخواہ' : 'Basic Salary';
  String get allowance => _ur ? 'الاؤنس' : 'Allowance';
  String get deduction => _ur ? 'کٹوتی' : 'Deduction';
  String get netPay => _ur ? 'خالص تنخواہ' : 'Net Pay';
  String get saveSalary => _ur ? 'تنخواہ محفوظ کریں' : 'Save Salary';
  String get salarySaved =>
      _ur ? 'تنخواہ کامیابی سے محفوظ ہو گئی!' : 'Salary saved!';
  String get staffRequired =>
      _ur ? 'استاد / عملہ منتخب کریں!' : 'Select a staff member!';
  String get salaryList => _ur ? 'تنخواہ کا ریکارڈ' : 'Salary Records';
  String get printSalaryRegister =>
      _ur ? 'تنخواہ رجسٹر پرنٹ کریں' : 'Print Salary Register';
  String get printPaySlip => _ur ? 'تنخواہ پرچی' : 'Pay Slip';
  String get noSalary => _ur ? 'ابھی کوئی تنخواہ کا ریکارڈ نہیں' : 'No salary records yet';

  // ------------------------- چھٹیاں (Holidays) -------------------------
  String get holidaysTitle => _ur ? 'چھٹیوں کا نظام' : 'Holiday System';
  String get addHoliday => _ur ? 'چھٹی شامل کریں' : 'Add Holiday';
  String get holidayTitle => _ur ? 'چھٹی کا عنوان' : 'Holiday Title';
  String get startDate => _ur ? 'شروع تاریخ' : 'Start Date';
  String get endDate => _ur ? 'آخری تاریخ' : 'End Date';
  String get holidayType => _ur ? 'چھٹی کی قسم' : 'Holiday Type';
  String get saveHoliday => _ur ? 'چھٹی محفوظ کریں' : 'Save Holiday';
  String get holidaySaved =>
      _ur ? 'چھٹی کامیابی سے محفوظ ہو گئی!' : 'Holiday saved!';
  String get holidayList => _ur ? 'چھٹیوں کی فہرست' : 'Holiday List';
  String get noHolidays => _ur ? 'ابھی کوئی چھٹی موجود نہیں' : 'No holidays yet';
  String get titleRequired => _ur ? 'عنوان لکھنا ضروری ہے!' : 'Title is required!';
  List<String> get holidayTypes =>
      _ur ? ['مذہبی', 'قومی', 'ہفتہ وار', 'دیگر'] : ['Religious', 'National', 'Weekly', 'Other'];

  // ------------------------- مشترکہ -------------------------
  String get selectHintShort => _ur ? '-- منتخب کریں --' : '-- Select --';
  String get byName => _ur ? 'بذریعہ نام' : 'By Name';

  // ------------------------- روز کا سبق (Daily Lesson) -------------------------
  String get dailyLessonTitle => _ur ? 'روز کا سبق' : 'Daily Lesson';
  String get addLesson => _ur ? 'سبق شامل کریں' : 'Add Lesson';
  String get lessonDate => _ur ? 'تاریخ' : 'Date';
  String get lessonBook => _ur ? 'کتاب' : 'Book';
  String get lessonTitleField => _ur ? 'سبق کا عنوان' : 'Lesson Title';
  String get lessonDetails => _ur ? 'تفصیل' : 'Details';
  String get saveLesson => _ur ? 'سبق محفوظ کریں' : 'Save Lesson';
  String get lessonSaved => _ur ? 'سبق کامیابی سے محفوظ ہو گیا!' : 'Lesson saved!';
  String get lessonList => _ur ? 'محفوظ شدہ اسباق' : 'Saved Lessons';
  String get noLessons => _ur ? 'ابھی کوئی سبق محفوظ نہیں' : 'No lessons yet';
  String get lessonTitleRequired =>
      _ur ? 'سبق کا عنوان لکھنا ضروری ہے!' : 'Lesson title is required!';
  String get printLesson => _ur ? 'سبق پرنٹ کریں' : 'Print Lesson';

  // ------------------------- پرنٹ کے عنوانات -------------------------
  String get printClassResult => _ur ? 'درجہ وار نتائج پرنٹ' : 'Print Class Result';
  String get printAttendance => _ur ? 'حاضری پرنٹ کریں' : 'Print Attendance';
  String get printRollSlips =>
      _ur ? 'رول نمبر سلپ پرنٹ کریں' : 'Print Roll Slips';
  String get rollSlip => _ur ? 'رول نمبر سلپ' : 'Roll No. Slip';
  String get attendanceRegister => _ur ? 'حاضری رجسٹر' : 'Attendance Register';
  String get reportReady =>
      _ur ? 'رپورٹ پرنٹ کے لیے تیار ہے' : 'Report is ready to print.';
  String get noRecordsToPrint =>
      _ur ? 'پرنٹ کے لیے کوئی ریکارڈ موجود نہیں!' : 'No records to print!';
  String get menu => _ur ? 'مینو' : 'Menu';
  String get printAllResults =>
      _ur ? 'تمام نتائج پرنٹ کریں' : 'Print All Results';
  String get editResultTitle => _ur ? 'نتیجہ تبدیل کریں' : 'Edit Result';
  String get resultUpdated =>
      _ur ? 'نتیجہ کامیابی سے تبدیل ہو گیا!' : 'Result updated successfully!';
  String get quickNav => _ur ? 'فوری رہنمائی' : 'Quick Navigation';
  String get pdfPreview => _ur ? 'پیش نظارہ' : 'Preview';
  String get pdfPreviewHint =>
      _ur ? 'پرنٹ یا PDF محفوظ کرنے سے پہلے پیش نظارہ دیکھیں' : 'Preview before print or save';
  String get lPrint => _ur ? 'پرنٹ' : 'Print';
  String get savePdf => _ur ? 'PDF محفوظ کریں' : 'Save PDF';
}
