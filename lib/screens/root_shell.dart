import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../repositories/ledger_repository.dart';
import '../repositories/sqlite_ledger_repository.dart';
import '../widgets/app_bottom_nav.dart';
import 'home_screen.dart';
import 'reports_screen.dart';
import 'ledger_screen.dart';
import 'settings_screen.dart';
import 'add_entry_screen.dart';

/// Loads/holds this device's ledger (via [LedgerRepository], backed by a
/// private local SQLite database) and hosts the 4 tab screens. All
/// add/edit/delete flows go through the repository so the on-screen list
/// and the database never drift apart.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final LedgerRepository _repository = SqliteLedgerRepository();

  int _index = 0;
  List<LedgerEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final entries = await _repository.getAll();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load your ledger. Please restart the app.';
      });
    }
  }

  Future<void> _openAddEntry() async {
    final result = await Navigator.of(context).push<LedgerEntry>(
      MaterialPageRoute(builder: (_) => const AddEntryScreen()),
    );
    if (result != null) {
      await _repository.add(result);
      await _loadEntries();
    }
  }

  Future<void> _openEditEntry(LedgerEntry entry) async {
    final result = await Navigator.of(context).push<LedgerEntry>(
      MaterialPageRoute(builder: (_) => AddEntryScreen(existingEntry: entry)),
    );
    if (result != null) {
      await _repository.update(result);
      await _loadEntries();
    }
  }

  Future<void> _deleteEntry(LedgerEntry entry) async {
    await _repository.delete(entry.id);
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _loadEntries,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final screens = [
      HomeScreen(
        entries: _entries,
        onAddPressed: _openAddEntry,
        onSeeAll: () => setState(() => _index = 2),
      ),
      ReportsScreen(entries: _entries),
      LedgerScreen(
        entries: _entries,
        onEdit: _openEditEntry,
        onDelete: _deleteEntry,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEntry,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        onAddPressed: _openAddEntry,
      ),
    );
  }
}
