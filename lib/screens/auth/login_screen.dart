import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    // TODO: Implement Supabase Authentication Logic
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // App Title/Logo Area
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.adminGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x523447E8),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'LoanOS',
                      style: AppTypography.heroAmount.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestión inteligente de préstamos',
                      style: AppTypography.subtext,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              
              // Login Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F090B1C),
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Iniciar Sesión',
                      style: AppTypography.headingPrincipal,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    CustomInput(
                      label: 'Correo Electrónico',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) => _emailController.text = val,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Contraseña',
                      obscureText: true,
                      onChanged: (val) => _passwordController.text = val,
                    ),
                    const SizedBox(height: 32),
                    _isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          type: ButtonType.admin,
                          text: 'Ingresar',
                          onPressed: _handleLogin,
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
