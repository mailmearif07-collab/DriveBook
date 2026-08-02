import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/entry_tile.dart';

class HomeScreen extends StatefulWidget {
  final List<LedgerEntry> entries;
  final VoidCallback onAddPressed;
  final VoidCallback onSeeAll;

  const HomeScreen({super.key, required this.entries, required this.onAddPressed, required this.onSeeAll});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    final onAddPressed = widget.onAddPressed;
    final onSeeAll = widget.onSeeAll;
    final cashIn = totalCashIn(entries);
    final cashOut = totalCashOut(entries);
    final balance = cashIn - cashOut;
    final query = _searchCtrl.text.trim().toLowerCase();
    final visible = query.isEmpty
        ? entries
        : entries.where((e) => e.description.toLowerCase().contains(query)).toList();
    final recent = visible.take(4).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Inter'),
                  children: [
                    TextSpan(text: 'Drive', style: TextStyle(color: AppColors.textPrimary)),
                    TextSpan(text: 'Book', style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                  Positioned(
                    right: -1, top: -1,
                    child: Container(width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Good Morning, Arif 👋',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          const Text('Have a safe drive and a productive day!',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 16),

          // Balance hero card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Today's Balance", style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(formatCurrency(balance),
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      const Text('Running Balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  width: 56, height: 56,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 summary cards
          Row(
            children: [
              Expanded(child: _SummaryCard(label: 'Total Cash In', value: cashIn, color: AppColors.cashIn, icon: Icons.arrow_upward_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(label: 'Total Cash Out', value: cashOut, color: AppColors.cashOut, icon: Icons.arrow_downward_rounded)),
              const SizedBox(width: 10),
              Expanded(child: _SummaryCard(label: 'Running Balance', value: balance, color: AppColors.primary, icon: Icons.account_balance_wallet_rounded)),
            ],
          ),
          const SizedBox(height: 16),

          // Search
          Container(
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
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search description...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (_searchCtrl.text.isNotEmpty)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 18),
                    onPressed: () => setState(() => _searchCtrl.clear()),
                  )
                else
                  const Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Entries', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
              TextButton(onPressed: onSeeAll, child: const Text('View All')),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
            child: Column(
              children: [
                for (int i = 0; i < recent.length; i++) ...[
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: EntryTile(entry: recent[i])),
                  if (i != recent.length - 1) const Divider(height: 1, indent: 10, endIndent: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Quick actions
          Row(
            children: [
              Expanded(child: _QuickAction(icon: Icons.receipt_long_outlined, label: 'Add Expense', onTap: onAddPressed)),
              Expanded(child: _QuickAction(icon: Icons.file_upload_outlined, label: 'Add Income', onTap: onAddPressed)),
              Expanded(child: _QuickAction(icon: Icons.pie_chart_outline_rounded, label: 'Reports', onTap: onSeeAll)),
              Expanded(child: _QuickAction(icon: Icons.menu_book_outlined, label: 'Ledger', onTap: onSeeAll)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  const _SummaryCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(formatCurrency(value), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 8),
          CircleAvatar(radius: 12, backgroundColor: color.withValues(alpha: 0.12), child: Icon(icon, size: 13, color: color)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Icon(icon, size: 19, color: AppColors.primary),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
