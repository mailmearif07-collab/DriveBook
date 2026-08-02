import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'backup_restore_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
        children: [
          const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),

          _cardWrap(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(radius: 26, backgroundColor: AppColors.scaffold, child: Icon(Icons.person, color: AppColors.textSecondary, size: 30)),
              title: const Text('Arif', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              subtitle: const Text('+91 98765 43210'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 18),

          _groupLabel('Account & Data'),
          _cardWrap(
            child: Column(
              children: [
                _settingsTile(context, Icons.cloud_upload_outlined, 'Backup & Restore', 'Backup your data & restore',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupRestoreScreen()))),
                const Divider(height: 1),
                _settingsTile(context, Icons.file_upload_outlined, 'Export Data', 'Export all data (CSV)'),
                const Divider(height: 1),
                _settingsTile(context, Icons.delete_outline, 'Clear All Data', 'Clear all app data', danger: true),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _groupLabel('Preferences'),
          _cardWrap(
            child: Column(
              children: [
                _settingsTile(context, Icons.palette_outlined, 'Theme', 'Light Mode'),
                const Divider(height: 1),
                _settingsTile(context, Icons.currency_rupee_rounded, 'Currency', 'Indian Rupee (₹)'),
                const Divider(height: 1),
                _settingsTile(context, Icons.date_range_outlined, 'Date Format', '30 May 2026'),
                const Divider(height: 1),
                _settingsTile(context, Icons.language_rounded, 'Language', 'English'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _groupLabel('App'),
          _cardWrap(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_none_rounded, color: AppColors.amber),
                  title: const Text('Notification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: const Text('Manage notifications', style: TextStyle(fontSize: 11.5)),
                  value: true,
                  onChanged: (_) {},
                ),
                const Divider(height: 1),
                _settingsTile(context, Icons.lock_outline_rounded, 'Security', 'App lock, passcode'),
                const Divider(height: 1),
                _settingsTile(context, Icons.info_outline_rounded, 'About DriveBook', 'Version 1.0.0'),
                const Divider(height: 1),
                _settingsTile(context, Icons.star_border_rounded, 'Rate DriveBook', 'Rate us on Play Store'),
                const Divider(height: 1),
                _settingsTile(context, Icons.share_outlined, 'Share DriveBook', 'Share with your friends'),
              ],
            ),
          ),
          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, color: AppColors.cashOut),
              label: const Text('Logout', style: TextStyle(color: AppColors.cashOut, fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.cashOut), padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.4)),
      );

  Widget _cardWrap({required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: child,
      );

  Widget _settingsTile(BuildContext context, IconData icon, String title, String subtitle, {bool danger = false, VoidCallback? onTap}) {
    final color = danger ? AppColors.cashOut : AppColors.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: danger ? AppColors.cashOut : AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap ?? () {},
    );
  }
}
