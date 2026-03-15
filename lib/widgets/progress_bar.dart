import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'hero_card.dart' show Role;

class ProgressBar extends StatelessWidget {
  final Role role;
  final String label;
  final double percentage; // 0.0 to 1.0
  final String subtext;

  const ProgressBar({
    Key? key,
    required this.role,
    required this.label,
    required this.percentage,
    required this.subtext,
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

  LinearGradient get _gradient {
    switch (role) {
      case Role.admin:
        return AppColors.adminGradient;
      case Role.cobrador:
        return AppColors.cobradorGradient;
      case Role.asesor:
        return AppColors.asesorGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F090B1C),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: AppTypography.monospace.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surface3,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (percentage * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _gradient,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - (percentage * 100).toInt(),
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.ink4,
            ),
          ),
        ],
      ),
    );
  }
}
