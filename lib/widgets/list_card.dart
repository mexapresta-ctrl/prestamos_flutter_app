import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'hero_card.dart' show Role;

class ListCard extends StatelessWidget {
  final Role role;
  final String title;
  final String subtitle;
  final String amount;
  final Widget badge;
  final Widget icon;

  const ListCard({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.badge,
    required this.icon,
  });

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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D090B1C), // 0.05 opacity
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -14, // To account for horizontal padding
            top: -12, // To account for vertical padding
            bottom: -12,
            child: Container(
              width: 3,
              color: _primaryColor,
            ),
          ),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.cardTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.subtext.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: AppTypography.monospace.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  badge,
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
