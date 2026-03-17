import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/providers/update_provider.dart';
import '../auth/login_assets.dart';
import '../auth/login_screen.dart';
import '../update/update_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  late final AnimationController _glowController;
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;

  late final AnimationController _sloganController;
  late final Animation<double> _sloganOpacity;
  late final Animation<Offset> _sloganSlide;

  late final AnimationController _loaderController;
  late final Animation<double> _loaderOpacity;

  late final AnimationController _stripeController;
  late final Animation<double> _stripeScale;

  late final AnimationController _shimmerController;
  
  // Dots animation
  late final AnimationController _dotsController;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    // 1. Logo Reveal (0.9s cubic-bezier)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final logoCurve = CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic);
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(logoCurve);
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(logoCurve);

    // 2. Glow Pulse (2.8s infinite)
    _glowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _glowScale = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _glowOpacity = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    // 3. Slogan Fade In (0.6s after 0.7s delay)
    _sloganController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _sloganOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _sloganController, curve: Curves.easeOut));
    _sloganSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _sloganController, curve: Curves.easeOut));

    // 4. Loader Area Fade In (0.5s after 0.95s delay)
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _loaderController, curve: Curves.easeOut));

    // 5. Stripes Reveal (1.2s cubic bezier after 1.2s delay)
    _stripeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _stripeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _stripeController, curve: Curves.easeOutCubic));

    // 6. Shimmer Track (1.8s infinite)
    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();

    // 7. Dots Bouncing (1.1s infinite)
    _dotsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();

    _startSequence();
  }

  void _startSequence() async {
    // Start Logo
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _logoController.forward();
    });
    // Start Slogan
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _sloganController.forward();
    });
    // Start Loader
    Future.delayed(const Duration(milliseconds: 950), () {
      if (mounted) _loaderController.forward();
      _checkStatusAndNavigate(); // Begin actual loading task
    });
    // Start Stripes
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _stripeController.forward();
    });
  }

  Future<void> _checkStatusAndNavigate() async {
    // Wait for minimum splash time to show animations (e.g. 2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    // Trigger exit animation
    setState(() {
      _isExiting = true;
    });
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Determine route based on update provider state
    // To ensure we get the latest state after the minimum wait
    final updateState = ref.read(updateProvider);
    
    updateState.when(
      loading: () {
        // Should not strictly happen if init is fast, but handle just in case
        _navigateToLogin(); 
      },
      error: (err, stack) => _navigateToLogin(),
      data: (info) {
        if (info.isUpdateRequired && info.updateUrl != null) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => UpdateScreen(appUrl: info.updateUrl!),
              transitionDuration: const Duration(milliseconds: 600),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
            ),
          );
        } else {
          _navigateToLogin();
        }
      },
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _sloganController.dispose();
    _loaderController.dispose();
    _stripeController.dispose();
    _shimmerController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background Atmospheric Gradients
          Positioned.fill(
            child: CustomPaint(
              painter: _AtmosphericBackgroundPainter(),
            ),
          ),
          
          // Particle Canvas placeholder (Skipped complex HTML particles for performance, keeping clean gradient)

          // Top Stripe
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _stripeScale,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.centerRight,
                  transform: Matrix4.identity()..scale(_stripeScale.value, 1.0),
                  child: const _TricolorStripe(height: 3),
                );
              },
            ),
          ),

          // Bottom Stripe
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _stripeScale,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.centerLeft,
                  transform: Matrix4.identity()..scale(_stripeScale.value, 1.0),
                  child: const _TricolorStripe(height: 4),
                );
              },
            ),
          ),

          // Main Content
          Center(
            child: AnimatedOpacity(
              opacity: _isExiting ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 400),
              child: AnimatedScale(
                scale: _isExiting ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 550),
                curve: Curves.easeIn,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LOGO AREA
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: child,
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Glow
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _glowScale.value,
                                child: Opacity(
                                  opacity: _glowOpacity.value,
                                  child: Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF006847).withOpacity(0.07),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.7],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Logo
                          Image.memory(
                            LoginAssets.getDecodedLogo(),
                            width: 160,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // SLOGAN
                    AnimatedBuilder(
                      animation: _sloganController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _sloganOpacity.value,
                          child: SlideTransition(
                            position: _sloganSlide,
                            child: child,
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                            letterSpacing: 1.5,
                          ),
                          children: const [
                            TextSpan(text: 'IMPULSANDO TU '),
                            TextSpan(
                              text: 'CRECIMIENTO',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF006847),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // LOADER AREA
                    AnimatedBuilder(
                      animation: _loaderController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _loaderOpacity.value,
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          // Dots Spinner
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _BouncingDot(controller: _dotsController, delay: 0.0),
                              const SizedBox(width: 7),
                              _BouncingDot(controller: _dotsController, delay: 0.15),
                              const SizedBox(width: 7),
                              _BouncingDot(controller: _dotsController, delay: 0.3),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Track Wrap
                          SizedBox(
                            width: 220,
                            height: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: Stack(
                                children: [
                                  Container(color: const Color(0xFFE5E7EB)),
                                  // Shimmer Fill
                                  AnimatedBuilder(
                                    animation: _shimmerController,
                                    builder: (context, child) {
                                      return Positioned(
                                        left: -220 + (_shimmerController.value * 440),
                                        child: Container(
                                          width: 220,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF006847).withOpacity(0.0),
                                                const Color(0xFF10B981),
                                                const Color(0xFF006847).withOpacity(0.0),
                                              ],
                                              stops: const [0.0, 0.5, 1.0],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Status Text
                          Text(
                            "Conectando al servidor...",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF9CA3AF),
                              letterSpacing: 0.4,
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
          
          // Version Badge (Optional)
          Positioned(
            bottom: 24,
            right: 24,
            child: AnimatedBuilder(
              animation: _stripeScale, // re-using stripe delay
              builder: (context, child) {
                return Opacity(
                  opacity: _stripeScale.value > 0.5 ? 1.0 : 0.0,
                  child: Text(
                    "v2.4.0",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD1D5DB),
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TricolorStripe extends StatelessWidget {
  final double height;
  const _TricolorStripe({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF006847),
            Color(0xFF006847),
            Colors.white,
            Colors.white,
            Color(0xFFCE1126),
            Color(0xFFCE1126),
          ],
          stops: [0.0, 0.333, 0.333, 0.666, 0.666, 1.0],
        ),
      ),
    );
  }
}

class _BouncingDot extends StatelessWidget {
  final AnimationController controller;
  final double delay;

  const _BouncingDot({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Calculate progress with offset
        double t = (controller.value + delay) % 1.0;
        
        // CSS bounce logic map:
        // 0-40%: var(--b) -> var(--green), scale 1 -> 1.4
        // 40-80%: var(--green) -> var(--b), scale 1.4 -> 1
        // 80-100%: var(--b), scale 1
        
        Color color = const Color(0xFFE5E7EB);
        double scale = 1.0;
        
        if (t < 0.4) {
          double p = t / 0.4;
          color = Color.lerp(const Color(0xFFE5E7EB), const Color(0xFF006847), Curves.easeInOut.transform(p))!;
          scale = 1.0 + (0.4 * Curves.easeInOut.transform(p));
        } else if (t < 0.8) {
          double p = (t - 0.4) / 0.4;
          color = Color.lerp(const Color(0xFF006847), const Color(0xFFE5E7EB), Curves.easeInOut.transform(p))!;
          scale = 1.4 - (0.4 * Curves.easeInOut.transform(p));
        }
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}


class _AtmosphericBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Top-Left Green Gradient
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF006847).withOpacity(0.05), Colors.transparent],
        stops: const [0.0, 0.65],
      ).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.15, size.height * 0.20),
          width: 800,
          height: 600));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);

    // Bottom-Right Red Gradient
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFCE1126).withOpacity(0.04), Colors.transparent],
        stops: const [0.0, 0.65],
      ).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.88, size.height * 0.85),
          width: 700,
          height: 600));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);

    // Center Gold Gradient
    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFC8960C).withOpacity(0.03), Colors.transparent],
        stops: const [0.0, 0.60],
      ).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.50, size.height * 0.50),
          width: 500,
          height: 500));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
