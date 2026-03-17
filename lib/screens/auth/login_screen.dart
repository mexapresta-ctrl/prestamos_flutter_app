import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_typography.dart';
import '../../core/providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';
import '../cobrador/cobrador_dashboard.dart';
import '../asesor/asesor_dashboard.dart';
import 'login_assets.dart';
import '../../widgets/success_animation.dart';

class RoleTheme {
  final String id;
  final String title;
  final String description;
  final Color primary;
  final Color light;
  final String avatarBase64;

  RoleTheme({
    required this.id,
    required this.title,
    required this.description,
    required this.primary,
    required this.light,
    required this.avatarBase64,
  });
}

final _roles = [
  RoleTheme(
    id: 'admin',
    title: 'Administrador',
    description: 'Acceso total al sistema',
    primary: const Color(0xFF1E3A8A),
    light: const Color(0xFFEFF6FF),
    avatarBase64: LoginAssets.adminBase64,
  ),
  RoleTheme(
    id: 'cobrador',
    title: 'Cobrador',
    description: 'Ruta de cobros',
    primary: const Color(0xFF065F46),
    light: const Color(0xFFECFDF5),
    avatarBase64: LoginAssets.cobradorBase64,
  ),
  RoleTheme(
    id: 'asesor',
    title: 'Asesor',
    description: 'Cartera y solicitudes',
    primary: const Color(0xFF92400E),
    light: const Color(0xFFFFFBEB),
    avatarBase64: LoginAssets.asesorBase64,
  ),
];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  int _selectedRoleIndex = 0;
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isSuccess = false;

  void _handleLogin() async {
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text.trim();
    final role = _roles[_selectedRoleIndex];

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa usuario y contraseña'), backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(usuario, password, role.id);
    
    if (!mounted) return;

    if (success) {
      setState(() {
        _isSuccess = true;
      });
    }
  }

  void _onAnimationComplete() {
    final role = _roles[_selectedRoleIndex];
    Widget nextScreen;
    switch (role.id) {
      case 'admin':
        nextScreen = const AdminDashboard();
        break;
      case 'asesor':
        nextScreen = const AsesorDashboard();
        break;
      case 'cobrador':
        nextScreen = const CobradorDashboard();
        break;
      default:
        nextScreen = const AdminDashboard();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = _roles[_selectedRoleIndex];
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header (Logo)
                Column(
                  children: [
                    Image.memory(
                      base64Decode(LoginAssets.logoBase64),
                      height: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MexaPresta',
                      style: AppTypography.headingPrincipal.copyWith(
                        fontSize: 28,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Impulsando tu crecimiento',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Main Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 450),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: _isSuccess ? 
                    SizedBox(
                      height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SuccessAnimationWidget(
                              onComplete: _onAnimationComplete,
                              primaryColor: role.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Acceso Concedido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: role.primary,
                            ),
                          )
                        ],
                      ),
                    )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Role Selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_roles.length, (index) {
                          final r = _roles[index];
                          final isSelected = _selectedRoleIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() => _selectedRoleIndex = index);
                              ref.read(authProvider.notifier).clearError();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? r.primary : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                r.title,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : const Color(0xFF4B5563),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Avatar & Title
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: role.light,
                                border: Border.all(color: role.primary.withValues(alpha: 0.2), width: 4),
                              ),
                              child: ClipOval(
                                child: Image.memory(
                                  base64Decode(role.avatarBase64),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              role.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error message
                      if (authState.error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Inputs
                      Text('Usuario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usuarioController,
                        onChanged: (_) => ref.read(authProvider.notifier).clearError(),
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu usuario',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF9CA3AF), size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: role.primary, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Contraseña', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        onChanged: (_) => ref.read(authProvider.notifier).clearError(),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9CA3AF), size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9CA3AF), size: 20),
                            onPressed: () => setState(() => _obscureText = !_obscureText),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: role.primary, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: role.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: authState.isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Iniciar Sesión', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
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
