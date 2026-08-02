import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Bottom nav with 4 destinations + a raised center FAB, matching the
/// reference screens (Home / Reports / [+] / Ledger / Settings).
class AppBottomNav extends StatelessWidget {
  final int currentIndex; // 0 Home, 1 Reports, 2 Ledger, 3 Settings
  final ValueChanged<int> onTap;
  final VoidCallback onAddPressed;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 8,
      height: 64,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Home', selected: currentIndex == 0, onTap: () => onTap(0)),
          _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports', selected: currentIndex == 1, onTap: () => onTap(1)),
          const SizedBox(width: 48), // space for notch
          _NavItem(icon: Icons.menu_book_rounded, label: 'Ledger', selected: currentIndex == 2, onTap: () => onTap(2)),
          _NavItem(icon: Icons.settings_rounded, label: 'Settings', selected: currentIndex == 3, onTap: () => onTap(3)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
