import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cobrador_provider.dart';
import '../../core/models/prestamo_model.dart';
import '../../core/models/cliente_model.dart';
import '../../core/models/tipo_pago_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/confirm_modal.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class CobradorDashboard extends ConsumerStatefulWidget {
  const CobradorDashboard({super.key});

  @override
  ConsumerState<CobradorDashboard> createState() => _CobradorDashboardState();
}

class _CobradorDashboardState extends ConsumerState<CobradorDashboard> {
  int _currentIndex = 0;
  TipoPagoModel? _selectedTipoPago;
  final TextEditingController _montoController = TextEditingController();

  void _showCobroModal(
      PrestamoModel prestamo, ClienteModel cliente, List<TipoPagoModel> tiposPago) {
    if (tiposPago.isEmpty) return;

    setState(() {
      _selectedTipoPago = tiposPago.first;
      _montoController.text = prestamo.cuotaSemanal.toStringAsFixed(2);
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return ConfirmModal(
              title: 'Registrar Cobro',
              subtitle: 'Cobrador · GPS activo',
              icon: const Icon(Icons.account_balance_wallet, color: AppColors.cobrador, size: 24),
              topBarGradient: AppColors.cobradorGradient,
              iconBackgroundColor: AppColors.cobradorSurface,
              confirmText: '✓ Confirmar Cobro',
              cancelText: 'Cancelar',
              confirmButtonType: ButtonType.cobrador,
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () async {
                final amount = num.tryParse(_montoController.text);
                if (amount == null || amount <= 0) return;

                try {
                  await ref.read(cobradorProvider.notifier).ejecutarCobro(
                        prestamo: prestamo,
                        cliente: cliente,
                        tipoPago: _selectedTipoPago!,
                        monto: amount,
                      );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _showSuccessAnimation(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              details: [
                ModalRow(
                  keyText: 'Cliente',
                  keyIcon: const Icon(Icons.person, size: 14, color: AppColors.ink3),
                  valueText: cliente.nombre,
                ),
                ModalRow(
                  keyText: 'Crédito',
                  keyIcon: const Icon(Icons.description, size: 14, color: AppColors.ink3),
                  valueText: '#${prestamo.codigo}',
                ),
                ModalRow(
                  keyText: 'Cuota',
                  keyIcon: const Icon(Icons.pie_chart, size: 14, color: AppColors.ink3),
                  valueText: '${prestamo.cuotasPagadas} / ${prestamo.cuotasTotales}',
                ),
              ],
              customBody: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('TIPO DE PAGO',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.ink4)),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface1,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TipoPagoModel>(
                        isExpanded: true,
                        value: _selectedTipoPago,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                          fontFamily: 'Plus Jakarta Sans',
                        ),
                        items: tiposPago
                            .map((tp) => DropdownMenuItem(
                                  value: tp,
                                  child: Text(tp.nombre),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => _selectedTipoPago = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('MONTO',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.ink4)),
                  const SizedBox(height: 6),
                  CustomInput(
                    hintText: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: _montoController,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 14, right: 8, top: 14),
                      child: Text('\$',
                          style: TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink3)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessAnimation(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (context.mounted) Navigator.of(context).pop();
        });
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.elasticOut,
          builder: (context, val, child) {
            return Transform.scale(
              scale: val,
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: AppColors.okSurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle, size: 60, color: AppColors.ok),
                    ),
                    const SizedBox(height: 20),
                    const Text('¡Pago Registrado!', style: TextStyle(
                       fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink
                    )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final cobradorState = ref.watch(cobradorProvider);
    final formatCurrency = NumberFormat.simpleCurrency();

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeView(cobradorState, user, formatCurrency),
          _buildRutaView(cobradorState),
          const SizedBox(), // FAB
          _buildBitacoraView(cobradorState, formatCurrency),
          _buildPerfilView(user),
        ],
      ),
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          heroTag: 'cobrador_fab',
          onPressed: () {
            final data = ref.read(cobradorProvider).value;
            if (data == null || data.prestamos.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No hay clientes asignados')),
              );
              return;
            }
            // Find first pending client
            final pendiente = data.prestamos.firstWhere(
              (p) => !data.cobrosHoy.any((c) => c.prestamoId == p.id),
              orElse: () => data.prestamos.first,
            );
            final cliente = data.clientes.firstWhere(
              (c) => c.id.toString() == pendiente.clienteId.toString(),
              orElse: () => ClienteModel(id: '', nombre: 'Desconocido'),
            );
            _showCobroModal(pendiente, cliente, data.tiposPago);
          },
          backgroundColor: AppColors.cobrador,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.attach_money, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    ));
  }

  // ── HOME VIEW ─────────────────────────────────────────────────────────────

  Widget _buildHomeView(AsyncValue<CobradorState> cobradorState,
      dynamic user, NumberFormat formatCurrency) {
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.cobrador,
        onRefresh: () async => ref.read(cobradorProvider.notifier).refresh(),
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
                        user?.nombre ?? 'Cobrador',
                        style: AppTypography.headingPrincipal.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cobrador',
                        style: const TextStyle(
                          color: AppColors.cobrador,
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
                          color: AppColors.cobrador,
                        ),
                      ),
                      const Text(
                        'Tu dinero al instante',
                        style: TextStyle(
                            color: AppColors.ink4,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              cobradorState.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.cobrador),
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('Error: $err',
                        style: const TextStyle(color: AppColors.error)),
                  ),
                ),
                data: (data) {
                  final pendientes = data.prestamos.length - data.cobrosHoy.length;
                  final pct = data.porcentajeMeta;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de progreso del día
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.cobradorGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Meta del Día',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text(
                                  '${(pct * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formatCurrency.format(data.cobradoHoy),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900),
                            ),
                            Text(
                              'de ${formatCurrency.format(data.metaDiaria)}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct.clamp(0.0, 1.0),
                                backgroundColor: Colors.white24,
                                color: Colors.white,
                                minHeight: 8,
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
                              title: 'COBRADO HOY',
                              value: formatCurrency.format(data.cobradoHoy),
                              icon: Icons.payments_rounded,
                              iconColor: AppColors.cobrador,
                              bgColor: AppColors.cobradorSurface,
                              onTap: () => setState(() => _currentIndex = 3),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'COBROS',
                              value: data.cobrosHoy.length.toString(),
                              icon: Icons.check_circle_rounded,
                              iconColor: AppColors.ok,
                              bgColor: AppColors.okSurface,
                              onTap: () => setState(() => _currentIndex = 3),
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
                              value: pendientes.toString(),
                              icon: Icons.hourglass_empty_rounded,
                              iconColor: AppColors.warn,
                              bgColor: AppColors.warnSurface,
                              onTap: () => setState(() => _currentIndex = 1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              title: 'CLIENTES',
                              value: data.clientes.length.toString(),
                              icon: Icons.group_rounded,
                              iconColor: AppColors.info,
                              bgColor: AppColors.infoSurface,
                              onTap: () => setState(() => _currentIndex = 1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Lista de Ruta (primeros 5)
                      Text('Ruta de Hoy',
                          style: AppTypography.headingPrincipal.copyWith(fontSize: 18)),
                      const SizedBox(height: 16),
                      _buildRutaList(data, compact: true),
                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── RUTA VIEW ─────────────────────────────────────────────────────────────

  Widget _buildRutaView(AsyncValue<CobradorState> state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ruta Completa', style: AppTypography.headingPrincipal),
            const SizedBox(height: 4),
            const Text('Todos tus clientes asignados',
                style: TextStyle(color: AppColors.ink3)),
            const SizedBox(height: 20),
            Expanded(
              child: state.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.cobrador)),
                error: (err, _) => Center(
                    child: Text('Error: $err',
                        style: const TextStyle(color: AppColors.error))),
                data: (data) => RefreshIndicator(
                  color: AppColors.cobrador,
                  onRefresh: () async =>
                      ref.read(cobradorProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildRutaList(data, compact: false),
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

  // ── BITACORA VIEW ─────────────────────────────────────────────────────────

  Widget _buildBitacoraView(AsyncValue<CobradorState> state, NumberFormat formatCurrency) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bitácora', style: AppTypography.headingPrincipal),
            const SizedBox(height: 4),
            const Text('Registro de cobros del día',
                style: TextStyle(color: AppColors.ink3)),
            const SizedBox(height: 20),
            Expanded(
              child: state.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.cobrador)),
                error: (err, _) => Center(
                    child: Text('Error: $err',
                        style: const TextStyle(color: AppColors.error))),
                data: (data) {
                  if (data.cobrosHoy.isEmpty) {
                    return const Center(
                        child: Text('No hay cobros registrados hoy.',
                            style: TextStyle(color: AppColors.ink4)));
                  }
                  return ListView.separated(
                    itemCount: data.cobrosHoy.length,
                    separatorBuilder: (context, i) => const SizedBox(height: 10),
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, i) {
                      final cobro = data.cobrosHoy[i];
                      final cliente = data.clientes.firstWhere(
                        (c) => c.id == cobro.clienteId,
                        orElse: () => ClienteModel(id: '', nombre: 'Desconocido'),
                      );
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.cobradorSurface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: AppColors.cobrador, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cliente.nombre,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.ink)),
                                  const SizedBox(height: 2),
                                  Text(
                                    cobro.fechaCobro?.substring(0, 10) ?? 'Hoy',
                                    style: const TextStyle(
                                        color: AppColors.ink4, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatCurrency.format(cobro.monto),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.cobrador),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
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
                    backgroundColor: AppColors.cobrador.withValues(alpha: 0.1),
                    child: const Icon(Icons.person_rounded,
                        size: 30, color: AppColors.cobrador),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nombre ?? 'Cobrador',
                          style: AppTypography.headingPrincipal.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.usuario ?? '@cobrador',
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
                      color: AppColors.cobradorSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Cobrador',
                        style: TextStyle(
                            color: AppColors.cobrador,
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
                    icon: Icons.monetization_on_outlined,
                    label: 'Mis Cobros',
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                  _buildPerfilItem(
                    icon: Icons.route_outlined,
                    label: 'Mi Ruta',
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    type: ButtonType.error,
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

  Widget _buildRutaList(CobradorState data, {required bool compact}) {
    final prestamos = compact ? data.prestamos.take(5).toList() : data.prestamos;
    if (prestamos.isEmpty) {
      return const Center(
        child: Text('No tienes clientes asignados hoy.',
            style: TextStyle(color: AppColors.ink4)),
      );
    }
    return Column(
      children: prestamos.map((prestamo) {
        final cliente = data.clientes.firstWhere(
          (c) => c.id.toString() == prestamo.clienteId.toString(),
          orElse: () => ClienteModel(id: '', nombre: 'Desconocido'),
        );
        final yaCobrado = data.cobrosHoy.any((c) => c.prestamoId == prestamo.id);

        return GestureDetector(
          onTap: yaCobrado
              ? null
              : () => _showCobroModal(prestamo, cliente, data.tiposPago),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: yaCobrado ? AppColors.cobrador.withValues(alpha: 0.4) : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: yaCobrado ? AppColors.cobradorSurface : AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    yaCobrado ? Icons.check_circle : Icons.person,
                    color: yaCobrado ? AppColors.cobrador : AppColors.ink4,
                    size: 22,
                  ),
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
                        'Cr. ${prestamo.codigo ?? '#${prestamo.id}'} · ${yaCobrado ? 'Cobrado ✓' : 'Pendiente'}',
                        style: TextStyle(
                          color: yaCobrado ? AppColors.cobrador : AppColors.ink4,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${prestamo.cuotaSemanal.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.ink),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: yaCobrado
                            ? AppColors.cobradorSurface
                            : AppColors.warnSurface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        yaCobrado ? 'Ok' : 'PENDIENTE',
                        style: TextStyle(
                          color: yaCobrado ? AppColors.cobrador : AppColors.warn,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                _buildNavItem(icon: Icons.route_rounded, label: 'Ruta', index: 1),
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
              color: isActive ? AppColors.cobrador : AppColors.ink4, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.cobrador : AppColors.ink4,
            ),
          ),
        ],
      ),
    );
  }
}
