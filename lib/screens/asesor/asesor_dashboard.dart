import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/asesor_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/list_card.dart';
import '../../core/models/cliente_model.dart';

class AsesorDashboard extends ConsumerStatefulWidget {
  const AsesorDashboard({super.key});

  @override
  ConsumerState<AsesorDashboard> createState() => _AsesorDashboardState();
}

class _AsesorDashboardState extends ConsumerState<AsesorDashboard> {
  final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final asesorState = ref.watch(asesorProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.asesor,
          onRefresh: () => ref.read(asesorProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, \${user?.nombre?.split(" ")[0] ?? "Asesor"}',
                              style: AppTypography.headingPrincipal,
                            ),
                            Text(
                              'Panel de Asesor',
                              style: AppTypography.label.copyWith(color: AppColors.ink3),
                            ),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.asesor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.logout, color: AppColors.asesor),
                            onPressed: () => ref.read(authProvider.notifier).logout(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // State Handling
                    asesorState.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: AppColors.asesor),
                        ),
                      ),
                      error: (err, stack) => Center(
                        child: Text(
                          'Error: $err',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                      data: (data) => _buildDashboardContent(data),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(AsesorDashboardData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Card (KPI Principal)
        HeroCard(
          role: Role.asesor,
          label: 'Monto Colocado',
          amount: formatCurrency.format(data.montoColocado),
          tags: const ['Créditos aprobados'],
        ),
        const SizedBox(height: 24),

        // Stats Row
        Row(
          children: [
            Expanded(
              child: StatCard(
                role: Role.asesor,
                label: 'Clientes Activos',
                value: '\${data.clientesActivos}',
                trendText: 'Vinculados',
                isUp: true,
                icon: const Icon(Icons.people, color: AppColors.asesor),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                role: Role.asesor,
                label: 'Aprobados',
                value: '\${data.prestamosAprobados}',
                trendText: '\${data.prestamosPendientes} pendientes',
                isUp: true,
                icon: const Icon(Icons.check_circle_outline, color: AppColors.ok),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

          // List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trámites Recientes',
                style: AppTypography.headingPrincipal.copyWith(fontSize: 18),
              ),
              Text(
              'Ver Todos',
              style: AppTypography.label.copyWith(color: AppColors.asesor),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of Prestamos Tramitados
        if (data.misPrestamosTramitados.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No has tramitado préstamos aún.',
                style: TextStyle(color: AppColors.ink3),
              ),
            ),
          )
        else
          ...data.misPrestamosTramitados.map((prestamo) {
            // Find client name
            final cliente = data.clientes.firstWhere(
              (c) => c.id == prestamo.clienteId,
              orElse: () => ClienteModel(id: '', nombre: 'Desconocido'),
            );

            IconData statusIcon = Icons.schedule;
            Color statusColor = AppColors.warn;
            
            if (prestamo.estado == 'activo') {
              statusIcon = Icons.check_circle;
              statusColor = AppColors.ok;
            } else if (prestamo.estado == 'rechazado') {
              statusIcon = Icons.error;
              statusColor = AppColors.error;
            }

            return ListCard(
              role: Role.asesor,
              title: cliente.nombre,
              subtitle: 'Préstamo: \${prestamo.codigo ?? "S/N"} • \${prestamo.cuotasTotales} semanas',
              amount: formatCurrency.format(prestamo.monto),
              badge: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  prestamo.estado.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
              icon: Icon(statusIcon, color: statusColor),
            );
          }),
      ],
    );
  }
}
