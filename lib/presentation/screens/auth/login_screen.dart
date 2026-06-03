import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/view_state.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_card.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Autentikasi Gagal'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = AppColors.isDark(context);
    final bgColor = AppColors.getBackground(context);
    final textPrimary = AppColors.getTextPrimary(context);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimalist Brand Logo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_library_rounded,
                    color: isDark ? Colors.black : Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 28),
                
                // Bold Headers
                Text(
                  'Perpustakaan\nDigital.',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sistem Manajemen Buku & Sirkulasi Peminjaman.',
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 36),
                
                // Form Card
                CustomCard(
                  padding: const EdgeInsets.all(24.0),
                  borderRadius: 20,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign In Staf',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Username Input
                        CustomTextField(
                          controller: _usernameController,
                          labelText: 'Username',
                          hintText: 'Masukkan username',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Username harus diisi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Password Input
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Kata Sandi',
                          hintText: 'Masukkan kata sandi',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Kata sandi harus diisi';
                            }
                            if (val.length < 4) {
                              return 'Minimal 4 karakter';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.getTextSecondary(context),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Action Button
                        CustomButton(
                          text: 'MASUK APLIKASI',
                          isLoading: authProvider.state == ViewState.loading,
                          onPressed: _onLoginPressed,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Demo Hint
                Center(
                  child: Text(
                    'Mode Demo: Gunakan sembarang kata sandi.',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context).withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
