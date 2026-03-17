import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../core/models/prestamo_model.dart';
import '../../../widgets/list_card.dart';
import '../../../widgets/hero_card.dart' show Role;
import 'admin_cliente_detalle_view.dart';

class AdminPrestamoDetalleView extends ConsumerWidget {
  final PrestamoModel prestamo;
  const AdminPrestamoDetalleView({super.key, required this.prestamo});

  Color _statusColor(String estado) {
    switch (estado) {
      case 'activo':
        return AppColors.ok;
      case 'vencido':
        return AppColors.warn;
      case 'solicitado':
        return AppColors.asesor;
      default:
        return AppColors.ink4;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final formatDate = DateFormat('dd/MM/yyyy HH:mm');
    final statusColor = _statusColor(prestamo.estado);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Detalle del Préstamo', style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: adminState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (data) {
          final cliente = data.clientes.where((c) => c.id == prestamo.clienteId).firstOrNull;
          final cobrador = data.cobradores.where((c) => c['id'].toString() == prestamo.cobradorId).firstOrNull;
          final cobrosDelPrestamo = data.cobros.where((c) => c.prestamoId == prestamo.id).toList()
            ..sort((a, b) => (b.fechaCobro ?? '').compareTo(a.fechaCobro ?? ''));

          final totalAbonado = cobrosDelPrestamo.fold(0.0, (sum, c) => sum + c.monto);
          final totalDeuda = prestamo.cuotaSemanal * prestamo.cuotasTotales;
          final progreso = totalDeuda > 0 ? (totalAbonado / totalDeuda).clamp(0.0, 1.0) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info Card ──
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Crédito ${prestamo.codigo ?? prestamo.id.substring(0, 8)}',
                                  style: AppTypography.headingPrincipal.copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    prestamo.estado.toUpperCase(),
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatCurrency.format(prestamo.monto),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: statusColor),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildInfoRow('Cliente', cliente?.nombre ?? 'Desconocido'),
                      _buildInfoRow('Cobrador', cobrador?['nombre'] ?? 'Sin asignar'),
                      _buildInfoRow('Cuota Semanal', formatCurrency.format(prestamo.cuotaSemanal)),
                      _buildInfoRow('Cuotas', '${prestamo.cuotasPagadas} / ${prestamo.cuotasTotales}'),
                      _buildInfoRow('Total Deuda', formatCurrency.format(totalDeuda)),
                      _buildInfoRow('Total Abonado', formatCurrency.format(totalAbonado)),
                      _buildInfoRow('Creado', DateFormat('dd/MM/yyyy').format(prestamo.createdAt)),
                      const SizedBox(height: 16),

                      // Progress bar
                      Text('Progreso de Pago', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink3)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progreso,
                          backgroundColor: AppColors.border,
                          color: AppColors.ok,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('${(progreso * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ok, fontSize: 13)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Action Buttons ──
                Row(
                  children: [
                    if (cliente != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminClienteDetalleView(cliente: cliente)));
                          },
                          icon: const Icon(Icons.person, size: 18),
                          label: const Text('Ver Cliente'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.admin,
                            side: const BorderSide(color: AppColors.admin),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // ── Cobros List ──
                Text('Historial de Pagos', style: AppTypography.headingPrincipal.copyWith(fontSize: 16)),
                const SizedBox(height: 16),

                if (cobrosDelPrestamo.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No hay pagos registrados.', style: TextStyle(color: AppColors.ink3))),
                  )
                else
                  ...cobrosDelPrestamo.map((c) => ListCard(
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
                      child: const Text('Pagado', style: TextStyle(fontSize: 10, color: AppColors.ok, fontWeight: FontWeight.bold)),
                    ),
                    icon: const Icon(Icons.check_circle, color: AppColors.ok, size: 22),
                  )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.ink3, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
        ],
      ),
    );
  }
}
