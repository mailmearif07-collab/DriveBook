# DriveBook — Flutter App (Phase 1)

Daily income & expense ledger for drivers. Every install is the same app;
every install's ledger is completely private, stored locally in that
device's own SQLite database.

## What Phase 1 delivers

- **Complete Flutter project**: `android/`, `ios/`, `web/`, `linux/`,
  `macos/`, `windows/`, `assets/`, `lib/`, `test/`, `pubspec.yaml`.
- **Local SQLite persistence** — `sqflite` on mobile/macOS,
  `sqflite_common_ffi` on Linux/Windows, `sqflite_common_ffi_web` (WASM)
  on web. One private database file per install; nothing is shared or
  networked.
- **CRUD** — add, edit, delete ledger entries end-to-end through the UI.
- **Running balance** — recomputed chronologically on every read, so it's
  always consistent after an edit or delete.
- **Search** — on the Home quick-search box and the Ledger screen's
  dedicated search field (matches description, category, notes).
- **Date filter** — full filter panel on the Ledger screen: date range,
  category, payment method, amount range, combined with the existing
  All/Cash In/Cash Out tabs.
- The approved UI is unchanged — every screen, color, and layout is the
  same; only the previously non-functional controls (search icon, filter
  fields, Edit/Delete buttons) were wired up to real behavior.

## Architecture

```
lib/
  models/ledger_entry.dart        Plain data model + SQLite (de)serialization
  services/
    database_service.dart         Owns the single SQLite connection, schema, migrations
    backup_service.dart           Interface stub for Phase 2 (Google Drive backup)
    platform/                     Per-platform database factory wiring (io/web/stub)
  repositories/
    ledger_repository.dart        Abstract contract the UI depends on
    sqlite_ledger_repository.dart SQLite implementation (CRUD + running balance)
  utils/
    ledger_filters.dart           Pure search/date/category/amount filtering
    formatters.dart                Currency/date formatting (unchanged)
  screens/, widgets/, theme/       Approved UI (functionality wired in, layout unchanged)
```

Screens never talk to SQLite directly — only to `LedgerRepository`. That
keeps persistence swappable and testable, and is why
`test/ledger_repository_test.dart` can exercise the real CRUD + balance
logic against an in-memory SQLite database.

## Privacy & multi-user model

- One shared app binary, ships to every user via normal app store updates.
- Each install's database file lives in that device's private app sandbox
  (`getApplicationDocumentsDirectory()` on mobile/desktop, browser storage
  on web) — the OS already prevents other apps or users from reading it.
- There is no backend server and no shared database in this codebase.
  Nothing here can let one installation read another's ledger.
- Google Drive backup (each user's own account, their own Drive) is
  intentionally **not implemented yet** — `lib/services/backup_service.dart`
  documents the contract for it and the Settings/Backup screens stay
  UI-only until that phase is approved.

## Releases & updates

- Android `applicationId` / iOS `PRODUCT_BUNDLE_IDENTIFIER` are fixed at
  `com.drivebook.app` — change this only if you intend to ship a *new*,
  separate app listing. Keeping it stable is what makes a Play
  Store/App Store update land on top of a user's existing install instead
  of installing side-by-side.
- The SQLite schema is versioned (`DatabaseService._dbVersion`). Future
  releases add migrations in `_onUpgrade` — existing rows are never
  dropped, so shipping an update never loses a user's data.
- You (the developer) control what ships by controlling this repo and the
  store listings/signing keys — nothing in the app lets a user modify or
  redistribute it as a different app.

## Running it locally

```
flutter pub get
flutter run                 # any connected device/emulator
flutter test                # repository + filter unit tests, widget smoke test
flutter build apk --release
```

First build on a fresh checkout: Flutter regenerates a few files that are
intentionally not committed as real content (`android/local.properties`,
`android/gradle/wrapper/gradle-wrapper.jar`, `ios/Flutter/Generated.xcconfig`,
`macos/Flutter/ephemeral/Flutter-Generated.xcconfig`, plugin registrants) —
this happens automatically on `flutter pub get` / `flutter build`, including
in CI (see `.github/workflows/build.yml`, `codemagic.yaml`). No manual step
needed on GitHub Actions or Codemagic.

Desktop targets (Linux/Windows/macOS) are included per the requested
project layout; the primary, most-tested targets for this app are Android
and iOS. If Xcode/CMake ever complains about a desktop platform file,
regenerating that one platform with `flutter create --platforms=<platform> .`
against your local Flutter SDK will restore it exactly — nothing under
`lib/` is affected by that.

## Next phase (not built yet — waiting for approval)

- Google Drive backup/restore, one user's own account only.
- Reports screen real aggregation from the database (currently mixes real
  today/summary numbers with illustrative weekly/monthly figures, as in
  the original UI mock).
- Settings: theme, currency, language, PIN lock.
- CSV/PDF export.
