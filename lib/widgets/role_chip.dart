import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'hero_card.dart' show Role;

class RoleChip extends StatelessWidget {
  final Role role;
  final String text;
  final IconData icon;

  const RoleChip({
    super.key,
    required this.role,
    required this.text,
    required this.icon,
  });

  Gradient get _gradient {
    switch (role) {
      case Role.admin:
        return AppColors.adminGradient;
      case Role.cobrador:
        return AppColors.cobradorGradient;
      case Role.asesor:
        return AppColors.asesorGradient;
    }
  }

  List<BoxShadow> get _shadows {
    switch (role) {
      case Role.admin:
        return const [
          BoxShadow(
            color: Color(0x4D3447E8), // 0.3 opacity
            blurRadius: 10,
            offset: Offset(0, 3),
          )
        ];
      case Role.cobrador:
        return const [
          BoxShadow(
            color: Color(0x4D0A7C5C),
            blurRadius: 10,
            offset: Offset(0, 3),
          )
        ];
      case Role.asesor:
        return const [
          BoxShadow(
            color: Color(0x4DC44C0A),
            blurRadius: 10,
            offset: Offset(0, 3),
          )
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(99),
        boxShadow: _shadows,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 9),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
