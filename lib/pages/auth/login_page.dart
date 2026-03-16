import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/google_auth_service.dart';
import '../home/main_shell.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainShell(userName: auth.user!.name),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login gagal'),
          backgroundColor: Colors.redAccent,
        ),
      );
      auth.clearError();
    }
  }

  Future<void> _loginWithGoogle() async {
    final account = await GoogleAuthService.signIn();
    if (account == null || !mounted) return;

    final idToken = await GoogleAuthService.getIdToken(account);
    if (idToken == null || !mounted) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithGoogle(idToken);

    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MainShell(userName: auth.user!.name),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login Google gagal'),
          backgroundColor: Colors.redAccent,
        ),
      );
      auth.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Selamat datang kembali',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                    fontFamily: 'DMSerifDisplay',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk untuk lanjutkan',
                  style: TextStyle(fontSize: 15, color: AppColors.slateBlue),
                ),
                const SizedBox(height: 36),
                Text('EMAIL',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                        letterSpacing: 1.0)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppStyles.inputDecoration(
                    hintText: 'nama@email.com',
                    suffixIcon:
                        Icon(Icons.mail_outline, color: Colors.grey.shade400),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email harus diisi';
                    if (!v.contains('@')) return 'Masukkan email yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('KATA SANDI',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                            letterSpacing: 1.0)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('Lupa kata sandi?',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.slateBlue,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: AppStyles.inputDecoration(
                    hintText: '********',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        Icon(Icons.lock_outline, color: Colors.grey.shade400),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kata sandi harus diisi';
                    if (v.length < 6) return 'Kata sandi minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _login,
                    style: AppStyles.darkButton,
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Masuk'),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('ATAU',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              letterSpacing: 1.0)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: loading ? null : _loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    icon: SvgPicture.asset('assets/google.svg', width: 20, height: 20),
                    label: const Text('Lanjutkan dengan Google',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Belum punya akun? ',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey.shade500)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterPage()),
                      ),
                      child: const Text('Daftar sekarang',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
