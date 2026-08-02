import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/ledger_entry.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  final List<LedgerEntry> entries;
  const ReportsScreen({super.key, required this.entries});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _period = 1; // 0 Today, 1 Weekly, 2 Monthly, 3 Custom

  @override
  Widget build(BuildContext context) {
    final cashIn = totalCashIn(widget.entries);
    final cashOut = totalCashOut(widget.entries);
    final balance = cashIn - cashOut;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Reports', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
              Spacer(),
              Icon(Icons.calendar_today_outlined, color: AppColors.textPrimary, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _PeriodChip(label: 'Today', selected: _period == 0, onTap: () => setState(() => _period = 0)),
              const SizedBox(width: 8),
              _PeriodChip(label: 'Weekly', selected: _period == 1, onTap: () => setState(() => _period = 1)),
              const SizedBox(width: 8),
              _PeriodChip(label: 'Monthly', selected: _period == 2, onTap: () => setState(() => _period = 2)),
              const SizedBox(width: 8),
              _PeriodChip(label: 'Custom', selected: _period == 3, onTap: () => setState(() => _period = 3)),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                _TotalCol(label: 'Cash In', value: cashIn, icon: Icons.arrow_upward_rounded),
                _TotalCol(label: 'Cash Out', value: cashOut, icon: Icons.arrow_downward_rounded),
                _TotalCol(label: 'Balance', value: balance, icon: Icons.account_balance_wallet_rounded, highlight: true),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (_period == 0) _TodayView(cashIn: cashIn, cashOut: cashOut, entries: widget.entries),
          if (_period == 1) _WeeklyView(entries: widget.entries),
          if (_period == 2) _MonthlyView(entries: widget.entries),
          if (_period == 3) _CustomView(entries: widget.entries),
        ],
      ),
    );
  }
}

class _TotalCol extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final bool highlight;
  const _TotalCol({required this.label, required this.value, required this.icon, this.highlight = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(formatCurrency(value), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 4),
          Icon(icon, color: Colors.white70, size: 14),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textSecondary)),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: child,
    );
  }
}

class _TodayView extends StatelessWidget {
  final double cashIn, cashOut;
  final List<LedgerEntry> entries;
  const _TodayView({required this.cashIn, required this.cashOut, required this.entries});
  @override
  Widget build(BuildContext context) {
    final total = cashIn + cashOut;
    final pctIn = total == 0 ? 0.0 : (cashIn / total) * 100;
    return Column(
      children: [
        _SectionCard(
          child: Column(
            children: [
              const Align(alignment: Alignment.centerLeft, child: Text('Overview', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 44,
                            sections: [
                              PieChartSectionData(value: cashIn, color: AppColors.cashIn, radius: 22, showTitle: false),
                              PieChartSectionData(value: cashOut, color: AppColors.cashOut, radius: 22, showTitle: false),
                            ],
                          )),
                          Text('${pctIn.round()}%\nCash In', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendRow('Cash In', cashIn, AppColors.cashIn),
                          const SizedBox(height: 10),
                          _legendRow('Cash Out', cashOut, AppColors.cashOut),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.cashInBg, borderRadius: BorderRadius.circular(12)),
          child: const Row(
            children: [
              Icon(Icons.trending_up_rounded, color: AppColors.cashIn),
              SizedBox(width: 10),
              Expanded(child: Text('Great! Your income is higher than your expenses.', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _statBox(entries.where((e) => e.isCashIn).length.toString(), 'Total In'),
            _statBox(entries.where((e) => !e.isCashIn).length.toString(), 'Total Out'),
            _statBox(entries.length.toString(), 'Total Entries'),
            _statBox(formatCurrency(total == 0 ? 0 : total / (entries.isEmpty ? 1 : entries.length)), 'Avg/Day', small: true),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('View Detailed Report'),
          ),
        ),
      ],
    );
  }

  Widget _legendRow(String label, double value, Color color) => Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5))),
          Text(formatCurrency(value), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      );

  Widget _statBox(String value, String label, {bool small = false}) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: small ? 11 : 15)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
}

class _WeeklyView extends StatelessWidget {
  final List<LedgerEntry> entries;
  const _WeeklyView({required this.entries});
  @override
  Widget build(BuildContext context) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final inVals = [5200.0, 6300.0, 5100.0, 7300.0, 6100.0, 4600.0, 4400.0];
    final outVals = [1900.0, 2400.0, 2100.0, 4800.0, 3300.0, 1600.0, 1600.0];
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Breakdown', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: const FlGridData(drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox.shrink();
                  return Padding(padding: const EdgeInsets.only(top: 6), child: Text(days[i], style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)));
                })),
              ),
              barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: inVals[i], color: AppColors.cashIn, width: 7, borderRadius: BorderRadius.circular(3)),
                BarChartRodData(toY: outVals[i], color: AppColors.cashOut, width: 7, borderRadius: BorderRadius.circular(3)),
              ])),
            )),
          ),
          const SizedBox(height: 16),
          const Text('Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const Divider(height: 20),
          _row('Highest Income', 'Wed, 27 May', AppColors.cashIn),
          _row('Highest Expense', 'Wed, 27 May', AppColors.cashOut),
          _row('Average Per Day (Net)', formatCurrency(2581.43), AppColors.primary),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5))),
            Text(value, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      );
}

class _MonthlyView extends StatelessWidget {
  final List<LedgerEntry> entries;
  const _MonthlyView({required this.entries});
  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Trip Income', 70250.0, AppColors.cashIn),
      ('Fuel (CNG/Petrol)', 45300.0, AppColors.cashOut),
      ('Driver Salary', 27600.0, AppColors.primary),
      ('Online Payment', 22150.0, AppColors.amber),
      ('Other Expenses', 18000.0, AppColors.purple),
    ];
    return Column(
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Category Breakdown', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: PieChart(PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 44,
                        sections: categories.map((c) => PieChartSectionData(value: c.$2, color: c.$3, radius: 22, showTitle: false)).toList(),
                      )),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: categories.map((c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(width: 9, height: 9, decoration: BoxDecoration(color: c.$3, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Expanded(child: Text(c.$1, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.cashInBg, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.savings_outlined, color: AppColors.cashIn),
              const SizedBox(width: 10),
              const Text('Net Savings this month', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(formatCurrency(71800), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.cashIn)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf_outlined, size: 16), label: const Text('Download PDF'))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined, size: 16), label: const Text('Share Report'))),
          ],
        ),
      ],
    );
  }
}

class _CustomView extends StatelessWidget {
  final List<LedgerEntry> entries;
  const _CustomView({required this.entries});
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Transactions Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const Divider(height: 20),
          _row('Total Transactions', '149'),
          _row('Cash In Transactions', '89'),
          _row('Cash Out Transactions', '60'),
          _row('Average Income Per Day', formatCurrency(3186.67)),
          _row('Average Expense Per Day', formatCurrency(1810.67)),
          _row('Net Average Per Day', formatCurrency(1376.00)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf_outlined, size: 16), label: const Text('Download PDF'))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share_outlined, size: 16), label: const Text('Share Report'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
            Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
