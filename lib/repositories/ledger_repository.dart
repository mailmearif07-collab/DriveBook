import '../models/ledger_entry.dart';

/// Storage-agnostic contract for reading/writing ledger entries. The rest
/// of the app (screens) talks to this interface only, never to SQLite
/// directly — swapping the backing store later means writing a new
/// implementation of this class, nothing else changes.
abstract class LedgerRepository {
  /// All entries for this install, newest first, each with
  /// [LedgerEntry.runningBalanceAfter] computed chronologically.
  Future<List<LedgerEntry>> getAll();

  Future<LedgerEntry> add(LedgerEntry entry);

  Future<void> update(LedgerEntry entry);

  Future<void> delete(String id);
}
