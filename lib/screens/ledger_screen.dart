import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ledger_filters.dart';

class LedgerScreen extends StatefulWidget {
  final List<LedgerEntry> entries;
  final ValueChanged<LedgerEntry> onEdit;
  final ValueChanged<LedgerEntry> onDelete;

  const LedgerScreen({
    super.key,
    required this.entries,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  int _tab = 0; // 0 All, 1 Cash In, 2 Cash Out
  bool _showFilters = false;
  bool _searchOpen = false;

  final _searchCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  DateTimeRange? _dateRange;
  String? _category;
  String? _paymentMethod;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  List<String> get _availableCategories => widget.entries
      .map((e) => e.category)
      .whereType<String>()
      .toSet()
      .toList()
    ..sort();

  List<String> get _availablePaymentMethods => widget.entries
      .map((e) => e.paymentMethod)
      .whereType<String>()
      .toSet()
      .toList()
    ..sort();

  List<LedgerEntry> get _tabFiltered {
    switch (_tab) {
      case 1:
        return widget.entries.where((e) => e.isCashIn).toList();
      case 2:
        return widget.entries.where((e) => !e.isCashIn).toList();
      default:
        return widget.entries;
    }
  }

  List<LedgerEntry> get _filtered => applyLedgerFilters(
        _tabFiltered,
        query: _searchCtrl.text,
        dateRange: _dateRange,
        category: _category,
        paymentMethod: _paymentMethod,
        minAmount: double.tryParse(_minCtrl.text),
        maxAmount: double.tryParse(_maxCtrl.text),
      );

  bool get _filtersActive =>
      _dateRange != null ||
      _category != null ||
      _paymentMethod != null ||
      _minCtrl.text.isNotEmpty ||
      _maxCtrl.text.isNotEmpty;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  void _resetFilters() {
    setState(() {
      _dateRange = null;
      _category = null;
      _paymentMethod = null;
      _minCtrl.clear();
      _maxCtrl.clear();
    });
  }

  void _openDetail(LedgerEntry e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => _EntryDetailSheet(
        entry: e,
        onEdit: () {
          Navigator.pop(sheetContext);
          widget.onEdit(e);
        },
        onDelete: () async {
          final confirmed = await showDialog<bool>(
            context: sheetContext,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Delete entry?'),
              content: Text('This will permanently remove "${e.description}".'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Delete', style: TextStyle(color: AppColors.cashOut)),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            if (sheetContext.mounted) Navigator.pop(sheetContext);
            widget.onDelete(e);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;
    final cashIn = totalCashIn(widget.entries);
    final cashOut = totalCashOut(widget.entries);
    final balance = cashIn - cashOut;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Ledger', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.search, color: _searchOpen ? AppColors.primary : AppColors.textPrimary),
                  onPressed: () => setState(() => _searchOpen = !_searchOpen),
                ),
                IconButton(
                  icon: Icon(Icons.tune_rounded, color: _showFilters || _filtersActive ? AppColors.primary : AppColors.textPrimary),
                  onPressed: () => setState(() => _showFilters = !_showFilters),
                ),
              ],
            ),
          ),

          if (_searchOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search description, category, notes...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    if (_searchCtrl.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                        onPressed: () => setState(() => _searchCtrl.clear()),
                      ),
                  ],
                ),
              ),
            ),

          // Totals banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                _TotalCol(label: 'Total Cash In', value: cashIn, color: Colors.greenAccent.shade100),
                _TotalCol(label: 'Total Cash Out', value: cashOut, color: Colors.redAccent.shade100),
                _TotalCol(label: 'Running Balance', value: balance, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _FilterTab(label: 'All', icon: Icons.swap_vert_rounded, selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                const SizedBox(width: 8),
                _FilterTab(label: 'Cash In', icon: Icons.arrow_upward_rounded, selected: _tab == 1, color: AppColors.cashIn, onTap: () => setState(() => _tab = 1)),
                const SizedBox(width: 8),
                _FilterTab(label: 'Cash Out', icon: Icons.arrow_downward_rounded, selected: _tab == 2, color: AppColors.cashOut, onTap: () => setState(() => _tab = 2)),
              ],
            ),
          ),

          if (_showFilters)
            _FilterPanel(
              dateRangeLabel: _dateRange == null
                  ? 'Select date range'
                  : '${formatShortDate(_dateRange!.start)} - ${formatShortDate(_dateRange!.end)}',
              onPickDateRange: _pickDateRange,
              category: _category,
              categories: _availableCategories,
              onCategoryChanged: (v) => setState(() => _category = v),
              paymentMethod: _paymentMethod,
              paymentMethods: _availablePaymentMethods,
              onPaymentMethodChanged: (v) => setState(() => _paymentMethod = v),
              minCtrl: _minCtrl,
              maxCtrl: _maxCtrl,
              onFieldChanged: () => setState(() {}),
              onReset: _resetFilters,
              onApply: () => setState(() => _showFilters = false),
            ),

          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  _dateRange == null
                      ? '${list.length} ${list.length == 1 ? 'entry' : 'entries'}'
                      : '${formatFullDate(_dateRange!.start)} - ${formatFullDate(_dateRange!.end)}',
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const Spacer(),
                const Icon(Icons.ios_share_rounded, size: 16, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: list.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 90),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final e = list[i];
                      final color = e.isCashIn ? AppColors.cashIn : AppColors.cashOut;
                      return InkWell(
                        onTap: () => _openDetail(e),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(width: 26, child: Text('${i + 1}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                              SizedBox(
                                width: 54,
                                child: Text(formatShortDate(e.date), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                              ),
                              Expanded(
                                child: Text(e.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(formatCurrency(e.runningBalanceAfter),
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 40, color: AppColors.textSecondary),
            SizedBox(height: 10),
            Text('No entries match your filters', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _TotalCol extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _TotalCol({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
          const SizedBox(height: 4),
          Text(formatCurrency(value), style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _FilterTab({required this.label, required this.icon, required this.selected, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.12) : Colors.white,
          border: Border.all(color: selected ? c : AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? c : AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: selected ? c : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final String dateRangeLabel;
  final VoidCallback onPickDateRange;
  final String? category;
  final List<String> categories;
  final ValueChanged<String?> onCategoryChanged;
  final String? paymentMethod;
  final List<String> paymentMethods;
  final ValueChanged<String?> onPaymentMethodChanged;
  final TextEditingController minCtrl;
  final TextEditingController maxCtrl;
  final VoidCallback onFieldChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const _FilterPanel({
    required this.dateRangeLabel,
    required this.onPickDateRange,
    required this.category,
    required this.categories,
    required this.onCategoryChanged,
    required this.paymentMethod,
    required this.paymentMethods,
    required this.onPaymentMethodChanged,
    required this.minCtrl,
    required this.maxCtrl,
    required this.onFieldChanged,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Date Range', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          InkWell(
            onTap: onPickDateRange,
            borderRadius: BorderRadius.circular(10),
            child: _fakeField(dateRangeLabel, Icons.calendar_today_outlined),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dropdownField(
                  label: 'Category',
                  hint: 'All Categories',
                  value: category,
                  items: categories,
                  onChanged: onCategoryChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdownField(
                  label: 'Payment Method',
                  hint: 'All Methods',
                  value: paymentMethod,
                  items: paymentMethods,
                  onChanged: onPaymentMethodChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Amount Range', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => onFieldChanged(),
                  decoration: const InputDecoration(hintText: 'Min Amount', isDense: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: maxCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => onFieldChanged(),
                  decoration: const InputDecoration(hintText: 'Max Amount', isDense: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.filter_alt_outlined, size: 16),
                  label: const Text('Apply Filter'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fakeField(String hint, IconData? icon) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(color: AppColors.scaffold, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Expanded(child: Text(hint, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary))),
            if (icon != null) Icon(icon, size: 15, color: AppColors.textSecondary),
          ],
        ),
      );

  Widget _dropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(color: AppColors.scaffold, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value,
              isExpanded: true,
              hint: Text(hint, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSecondary),
              items: [
                DropdownMenuItem<String?>(value: null, child: Text(hint, style: const TextStyle(fontSize: 12.5))),
                ...items.map((c) => DropdownMenuItem<String?>(value: c, child: Text(c, style: const TextStyle(fontSize: 12.5)))),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _EntryDetailSheet extends StatelessWidget {
  final LedgerEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _EntryDetailSheet({required this.entry, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = entry.isCashIn ? AppColors.cashIn : AppColors.cashOut;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: Icon(entry.isCashIn ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: color)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.description, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                    Text('${formatFullDate(entry.date)} • ${formatTime(entry.date)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 14),
          Text(formatCurrency(entry.amount), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: color)),
          Text(entry.isCashIn ? 'Cash In' : 'Cash Out', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          _detailRow('Description', entry.description),
          if (entry.category != null) _detailRow('Category', entry.category!),
          if (entry.paymentMethod != null) _detailRow('Payment Method', entry.paymentMethod!),
          _detailRow('Date', formatFullDate(entry.date)),
          _detailRow('Time', formatTime(entry.date)),
          if (entry.notes != null) _detailRow('Notes', entry.notes!),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.scaffold, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Running Balance After This Entry', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                Text(formatCurrency(entry.runningBalanceAfter), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 16), label: const Text('Edit')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.cashOut),
                  label: const Text('Delete', style: TextStyle(color: AppColors.cashOut)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.cashOut)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
          ],
        ),
      );
}
