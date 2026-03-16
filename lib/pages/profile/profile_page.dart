import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/context_provider.dart';
import '../auth/login_page.dart';
import 'edit_profile_page.dart';
import '../transaction/reimbursement_page.dart';
import '../couple/couple_invite_page.dart';
import '../couple/couple_requests_page.dart';
import '../settings/notification_settings_page.dart';
import '../settings/security_page.dart';
import '../settings/display_settings_page.dart';
import '../settings/help_page.dart';
import '../settings/about_page.dart';

class ProfilePage extends StatelessWidget {
  final String userName;

  const ProfilePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final ctxProvider = context.watch<ContextProvider>();
    final personalCtx = ctxProvider.personalContext;
    final coupleCtx = ctxProvider.coupleContext;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.gold,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                fontFamily: 'DMSerifDisplay',
              ),
            ),
            const SizedBox(height: 32),
            _buildMenuItem(Icons.person_outline, 'Edit Profil', onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            }),
            if (personalCtx != null)
              _buildMenuItem(Icons.receipt_long_outlined, 'Reimbursement',
                  onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ReimbursementPage(contextId: personalCtx.id),
                  ),
                );
              }),
            if (coupleCtx != null) ...[
              _buildMenuItem(Icons.favorite_border, 'Undang Pasangan',
                  onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CoupleInvitePage()),
                );
              }),
              _buildMenuItem(Icons.person_add_outlined, 'Permintaan Bergabung',
                  onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const CoupleRequestsPage()),
                );
              }),
            ],
            _buildMenuItem(Icons.notifications_outlined, 'Notifikasi',
                onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsPage()),
              );
            }),
            _buildMenuItem(Icons.lock_outline, 'Keamanan', onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SecurityPage()),
              );
            }),
            _buildMenuItem(Icons.palette_outlined, 'Tampilan', onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const DisplaySettingsPage()),
              );
            }),
            _buildMenuItem(Icons.help_outline, 'Bantuan', onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpPage()),
              );
            }),
            _buildMenuItem(Icons.info_outline, 'Tentang Lumen', onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textDark),
        title: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        trailing:
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
