import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class EntryTile extends StatelessWidget {
  final LedgerEntry entry;
  final VoidCallback? onTap;

  const EntryTile({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIn = entry.isCashIn;
    final color = isIn ? AppColors.cashIn : AppColors.cashOut;
    final bg = isIn ? AppColors.cashInBg : AppColors.cashOutBg;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: bg,
              child: Icon(
                isIn ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(formatFullDate(entry.date),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(entry.description,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatCurrency(entry.amount),
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(isIn ? 'Cash In' : 'Cash Out',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
