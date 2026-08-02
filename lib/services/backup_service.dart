/// Contract for backing up this device's local ledger database to the
/// signed-in user's own cloud storage (Google Drive), and restoring from
/// it. Intentionally unimplemented in Phase 1 — the Settings/Backup &
/// Restore screens stay UI-only until this is wired up in a later phase.
///
/// Design intent for the future implementation (do not build yet):
/// - Each user authenticates their own Google account on-device
///   (google_sign_in) and the backup is written to that user's Drive
///   app-data folder — Anthropic/DriveBook never sees or stores the file.
/// - Nothing is backed up to a server owned by the developer; the
///   developer only ships app code/updates, never touches user data.
abstract class BackupService {
  Future<void> backupNow();
  Future<void> restoreFromBackup();
  Future<DateTime?> lastBackupTime();
}

/// Placeholder used until the real Google Drive-backed implementation
/// lands. Throws so any accidental wiring in Phase 1 fails loudly instead
/// of silently pretending to back data up.
class UnimplementedBackupService implements BackupService {
  const UnimplementedBackupService();

  @override
  Future<void> backupNow() async {
    throw UnimplementedError('Google Drive backup ships in a later phase.');
  }

  @override
  Future<void> restoreFromBackup() async {
    throw UnimplementedError('Google Drive restore ships in a later phase.');
  }

  @override
  Future<DateTime?> lastBackupTime() async => null;
}
