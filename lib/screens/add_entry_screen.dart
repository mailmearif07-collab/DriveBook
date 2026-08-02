import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class AddEntryScreen extends StatefulWidget {
  /// When non-null, the screen opens pre-filled for editing this entry
  /// instead of creating a new one. On save, the returned [LedgerEntry]
  /// keeps this entry's original [LedgerEntry.id] so the caller can
  /// update the existing row rather than inserting a new one.
  final LedgerEntry? existingEntry;

  const AddEntryScreen({super.key, this.existingEntry});

  bool get isEditing => existingEntry != null;

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late EntryType _type;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _notesCtrl;
  String? _category;
  String? _paymentMethod;
  late DateTime _date;

  Color get _accent => _type == EntryType.cashIn ? AppColors.cashIn : AppColors.cashOut;
  Color get _accentBg => _type == EntryType.cashIn ? AppColors.cashInBg : AppColors.cashOutBg;

  final _categories = const ['Trip Income', 'Fuel', 'Salary', 'Maintenance', 'Other'];
  final _paymentMethods = const ['Cash', 'UPI', 'Bank Transfer', 'Card'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingEntry;
    _type = existing?.type ?? EntryType.cashIn;
    _amountCtrl = TextEditingController(
      text: existing == null ? '' : _trimZeros(existing.amount),
    );
    _descCtrl = TextEditingController(text: existing?.description ?? '');
    _notesCtrl = TextEditingController(text: existing?.notes ?? '');
    _category = existing?.category;
    _paymentMethod = existing?.paymentMethod;
    _date = existing?.date ?? DateTime.now();
  }

  String _trimZeros(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (amount <= 0 || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter amount and description')),
      );
      return;
    }
    final existing = widget.existingEntry;
    final entry = LedgerEntry(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      amount: amount,
      description: _descCtrl.text.trim(),
      category: _category,
      paymentMethod: _paymentMethod,
      date: _date,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      runningBalanceAfter: 0, // recomputed by the repository on next read
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(widget.isEditing ? 'Edit Entry' : 'Add New Entry'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.history, size: 18),
            label: const Text('History'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
        children: [
          // Cash In / Cash Out toggle
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                Expanded(child: _ToggleTab(
                  label: 'Cash In', icon: Icons.arrow_upward_rounded,
                  selected: _type == EntryType.cashIn, color: AppColors.cashIn,
                  onTap: () => setState(() => _type = EntryType.cashIn),
                )),
                Expanded(child: _ToggleTab(
                  label: 'Cash Out', icon: Icons.arrow_downward_rounded,
                  selected: _type == EntryType.cashOut, color: AppColors.cashOut,
                  onTap: () => setState(() => _type = EntryType.cashOut),
                )),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _accentBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.account_balance_wallet, color: _accent, size: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_type == EntryType.cashIn ? 'Cash In' : 'Cash Out',
                          style: TextStyle(fontWeight: FontWeight.w700, color: _accent, fontSize: 15)),
                      Text(_type == EntryType.cashIn ? 'Add income or cash received' : 'Add expense or cash spent',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Icon(_type == EntryType.cashIn ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: _accent),
              ],
            ),
          ),

          const _FieldLabel('Amount'),
          TextField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(prefixText: '₹  ', hintText: 'Enter amount'),
          ),
          const SizedBox(height: 10),
          Row(
            children: [100, 500, 1000, 2000].map((v) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton(
                    onPressed: () {
                      final current = double.tryParse(_amountCtrl.text) ?? 0;
                      _amountCtrl.text = (current + v).toStringAsFixed(0);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: BorderSide(color: _accent.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('+ ₹$v', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            }).toList(),
          ),

          const _FieldLabel('Description'),
          TextField(
            controller: _descCtrl,
            maxLength: 100,
            decoration: const InputDecoration(hintText: 'Enter description'),
          ),

          const _FieldLabel('Category (Optional)'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            hint: const Text('Select category'),
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v),
          ),

          const _FieldLabel('Date'),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context, initialDate: _date,
                firstDate: DateTime(2020), lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _date = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatFullDate(_date)),
                  const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),

          const _FieldLabel('Payment Method (Optional)'),
          DropdownButtonFormField<String>(
            initialValue: _paymentMethod,
            hint: const Text('Select payment method'),
            items: _paymentMethods.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),

          const _FieldLabel('Notes (Optional)'),
          TextField(
            controller: _notesCtrl,
            maxLength: 150,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Add a note...'),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: Text(widget.isEditing ? 'Update Entry' : 'Save Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _ToggleTab({required this.label, required this.icon, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: selected ? color : Colors.transparent, borderRadius: BorderRadius.circular(11)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    );
  }
}
