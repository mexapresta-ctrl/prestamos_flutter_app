import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../widgets/list_card.dart';
import '../../../widgets/hero_card.dart' show Role;

class AdminPagosView extends ConsumerStatefulWidget {
  const AdminPagosView({super.key});

  @override
  ConsumerState<AdminPagosView> createState() => _AdminPagosViewState();
}

class _AdminPagosViewState extends ConsumerState<AdminPagosView> {
  int _selectedFilter = 0;
  final _filterLabels = const ['Hoy', 'Semana', 'Mes', 'Todos'];

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final formatDate = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pagos', style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: adminState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (data) {
          final now = DateTime.now();
          final hoy = now.toIso8601String().substring(0, 10);
          final inicioSemana = now.subtract(Duration(days: now.weekday - 1));
          final inicioMes = DateTime(now.year, now.month, 1);

          var cobros = data.cobros.toList()
            ..sort((a, b) => (b.fechaCobro ?? '').compareTo(a.fechaCobro ?? ''));

          // Apply filter
          if (_selectedFilter == 0) {
            cobros = cobros.where((c) => c.fechaCobro != null && c.fechaCobro!.startsWith(hoy)).toList();
          } else if (_selectedFilter == 1) {
            cobros = cobros.where((c) {
              if (c.fechaCobro == null) return false;
              final f = DateTime.tryParse(c.fechaCobro!);
              return f != null && f.isAfter(inicioSemana.subtract(const Duration(days: 1)));
            }).toList();
          } else if (_selectedFilter == 2) {
            cobros = cobros.where((c) {
              if (c.fechaCobro == null) return false;
              final f = DateTime.tryParse(c.fechaCobro!);
              return f != null && f.isAfter(inicioMes.subtract(const Duration(days: 1)));
            }).toList();
          }

          final totalFiltered = cobros.fold(0.0, (sum, c) => sum + c.monto);

          return Column(
            children: [
              // Filter chips
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: List.generate(_filterLabels.length, (i) {
                    final isActive = _selectedFilter == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_filterLabels[i]),
                        selected: isActive,
                        onSelected: (_) => setState(() => _selectedFilter = i),
                        selectedColor: AppColors.admin,
                        labelStyle: TextStyle(
                          color: isActive ? Colors.white : AppColors.ink3,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: isActive ? AppColors.admin : AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                    );
                  }),
                ),
              ),

              // Total
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${cobros.length} pagos', style: const TextStyle(color: AppColors.ink3, fontSize: 13)),
                    Text('Total: ${formatCurrency.format(totalFiltered)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ok, fontSize: 14)),
                  ],
                ),
              ),

              // List
              Expanded(
                child: cobros.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payments_outlined, size: 48, color: AppColors.ink4.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text('Sin cobros en este periodo', style: TextStyle(color: AppColors.ink3)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        itemCount: cobros.length,
                        itemBuilder: (context, index) {
                          final c = cobros[index];
                          final clientName = data.clientes.where((cl) => cl.id == c.clienteId).map((cl) => cl.nombre).firstOrNull ?? 'Cliente';
                          final cobradorName = data.cobradores.where((cb) => cb['id'].toString() == c.cobradorId).map((cb) => cb['nombre']).firstOrNull ?? '';

                          return ListCard(
                            role: Role.admin,
                            title: clientName,
                            subtitle: '${c.fechaCobro != null ? formatDate.format(DateTime.parse(c.fechaCobro!)) : 'Sin fecha'}${cobradorName.isNotEmpty ? ' · $cobradorName' : ''}',
                            amount: '+${formatCurrency.format(c.monto)}',
                            badge: const SizedBox(),
                            icon: const Icon(Icons.check_circle, color: AppColors.ok, size: 22),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
