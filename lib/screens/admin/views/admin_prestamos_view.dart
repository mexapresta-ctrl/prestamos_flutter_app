import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/admin_provider.dart';

import '../../../widgets/list_card.dart';
import '../../../widgets/hero_card.dart' show Role;
import 'admin_prestamo_detalle_view.dart';

class AdminPrestamosView extends ConsumerStatefulWidget {
  final String initialFilter;
  const AdminPrestamosView({super.key, this.initialFilter = 'todos'});

  @override
  ConsumerState<AdminPrestamosView> createState() => _AdminPrestamosViewState();
}

class _AdminPrestamosViewState extends ConsumerState<AdminPrestamosView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = const ['Todos', 'Activos', 'Vencidos', 'Solicitados'];
  final _filters = const ['todos', 'activo', 'vencido', 'solicitado'];

  @override
  void initState() {
    super.initState();
    final initialIndex = _filters.indexOf(widget.initialFilter);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(String estado) {
    switch (estado) {
      case 'activo':
        return AppColors.ok;
      case 'vencido':
        return AppColors.warn;
      case 'solicitado':
        return AppColors.asesor;
      case 'liquidado':
        return AppColors.ink3;
      default:
        return AppColors.ink4;
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Préstamos', style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.admin,
          unselectedLabelColor: AppColors.ink4,
          indicatorColor: AppColors.admin,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: adminState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (data) {
          return TabBarView(
            controller: _tabController,
            children: _filters.map((filter) {
              final prestamos = filter == 'todos'
                  ? data.prestamos
                  : data.prestamos.where((p) => p.estado == filter).toList();

              if (prestamos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_off_rounded, size: 48, color: AppColors.ink4.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text('No hay préstamos ${filter == 'todos' ? '' : filter}s', style: const TextStyle(color: AppColors.ink3)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: prestamos.length,
                itemBuilder: (context, index) {
                  final p = prestamos[index];
                  // Find client name
                  final clientName = data.clientes
                      .where((c) => c.id == p.clienteId)
                      .map((c) => c.nombre)
                      .firstOrNull ?? 'Cliente desconocido';

                  final statusColor = _statusColor(p.estado);

                  return ListCard(
                    role: Role.admin,
                    title: clientName,
                    subtitle: '${p.cuotasPagadas}/${p.cuotasTotales} cuotas · ${formatCurrency.format(p.cuotaSemanal)}/sem',
                    amount: formatCurrency.format(p.monto),
                    badge: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        p.estado.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                    icon: Icon(
                      p.estado == 'activo' ? Icons.credit_card : p.estado == 'vencido' ? Icons.warning_rounded : Icons.hourglass_empty,
                      color: statusColor,
                      size: 22,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminPrestamoDetalleView(prestamo: p)),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
