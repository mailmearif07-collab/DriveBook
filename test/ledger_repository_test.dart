import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:drivebook/models/ledger_entry.dart';
import 'package:drivebook/repositories/sqlite_ledger_repository.dart';
import 'package:drivebook/services/database_service.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
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
