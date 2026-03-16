import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'profile_setup_page.dart';

class UseCaseSelectionPage extends StatefulWidget {
  final String name;

  const UseCaseSelectionPage({super.key, required this.name});

  @override
  State<UseCaseSelectionPage> createState() => _UseCaseSelectionPageState();
}

class _UseCaseSelectionPageState extends State<UseCaseSelectionPage> {
  final Set<int> _selected = {0}; // Default first option selected

  final List<_UseCaseOption> _options = [
    _UseCaseOption(
      icon: Icons.person_outline,
      title: 'Untuk Diri Sendiri',
      subtitle: 'Catat pengeluaran pribadi &\npantau budget',
    ),
    _UseCaseOption(
      icon: Icons.people_outline,
      title: 'Bersama Pasangan atau\nKeluarga',
      subtitle: 'Budget bersama, pengeluaran\ntransparan',
    ),
    _UseCaseOption(
      icon: Icons.grid_view_outlined,
      title: 'Untuk Tim atau Bisnis',
      subtitle: 'Kelola pengeluaran tim,\napproval & reimburse',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(true),
                  const SizedBox(width: 8),
                  _buildDot(false),
                  const SizedBox(width: 8),
                  _buildDot(false),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Kamu pakai Lumen untuk apa?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'DMSerifDisplay',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bisa dipilih lebih dari satu',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 24),
              // Options
              ...List.generate(_options.length, (index) {
                final option = _options[index];
                final isSelected = _selected.contains(index);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(index);
                        } else {
                          _selected.add(index);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFFF0EAE0)
                                  : Colors.grey.shade100,
                            ),
                            child: Icon(
                              option.icon,
                              size: 28,
                              color: isSelected
                                  ? AppColors.gold
                                  : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  option.subtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.gold,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              ),
                            )
                          else
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              // Lanjutkan button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected.isNotEmpty
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileSetupPage(
                                name: widget.name,
                                hasCouple: _selected.contains(1),
                                hasTeam: _selected.contains(2),
                              ),
                            ),
                          );
                        }
                      : null,
                  style: AppStyles.goldButton,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lanjutkan'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.gold : Colors.grey.shade300,
      ),
    );
  }
}

class _UseCaseOption {
  final IconData icon;
  final String title;
  final String subtitle;

  _UseCaseOption({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
