import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'platform/db_init_stub.dart'
    if (dart.library.io) 'platform/db_init_io.dart'
    if (dart.library.html) 'platform/db_init_web.dart';

/// Owns the single SQLite connection for this install of the app.
///
/// Every user who installs DriveBook gets their own local database file —
/// there is no shared/remote database. On mobile this file lives inside
/// the app's private sandboxed documents directory, which the OS already
/// isolates per-app and per-device-user, so one person's ledger is never
/// visible to another install or another account on the device.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  /// Bump this and add a branch in [_onUpgrade] whenever the schema needs
  /// to change in a future release. Existing rows are never dropped by an
  /// upgrade — only additive `ALTER TABLE` / `CREATE TABLE IF NOT EXISTS`
  /// migrations should run here, so updating the app never loses data.
  static const int _dbVersion = 1;
  static const String _dbName = 'drivebook.db';
  static const String tableEntries = 'ledger_entries';

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    final opened = await _open();
    _db = opened;
    return opened;
  }

  Future<Database> _open() async {
    configureDatabaseFactory();

    final String path;
    if (kIsWeb) {
      path = _dbName;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      path = join(dir.path, _dbName);
    }

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableEntries (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT,
        payment_method TEXT,
        date_millis INTEGER NOT NULL,
        notes TEXT,
        created_at_millis INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_ledger_entries_date ON $tableEntries (date_millis)',
    );
  }

  // ignore: unused_element
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future schema changes go here as `if (oldVersion < N) { ... }`
    // blocks. Never DROP or recreate the entries table — always migrate
    // additively so upgrading the app preserves the user's existing data.
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }

  /// Used by tests / "reset app" style flows only.
  Future<void> deleteAllData() async {
    final db = await database;
    await db.delete(tableEntries);
  }
}
