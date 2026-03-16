import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get heroAmount => GoogleFonts.fraunces(
        fontSize: 42,
        fontWeight: FontWeight.w600,
        letterSpacing: -2,
        height: 1,
        color: Colors.white,
      );

  static TextStyle get fountMedium => GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      );

  static TextStyle get headingPrincipal => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      );

  static TextStyle get cardTitle => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.ink2,
      );

  static TextStyle get subtext => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.ink3,
      );

  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.ink4,
      );

  static TextStyle get monospace => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );
}
