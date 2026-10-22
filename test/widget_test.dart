import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:madarsa_app/main.dart';
import 'package:madarsa_app/strings.dart';

void main() {
  testWidgets('Dashboard renders Urdu sections', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MadarsaApp());
    await tester.pumpAndSettle();

    final s = Strings.current;

    // AppBar + Section A (اعداد و شمار)
    expect(find.text(s.appTitle), findsOneWidget);
    expect(find.text(s.studentsCount), findsOneWidget);
    expect(find.text(s.staffTitle), findsOneWidget);

    // خلاصہ ٹیب کا مواد
    expect(find.text(s.welcome), findsOneWidget);
    expect(find.text(s.quickOverview), findsOneWidget);
    expect(find.text(s.todayAttendance), findsOneWidget);
    expect(find.text(s.recentAdmissions), findsOneWidget);
  });

  testWidgets('Navigation menu shows modules', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MadarsaApp());
    await tester.pumpAndSettle();

    final s = Strings.current;

    // Tap menu button
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Verify popup menu entries
    expect(find.text(s.quickNav), findsOneWidget);
    expect(find.text(s.mStudents), findsWidgets);
    expect(find.text(s.mTeachersStaff), findsOneWidget);
    expect(find.text(s.mNewClass), findsOneWidget);
    expect(find.text(s.mDailyLesson), findsOneWidget);
  });
}
