import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/context_provider.dart';
import 'team_verification_page.dart';
import 'onboarding_complete_page.dart';

class TeamSetupPage extends StatefulWidget {
  final String name;

  const TeamSetupPage({super.key, required this.name});

  @override
  State<TeamSetupPage> createState() => _TeamSetupPageState();
}

class _TeamSetupPageState extends State<TeamSetupPage> {
  final _teamNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    _teamNameController.dispose();
    _descriptionController.dispose();
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _codeFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _finish() async {
    final teamName = _teamNameController.text.trim();
    if (teamName.isNotEmpty) {
      // Create team context via API
      await context.read<ContextProvider>().createContext(
            name: teamName,
            type: 'team',
          );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => OnboardingCompletePage(name: widget.name),
        ),
        (route) => false,
      );
    } else {
      // Joining a team - go to verification
      final code = _codeControllers.map((c) => c.text).join();
      if (code.length == 6) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TeamVerificationPage(
              name: widget.name,
              teamName: 'Tim Kantor',
              code: code,
            ),
          ),
        );
      }
    }
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
        centerTitle: true,
        title: const Text(
          'Lumen Onboarding',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(false),
                  const SizedBox(width: 8),
                  _buildDot(false),
                  const SizedBox(width: 8),
                  _buildActiveDot(),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Buat atau Gabung Tim',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'DMSerifDisplay',
                ),
              ),
              const SizedBox(height: 24),
              // Buat Tim Baru card
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
                            Icons.group_add_outlined,
                            size: 20,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Buat Tim Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Nama Tim',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _teamNameController,
                      decoration: AppStyles.inputDecoration(
                        hintText: 'Contoh: Tim Inovasi Lumen',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Deskripsi (Opsional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: AppStyles.inputDecoration(
                        hintText: 'Tujuan tim ini...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Invite Anggota',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Copy link
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Copy Link'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Gabung Tim yang Ada card
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
                        const Text(
                          'Gabung Tim yang Ada',
                          style: TextStyle(
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
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Code input boxes
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
              const SizedBox(height: 32),
              // Selesai & Mulai button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finish,
                  style: AppStyles.goldButton,
                  child: const Text('Selesai & Mulai'),
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

  Widget _buildActiveDot() {
    return Container(
      width: 24,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.gold,
      ),
    );
  }
}
