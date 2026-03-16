import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/list_card.dart';
import '../../widgets/role_chip.dart';
import '../../widgets/progress_bar.dart';

class AsesorDashboard extends ConsumerWidget {
  const AsesorDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen',
                        style: AppTypography.headingPrincipal,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hola, María L.',
                        style: AppTypography.subtext,
                      ),
                    ],
                  ),
                  const RoleChip(
                    role: Role.asesor,
                    text: 'Asesor',
                    icon: Icons.star_border_rounded, 
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hero
              const HeroCard(
                role: Role.asesor,
                label: 'Cartera Propia',
                amount: '98,450',
                tags: ['34 clientes', '#1'],
              ),
              const SizedBox(height: 16),
              
              const ProgressBar(
                role: Role.asesor,
                label: 'Meta mensual',
                percentage: 0.78,
                subtext: '\$78,000 de \$100,000',
              ),
              const SizedBox(height: 24),

              // Stats Grid
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      role: Role.asesor,
                      label: 'Solicitudes Activas',
                      value: '5',
                      trendText: '+2 vs mes ant.',
                      isUp: true,
                      icon: Icon(Icons.file_copy_outlined, color: AppColors.asesor, size: 20),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      role: Role.asesor,
                      label: 'Aprobadas',
                      value: '12',
                      trendText: '90% efectividad',
                      isUp: true,
                      icon: Icon(Icons.check_circle_outline, color: AppColors.asesor, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'Clientes por Renovar',
                style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.ink),
              ),
              const SizedBox(height: 16),

              // Placeholder for ListCards 
              ListCard(
                role: Role.asesor,
                title: 'Laura Sánchez',
                subtitle: 'Cr. #1142 · Vigente',
                amount: '\$8,000',
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.okSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Al día', style: TextStyle(color: AppColors.ok, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                icon: const Icon(Icons.person, color: AppColors.asesor, size: 22),
              ),
              ListCard(
                role: Role.asesor,
                title: 'Pedro Linares',
                subtitle: 'Cr. #1088 · Vigente',
                amount: '\$5,500',
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warnSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Por vencer', style: TextStyle(color: AppColors.warn, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                icon: const Icon(Icons.person, color: AppColors.asesor, size: 22),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home, label: 'Inicio', isActive: true),
          _buildNavItem(icon: Icons.people, label: 'Clientes', isActive: false),
          // FAB placeholder
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: AppColors.asesorGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66C44C0A),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          _buildNavItem(icon: Icons.format_list_bulleted, label: 'Solicitudes', isActive: false),
          _buildNavItem(icon: Icons.person, label: 'Perfil', isActive: false),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isActive}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.asesorSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.asesor : AppColors.ink4,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.asesor : AppColors.ink4,
          ),
        ),
      ],
    );
  }
}
