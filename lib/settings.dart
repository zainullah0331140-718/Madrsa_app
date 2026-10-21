import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'notification_service.dart';
import 'strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Strings.current;
    final settings = AppSettings.instance;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(s.settingsTitle),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionHeader(s.languageTitle, Icons.language),
              _card(
                children: [
                  RadioGroup<String>(
                    groupValue: settings.language,
                    onChanged: (v) {
                      if (v != null) settings.setLanguage(v);
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'ur',
                          title: Text(s.urdu),
                        ),
                        RadioListTile<String>(
                          value: 'en',
                          title: Text(s.english),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 8),
                child: Text(
                  s.languageSubtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              _sectionHeader(s.themeTitle, Icons.brightness_6),
              _card(
                children: [
                  RadioGroup<String>(
                    groupValue: settings.themeMode,
                    onChanged: (v) {
                      if (v != null) settings.setThemeMode(v);
                    },
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'light',
                          title: Text(s.light),
                          secondary: const Icon(Icons.light_mode),
                        ),
                        RadioListTile<String>(
                          value: 'dark',
                          title: Text(s.dark),
                          secondary: const Icon(Icons.dark_mode),
                        ),
                        RadioListTile<String>(
                          value: 'system',
                          title: Text(s.system),
                          secondary: const Icon(Icons.settings_suggest),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6, top: 8),
                child: Text(
                  s.themeSubtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              _sectionHeader(s.notificationsTitle, Icons.notifications_active),
              _card(
                children: [
                  SwitchListTile(
                    value: settings.notificationsEnabled,
                    onChanged: (v) async {
                      await settings.setNotificationsEnabled(v);
                      if (v) {
                        await NotificationService.instance.requestPermission();
                        await NotificationService.instance
                            .scheduleDailyReminder(settings.reminderMinutes);
                      } else {
                        await NotificationService.instance.cancelDailyReminder();
                      }
                    },
                    title: Text(s.attendanceReminder),
                    subtitle: Text(s.attendanceReminderSubtitle),
                    secondary: const Icon(Icons.event_available),
                  ),
                  if (settings.notificationsEnabled)
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(s.reminderTime),
                      subtitle: Text(
                        _timeLabel(settings.reminderHour, settings.reminderMinute),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: settings.reminderHour,
                            minute: settings.reminderMinute,
                          ),
                        );
                        if (picked != null) {
                          final minutes = picked.hour * 60 + picked.minute;
                          await settings.setReminderTime(minutes);
                          await NotificationService.instance
                              .scheduleDailyReminder(minutes);
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeLabel(int hour, int minute) {
    final period = hour < 12 ? 'AM' : 'PM';
    var h = hour % 12;
    if (h == 0) h = 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: children),
    );
  }
}
