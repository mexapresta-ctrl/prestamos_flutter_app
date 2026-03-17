import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../widgets/list_card.dart';
import '../../../widgets/role_chip.dart';
import '../../../widgets/hero_card.dart' show Role;
import 'admin_cobrador_detalle_view.dart';

class AdminEquipoView extends ConsumerWidget {
  const AdminEquipoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Equipo', style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: adminState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (data) {
          final allUsers = [...data.cobradores, ...data.asesores];

          if (allUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups_outlined, size: 48, color: AppColors.ink4.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('No hay miembros del equipo', style: TextStyle(color: AppColors.ink3)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              final u = allUsers[index];
              final nombre = u['nombre'] ?? 'Sin nombre';
              final rol = u['rol'] ?? 'cobrador';
              final isCobrador = rol == 'cobrador';

              return ListCard(
                role: Role.admin,
                title: nombre,
                subtitle: '@${u['usuario'] ?? ''}',
                amount: '',
                badge: RoleChip(
                  role: isCobrador ? Role.cobrador : Role.asesor,
                  text: isCobrador ? 'Cobrador' : 'Asesor',
                  icon: isCobrador ? Icons.directions_run : Icons.support_agent,
                ),
                icon: Icon(
                  isCobrador ? Icons.directions_run_rounded : Icons.support_agent_rounded,
                  color: isCobrador ? AppColors.cobrador : AppColors.asesor,
                  size: 22,
                ),
                onTap: isCobrador
                    ? () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminCobradorDetalleView(cobrador: u)));
                      }
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
