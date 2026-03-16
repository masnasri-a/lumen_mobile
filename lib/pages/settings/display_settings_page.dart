import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DisplaySettingsPage extends StatefulWidget {
  const DisplaySettingsPage({super.key});

  @override
  State<DisplaySettingsPage> createState() => _DisplaySettingsPageState();
}

class _DisplaySettingsPageState extends State<DisplaySettingsPage> {
  bool _darkMode = false;

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
          'Tampilan',
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
              'PENGATURAN TAMPILAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dark_mode_outlined,
                          color: AppColors.gold, size: 20),
                    ),
                    title: const Text(
                      'Mode Gelap',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                    subtitle: Text(
                      'Aktifkan tampilan gelap',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                    trailing: Switch(
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                      activeThumbColor: AppColors.gold,
                    ),
                  ),
                  Divider(
                      height: 1, color: Colors.grey.shade100, indent: 72),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.language_outlined,
                          color: AppColors.gold, size: 20),
                    ),
                    title: const Text(
                      'Bahasa',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                    subtitle: const Text(
                      'Bahasa Indonesia',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: Colors.grey.shade400, size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Segera hadir')),
                      );
                    },
                  ),
                  Divider(
                      height: 1, color: Colors.grey.shade100, indent: 72),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.monetization_on_outlined,
                          color: AppColors.gold, size: 20),
                    ),
                    title: const Text(
                      'Mata Uang',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                    subtitle: const Text(
                      'IDR - Rupiah Indonesia',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: Colors.grey.shade400, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
