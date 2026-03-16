import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
          'Tentang Lumen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            fontFamily: 'DMSerifDisplay',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/lumen_logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.lightbulb_outline,
                      size: 48, color: AppColors.gold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lumen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontFamily: 'DMSerifDisplay',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Lumen adalah aplikasi manajemen keuangan pribadi dan tim yang membantu Anda mencatat, menganalisis, dan mengelola pengeluaran dengan lebih cerdas dan efisien.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined,
                        color: AppColors.gold),
                    title: const Text(
                      'Kebijakan Privasi',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
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
                      height: 1,
                      color: Colors.grey.shade100,
                      indent: 16,
                      endIndent: 16),
                  ListTile(
                    leading: Icon(Icons.gavel_outlined,
                        color: AppColors.gold),
                    title: const Text(
                      'Syarat & Ketentuan',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: Colors.grey.shade400, size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Segera hadir')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '© 2025 Lumen. Hak Cipta Dilindungi.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
