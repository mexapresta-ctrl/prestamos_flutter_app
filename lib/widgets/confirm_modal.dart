import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'custom_button.dart';

class ConfirmModal extends StatelessWidget {
  final Future<void> Function() onConfirm;
  final VoidCallback onCancel;
  final String title;
  final String subtitle;
  final Widget icon;
  final LinearGradient topBarGradient;
  final Color iconBackgroundColor;
  final List<Widget> details;
  final Widget? customBody;
  final String confirmText;
  final String cancelText;
  final ButtonType confirmButtonType;

  const ConfirmModal({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.topBarGradient,
    required this.iconBackgroundColor,
    required this.details,
    this.customBody,
    this.confirmText = '✓ Confirmar',
    this.cancelText = 'Cancelar',
    this.confirmButtonType = ButtonType.admin,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1C090B1C), // 0.11 opacity
              blurRadius: 44,
              offset: Offset(0, 14),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Container(
              height: 3,
              decoration: BoxDecoration(gradient: topBarGradient),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(child: icon),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.ink3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Warning Note (Optional, can be parameterized)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warnSurface,
                      border: Border.all(color: const Color(0x269A5500)), // rgba(154,85,0,.15)
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('⚠️', style: TextStyle(fontSize: 13)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Esta acción queda registrada en auditoría',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.warn,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),
            // Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              child: Column(
                children: [
                  ...details,
                  if (customBody != null) ...[
                    const SizedBox(height: 16),
                    customBody!,
                  ]
                ],
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      type: ButtonType.secondary,
                      text: cancelText,
                      onPressed: onCancel,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      type: confirmButtonType,
                      text: confirmText,
                      onPressed: () async {
                        await onConfirm();
                        // Animation and success logic can be handled by caller or state
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModalRow extends StatelessWidget {
  final String keyText;
  final Widget keyIcon;
  final String valueText;
  final bool isBigValue;
  final Color? bigValueColor;

  const ModalRow({
    super.key,
    required this.keyText,
    required this.keyIcon,
    required this.valueText,
    this.isBigValue = false,
    this.bigValueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              keyIcon,
              const SizedBox(width: 7),
              Text(
                keyText,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.ink3,
                ),
              ),
            ],
          ),
          if (isBigValue)
            Text(
              valueText,
              style: AppTypography.fountMedium.copyWith(
                fontSize: 20,
                color: bigValueColor ?? AppColors.ink,
              ),
            )
          else
            Text(
              valueText,
              style: AppTypography.monospace.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
        ],
      ),
    );
  }
}
