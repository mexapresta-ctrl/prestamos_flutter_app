import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/list_card.dart';
import '../../widgets/role_chip.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

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
                        'Dashboard',
                        style: AppTypography.headingPrincipal,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bienvenido, Carlos M.',
                        style: AppTypography.subtext,
                      ),
                    ],
                  ),
                  const RoleChip(
                    role: Role.admin,
                    text: 'Admin',
                    icon: Icons.shield_rounded, // fallback icon
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hero
              const HeroCard(
                role: Role.admin,
                label: 'Cartera Total',
                amount: '847,320',
                tags: ['+12.4%', '142 créditos'],
              ),
              const SizedBox(height: 24),

              // Stats Grid
              const Row(
                children: [
                  Expanded(
                    child: StatCard(
                      role: Role.admin,
                      label: 'Desembolsos hoy',
                      value: '\$23,500',
                      trendText: '+8 vs ayer',
                      isUp: true,
                      icon: Icon(Icons.account_balance_wallet, color: AppColors.admin, size: 20),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      role: Role.admin,
                      label: 'Nuevos Clientes',
                      value: '14',
                      trendText: '+2 vs ayer',
                      isUp: true,
                      icon: Icon(Icons.people, color: AppColors.admin, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Activity or Audit Log
              Text(
                'Actividad Reciente',
                style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.ink),
              ),
              const SizedBox(height: 16),

              // Placeholder for ListCards (Audit Log representation)
              ListCard(
                role: Role.admin,
                title: 'Desembolso aprobado',
                subtitle: 'Asesor: María L. · Cliente: J. Rodríguez',
                amount: '\$5,000',
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.okSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('OK', style: TextStyle(color: AppColors.ok, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                icon: const Icon(Icons.check_circle, color: AppColors.ok, size: 22),
              ),
              ListCard(
                role: Role.admin,
                title: 'Crédito en mora',
                subtitle: 'Cobrador: A. García · 3 días vencido',
                amount: '#1055',
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warnSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Aviso', style: TextStyle(color: AppColors.warn, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                icon: const Icon(Icons.warning, color: AppColors.warn, size: 22),
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
          _buildNavItem(icon: Icons.bar_chart, label: 'Reportes', isActive: false),
          // FAB placeholder
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: AppColors.adminGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x663447E8),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          _buildNavItem(icon: Icons.people, label: 'Usuarios', isActive: false),
          _buildNavItem(icon: Icons.settings, label: 'Config', isActive: false),
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
            color: isActive ? AppColors.adminSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.admin : AppColors.ink4,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.admin : AppColors.ink4,
          ),
        ),
      ],
    );
  }
}
