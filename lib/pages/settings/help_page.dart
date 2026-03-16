import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _faqs = [
    (
      question: 'Bagaimana cara menambahkan transaksi?',
      answer:
          'Anda dapat menambahkan transaksi melalui tombol "Catat Manual" di halaman utama, atau menggunakan fitur "Scan Struk" untuk memindai struk belanja secara otomatis. Pilih kategori, masukkan jumlah, dan simpan transaksi Anda.',
    ),
    (
      question: 'Bagaimana cara mengundang anggota tim?',
      answer:
          'Buka menu Tim di halaman utama, lalu pilih "Undang Anggota". Masukkan email anggota yang ingin diundang dan pilih peran yang sesuai. Anggota akan menerima undangan melalui email.',
    ),
    (
      question: 'Apakah data saya aman?',
      answer:
          'Ya, keamanan data Anda adalah prioritas utama kami. Semua data disimpan dengan enkripsi tingkat tinggi. Kami tidak pernah menjual atau membagikan data pribadi Anda kepada pihak ketiga tanpa persetujuan eksplisit dari Anda.',
    ),
    (
      question: 'Bagaimana cara mengekspor laporan?',
      answer:
          'Masuk ke halaman Analitik, lalu pilih periode laporan yang diinginkan. Tekan tombol ekspor di pojok kanan atas untuk mengunduh laporan dalam format PDF atau Excel. Fitur ini tersedia untuk semua pengguna.',
    ),
  ];

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
          'Bantuan',
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
              'PERTANYAAN UMUM',
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
                children: _faqs.asMap().entries.map((entry) {
                  final i = entry.key;
                  final faq = entry.value;
                  return Column(
                    children: [
                      if (i > 0)
                        Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                            indent: 16,
                            endIndent: 16),
                      ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        childrenPadding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 16),
                        iconColor: AppColors.gold,
                        collapsedIconColor: Colors.grey.shade400,
                        title: Text(
                          faq.question,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        children: [
                          Text(
                            faq.answer,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'HUBUNGI KAMI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.email_outlined,
                        color: AppColors.gold, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email Dukungan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'support@lumen.app',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.slateBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
