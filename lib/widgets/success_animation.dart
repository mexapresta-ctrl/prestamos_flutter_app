import 'dart:math';
import 'package:flutter/material.dart';

class SuccessAnimationWidget extends StatefulWidget {
  final VoidCallback onComplete;
  final Color primaryColor;

  const SuccessAnimationWidget({
    super.key,
    required this.onComplete,
    required this.primaryColor,
  });

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget> with TickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  late AnimationController _confettiController;
  final List<Particle> particles = [];
  bool _confettiInited = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _checkAnimation = CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack);
    
    _confettiController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _confettiController.addListener(() {
      for (var p in particles) {
        p.update();
      }
      setState(() {});
    });

    _checkController.forward().then((_) {
      if (mounted) {
         _initConfetti();
        _confettiController.forward().then((_) {
          if (mounted) widget.onComplete();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-initialize particles off-screen to avoid null errors on first frame
    if (!_confettiInited) {
      _initConfetti();
      _confettiInited = true;
    }
  }
  
  void _initConfetti() {
    particles.clear();
    final random = Random();
    final size = MediaQuery.of(context).size;
    final startX = size.width / 2;
    final startY = size.height / 2;

    for (int i = 0; i < 150; i++) {
      particles.add(Particle(
        x: startX,
        y: startY,
        vx: (random.nextDouble() - 0.5) * 30, // Explode outwards
        vy: (random.nextDouble() - 1.0) * 30 - 10, // Explode upwards
        color: Color((random.nextDouble() * 0xFFFFFF).toInt()).withValues(alpha: 1.0),
        size: random.nextDouble() * 8 + 4,
      ));
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_confettiController.isAnimating)
          CustomPaint(
            size: Size.infinite,
            painter: ConfettiPainter(particles),
          ),
        Center(
          child: AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _checkAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: widget.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withValues(alpha: 0.4), 
                        blurRadius: 30, 
                        spreadRadius: 8
                      )
                    ]
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: Colors.white, size: 60),
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}

class Particle {
  double x, y, vx, vy, size;
  Color color;
  Particle({required this.x, required this.y, required this.vx, required this.vy, required this.color, required this.size});

  void update() {
    x += vx;
    y += vy;
    vy += 0.8; // gravity
  }
}

class ConfettiPainter extends CustomPainter {
  final List<Particle> particles;
  ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = p.color..style = PaintingStyle.fill;
      // Depending on the shape we can draw circles or small rects
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
