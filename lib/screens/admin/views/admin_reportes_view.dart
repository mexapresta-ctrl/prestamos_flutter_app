import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/stat_card.dart';
import '../../../widgets/hero_card.dart' show Role;
import '../../../core/providers/admin_provider.dart';

class AdminReportesView extends ConsumerWidget {
  const AdminReportesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reportes Financieros', style: AppTypography.headingPrincipal),
            const SizedBox(height: 24),
            
            Expanded(
              child: adminState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
                data: (data) {
                  return ListView(
                    children: [
                      Text('Resumen de Cartera', style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              role: Role.admin,
                              label: 'Cartera Total',
                              value: formatCurrency.format(data.carteraTotal),
                              trendText: 'Este mes',
                              isUp: true,
                              icon: const Icon(Icons.account_balance_wallet, color: AppColors.admin),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              role: Role.admin,
                              label: 'Créditos Activos',
                              value: '${data.prestamos.where((p) => p.estado == "activo").length}',
                              trendText: 'Estables',
                              isUp: true,
                              icon: const Icon(Icons.credit_card, color: AppColors.ok),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              role: Role.admin,
                              label: 'En Mora',
                              value: '${data.enMora}',
                              trendText: 'Atención',
                              isUp: false,
                              icon: const Icon(Icons.warning, color: AppColors.warn),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatCard(
                              role: Role.admin,
                              label: 'Cobrado Hoy',
                              value: formatCurrency.format(data.cobradoHoy),
                              trendText: 'Hoy',
                              isUp: true,
                              icon: const Icon(Icons.payments, color: AppColors.cobrador),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      Text('Estadísticas Visuales', style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
                      const SizedBox(height: 16),
                      _buildStatRow('Clientes Registrados', '${data.clientes.length}', Icons.people),
                      _buildStatRow('Cobradores Activos', '${data.cobradores.length}', Icons.directions_run),
                      _buildStatRow('Préstamos Entregados', '${data.prestamos.length}', Icons.folder_shared),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Container(
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
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.ink3, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.admin)),
        ],
      ),
    );
  }
}
