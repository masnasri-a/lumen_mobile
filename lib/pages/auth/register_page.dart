import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'email_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (ok) {
      // OTP sudah dikirim otomatis oleh backend saat register.
      // Arahkan ke halaman verifikasi email.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(
            email: _emailController.text.trim(),
            name: auth.user!.name,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Pendaftaran gagal'),
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
                const SizedBox(height: 8),
                const Text(
                  'Daftar Akun Baru',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    fontFamily: 'DMSerifDisplay',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lengkapi data di bawah ini untuk bergabung\ndengan Lumen.',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade500,
                      height: 1.5),
                ),
                const SizedBox(height: 32),
                // Nama
                const Text('Nama lengkap',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: AppStyles.inputDecoration(
                    hintText: 'Masukkan nama lengkap',
                    suffixIcon: Icon(Icons.person_outline,
                        color: Colors.grey.shade400),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nama lengkap harus diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Email
                const Text('Email',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: AppStyles.inputDecoration(
                    hintText: 'Alamat email',
                    suffixIcon:
                        Icon(Icons.mail_outline, color: Colors.grey.shade400),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email harus diisi';
                    if (!v.contains('@')) return 'Masukkan email yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Kata sandi
                const Text('Kata sandi',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: AppStyles.inputDecoration(
                    hintText: 'min 8 karakter',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.lock_outline
                            : Icons.lock_open,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Kata sandi harus diisi';
                    if (v.length < 8) return 'Kata sandi minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Konfirmasi
                const Text('Konfirmasi kata sandi',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: AppStyles.inputDecoration(
                    hintText: 'Ulangi kata sandi',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.shield_outlined,
                          color: Colors.grey.shade400),
                      onPressed: () => setState(() =>
                          _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Konfirmasi kata sandi harus diisi';
                    }
                    if (v != _passwordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _register,
                    style: AppStyles.darkButton,
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Buat Akun'),
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Sudah punya akun? ',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade500)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text('Masuk',
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
