import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonType { admin, cobrador, asesor, ok, error, secondary }

class CustomButton extends StatelessWidget {
  final ButtonType type;
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.type,
    required this.text,
    this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor;
    Gradient? gradient;
    Color? backgroundColor;
    BoxBorder? border;
    List<BoxShadow>? shadows;

    switch (type) {
      case ButtonType.admin:
        gradient = AppColors.adminGradient;
        textColor = Colors.white;
        shadows = [
          const BoxShadow(
            color: Color(0x523447E8), // opacity 0.32
            blurRadius: 14,
            offset: Offset(0, 4),
          )
        ];
        break;
      case ButtonType.cobrador:
        gradient = AppColors.cobradorGradient;
        textColor = Colors.white;
        shadows = [
          const BoxShadow(
            color: Color(0x520A7C5C),
            blurRadius: 14,
            offset: Offset(0, 4),
          )
        ];
        break;
      case ButtonType.asesor:
        gradient = AppColors.asesorGradient;
        textColor = Colors.white;
        shadows = [
          const BoxShadow(
            color: Color(0x52C44C0A),
            blurRadius: 14,
            offset: Offset(0, 4),
          )
        ];
        break;
      case ButtonType.ok:
        gradient = const LinearGradient(
          colors: [AppColors.ok, Color(0xFF1BB880)],
        );
        textColor = Colors.white;
        shadows = [
          const BoxShadow(
            color: Color(0x520A7050),
            blurRadius: 14,
            offset: Offset(0, 4),
          )
        ];
        break;
      case ButtonType.error:
        gradient = const LinearGradient(
          colors: [AppColors.error, Color(0xFFE85060)],
        );
        textColor = Colors.white;
        shadows = [
          const BoxShadow(
            color: Color(0x52B82428),
            blurRadius: 14,
            offset: Offset(0, 4),
          )
        ];
        break;
      case ButtonType.secondary:
        backgroundColor = AppColors.surface1;
        border = Border.all(color: AppColors.border, width: 1.5);
        textColor = AppColors.ink2;
        break;
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: border,
          boxShadow: shadows,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
