import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/models/user_model.dart';
import 'views/admin_usuarios_view.dart';
import 'views/admin_reportes_view.dart';
import 'views/admin_settings_view.dart';
import 'views/admin_cliente_create_view.dart';
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
          const AdminUsuariosView(),    // Clientes
          const SizedBox(),             // FAB uses this space
          const AdminReportesView(),    // Bitácora
          const AdminSettingsView(),    // Mi Perfil
        ],
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminClienteCreateView()),
            );
          },
          backgroundColor: AppColors.admin,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeView(AsyncValue<AdminDashboardData> adminState, UserModel? user, NumberFormat formatCurrency) {
    final hoy = DateTime.now().toIso8601String().substring(0, 10);

    return SafeArea(
      child: SingleChildScrollView(
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
                        user?.nombre ?? 'Administrador',
                        style: AppTypography.headingPrincipal.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Admin',
                        style: const TextStyle(color: AppColors.ink3, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'MexaPresta',
                        style: AppTypography.headingPrincipal.copyWith(fontSize: 18, color: AppColors.admin),
                      ),
                      Text(
                        'Tu dinero al instante',
                        style: const TextStyle(color: AppColors.ink4, fontSize: 12, fontWeight: FontWeight.w500),
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
                    // 4 Tarjetas
                    Row(
                      children: [
                        Expanded(
                          child: _buildDashboardCard(
                            title: 'COBRADO HOY',
                            value: formatCurrency.format(data.cobradoHoy),
                            icon: Icons.payments_rounded,
                            iconColor: AppColors.admin,
                            bgColor: AppColors.adminSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDashboardCard(
                            title: 'CLIENTES',
                            value: data.clientes.length.toString(),
                            icon: Icons.group_rounded,
                            iconColor: AppColors.cobrador,
                            bgColor: AppColors.cobradorSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDashboardCard(
                            title: 'EN MORA',
                            value: formatCurrency.format(data.montoEnMora),
                            icon: Icons.warning_rounded,
                            iconColor: AppColors.warn,
                            bgColor: AppColors.warnSurface,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDashboardCard(
                            title: 'POR APROBAR',
                            value: data.porAprobar.toString(),
                            icon: Icons.hourglass_empty_rounded,
                            iconColor: AppColors.asesor,
                            bgColor: AppColors.asesorSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Resumen (Cobradores)
                    Text(
                      'Resumen (Cobradores)',
                      style: AppTypography.headingPrincipal.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),

                    if (data.cobradores.isNotEmpty)
                      ...data.cobradores.map((c) {
                        final String cobradorId = c['id'].toString();
                        final String nombre = c['nombre'] ?? 'Desconocido';
                        
                        // Calculate metrics
                        final prestamosAsignados = data.prestamos.where((p) => p.cobradorId == cobradorId && p.estado == 'activo');
                        final totalClientes = prestamosAsignados.map((p) => p.clienteId).toSet().length;
                        
                        final cobrosHoy = data.cobros.where((cobro) => cobro.cobradorId == cobradorId && cobro.fechaCobro != null && cobro.fechaCobro!.startsWith(hoy));
                        final clientesCobrados = cobrosHoy.map((cobro) => cobro.clienteId).toSet().length;
                        final montoCobrado = cobrosHoy.fold(0.0, (sum, cobro) => sum + cobro.monto);
                        
                        final double porcentaje = totalClientes > 0 ? (clientesCobrados / totalClientes) * 100 : 0;

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
                              // Icono
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AppColors.cobradorSurface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.directions_walk_rounded, color: AppColors.cobrador, size: 24),
                              ),
                              const SizedBox(width: 16),
                              
                              // Detalles
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Cobrados: $clientesCobrados', style: const TextStyle(color: AppColors.ink3, fontSize: 13)),
                                            const SizedBox(height: 2),
                                            Text('Pagos: ${formatCurrency.format(montoCobrado)}', style: const TextStyle(color: AppColors.ink3, fontSize: 13, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('${porcentaje.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.ok, fontSize: 16, fontWeight: FontWeight.w800)),
                                            const Text('de meta', style: TextStyle(color: AppColors.ink4, fontSize: 10)),
                                          ],
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Progress bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: porcentaje / 100.0,
                                        backgroundColor: AppColors.border,
                                        color: AppColors.ok,
                                        minHeight: 6,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),


                    if (data.cobradores.isEmpty)
                      const Text('No hay cobradores registrados.', style: TextStyle(
                            fontSize: 14,
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

  Widget _buildDashboardCard({required String title, required String value, required IconData icon, required Color iconColor, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: AppColors.ink4, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

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
            // Lado Izquierdo
            Row(
              children: [
                _buildNavItem(icon: Icons.home_rounded, label: 'Inicio', index: 0),
                const SizedBox(width: 32),
                _buildNavItem(icon: Icons.group_rounded, label: 'Clientes', index: 1),
              ],
            ),
            // Lado Derecho
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

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.admin : AppColors.ink4,
            size: 26,
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

