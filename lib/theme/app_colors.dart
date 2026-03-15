import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color admin = Color(0xFF3447E8);
  static const Color adminLight = Color(0xFF6978FF);
  static const Color adminSurface = Color(0xFFECEDFE);

  static const Color cobrador = Color(0xFF0A7C5C);
  static const Color cobradorLight = Color(0xFF1DB888);
  static const Color cobradorSurface = Color(0xFFE4F5F0);

  static const Color asesor = Color(0xFFC44C0A);
  static const Color asesorLight = Color(0xFFF06820);
  static const Color asesorSurface = Color(0xFFFDEFEA);

  // Semantic Colors
  static const Color ok = Color(0xFF0A7050);
  static const Color okSurface = Color(0xFFE3F5EE);

  static const Color warn = Color(0xFF9A5500);
  static const Color warnSurface = Color(0xFFFEF3E2);

  static const Color error = Color(0xFFB82428);
  static const Color errorSurface = Color(0xFFFCEAEA);

  static const Color info = Color(0xFF1840BA);
  static const Color infoSurface = Color(0xFFEBF0FC);

  // Neutral Colors (Ink)
  static const Color ink = Color(0xFF090B1C);  // Text
  static const Color ink2 = Color(0xFF1E2040); 
  static const Color ink3 = Color(0xFF525880); // Subtext, labels
  static const Color ink4 = Color(0xFF8E93BA); // Placeholders
  static const Color ink5 = Color(0xFFC4C7DE);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF2F1F9);
  static const Color surface1 = Color(0xFFF8F7FF); 
  static const Color surface2 = Color(0xFFF1F0FA);
  static const Color surface3 = Color(0xFFE8E7F5);
  static const Color border = Color(0xFFE0DFF4);
  static const Color card = Colors.white;

  // Role Based Gradients
  static const LinearGradient adminGradient = LinearGradient(
    colors: [admin, adminLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cobradorGradient = LinearGradient(
    colors: [cobrador, cobradorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient asesorGradient = LinearGradient(
    colors: [asesor, asesorLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
