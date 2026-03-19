import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/custom_button.dart';
import '../../../core/providers/auth_provider.dart';
import 'admin_prestamos_view.dart';
import 'admin_pagos_view.dart';
import 'admin_equipo_view.dart';
import 'admin_reportes_view.dart';

import 'admin_modalidades_view.dart';
import 'admin_prestamistas_view.dart';

class AdminSettingsView extends ConsumerWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mi Perfil', style: AppTypography.headingPrincipal),
            const SizedBox(height: 24),
            
            // Perfil Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                   CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.admin.withValues(alpha: 0.1),
                    child: const Icon(Icons.person_rounded, size: 30, color: AppColors.admin),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nombre ?? 'Administrador',
                          style: AppTypography.headingPrincipal.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.usuario ?? '@admin',
                          style: const TextStyle(color: AppColors.ink3, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Expanded(
              child: ListView(
                children: [
                  _buildActionCard(
                    icon: Icons.monetization_on_outlined,
                    label: 'Préstamos',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPrestamosView()));
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.payments_outlined,
                    label: 'Pagos',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPagosView()));
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.calculate_outlined,
                    label: 'Modalidades',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminModalidadesView()));
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.handshake_outlined,
                    label: 'Prestamistas',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPrestamistasView()));
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.groups_outlined,
                    label: 'Equipo',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEquipoView()));
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.fact_check_outlined,
                    label: 'Auditoría',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReportesView()));
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Logout
                  CustomButton(
                    type: ButtonType.secondary,
                    text: 'Cerrar Sesión',
                    icon: Icons.logout,
                    onPressed: () {
                       ref.read(authProvider.notifier).logout();
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.ink2, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink, fontSize: 15))),
            const Icon(Icons.chevron_right, color: AppColors.ink4),
          ],
        ),
      ),
    );
  }
}
