import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/asesor_provider.dart';
import '../../core/models/cliente_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_button.dart';

class AsesorDashboard extends ConsumerStatefulWidget {
  const AsesorDashboard({super.key});

  @override
  ConsumerState<AsesorDashboard> createState() => _AsesorDashboardState();
}

class _AsesorDashboardState extends ConsumerState<AsesorDashboard> {
  int _currentIndex = 0;
  final formatCurrency = NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final asesorState = ref.watch(asesorProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeView(asesorState, user),
          _buildClientesView(asesorState),
          const SizedBox(), // FAB
          _buildBitacoraView(asesorState),
          _buildPerfilView(user),
        ],
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nuevo trámite próximamente')),
            );
          },
          backgroundColor: AppColors.asesor,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HOME VIEW ─────────────────────────────────────────────────────────────

  Widget _buildHomeView(AsyncValue<AsesorDashboardData> asesorState, dynamic user) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.asesor,
        onRefresh: () async => ref.read(asesorProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nombre ?? 'Asesor',
                        style: AppTypography.headingPrincipal.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Asesor',
                        style: TextStyle(
                          color: AppColors.asesor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'MexaPresta',
                        style: AppTypography.headingPrincipal.copyWith(
                          fontSize: 18,
                          color: AppColors.asesor,
                        ),
                      ),
                      const Text(
                        'Tu dinero al instante',
                        style: TextStyle(
                          color: AppColors.ink4,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              asesorState.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.asesor),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('Error: $err',
                        style: const TextStyle(color: AppColors.error)),
                  ),
                ),
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cartera Colocada — banner naranja
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.asesorGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cartera Colocada',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatCurrency.format(data.montoColocado),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Créditos aprobados',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.trending_up_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4 Tarjetas
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'CLIENTES',
                            value: data.clientesActivos.toString(),
                            icon: Icons.group_rounded,
                            iconColor: AppColors.asesor,
                            bgColor: AppColors.asesorSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'APROBADOS',
                            value: data.prestamosAprobados.toString(),
                            icon: Icons.check_circle_rounded,
                            iconColor: AppColors.ok,
                            bgColor: AppColors.okSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'PENDIENTES',
                            value: data.prestamosPendientes.toString(),
                            icon: Icons.hourglass_empty_rounded,
                            iconColor: AppColors.warn,
                            bgColor: AppColors.warnSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'TRÁMITES',
                            value: data.misPrestamosTramitados.length.toString(),
                            icon: Icons.description_rounded,
                            iconColor: AppColors.info,
                            bgColor: AppColors.infoSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Trámites Recientes
                    Text(
                      'Trámites Recientes',
                      style: AppTypography.headingPrincipal.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    _buildTramitesList(data, compact: true),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CLIENTES VIEW ─────────────────────────────────────────────────────────

  Widget _buildClientesView(AsyncValue<AsesorDashboardData> state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mis Clientes', style: AppTypography.headingPrincipal),
            const SizedBox(height: 4),
            const Text('Clientes vinculados a tus trámites',
                style: TextStyle(color: AppColors.ink3)),
            const SizedBox(height: 20),
            Expanded(
              child: state.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.asesor)),
                error: (err, _) => Center(
                    child: Text('Error: $err',
                        style: const TextStyle(color: AppColors.error))),
                data: (data) {
                  final clientesEnTramites = data.clientes
                      .where((c) =>
                          data.misPrestamosTramitados.any((p) => p.clienteId == c.id))
                      .toList();

                  if (clientesEnTramites.isEmpty) {
                    return const Center(
                      child: Text('No tienes clientes vinculados aún.',
                          style: TextStyle(color: AppColors.ink4)),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.asesor,
                    onRefresh: () async =>
                        ref.read(asesorProvider.notifier).refresh(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: clientesEnTramites.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final c = clientesEnTramites[i];
                        final tramitesCliente = data.misPrestamosTramitados
                            .where((p) => p.clienteId == c.id)
                            .length;
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.asesorSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person,
                                    color: AppColors.asesor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.nombre,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.ink)),
                                    const SizedBox(height: 2),
                                    Text(
                                      c.telefono != null && c.telefono!.isNotEmpty
                                          ? 'Tel: ${c.telefono}'
                                          : 'Sin teléfono',
                                      style: const TextStyle(
                                          color: AppColors.ink4, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.asesorSurface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$tramitesCliente trámite${tramitesCliente != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: AppColors.asesor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BITÁCORA VIEW ─────────────────────────────────────────────────────────

  Widget _buildBitacoraView(AsyncValue<AsesorDashboardData> state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bitácora', style: AppTypography.headingPrincipal),
            const SizedBox(height: 4),
            const Text('Todos tus trámites gestionados',
                style: TextStyle(color: AppColors.ink3)),
            const SizedBox(height: 20),
            Expanded(
              child: state.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.asesor)),
                error: (err, _) => Center(
                    child: Text('Error: $err',
                        style: const TextStyle(color: AppColors.error))),
                data: (data) => RefreshIndicator(
                  color: AppColors.asesor,
                  onRefresh: () async =>
                      ref.read(asesorProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildTramitesList(data, compact: false),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PERFIL VIEW ───────────────────────────────────────────────────────────

  Widget _buildPerfilView(dynamic user) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mi Perfil', style: AppTypography.headingPrincipal),
            const SizedBox(height: 24),

            // Profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.asesor.withValues(alpha: 0.1),
                    child: const Icon(Icons.person_rounded,
                        size: 30, color: AppColors.asesor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nombre ?? 'Asesor',
                          style:
                              AppTypography.headingPrincipal.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.usuario ?? '@asesor',
                          style: const TextStyle(
                              color: AppColors.ink3, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.asesorSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Asesor',
                        style: TextStyle(
                            color: AppColors.asesor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: ListView(
                children: [
                  _buildPerfilItem(
                    icon: Icons.people_outline,
                    label: 'Mis Clientes',
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _buildPerfilItem(
                    icon: Icons.description_outlined,
                    label: 'Mis Trámites',
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  _buildPerfilItem(
                    icon: Icons.cloud_download_outlined,
                    label: 'Buscar Actualizaciones',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Comprobando actualizaciones...'))),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    type: ButtonType.secondary,
                    text: 'Cerrar Sesión',
                    icon: Icons.logout,
                    onPressed: () => ref.read(authProvider.notifier).logout(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Widget _buildTramitesList(AsesorDashboardData data, {required bool compact}) {
    final prestamos = compact
        ? data.misPrestamosTramitados.take(5).toList()
        : data.misPrestamosTramitados;

    if (prestamos.isEmpty) {
      return const Center(
        child: Text('No has tramitado préstamos aún.',
            style: TextStyle(color: AppColors.ink4)),
      );
    }

    return Column(
      children: prestamos.map((prestamo) {
        final cliente = data.clientes.firstWhere(
          (c) => c.id == prestamo.clienteId,
          orElse: () => ClienteModel(id: '', nombre: 'Desconocido'),
        );

        Color statusColor;
        IconData statusIcon;
        Color statusBg;
        switch (prestamo.estado) {
          case 'activo':
            statusColor = AppColors.ok;
            statusBg = AppColors.okSurface;
            statusIcon = Icons.check_circle_rounded;
            break;
          case 'rechazado':
            statusColor = AppColors.error;
            statusBg = AppColors.errorSurface;
            statusIcon = Icons.cancel_rounded;
            break;
          default:
            statusColor = AppColors.warn;
            statusBg = AppColors.warnSurface;
            statusIcon = Icons.hourglass_empty_rounded;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente.nombre,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.ink)),
                    const SizedBox(height: 2),
                    Text(
                      'Cr. ${prestamo.codigo ?? 'S/N'} · ${prestamo.cuotasTotales} semanas',
                      style:
                          const TextStyle(color: AppColors.ink4, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency.format(prestamo.monto),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      prestamo.estado.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  color: AppColors.ink4,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildPerfilItem(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.ink2, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                        fontSize: 15))),
            const Icon(Icons.chevron_right, color: AppColors.ink4),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM NAV ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      elevation: 10,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildNavItem(icon: Icons.home_rounded, label: 'Inicio', index: 0),
                const SizedBox(width: 32),
                _buildNavItem(icon: Icons.group_rounded, label: 'Clientes', index: 1),
              ],
            ),
            Row(
              children: [
                _buildNavItem(icon: Icons.assignment_rounded, label: 'Bitácora', index: 3),
                const SizedBox(width: 32),
                _buildNavItem(icon: Icons.person_rounded, label: 'Mi Perfil', index: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isActive ? AppColors.asesor : AppColors.ink4, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.asesor : AppColors.ink4,
            ),
          ),
        ],
      ),
    );
  }
}
