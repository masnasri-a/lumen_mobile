import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../services/otp_service.dart';
import '../onboarding/use_case_selection_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final String name;

  const EmailVerificationPage({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _otpService = OtpService();
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _secondsRemaining = 120;
  Timer? _timer;
  bool _verifying = false;
  bool _resending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 120);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length != 6) return;

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      await _otpService.verifyOtp(widget.email, _code);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => UseCaseSelectionPage(name: widget.name),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    if (_resending || _secondsRemaining > 0) return;

    setState(() {
      _resending = true;
      _error = null;
    });

    try {
      await _otpService.sendOtp(widget.email);
      if (!mounted) return;
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP baru telah dikirim')),
      );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
              // Email icon
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
                  Icons.mark_email_read_outlined,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Cek emailmu',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  fontFamily: 'DMSerifDisplay',
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Kami kirim kode 6 digit ke\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // OTP fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 60,
                    child: TextFormField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: _error != null
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFF0EDF5),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: AppColors.gold, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (_error != null) setState(() => _error = null);
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        // Auto-verify when all 6 digits entered
                        if (_code.length == 6) _verify();
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Error message
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                        color: Color(0xFFEF4444), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              // Timer / Resend
              if (_secondsRemaining > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kirim ulang kode dalam ',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey.shade500),
                    ),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: _resend,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_resending)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.gold),
                        )
                      else
                        const Icon(Icons.refresh,
                            size: 18, color: AppColors.gold),
                      const SizedBox(width: 6),
                      Text(
                        _resending ? 'Mengirim...' : 'Kirim Ulang Kode',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              // Verifikasi button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_code.length == 6 && !_verifying) ? _verify : null,
                  style: AppStyles.darkButton,
                  child: _verifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Verifikasi'),
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
