import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ایپ کی ترتیبات: زبان (اردو/انگلیش)، تھیم (ہلکا/گہرا) اور اطلاعات
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const String _kLanguage = 'app_language';
  static const String _kThemeMode = 'app_theme_mode';
  static const String _kNotifications = 'notifications_enabled';
  static const String _kReminderTime = 'notification_reminder_time';

  String _language = 'ur';
  String _themeMode = 'light';
  bool _notificationsEnabled = false;
  int _reminderMinutes = 8 * 60; // صبح 8:00 بجے

  String get language => _language;
  bool get isUrdu => _language == 'ur';
  String get themeMode => _themeMode;

  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderMinutes => _reminderMinutes;
  int get reminderHour => _reminderMinutes ~/ 60;
  int get reminderMinute => _reminderMinutes % 60;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _language = prefs.getString(_kLanguage) ?? 'ur';
      _themeMode = prefs.getString(_kThemeMode) ?? 'light';
      _notificationsEnabled = prefs.getBool(_kNotifications) ?? false;
      _reminderMinutes = prefs.getInt(_kReminderTime) ?? 8 * 60;
    } catch (_) {
      // ترتیبات لوڈ نہ ہوں تو پہلے طے شدہ اقدار استعمال ہوں
    }
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (lang == _language) return;
    _language = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLanguage, lang);
    } catch (_) {}
  }

  Future<void> setThemeMode(String mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeMode, mode);
    } catch (_) {}
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kNotifications, value);
    } catch (_) {}
  }

  Future<void> setReminderTime(int minutesAfterMidnight) async {
    _reminderMinutes = minutesAfterMidnight;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kReminderTime, minutesAfterMidnight);
    } catch (_) {}
  }
}
