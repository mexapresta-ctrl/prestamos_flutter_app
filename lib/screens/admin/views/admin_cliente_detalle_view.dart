import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/models/cliente_model.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../widgets/list_card.dart';
import '../../../widgets/hero_card.dart' show Role;

class AdminClienteDetalleView extends ConsumerWidget {
  final ClienteModel cliente;

  const AdminClienteDetalleView({super.key, required this.cliente});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final formatDate = DateFormat('dd/MM/yyyy HH:mm');
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detalle del Cliente', style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: adminState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (data) {
          // Filtrar préstamos de este cliente
          final prestamosDelCliente = data.prestamos.where((p) => p.clienteId == cliente.id).toList();
          
          // Obtener los IDs de los préstamos
          final prestamosIds = prestamosDelCliente.map((p) => p.id).toSet();
          
          // Filtrar los cobros aplicados a esos préstamos
          final cobrosDelCliente = data.cobros.where((c) => prestamosIds.contains(c.prestamoId)).toList();
          
          // Calcular sumatorias
          double totalPrestado = 0;
          for (var p in prestamosDelCliente) {
             totalPrestado += p.cuotaSemanal * p.cuotasTotales;
          }
          
          double totalAbonado = 0;
          for (var c in cobrosDelCliente) {
             totalAbonado += c.monto;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de información del cliente
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.surface1,
                            child: Icon(Icons.person, color: AppColors.admin),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cliente.nombre, style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
                                Text(cliente.telefono != null && cliente.telefono!.isNotEmpty ? 'Tel: ${cliente.telefono}' : 'Tel: No registrado', style: const TextStyle(color: AppColors.ink3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniStat('Préstamos Totales', '${prestamosDelCliente.length}'),
                          _buildMiniStat('Total Acumulado', formatCurrency.format(totalPrestado)),
                          _buildMiniStat('Total Abonado', formatCurrency.format(totalAbonado)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                Text('Historial de Préstamos', style: AppTypography.headingPrincipal.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                
                if (prestamosDelCliente.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No hay préstamos para este cliente.', style: TextStyle(color: AppColors.ink3))),
                  )
                else
                  ...prestamosDelCliente.map((p) => ListCard(
                    role: Role.admin,
                    title: 'Crédito ${p.codigo ?? p.id.substring(0, 8)}',
                    subtitle: '${p.cuotasTotales} cuotas de ${formatCurrency.format(p.cuotaSemanal)}',
                    amount: formatCurrency.format(p.cuotaSemanal * p.cuotasTotales),
                    badge: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: p.estado == 'activo' ? AppColors.ok.withValues(alpha: 0.1) : AppColors.warn.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p.estado.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: p.estado == 'activo' ? AppColors.ok : AppColors.warn,
                        ),
                      ),
                    ),
                    icon: Icon(p.estado == 'activo' ? Icons.credit_card : Icons.task_alt, color: p.estado == 'activo' ? AppColors.admin : AppColors.ok),
                  )),
                  
                const SizedBox(height: 32),
                Text('Historial de Pagos', style: AppTypography.headingPrincipal.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                
                if (cobrosDelCliente.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No hay pagos registrados.', style: TextStyle(color: AppColors.ink3))),
                  )
                else
                  ...cobrosDelCliente.map((c) => ListCard(
                    role: Role.admin,
                    title: 'Abono ${formatCurrency.format(c.monto)}',
                    subtitle: c.fechaCobro != null ? formatDate.format(DateTime.parse(c.fechaCobro!)) : 'Sin fecha',
                    amount: '+${formatCurrency.format(c.monto)}',
                    badge: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.ok.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Completado', style: TextStyle(fontSize: 10, color: AppColors.ok)),
                    ),
                    icon: const Icon(Icons.attach_money, color: AppColors.ok),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.ink4)),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.label.copyWith(fontSize: 14)),
      ],
    );
  }
}
