import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class TeamTab extends StatelessWidget {
  final String userName;
  final VoidCallback onBack;

  const TeamTab({super.key, required this.userName, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EAE0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.grid_view_rounded,
                          color: AppColors.gold, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Tim Kantor',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down,
                                size: 20, color: Colors.grey.shade500),
                          ],
                        ),
                        Text(
                          'Lumen Mobile Team',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Icon(Icons.notifications_outlined,
                        color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Approval banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFFE4B5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment_outlined,
                            size: 18, color: AppColors.gold),
                        const SizedBox(width: 8),
                        Text(
                          '7 menunggu persetujuanmu',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tinjau permintaan anggaran tim Anda segera',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade300,
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Sarah Miller',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                Text('Rp 1.250.000',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Tinjau',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Lihat Semua Permintaan \u2192',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slateBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Pengeluaran Tim
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text(
                'Pengeluaran Tim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'DMSerifDisplay',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Spending',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Rp 45.000.000',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            fontFamily: 'DMSerifDisplay',
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('\u2197 12%',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEF4444))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('vs Bulan Lalu (Rp 40.150.000)',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                    const SizedBox(height: 20),
                    // Simple bar chart
                    SizedBox(
                      height: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar('Alex', 0.6),
                          _buildBar('Budi', 0.8),
                          _buildBar('Cici', 0.5),
                          _buildBar('Dedi', 1.0),
                          _buildBar('Eka', 0.4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Anggota Tim
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Anggota Tim',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'DMSerifDisplay',
                    ),
                  ),
                  Text('Lihat Semua',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slateBlue)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildMemberItem('Alex Johnson', 'Product Manager', 'Admin',
                'Rp 12.4M', const Color(0xFF22C55E)),
            _buildMemberItem('Cici Wang', 'UI/UX Designer', 'Member',
                'Rp 8.1M', AppColors.gold),
            const SizedBox(height: 24),
            // Transaksi Terbaru Tim
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Text(
                'Transaksi Terbaru Tim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'DMSerifDisplay',
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildTeamTransaction(
              Icons.shopping_cart_outlined,
              'AWS Subscription',
              'Diajukan oleh Alex Johnson',
              'Rp 3.200.000',
              'Tadi, 14:20',
            ),
            _buildTeamTransaction(
              Icons.directions_car,
              'Gojek - Client Meeting',
              'Diajukan oleh Cici Wang',
              'Rp 85.000',
              'Kemarin, 18:05',
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 80 * heightFactor,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.3 + heightFactor * 0.7),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildMemberItem(String name, String role, String badge,
      String amount, Color badgeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(badge,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: badgeColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(role,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text('Pengeluaran',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamTransaction(
      IconData icon, String title, String subtitle, String amount, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.grey.shade600, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(time,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
