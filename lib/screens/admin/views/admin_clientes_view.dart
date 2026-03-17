import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/list_card.dart';
import '../../../widgets/hero_card.dart' show Role;
import '../../../core/providers/admin_provider.dart';
import 'admin_cliente_detalle_view.dart';
import 'admin_cliente_create_view.dart';

class AdminClientesView extends ConsumerStatefulWidget {
  const AdminClientesView({super.key});

  @override
  ConsumerState<AdminClientesView> createState() => _AdminClientesViewState();
}

class _AdminClientesViewState extends ConsumerState<AdminClientesView> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text('Clientes', style: AppTypography.headingPrincipal),
            ),
            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _search = v.toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Buscar cliente...',
                  hintStyle: const TextStyle(color: AppColors.ink4, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppColors.ink4, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.admin, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Client list
            Expanded(
              child: adminState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
                data: (data) {
                  final filtered = data.clientes.where((c) {
                    if (_search.isEmpty) return true;
                    return c.nombre.toLowerCase().contains(_search) ||
                        (c.telefono ?? '').toLowerCase().contains(_search);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_rounded, size: 48, color: AppColors.ink4.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            _search.isEmpty ? 'No hay clientes registrados' : 'Sin resultados para "$_search"',
                            style: const TextStyle(color: AppColors.ink3, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return ListCard(
                        role: Role.admin,
                        title: c.nombre,
                        subtitle: c.telefono != null && c.telefono!.isNotEmpty
                            ? 'Tel: ${c.telefono}'
                            : 'Tel: No registrado',
                        amount: '',
                        badge: const SizedBox(),
                        icon: const Icon(Icons.person, color: AppColors.admin, size: 22),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AdminClienteDetalleView(cliente: c)),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminClienteCreateView()),
          );
        },
        backgroundColor: AppColors.admin,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
