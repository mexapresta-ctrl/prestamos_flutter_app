import 'dart:convert';
import 'dart:math' as math;
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
    description: 'Control total',
    primary: const Color(0xFF1E3A8A),
    light: const Color(0xFFEFF6FF),
    avatarBase64: LoginAssets.adminBase64,
  ),
  RoleTheme(
    id: 'cobrador',
    title: 'Cobrador',
    description: 'Cobros en campo',
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

// ── Decoded images cache ──
final _avatarCache = <String, MemoryImage>{};
MemoryImage _avatarFor(String b64) {
  return _avatarCache.putIfAbsent(b64, () => MemoryImage(base64Decode(b64)));
}

final _logoImage = MemoryImage(LoginAssets.getDecodedLogo());

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  int _selectedRoleIndex = 0;
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isSuccess = false;

  // ── Animations ──
  late AnimationController _fadeUpController;
  late Animation<double> _fadeUpSlide;
  late Animation<double> _fadeUpOpacity;

  late AnimationController _avatarWaveController;
  late Animation<double> _avatarWave;

  late AnimationController _buttonSweepController;

  @override
  void initState() {
    super.initState();

    // Card fade-up animation
    _fadeUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeUpSlide = Tween<double>(begin: 30, end: 0).animate(CurvedAnimation(
      parent: _fadeUpController,
      curve: Curves.easeOutCubic,
    ));
    _fadeUpOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeUpController,
      curve: Curves.easeOut,
    ));

    // Avatar wave animation (plays on role change)
    _avatarWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _avatarWave = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 14),
      TweenSequenceItem(tween: Tween(begin: -12, end: 13), weight: 16),
      TweenSequenceItem(tween: Tween(begin: 13, end: -8), weight: 16),
      TweenSequenceItem(tween: Tween(begin: -8, end: 10), weight: 16),
      TweenSequenceItem(tween: Tween(begin: 10, end: -4), weight: 16),
      TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 22),
    ]).animate(CurvedAnimation(
      parent: _avatarWaveController,
      curve: Curves.easeInOut,
    ));

    // Button sweep animation
    _buttonSweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Start fade-up after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fadeUpController.forward();
    });
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    _fadeUpController.dispose();
    _avatarWaveController.dispose();
    _buttonSweepController.dispose();
    super.dispose();
  }

  void _selectRole(int index) {
    if (index == _selectedRoleIndex) return;
    setState(() => _selectedRoleIndex = index);
    ref.read(authProvider.notifier).clearError();
    _avatarWaveController.forward(from: 0.0);
  }

  void _handleLogin() async {
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text.trim();
    final role = _roles[_selectedRoleIndex];

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa usuario y contraseña'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final success =
        await ref.read(authProvider.notifier).login(usuario, password, role.id);

    if (!mounted) return;

    if (success) {
      setState(() => _isSuccess = true);
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
    final isLoading = ref.watch(authProvider.select((s) => s.isLoading));
    final error = ref.watch(authProvider.select((s) => s.error));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // ── Subtle background gradients (like the HTML) ──
          Positioned.fill(
            child: CustomPaint(painter: _SubtleBgPainter()),
          ),
          // ── Main content ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: AnimatedBuilder(
                  animation: _fadeUpController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeUpOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _fadeUpSlide.value),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 480),
                    padding: const EdgeInsets.fromLTRB(36, 36, 36, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
                        BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 8)),
                        BoxShadow(color: Color(0x0F000000), blurRadius: 56, offset: Offset(0, 24)),
                      ],
                    ),
                    child: _isSuccess
                        ? SizedBox(
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
                                  '¡Bienvenido!',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: role.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Cargando panel...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ── Logo ──
                              Image(image: _logoImage, height: 80),
                              const SizedBox(height: 2),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFF006847), Color(0xFF1a7a50)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: Text(
                                  'MexaPresta',
                                  style: AppTypography.headingPrincipal.copyWith(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'IMPULSANDO TU CRECIMIENTO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[400],
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Gradient divider ──
                              Container(
                                height: 1,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Color(0xFFE5E7EB), Colors.transparent],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── "Selecciona tu rol" label ──
                              Text(
                                'SELECCIONA TU ROL',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // ── Role selector cards (3 columns) ──
                              Row(
                                children: List.generate(_roles.length, (index) {
                                  final r = _roles[index];
                                  final isSelected = _selectedRoleIndex == index;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => _selectRole(index),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        curve: Curves.easeOutBack,
                                        margin: EdgeInsets.only(
                                          left: index == 0 ? 0 : 5,
                                          right: index == 2 ? 0 : 5,
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                        transform: Matrix4.translationValues(
                                          0,
                                          isSelected ? -5 : 0,
                                          0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected ? r.light : const Color(0xFFF3F4F6),
                                          border: Border.all(
                                            color: isSelected ? r.primary : const Color(0xFFE5E7EB),
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: isSelected
                                              ? [BoxShadow(
                                                  color: r.primary.withValues(alpha: 0.14),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 6),
                                                )]
                                              : null,
                                        ),
                                        child: Column(
                                          children: [
                                            // Checkmark
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 200),
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isSelected ? r.primary : Colors.white,
                                                  border: Border.all(
                                                    color: isSelected ? r.primary : const Color(0xFFE5E7EB),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            // Avatar with wave animation
                                            AnimatedBuilder(
                                              animation: _avatarWave,
                                              builder: (context, child) {
                                                final double rotation = isSelected
                                                    ? _avatarWave.value * (math.pi / 180)
                                                    : 0;
                                                final double scale = isSelected
                                                    ? 1.0 + (_avatarWaveController.isAnimating
                                                        ? 0.1 * math.sin(_avatarWaveController.value * math.pi)
                                                        : 0)
                                                    : 1.0;
                                                return Transform(
                                                  alignment: Alignment.bottomCenter,
                                                  transform: Matrix4.identity()
                                                    ..rotateZ(rotation)
                                                    ..scale(scale),
                                                  child: child,
                                                );
                                              },
                                              child: Container(
                                                width: 56,
                                                height: 56,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipOval(
                                                  child: Image(
                                                    image: _avatarFor(r.avatarBase64),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              r.title,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF2D3142),
                                              ),
                                            ),
                                            const SizedBox(height: 1),
                                            Text(
                                              r.description,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 9,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 24),

                              // ── Form header ──
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: role.light,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      role.title,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: role.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0D1117),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // ── Error message ──
                              if (error != null)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(9),
                                  margin: const EdgeInsets.only(bottom: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFECACA)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          error,
                                          style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // ── Usuario field ──
                              _buildField(
                                label: 'USUARIO',
                                hint: 'Ingresa tu usuario',
                                icon: Icons.person_outline,
                                controller: _usuarioController,
                                role: role,
                              ),
                              const SizedBox(height: 14),

                              // ── Contraseña field ──
                              _buildField(
                                label: 'CONTRASEÑA',
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                controller: _passwordController,
                                role: role,
                                isPassword: true,
                              ),
                              const SizedBox(height: 20),

                              // ── Login button with gradient + sweep animation ──
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: _buildGradientButton(
                                  role: role,
                                  isLoading: isLoading,
                                  onPressed: _handleLogin,
                                ),
                              ),

                              // ── Forgot password ──
                              const SizedBox(height: 14),
                              Center(
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required RoleTheme role,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword ? _obscureText : false,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 16),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[400],
                      size: 18,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: role.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required RoleTheme role,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    // Gradient colors per role
    List<Color> gradColors;
    Color shadowColor;
    switch (role.id) {
      case 'admin':
        gradColors = [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)];
        shadowColor = const Color(0xFF1E3A8A);
        break;
      case 'cobrador':
        gradColors = [const Color(0xFF065F46), const Color(0xFF10B981)];
        shadowColor = const Color(0xFF065F46);
        break;
      case 'asesor':
        gradColors = [const Color(0xFF92400E), const Color(0xFFF59E0B)];
        shadowColor = const Color(0xFF92400E);
        break;
      default:
        gradColors = [const Color(0xFF006847), const Color(0xFF10B981)];
        shadowColor = const Color(0xFF006847);
    }

    return AnimatedBuilder(
      animation: _buttonSweepController,
      builder: (context, child) {
        return GestureDetector(
          onTap: isLoading ? null : onPressed,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: LinearGradient(
                colors: gradColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Stack(
                children: [
                  // Sweep shine effect
                  Positioned(
                    left: ((_buttonSweepController.value * 3) - 1) *
                        MediaQuery.of(context).size.width * 0.5,
                    top: 0,
                    bottom: 0,
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Button content
                  Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.1,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Subtle radial gradient background like the HTML mockup
class _SubtleBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Green gradient top-left
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF006847).withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.1, size.height * 0.2),
          radius: size.width * 0.5,
        )),
    );
    // Red gradient bottom-right
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.8),
      size.width * 0.45,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFCE1126).withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.9, size.height * 0.8),
          radius: size.width * 0.45,
        )),
    );
    // Gold gradient center
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.35,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFC8960C).withValues(alpha: 0.03),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.5),
          radius: size.width * 0.35,
        )),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
