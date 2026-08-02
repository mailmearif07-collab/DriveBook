import '../models/ledger_entry.dart';
import '../services/database_service.dart';
import 'ledger_repository.dart';

/// SQLite-backed [LedgerRepository]. Each installed app instance opens its
/// own local database file (see [DatabaseService]) — nothing here is
/// shared between users or devices, and there is no network call in this
/// class at all.
class SqliteLedgerRepository implements LedgerRepository {
  SqliteLedgerRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  final DatabaseService _databaseService;

  @override
  Future<List<LedgerEntry>> getAll() async {
    final db = await _databaseService.database;
    final rows = await db.query(
      DatabaseService.tableEntries,
      orderBy: 'date_millis ASC',
    );

    final chronological = rows.map(LedgerEntry.fromMap).toList();

    double running = 0;
    final withBalance = <LedgerEntry>[];
    for (final entry in chronological) {
      running += entry.isCashIn ? entry.amount : -entry.amount;
      withBalance.add(entry.copyWith(runningBalanceAfter: running));
    }

    // Screens expect newest-first ordering (matches the original UI mock).
    return withBalance.reversed.toList();
  }

  @override
  Future<LedgerEntry> add(LedgerEntry entry) async {
    final db = await _databaseService.database;
    await db.insert(DatabaseService.tableEntries, entry.toMap());
    return entry;
  }

  @override
  Future<void> update(LedgerEntry entry) async {
    final db = await _databaseService.database;
    await db.update(
      DatabaseService.tableEntries,
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      DatabaseService.tableEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
