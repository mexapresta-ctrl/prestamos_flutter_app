import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/custom_button.dart';
import '../../../core/providers/auth_provider.dart';

class AdminSettingsView extends ConsumerWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configuración', style: AppTypography.headingPrincipal),
            const SizedBox(height: 32),
            
            // Perfil
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.admin.withOpacity(0.1),
                    child: const Icon(Icons.admin_panel_settings, size: 50, color: AppColors.admin),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.user?.nombre ?? 'Administrador',
                    style: AppTypography.headingPrincipal.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.user?.rol.toUpperCase() ?? 'ADMIN',
                    style: const TextStyle(color: AppColors.ink3),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            Text('Opciones de la Cuenta', style: AppTypography.headingPrincipal.copyWith(fontSize: 16)),
            const SizedBox(height: 16),
            
            _buildActionCard(
              icon: Icons.person_outline,
              label: 'Editar Perfil',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente')));
              },
            ),
            _buildActionCard(
              icon: Icons.lock_outline,
              label: 'Cambiar Contraseña',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Próximamente')));
              },
            ),
            _buildActionCard(
              icon: Icons.cloud_download_outlined,
              label: 'Buscar Actualizaciones',
              onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comprobando actualizaciones...')));
              },
            ),
            
            const Spacer(),
            
            // Logout
            CustomButton(
              type: ButtonType.secondary,
              text: 'Cerrar Sesión',
              icon: Icons.logout,
              onPressed: () {
                 ref.read(authProvider.notifier).logout();
              },
            ),
            const SizedBox(height: 20),
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
            Icon(icon, color: AppColors.ink2, size: 24),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink))),
            const Icon(Icons.chevron_right, color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}
