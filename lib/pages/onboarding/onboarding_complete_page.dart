import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../home/main_shell.dart';

class OnboardingCompletePage extends StatelessWidget {
  final String name;

  const OnboardingCompletePage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Check icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Semuanya siap, $name!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        fontFamily: 'DMSerifDisplay',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.celebration, size: 28, color: AppColors.gold),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Yuk mulai catat pengeluaran pertamamu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 40),
              // Mulai Gunakan Lumen button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => MainShell(userName: name),
                      ),
                      (route) => false,
                    );
                  },
                  style: AppStyles.darkButton,
                  child: const Text('Mulai Gunakan Lumen'),
                ),
              ),
              const SizedBox(height: 12),
              // Lihat tur singkat button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Tour
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text('Lihat tur singkat'),
                ),
              ),
              const Spacer(flex: 1),
              // Bottom navigation preview
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.home_filled, 'HOME', true),
                    _buildNavItem(Icons.calendar_today_outlined, 'ACTIVITY', false),
                    _buildNavItem(Icons.pie_chart_outline, 'BUDGET', false),
                    _buildNavItem(Icons.person_outline, 'PROFILE', false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 24,
          color: isActive ? AppColors.gold : Colors.grey.shade400,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.gold : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
