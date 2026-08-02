import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Web has no filesystem, so sqflite runs on top of a WASM SQLite build
/// backed by browser storage (IndexedDB/OPFS) via sqflite_common_ffi_web.
void configureDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
