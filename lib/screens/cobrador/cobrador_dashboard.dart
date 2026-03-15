import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/list_card.dart';
import '../../widgets/role_chip.dart';
import '../../widgets/progress_bar.dart';

class CobradorDashboard extends ConsumerWidget {
  const CobradorDashboard({super.key});

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
                        'Ruta Hoy',
                        style: AppTypography.headingPrincipal,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hola, Alejandro G.',
                        style: AppTypography.subtext,
                      ),
                    ],
                  ),
                  const RoleChip(
                    role: Role.cobrador,
                    text: 'Cobrador',
                    icon: Icons.directions_walk_rounded, 
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hero
              const HeroCard(
                role: Role.cobrador,
                label: 'Meta de Cobro',
                amount: '4,800',
                tags: ['66.7% cobrado'],
              ),
              const SizedBox(height: 16),
              
              const ProgressBar(
                role: Role.cobrador,
                label: 'Progreso del día',
                percentage: 0.667,
                subtext: '\$3,200 de \$4,800',
              ),
              const SizedBox(height: 24),

              // Stats Grid
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      role: Role.cobrador,
                      label: 'Cobros realizados',
                      value: '12',
                      trendText: '+3 vs ayer',
                      isUp: true,
                      icon: Icon(Icons.check_circle_outline, color: AppColors.cobrador, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      role: Role.cobrador,
                      label: 'Clientes pendientes',
                      value: '8',
                      trendText: 'En tiempo',
                      isUp: true,
                      icon: Icon(Icons.people_outline, color: AppColors.cobrador, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'Próximas Visitas',
                style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.ink),
              ),
              const SizedBox(height: 16),

              // Placeholder for ListCards 
              ListCard(
                role: Role.cobrador,
                title: 'Ana Torres',
                subtitle: 'Cr. #1103 · Pendiente',
                amount: '\$550',
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.infoSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Pendiente', style: TextStyle(color: AppColors.info, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                icon: Icon(Icons.person, color: AppColors.cobrador, size: 22),
              ),
              ListCard(
                role: Role.cobrador,
                title: 'Pedro Limas',
                subtitle: 'Cr. #1055 · Mora',
                amount: '\$900',
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Mora', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                icon: Icon(Icons.person, color: AppColors.cobrador, size: 22),
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
          _buildNavItem(icon: Icons.map, label: 'Mapa', isActive: false),
          // FAB placeholder
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: AppColors.cobradorGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x660A7C5C),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
          ),
          _buildNavItem(icon: Icons.route, label: 'Ruta', isActive: false),
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
            color: isActive ? AppColors.cobradorSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.cobrador : AppColors.ink4,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.cobrador : AppColors.ink4,
          ),
        ),
      ],
    );
  }
}
