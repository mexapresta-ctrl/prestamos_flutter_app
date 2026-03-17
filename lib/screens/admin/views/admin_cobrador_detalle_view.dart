import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../widgets/list_card.dart';
import '../../../widgets/hero_card.dart' show Role;

class AdminCobradorDetalleView extends ConsumerWidget {
  final Map<String, dynamic> cobrador;
  const AdminCobradorDetalleView({super.key, required this.cobrador});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final formatDate = DateFormat('dd/MM/yyyy HH:mm');
    final cobradorId = cobrador['id'].toString();
    final nombre = cobrador['nombre'] ?? 'Cobrador';
    final iniciales = cobrador['iniciales'] ?? nombre.substring(0, 2).toUpperCase();
    final hoy = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(nombre, style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: adminState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (data) {
          final prestamosAsignados = data.prestamos.where((p) => p.cobradorId == cobradorId && p.estado == 'activo').toList();
          final clienteIds = prestamosAsignados.map((p) => p.clienteId).toSet();
          final totalClientes = clienteIds.length;

          final cobrosHoy = data.cobros.where((c) => c.cobradorId == cobradorId && c.fechaCobro != null && c.fechaCobro!.startsWith(hoy)).toList();
          final monteCobradoHoy = cobrosHoy.fold(0.0, (sum, c) => sum + c.monto);
          final clientesCobradosHoy = cobrosHoy.map((c) => c.clienteId).toSet().length;

          final todosLosCobros = data.cobros.where((c) => c.cobradorId == cobradorId).toList()
            ..sort((a, b) => (b.fechaCobro ?? '').compareTo(a.fechaCobro ?? ''));

          final porcentaje = totalClientes > 0 ? (clientesCobradosHoy / totalClientes * 100) : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Profile Card ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.cobradorSurface,
                        child: Text(iniciales, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.cobrador)),
                      ),
                      const SizedBox(height: 12),
                      Text(nombre, style: AppTypography.headingPrincipal.copyWith(fontSize: 20)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.cobradorSurface,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text('Cobrador', style: TextStyle(color: AppColors.cobrador, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat('Clientes', totalClientes.toString()),
                          _buildStat('Cobrado Hoy', formatCurrency.format(monteCobradoHoy)),
                          _buildStat('Meta', '${porcentaje.toStringAsFixed(0)}%'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: porcentaje / 100,
                          backgroundColor: AppColors.border,
                          color: AppColors.ok,
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Clientes Asignados ──
                Text('Clientes Asignados ($totalClientes)', style: AppTypography.headingPrincipal.copyWith(fontSize: 16)),
                const SizedBox(height: 12),

                if (prestamosAsignados.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Sin clientes asignados.', style: TextStyle(color: AppColors.ink3))))
                else
                  ...prestamosAsignados.map((p) {
                    final clientName = data.clientes.where((c) => c.id == p.clienteId).map((c) => c.nombre).firstOrNull ?? 'Desconocido';
                    return ListCard(
                      role: Role.admin,
                      title: clientName,
                      subtitle: '${p.cuotasPagadas}/${p.cuotasTotales} cuotas · ${formatCurrency.format(p.cuotaSemanal)}/sem',
                      amount: formatCurrency.format(p.monto),
                      badge: const SizedBox(),
                      icon: const Icon(Icons.person, color: AppColors.cobrador, size: 22),
                    );
                  }),

                const SizedBox(height: 24),

                // ── Cobros Recientes ──
                Text('Cobros Recientes', style: AppTypography.headingPrincipal.copyWith(fontSize: 16)),
                const SizedBox(height: 12),

                if (todosLosCobros.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Sin cobros registrados.', style: TextStyle(color: AppColors.ink3))))
                else
                  ...todosLosCobros.take(20).map((c) {
                    final clientName = data.clientes.where((cl) => cl.id == c.clienteId).map((cl) => cl.nombre).firstOrNull ?? 'Cliente';
                    return ListCard(
                      role: Role.admin,
                      title: clientName,
                      subtitle: c.fechaCobro != null ? formatDate.format(DateTime.parse(c.fechaCobro!)) : 'Sin fecha',
                      amount: '+${formatCurrency.format(c.monto)}',
                      badge: const SizedBox(),
                      icon: const Icon(Icons.payments, color: AppColors.ok, size: 22),
                    );
                  }),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.ink)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.ink4)),
      ],
    );
  }
}
