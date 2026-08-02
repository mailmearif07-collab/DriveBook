enum EntryType { cashIn, cashOut }

extension EntryTypeStorage on EntryType {
  String get storageValue => this == EntryType.cashIn ? 'cash_in' : 'cash_out';

  static EntryType fromStorage(String value) =>
      value == 'cash_in' ? EntryType.cashIn : EntryType.cashOut;
}

class LedgerEntry {
  final String id;
  final EntryType type;
  final double amount;
  final String description;
  final String? category;
  final String? paymentMethod;
  final DateTime date;
  final String? notes;

  /// Computed at read-time by the repository (chronological running
  /// total) — never trusted from storage, so edits/deletes elsewhere in
  /// the ledger can never leave a stale balance behind.
  final double runningBalanceAfter;

  const LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    this.runningBalanceAfter = 0,
    this.category,
    this.paymentMethod,
    this.notes,
  });

  bool get isCashIn => type == EntryType.cashIn;

  LedgerEntry copyWith({
    String? id,
    EntryType? type,
    double? amount,
    String? description,
    String? category,
    String? paymentMethod,
    DateTime? date,
    String? notes,
    double? runningBalanceAfter,
    bool clearCategory = false,
    bool clearPaymentMethod = false,
    bool clearNotes = false,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: clearCategory ? null : (category ?? this.category),
      paymentMethod:
          clearPaymentMethod ? null : (paymentMethod ?? this.paymentMethod),
      date: date ?? this.date,
      notes: clearNotes ? null : (notes ?? this.notes),
      runningBalanceAfter: runningBalanceAfter ?? this.runningBalanceAfter,
    );
  }

  /// Row map for `sqflite` insert/update. `runningBalanceAfter` is
  /// intentionally not persisted — it's derived, not stored.
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'type': type.storageValue,
      'amount': amount,
      'description': description,
      'category': category,
      'payment_method': paymentMethod,
      'date_millis': date.millisecondsSinceEpoch,
      'notes': notes,
      'created_at_millis': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory LedgerEntry.fromMap(Map<String, Object?> map) {
    return LedgerEntry(
      id: map['id'] as String,
      type: EntryTypeStorage.fromStorage(map['type'] as String),
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      category: map['category'] as String?,
      paymentMethod: map['payment_method'] as String?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date_millis'] as int),
      notes: map['notes'] as String?,
    );
  }
}

double totalCashIn(List<LedgerEntry> list) =>
    list.where((e) => e.isCashIn).fold(0.0, (sum, e) => sum + e.amount);

double totalCashOut(List<LedgerEntry> list) =>
    list.where((e) => !e.isCashIn).fold(0.0, (sum, e) => sum + e.amount);

double runningBalance(List<LedgerEntry> list) =>
    totalCashIn(list) - totalCashOut(list);
