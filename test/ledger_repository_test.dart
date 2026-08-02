import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:drivebook/models/ledger_entry.dart';
import 'package:drivebook/repositories/sqlite_ledger_repository.dart';
import 'package:drivebook/services/database_service.dart';

/// Test-only fake for `path_provider`. `DatabaseService` calls
/// `getApplicationDocumentsDirectory()` on non-web platforms; in a plain
/// `flutter test` run there is no real platform plugin registered to
/// answer that method channel, so we swap in a fake that hands back a
/// fresh temp directory for each database open.
class _FakePathProviderPlatform extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = await Directory.systemTemp.createTemp('drivebook_test_');
    return dir.path;
  }
}

void main() {
  // Must run before any repository/database initialization below —
  // DatabaseService opens a real (FFI-backed) sqflite database and touches
  // platform channels (via path_provider), both of which require the test
  // binding to be initialized first.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    PathProviderPlatform.instance = _FakePathProviderPlatform();
  });

  tearDown(() async {
    await DatabaseService.instance.close();
  });

  test('add + getAll computes running balance chronologically', () async {
    final repo = SqliteLedgerRepository();

    await repo.add(LedgerEntry(
      id: '1',
      type: EntryType.cashIn,
      amount: 1000,
      description: 'Trip 1',
      date: DateTime(2026, 1, 1, 9),
    ));
    await repo.add(LedgerEntry(
      id: '2',
      type: EntryType.cashOut,
      amount: 300,
      description: 'Fuel',
      date: DateTime(2026, 1, 1, 10),
    ));
    await repo.add(LedgerEntry(
      id: '3',
      type: EntryType.cashIn,
      amount: 500,
      description: 'Trip 2',
      date: DateTime(2026, 1, 1, 11),
    ));

    final all = await repo.getAll();

    // newest first
    expect(all.map((e) => e.id).toList(), ['3', '2', '1']);
    expect(all.firstWhere((e) => e.id == '1').runningBalanceAfter, 1000);
    expect(all.firstWhere((e) => e.id == '2').runningBalanceAfter, 700);
    expect(all.firstWhere((e) => e.id == '3').runningBalanceAfter, 1200);
  });

  test('update recalculates dependent running balances', () async {
    final repo = SqliteLedgerRepository();
    await repo.add(LedgerEntry(id: '1', type: EntryType.cashIn, amount: 1000, description: 'A', date: DateTime(2026, 1, 1)));
    await repo.add(LedgerEntry(id: '2', type: EntryType.cashOut, amount: 200, description: 'B', date: DateTime(2026, 1, 2)));

    final entryToUpdate = (await repo.getAll()).firstWhere((e) => e.id == '1');
    await repo.update(entryToUpdate.copyWith(amount: 2000));

    final all = await repo.getAll();
    expect(all.firstWhere((e) => e.id == '1').amount, 2000);
    expect(all.firstWhere((e) => e.id == '2').runningBalanceAfter, 1800);
  });

  test('delete removes entry and recalculates balances', () async {
    final repo = SqliteLedgerRepository();
    await repo.add(LedgerEntry(id: '1', type: EntryType.cashIn, amount: 1000, description: 'A', date: DateTime(2026, 1, 1)));
    await repo.add(LedgerEntry(id: '2', type: EntryType.cashOut, amount: 200, description: 'B', date: DateTime(2026, 1, 2)));

    await repo.delete('1');
    final all = await repo.getAll();

    expect(all.length, 1);
    expect(all.first.id, '2');
    expect(all.first.runningBalanceAfter, -200);
  });
}
