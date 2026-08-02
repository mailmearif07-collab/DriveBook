import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:drivebook/models/ledger_entry.dart';
import 'package:drivebook/utils/ledger_filters.dart';

void main() {
  final entries = [
    LedgerEntry(id: '1', type: EntryType.cashIn, amount: 850, description: 'Cash Payment - Trip', category: 'Trip Income', date: DateTime(2026, 5, 30)),
    LedgerEntry(id: '2', type: EntryType.cashOut, amount: 450, description: 'CNG refill', category: 'Fuel', date: DateTime(2026, 5, 29)),
    LedgerEntry(id: '3', type: EntryType.cashOut, amount: 800, description: 'Driver Salary', category: 'Salary', date: DateTime(2026, 5, 28)),
  ];

  test('search matches description case-insensitively', () {
    final result = applyLedgerFilters(entries, query: 'cng');
    expect(result.map((e) => e.id), ['2']);
  });

  test('date range filter is inclusive of both ends', () {
    final result = applyLedgerFilters(
      entries,
      dateRange: DateTimeRange(start: DateTime(2026, 5, 29), end: DateTime(2026, 5, 30)),
    );
    expect(result.map((e) => e.id).toSet(), {'1', '2'});
  });

  test('category and amount filters combine', () {
    final result = applyLedgerFilters(entries, category: 'Fuel', minAmount: 100, maxAmount: 500);
    expect(result.map((e) => e.id), ['2']);
  });
}
