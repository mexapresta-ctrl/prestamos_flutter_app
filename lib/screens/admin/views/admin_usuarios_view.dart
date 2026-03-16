import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/list_card.dart';
import '../../../widgets/role_chip.dart';
import '../../../core/providers/admin_provider.dart';
import '../../../widgets/hero_card.dart';
import 'admin_cliente_detalle_view.dart';

class AdminUsuariosView extends ConsumerStatefulWidget {
  const AdminUsuariosView({super.key});

  @override
  ConsumerState<AdminUsuariosView> createState() => _AdminUsuariosViewState();
}

class _AdminUsuariosViewState extends ConsumerState<AdminUsuariosView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text(
              'Gestión de Usuarios',
              style: AppTypography.headingPrincipal,
            ),
          ),
          const SizedBox(height: 16),
          
          // TabBar
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.admin,
            unselectedLabelColor: AppColors.ink4,
            indicatorColor: AppColors.admin,
            dividerColor: AppColors.border,
            tabs: const [
              Tab(text: 'Clientes'),
              Tab(text: 'Cobradores'),
              Tab(text: 'Asesores'),
              Tab(text: 'Prestamistas'),
            ],
          ),
          
          // Content
          Expanded(
            child: adminState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
              data: (data) => TabBarView(
                controller: _tabController,
                children: [
                  _buildClientesList(data),
                  _buildCobradoresList(data),
                  _buildAsesoresList(data),
                  _buildPrestamistasList(data),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientesList(AdminDashboardData data) {
    if (data.clientes.isEmpty) {
      return const Center(child: Text('No hay clientes registrados', style: TextStyle(color: AppColors.ink3)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: data.clientes.length,
      itemBuilder: (context, index) {
        final c = data.clientes[index];
        return ListCard(
          role: Role.admin,
          title: c.nombre,
          subtitle: c.telefono != null && c.telefono!.isNotEmpty ? 'Tel: ${c.telefono}' : 'Tel: No registrado',
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
  }

  Widget _buildCobradoresList(AdminDashboardData data) {
    if (data.cobradores.isEmpty) {
      return const Center(child: Text('No hay cobradores registrados', style: TextStyle(color: AppColors.ink3)));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: data.cobradores.length,
      itemBuilder: (context, index) {
        final c = data.cobradores[index];
        final usuarioName = c['usuario'] ?? '';
        return ListCard(
          role: Role.admin,
          title: c['nombre'] ?? 'Sin nombre',
          subtitle: 'ID: $usuarioName',
          amount: '',
          badge: RoleChip(
            role: Role.cobrador,
            text: c['iniciales'] ?? 'CB',
            icon: Icons.person_pin_circle,
          ),
          icon: const Icon(Icons.directions_run_rounded, color: AppColors.cobrador, size: 22),
        );
      },
    );
  }

  // Placeholder para Asesores 
  Widget _buildAsesoresList(AdminDashboardData data) {
    return const Center(child: Text('Lista de Asesores (Próximamente)', style: TextStyle(color: AppColors.ink3)));
  }

  // Placeholder para Prestamistas
  Widget _buildPrestamistasList(AdminDashboardData data) {
    return const Center(child: Text('Lista de Prestamistas (Próximamente)', style: TextStyle(color: AppColors.ink3)));
  }
}
