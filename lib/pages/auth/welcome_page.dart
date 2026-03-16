import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../services/google_auth_service.dart';
import '../home/main_shell.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final account = await GoogleAuthService.signIn();
    if (account != null && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainShell(
            userName: account.displayName ?? account.email.split('@').first,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Gold gradient at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFD4A860),
                    Color(0xFFCDA050),
                    Color(0xFFE8D5B0),
                    Color(0xFFF5F1E8),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
          // Lumen logo top-left
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            child: Row(
              children: [
                Image.asset(
                  'assets/lumen_logo.png',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                    fontFamily: 'DMSerifDisplay',
                  ),
                ),
              ],
            ),
          ),
          // Bottom white card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catat. Pahami. Kendalikan.',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontFamily: 'DMSerifDisplay',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Keuangan pribadi, bersama keluarga, atau tim —\nsemua dalam satu tempat.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Masuk dengan Email button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      style: AppStyles.goldButton,
                      child: const Text('Masuk dengan Email'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Daftar Akun Baru button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      style: AppStyles.outlinedButton,
                      child: const Text('Daftar Akun Baru'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Masuk dengan Google button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleGoogleSignIn(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      icon: SvgPicture.asset(
                        'assets/google.svg',
                        width: 20,
                        height: 20,
                      ),
                      label: const Text(
                        'Masuk dengan Google',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Privacy policy text
                  Center(
                    child: Text(
                      'DENGAN MELANJUTKAN, ANDA MENYETUJUI KEBIJAKAN PRIVASI KAMI.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
