import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:drivebook/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App boots to splash screen without crashing', (tester) async {
    await tester.pumpWidget(const DriveBookApp());
    await tester.pump();
    expect(find.text('DriveBook'), findsWidgets);
  });
}
