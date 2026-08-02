import 'package:flutter/material.dart' show DateTimeRange;

import '../models/ledger_entry.dart';

/// Applies text search + optional structured filters to an already-loaded
/// list of entries. Kept as a pure function (no state) so it's trivial to
/// unit test and reuse from any screen.
List<LedgerEntry> applyLedgerFilters(
  List<LedgerEntry> entries, {
  String query = '',
  DateTimeRange? dateRange,
  String? category,
  String? paymentMethod,
  double? minAmount,
  double? maxAmount,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  return entries.where((e) {
    if (normalizedQuery.isNotEmpty) {
      final matches = e.description.toLowerCase().contains(normalizedQuery) ||
          (e.category?.toLowerCase().contains(normalizedQuery) ?? false) ||
          (e.notes?.toLowerCase().contains(normalizedQuery) ?? false);
      if (!matches) return false;
    }

    if (dateRange != null) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      final start = DateTime(
          dateRange.start.year, dateRange.start.month, dateRange.start.day);
      final end =
          DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
      if (day.isBefore(start) || day.isAfter(end)) return false;
    }

    if (category != null && e.category != category) return false;
    if (paymentMethod != null && e.paymentMethod != paymentMethod) {
      return false;
    }
    if (minAmount != null && e.amount < minAmount) return false;
    if (maxAmount != null && e.amount > maxAmount) return false;

    return true;
  }).toList();
}
