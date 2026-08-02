import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// On Linux/Windows desktop there is no native sqflite plugin, so we swap
/// in the FFI-based implementation. Android, iOS and macOS keep using the
/// default platform-channel sqflite factory untouched.
void configureDatabaseFactory() {
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
