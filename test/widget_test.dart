import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:drivebook/main.dart';
import 'package:drivebook/screens/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App boots to splash screen without crashing', (tester) async {
    await tester.pumpWidget(const DriveBookApp());
    await tester.pump();

    // Smoke test only: confirm the widget tree built with no errors and
    // that we're looking at the real splash screen. The splash's
    // "DriveBook" wordmark is rendered as a RichText with two styled
    // TextSpans ("Drive" + "Book"), not a single Text('DriveBook'), so we
    // assert against stable, non-styled elements of the current splash
    // instead of that composed string.
    expect(tester.takeException(), isNull);
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    expect(
      find.text('Daily Income & Expense\nTracker for Drivers'),
      findsOneWidget,
    );
  });
}
