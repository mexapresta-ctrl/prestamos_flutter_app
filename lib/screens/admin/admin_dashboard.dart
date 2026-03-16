import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/list_card.dart';
import '../../widgets/role_chip.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/models/cliente_model.dart';
import '../../core/models/user_model.dart';
import 'views/admin_usuarios_view.dart';
import 'views/admin_reportes_view.dart';
import 'views/admin_settings_view.dart';
import 'views/admin_cliente_detalle_view.dart';
import 'views/admin_cliente_create_view.dart';
import 'widgets/user_create_dialog.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final user = ref.watch(authProvider).user;
    final formatCurrency = NumberFormat.simpleCurrency();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeView(adminState, user, formatCurrency),
          const AdminReportesView(),
          const SizedBox(), // Spacer for center FAB
          const AdminUsuariosView(),
          const AdminSettingsView(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeView(AsyncValue<AdminDashboardData> adminState, UserModel? user, NumberFormat formatCurrency) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: AppTypography.headingPrincipal,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bienvenido, ${user?.nombre.split(' ')[0] ?? 'Admin'}',
                        style: AppTypography.subtext,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const RoleChip(
                        role: Role.admin,
                        text: 'Admin',
                        icon: Icons.shield_rounded, // fallback icon
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          ref.read(authProvider.notifier).logout();
                        },
                        icon: const Icon(Icons.logout, color: AppColors.ink4),
                        tooltip: 'Cerrar Sesión',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Data states
              adminState.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text('Error: $err', style: const TextStyle(color: AppColors.error)),
                  ),
                ),
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero
                    HeroCard(
                      role: Role.admin,
                      label: 'Cartera Total',
                      amount: formatCurrency.format(data.carteraTotal),
                      tags: [
                        '${data.prestamos.where((p) => p.estado == 'activo').length} activos',
                        '${data.prestamos.length} créditos'
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            role: Role.admin,
                            label: 'Cobrado Hoy',
                            value: formatCurrency.format(data.cobradoHoy),
                            trendText: data.cobradoHoy > 0 ? 'Con ingresos' : 'Sin ingresos',
                            isUp: data.cobradoHoy > 0,
                            icon: const Icon(Icons.account_balance_wallet, color: AppColors.admin, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            role: Role.admin,
                            label: 'Nuevos Clientes',
                            value: data.clientes.length.toString(),
                            trendText: 'Totales',
                            isUp: true,
                            icon: const Icon(Icons.people, color: AppColors.admin, size: 20),
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
                            value: data.enMora.toString(),
                            trendText: 'Préstamos vencidos',
                            isUp: false,
                            icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warn, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            role: Role.admin,
                            label: 'Por Aprobar',
                            value: data.porAprobar.toString(),
                            trendText: 'Esperando',
                            isUp: data.porAprobar == 0,
                            icon: const Icon(Icons.access_time_rounded, color: AppColors.admin, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Resumen
                    Text(
                      'Resumen',
                      style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.ink),
                    ),
                    const SizedBox(height: 16),

                    if (data.cobradores.isNotEmpty)
                      ...data.cobradores.map((c) => ListCard(
                        role: Role.admin,
                        title: c['nombre'] ?? 'Desconocido',
                        subtitle: 'Cobrador · ${c['usuario']}',
                        amount: '',
                        badge: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.adminSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Activo', style: TextStyle(color: AppColors.admin, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        icon: const Icon(Icons.directions_walk_rounded, color: AppColors.admin, size: 22),
                      )),


                    if (data.cobradores.isEmpty)
                      const Text('No hay cobradores registrados.', style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink3,
                          )),
                    
                    const SizedBox(height: 32),

                    // Clientes
                    Text(
                      'Últimos Clientes Registrados',
                      style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.ink),
                    ),
                    const SizedBox(height: 16),

                    if (data.clientes.isNotEmpty)
                      ...data.clientes.take(5).map((c) => ListCard(
                        role: Role.admin,
                        title: c.nombre,
                        subtitle: c.telefono != null && c.telefono!.isNotEmpty ? 'Tel: ${c.telefono}' : 'Tel: No registrado',
                        amount: '',
                        badge: const SizedBox(), // Required parameter in ListCard
                        icon: const Icon(Icons.person, color: AppColors.admin, size: 22),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminClienteDetalleView(cliente: c),
                            ),
                          );
                        },
                      )),

                    if (data.clientes.isEmpty)
                      const Text('No hay clientes registrados.', style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink3,
                          )),

                    const SizedBox(height: 32),

                    // Prestamos 
                    Text(
                      'Préstamos Recientes',
                      style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.ink),
                    ),
                    const SizedBox(height: 16),

                    if (data.prestamos.isNotEmpty)
                      ...data.prestamos.take(5).map((p) {
                        final cliente = data.clientes.firstWhere(
                          (c) => c.id == p.clienteId, 
                          orElse: () => ClienteModel(id: '', nombre: 'Desconocido', telefono: '')
                        );
                        return ListCard(
                          role: Role.admin,
                          title: cliente.nombre,
                          subtitle: 'Crédito ${p.codigo ?? p.id.substring(0, 8)}',
                          amount: formatCurrency.format(p.cuotaSemanal * p.cuotasTotales),
                          badge: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.estado == 'activo' ? AppColors.okSurface : AppColors.warnSurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(p.estado.toUpperCase(), style: TextStyle(color: p.estado == 'activo' ? AppColors.ok : AppColors.warn, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          icon: const Icon(Icons.credit_card, color: AppColors.admin, size: 22),
                        );
                      }),

                    if (data.prestamos.isEmpty)
                      const Text('No hay préstamos registrados.', style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink3,
                          )),
                    
                    const SizedBox(height: 100), // padding for bottom nav
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home, label: 'Inicio', index: 0),
          _buildNavItem(icon: Icons.bar_chart, label: 'Reportes', index: 1),
          // FAB placeholder
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminClienteCreateView()),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: AppColors.adminGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x663447E8),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
          _buildNavItem(icon: Icons.people, label: 'Usuarios', index: 3),
          _buildNavItem(icon: Icons.settings, label: 'Config', index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.adminSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.admin : AppColors.ink4,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.admin : AppColors.ink4,
          ),
        ),
      ],
      ),
    );
  }
}
