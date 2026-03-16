import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';
import '../../core/providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';
import '../cobrador/cobrador_dashboard.dart';
import '../asesor/asesor_dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'admin';

  final List<Map<String, dynamic>> _roles = [
    {'id': 'admin', 'label': 'Administrador', 'icon': '🛡️', 'desc': 'Acceso total al sistema', 'color': AppColors.admin},
    {'id': 'asesor', 'label': 'Asesor', 'icon': '💼', 'desc': 'Cartera y solicitudes', 'color': AppColors.asesor},
    {'id': 'cobrador', 'label': 'Cobrador', 'icon': '💵', 'desc': 'Ruta de cobros', 'color': AppColors.cobrador},
  ];

  void _handleLogin() async {
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa usuario y contraseña'), backgroundColor: AppColors.error),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).login(usuario, password, _selectedRole);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido 👋'), backgroundColor: AppColors.ok),
      );
      
      Widget nextScreen;
      switch (_selectedRole) {
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
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Area
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
                        child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('MexaPresta', style: AppTypography.heroAmount.copyWith(color: AppColors.ink)),
                    const SizedBox(height: 4),
                    Text('Impulsando tu crecimiento', style: AppTypography.subtext),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Login Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [BoxShadow(color: Color(0x0F090B1C), blurRadius: 20, offset: Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Iniciar Sesión', style: AppTypography.headingPrincipal, textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text('Selecciona tu rol y accede al sistema', style: AppTypography.subtext, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    
                    // Role Selector
                    Text('SELECCIONA TU ROL', style: AppTypography.label),
                    const SizedBox(height: 8),
                    Row(
                      children: _roles.map((role) {
                        final isSelected = _selectedRole == role['id'];
                        final color = role['color'] as Color;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedRole = role['id'] as String);
                              ref.read(authProvider.notifier).clearError();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? color.withOpacity(0.1) : AppColors.surface1,
                                border: Border.all(color: isSelected ? color : AppColors.border, width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(role['icon'] as String, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(
                                    role['label'] as String, 
                                    style: TextStyle(
                                      fontSize: 11, 
                                      fontWeight: FontWeight.w600, 
                                      color: isSelected ? color : AppColors.ink,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Inputs
                    CustomInput(
                      label: 'Usuario',
                      initialValue: '',
                      onChanged: (val) => _usuarioController.text = val,
                    ),
                    const SizedBox(height: 16),
                    CustomInput(
                      label: 'Contraseña',
                      obscureText: true,
                      initialValue: '',
                      onChanged: (val) => _passwordController.text = val,
                    ),
                    const SizedBox(height: 24),

                    if (authState.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.errorSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                        ),
                        child: Text(
                          authState.error!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),

                    authState.isLoading 
                      ? const Center(child: CircularProgressIndicator())
                      : CustomButton(
                          type: _getButtonTypeForRole(),
                          text: '🔑 Iniciar Sesión',
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

  ButtonType _getButtonTypeForRole() {
    switch (_selectedRole) {
      case 'admin': return ButtonType.admin;
      case 'cobrador': return ButtonType.cobrador;
      case 'asesor': return ButtonType.asesor;
      default: return ButtonType.admin;
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
