import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/admin_provider.dart';
import '../../core/models/user_model.dart';
import 'views/admin_clientes_view.dart';
import 'views/admin_reportes_view.dart';
import 'views/admin_settings_view.dart';
import 'views/admin_prestamos_view.dart';
import 'views/admin_cobrador_detalle_view.dart';
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
          const AdminClientesView(),    // Clientes
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
          heroTag: 'main_fab',
          onPressed: () => _showRegistrarPago(context),
          backgroundColor: AppColors.admin,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.attach_money, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Opens a bottom sheet to select a client and register a payment
  void _showRegistrarPago(BuildContext context) {
    final adminState = ref.read(adminProvider);
    final data = adminState.value;
    if (data == null) return;

    final formatCurrency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final montoController = TextEditingController();
    String? selectedClienteId;
    String? selectedPrestamoId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            // Active loans for selected client
            final prestamosCliente = selectedClienteId != null
                ? data.prestamos.where((p) => p.clienteId == selectedClienteId && p.estado == 'activo').toList()
                : <dynamic>[];

            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Registrar Pago', style: AppTypography.headingPrincipal.copyWith(fontSize: 20)),
                      const SizedBox(height: 20),

                      // Client dropdown
                      const Text('Cliente', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink2)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedClienteId,
                        decoration: InputDecoration(
                          hintText: 'Seleccionar cliente',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                        items: data.clientes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nombre, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (v) => setModalState(() {
                          selectedClienteId = v;
                          selectedPrestamoId = null;
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Loan dropdown (appears after client selected)
                      if (selectedClienteId != null) ...[
                        const Text('Préstamo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink2)),
                        const SizedBox(height: 8),
                        if (prestamosCliente.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.warnSurface, borderRadius: BorderRadius.circular(8)),
                            child: const Text('Este cliente no tiene préstamos activos.', style: TextStyle(color: AppColors.warn, fontSize: 13)),
                          )
                        else
                          DropdownButtonFormField<String>(
                            initialValue: selectedPrestamoId,
                            decoration: InputDecoration(
                              hintText: 'Seleccionar préstamo',
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            ),
                            items: prestamosCliente.map<DropdownMenuItem<String>>((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.codigo ?? p.id.substring(0, 8)} · ${formatCurrency.format(p.cuotaSemanal)}/sem'),
                            )).toList(),
                            onChanged: (v) => setModalState(() => selectedPrestamoId = v),
                          ),
                        const SizedBox(height: 16),
                      ],

                      // Amount
                      if (selectedPrestamoId != null) ...[
                        const Text('Monto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink2)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: montoController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            prefixText: '\$ ',
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.admin, width: 2)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final monto = double.tryParse(montoController.text);
                              if (monto == null || monto <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ingresa un monto válido'), backgroundColor: AppColors.error),
                                );
                                return;
                              }
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Pago de ${formatCurrency.format(monto)} registrado'),
                                  backgroundColor: AppColors.ok,
                                ),
                              );
                              // TODO: Hook into actual cobro insertion via provider
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Registrar Pago', style: TextStyle(fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.admin,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
                      const Text(
                        'Admin',
                        style: TextStyle(color: AppColors.ink3, fontWeight: FontWeight.w600),
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
                      const Text(
                        'Tu dinero al instante',
                        style: TextStyle(color: AppColors.ink4, fontSize: 12, fontWeight: FontWeight.w500),
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
                            onTap: () => setState(() => _currentIndex = 3),
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
                            onTap: () => setState(() => _currentIndex = 1),
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
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPrestamosView(initialFilter: 'vencido')));
                            },
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
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPrestamosView(initialFilter: 'solicitado')));
                            },
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
                        
                        final prestamosAsignados = data.prestamos.where((p) => p.cobradorId == cobradorId && p.estado == 'activo');
                        final totalClientes = prestamosAsignados.map((p) => p.clienteId).toSet().length;
                        
                        final cobrosHoy = data.cobros.where((cobro) => cobro.cobradorId == cobradorId && cobro.fechaCobro != null && cobro.fechaCobro!.startsWith(hoy));
                        final clientesCobrados = cobrosHoy.map((cobro) => cobro.clienteId).toSet().length;
                        final montoCobrado = cobrosHoy.fold(0.0, (sum, cobro) => sum + cobro.monto);
                        
                        final double porcentaje = totalClientes > 0 ? (clientesCobrados / totalClientes) * 100 : 0;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminCobradorDetalleView(cobrador: c)));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: AppColors.cobradorSurface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.directions_walk_rounded, color: AppColors.cobrador, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              nombre,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.ink),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right, color: AppColors.ink4, size: 20),
                                        ],
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
                          ),
                        );
                      }),


                    if (data.cobradores.isEmpty)
                      const Text('No hay cobradores registrados.', style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink3,
                          )),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
