import 'package:flutter/material.dart';
import '../theme/app_typography.dart';

enum Role { admin, cobrador, asesor }

class HeroCard extends StatelessWidget {
  final Role role;
  final String label;
  final String amount;
  final List<String> tags;

  const HeroCard({
    super.key,
    required this.role,
    required this.label,
    required this.amount,
    required this.tags,
  });

  LinearGradient get _gradient {
    switch (role) {
      case Role.admin:
        return const LinearGradient(
          colors: [Color(0xFF1A2AD8), Color(0xFF3447E8), Color(0xFF5B3AFF)],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Role.cobrador:
        return const LinearGradient(
          colors: [Color(0xFF065C44), Color(0xFF0A7C5C), Color(0xFF0AA88A)],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case Role.asesor:
        return const LinearGradient(
          colors: [Color(0xFF8A2C00), Color(0xFFC44C0A), Color(0xFFE86820)],
          stops: [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: _gradient,
      ),
      child: Stack(
        children: [
          // Background decorations could be added here
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.3),
                    margin: const EdgeInsets.only(right: 6),
                  ),
                  Text(
                    label.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$',
                    style: AppTypography.heroAmount.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  Text(
                    amount,
                    style: AppTypography.heroAmount,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags.map((tag) => _buildTag(tag)).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
