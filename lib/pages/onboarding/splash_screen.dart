import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/auth_provider.dart';
import '../../providers/context_provider.dart';
import '../auth/welcome_page.dart';
import '../home/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated && auth.user != null) {
        await context.read<ContextProvider>().fetchContexts();
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainShell(userName: auth.user!.name),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: Stack(
        children: [
          // Wavy background pattern
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: _WavyBackgroundPainter(),
          ),
          // Large circle in the top-right corner
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5EFE0).withValues(alpha: 0.6),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  // Center content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lumen logo
                      Image.asset(
                        'assets/lumen_logo.png',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 20),
                      // Lumen text with serif font
                      Text(
                        'Lumen',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade800,
                          fontFamily: 'DMSerifDisplay',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tagline
                      Text(
                        'Your finances, beautifully understood',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPageIndicator(true),
                          const SizedBox(width: 8),
                          _buildPageIndicator(false),
                          const SizedBox(width: 8),
                          _buildPageIndicator(false),
                        ],
                      ),
                    ],
                  ),
                  // Footer text
                  Text(
                    'BY PT NURATECH DIGITAL NUSANTARA',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w300,
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

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFFD4A574) : Colors.grey.shade300,
      ),
    );
  }
}

class _WavyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEDE8DC).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw multiple wavy lines across the screen
    for (int i = 0; i < 12; i++) {
      final yOffset = size.height * 0.15 + (i * size.height * 0.06);
      final path = Path();
      path.moveTo(0, yOffset);

      for (double x = 0; x <= size.width; x += 1) {
        final y = yOffset +
            sin((x / size.width) * 2 * pi + (i * 0.3)) * 8 +
            sin((x / size.width) * 4 * pi + (i * 0.5)) * 4;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
