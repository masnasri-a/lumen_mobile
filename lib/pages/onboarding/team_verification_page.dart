import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'onboarding_complete_page.dart';

class TeamVerificationPage extends StatefulWidget {
  final String name;
  final String teamName;
  final String code;

  const TeamVerificationPage({
    super.key,
    required this.name,
    required this.teamName,
    required this.code,
  });

  @override
  State<TeamVerificationPage> createState() => _TeamVerificationPageState();
}

class _TeamVerificationPageState extends State<TeamVerificationPage> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing code
    for (int i = 0; i < widget.code.length && i < 6; i++) {
      _codeControllers[i].text = widget.code[i];
    }
  }

  @override
  void dispose() {
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _validate() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => OnboardingCompletePage(name: widget.name),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Check icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verifikasi Team',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'DMSerifDisplay',
                ),
              ),
              const SizedBox(height: 40),
              // Team card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF0EAE0),
                          ),
                          child: const Icon(
                            Icons.login_outlined,
                            size: 20,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.teamName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Masukkan Kode Undangan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 48,
                          height: 56,
                          child: TextFormField(
                            controller: _codeControllers[index],
                            focusNode: _codeFocusNodes[index],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: const Color(0xFFF5F1E8),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                _codeFocusNodes[index + 1].requestFocus();
                              } else if (value.isEmpty && index > 0) {
                                _codeFocusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Minta admin tim Anda untuk kode undangan 6-\nkarakter.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Validasi button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validate,
                  style: AppStyles.darkButton,
                  child: const Text('Validasi'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
