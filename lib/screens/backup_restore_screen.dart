import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Keep Your Data Safe', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.primary)),
                      SizedBox(height: 4),
                      Text('Backup your data regularly to avoid losing important records.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 36),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _groupLabel('Backup'),
          _cardWrap(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cloud_done_outlined, color: AppColors.primary),
                  title: const Text('Last Backup', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: const Text('30 May 2026, 08:45 AM', style: TextStyle(fontSize: 11.5)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.cashInBg, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Success', style: TextStyle(color: AppColors.cashIn, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ),
                const Divider(height: 1),
                _row(Icons.list_alt_rounded, 'Total Records', '1,248'),
                const Divider(height: 1),
                _row(Icons.insert_drive_file_outlined, 'Backup Size', '2.45 MB'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Create New Backup'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 18),

          _groupLabel('Auto Backup'),
          _cardWrap(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.cloud_sync_outlined, color: AppColors.primary),
                  title: const Text('Auto Backup', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: const Text('Automatically backup data', style: TextStyle(fontSize: 11.5)),
                  value: _autoBackup,
                  onChanged: (v) => setState(() => _autoBackup = v),
                ),
                const Divider(height: 1),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Backup Frequency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  subtitle: Text('Choose how often to backup', style: TextStyle(fontSize: 11.5)),
                  trailing: Text('Daily', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _groupLabel('Restore'),
          _cardWrap(
            child: Column(
              children: [
                _navRow(Icons.restore_rounded, 'Restore from Backup', 'Restore your data from backup file', AppColors.cashIn),
                const Divider(height: 1),
                _navRow(Icons.folder_open_outlined, 'Choose Backup File', 'Select a backup file from device', AppColors.purple),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _groupLabel('More Options'),
          _cardWrap(
            child: Column(
              children: [
                _navRow(Icons.delete_outline, 'Delete Old Backups', 'Delete old backup files', AppColors.cashOut),
                const Divider(height: 1),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.folder_outlined, color: AppColors.amber),
                  title: Text('Backup Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  trailing: Text('Internal Storage', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.cashInBg, borderRadius: BorderRadius.circular(12)),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: AppColors.cashIn),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your data is completely safe', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                      SizedBox(height: 2),
                      Text('All backups are stored only on your device. We don\'t upload your data to any server.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
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

  Widget _row(IconData icon, String label, String value) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      );

  Widget _navRow(IconData icon, String title, String subtitle, Color color) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: () {},
      );
}
