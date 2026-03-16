import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _newTransaction = true;
  bool _reimbursementApproved = true;
  bool _budgetNearLimit = true;
  bool _weeklyReport = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        centerTitle: false,
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            fontFamily: 'DMSerifDisplay',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'PENGATURAN NOTIFIKASI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            _buildToggleTile(
              icon: Icons.receipt_long_outlined,
              title: 'Transaksi Baru',
              subtitle: 'Notifikasi setiap ada transaksi baru',
              value: _newTransaction,
              onChanged: (v) => setState(() => _newTransaction = v),
            ),
            _buildToggleTile(
              icon: Icons.check_circle_outline,
              title: 'Reimbursement Diapprove',
              subtitle: 'Notifikasi saat reimbursement disetujui',
              value: _reimbursementApproved,
              onChanged: (v) => setState(() => _reimbursementApproved = v),
            ),
            _buildToggleTile(
              icon: Icons.warning_amber_outlined,
              title: 'Budget Hampir Habis',
              subtitle: 'Peringatan saat budget mendekati batas',
              value: _budgetNearLimit,
              onChanged: (v) => setState(() => _budgetNearLimit = v),
            ),
            _buildToggleTile(
              icon: Icons.bar_chart_outlined,
              title: 'Laporan Mingguan',
              subtitle: 'Ringkasan pengeluaran mingguan',
              value: _weeklyReport,
              onChanged: (v) => setState(() => _weeklyReport = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.gold, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.gold,
        ),
      ),
    );
  }
}
