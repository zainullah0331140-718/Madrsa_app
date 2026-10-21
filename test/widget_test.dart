import 'package:flutter_test/flutter_test.dart';

import 'package:madarsa_app/main.dart';

void main() {
  testWidgets('Dashboard renders Urdu sections', (WidgetTester tester) async {
    await tester.pumpWidget(const MadarsaApp());
    await tester.pump();

    // AppBar + Section A (اعداد و شمار)
    expect(find.text('مدرسہ مینجمنٹ سسٹم'), findsOneWidget);
    expect(find.text('طلبہ کی تعداد'), findsOneWidget);
    expect(find.text('اساتذہ و عملہ'), findsOneWidget);

    // Section B (ٹیب بار)
    expect(find.text('خلاصہ'), findsOneWidget);
    expect(find.text('نیا اندراج'), findsOneWidget);
    expect(find.text('تمام طلبہ'), findsOneWidget);
    expect(find.text('متفرق'), findsOneWidget);
    expect(find.text('رپورٹس'), findsOneWidget);

    // خلاصہ ٹیب کا مواد
    expect(find.text('خوش آمدید'), findsOneWidget);
    expect(find.text('حالیہ داخلے'), findsOneWidget);
  });

  testWidgets('نیا اندراج tab shows module grid', (WidgetTester tester) async {
    await tester.pumpWidget(const MadarsaApp());
    await tester.pump();

    await tester.tap(find.text('نیا اندراج'));
    await tester.pumpAndSettle();

    expect(find.text('طلبہ'), findsOneWidget);
    expect(find.text('اساتذہ و عملہ اراکین'), findsOneWidget);
    expect(find.text('نیا درجہ'), findsOneWidget);
    expect(find.text('روز کا سبق'), findsOneWidget);
  });
}
