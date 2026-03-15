import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'hero_card.dart' show Role;

class StatCard extends StatelessWidget {
  final Role role;
  final String label;
  final String value;
  final String trendText;
  final bool isUp;
  final Widget icon;

  const StatCard({
    Key? key,
    required this.role,
    required this.label,
    required this.value,
    required this.trendText,
    required this.isUp,
    required this.icon,
  }) : super(key: key);

  Color get _primaryColor {
    switch (role) {
      case Role.admin:
        return AppColors.admin;
      case Role.cobrador:
        return AppColors.cobrador;
      case Role.asesor:
        return AppColors.asesor;
    }
  }

  Color get _lightColor {
    switch (role) {
      case Role.admin:
        return AppColors.adminLight;
      case Role.cobrador:
        return AppColors.cobradorLight;
      case Role.asesor:
        return AppColors.asesorLight;
    }
  }

  Color get _surfaceColor {
    switch (role) {
      case Role.admin:
        return AppColors.adminSurface;
      case Role.cobrador:
        return AppColors.cobradorSurface;
      case Role.asesor:
        return AppColors.asesorSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F090B1C), // 0.06 opacity
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 2.5,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [_primaryColor, _lightColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 9),
          Text(
            label.toUpperCase(),
            style: AppTypography.label.copyWith(
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTypography.fountMedium.copyWith(
              color: AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${isUp ? '▲' : '▼'} $trendText',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isUp ? AppColors.ok : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
