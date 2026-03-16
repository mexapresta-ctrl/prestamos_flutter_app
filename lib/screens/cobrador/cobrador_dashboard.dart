import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cobrador_provider.dart';
import '../../core/models/prestamo_model.dart';
import '../../core/models/cliente_model.dart';
import '../../core/models/tipo_pago_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/list_card.dart';
import '../../widgets/role_chip.dart';
import '../../widgets/confirm_modal.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class CobradorDashboard extends ConsumerStatefulWidget {
  const CobradorDashboard({super.key});

  @override
  ConsumerState<CobradorDashboard> createState() => _CobradorDashboardState();
}

class _CobradorDashboardState extends ConsumerState<CobradorDashboard> {
  // Modal state
  TipoPagoModel? _selectedTipoPago;
  final TextEditingController _montoController = TextEditingController();

  void _showCobroModal(
      PrestamoModel prestamo, ClienteModel cliente, List<TipoPagoModel> tiposPago) {
    if (tiposPago.isEmpty) return;
    
    // Set defaults
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cobro registrado exitosamente')),
                    );
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
                        items: tiposPago.map((tp) => DropdownMenuItem(
                          value: tp,
                          child: Text(tp.nombre),
                        )).toList(),
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
                      child: Text('\$', style: TextStyle(
                        fontFamily: 'Fraunces', 
                        fontSize: 18, 
                        fontWeight: FontWeight.w600, 
                        color: AppColors.ink3
                      )),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final cobradorState = ref.watch(cobradorProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(cobradorProvider.notifier).refresh();
          },
          child: cobradorState.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.cobrador)),
            error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
            data: (data) {
              final nombreCorto = user?.nombre.split(' ').first ?? 'Usuario';
              final pendientes = data.prestamos.length - data.cobrosHoy.length;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                              'Ruta Hoy',
                              style: AppTypography.headingPrincipal,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hola, $nombreCorto',
                              style: AppTypography.subtext,
                            ),
                          ],
                        ),
                        const RoleChip(
                          role: Role.cobrador,
                          text: 'Cobrador',
                          icon: Icons.directions_walk_rounded, 
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Hero Meta
                    HeroCard(
                      role: Role.cobrador,
                      label: 'Meta de Cobro',
                      amount: data.metaDiaria.toStringAsFixed(2),
                      tags: ['${(data.porcentajeMeta * 100).toStringAsFixed(1)}% cobrado'],
                    ),
                    const SizedBox(height: 16),
                    
                    // Progreso
                    ProgressBar(
                      role: Role.cobrador,
                      label: 'Progreso del día',
                      percentage: data.porcentajeMeta,
                      subtext: '\$${data.cobradoHoy.toStringAsFixed(2)} de \$${data.metaDiaria.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            role: Role.cobrador,
                            label: 'Cobros realizados',
                            value: data.cobrosHoy.length.toString(),
                            trendText: 'Registrados hoy',
                            isUp: true,
                            icon: const Icon(Icons.check_circle_outline, color: AppColors.cobrador, size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            role: Role.cobrador,
                            label: 'Pendientes',
                            value: pendientes.toString(),
                            trendText: 'De ruta total',
                            isUp: pendientes > 0 ? false : true, // Just as a UI indicator that 0 = good
                            icon: const Icon(Icons.people_outline, color: AppColors.cobrador, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Ruta Total',
                      style: AppTypography.cardTitle.copyWith(fontSize: 16, color: AppColors.ink),
                    ),
                    const SizedBox(height: 16),

                    if (data.prestamos.isEmpty)
                      const Center(
                        child: Text(
                          'No hay préstamos asignados a tu ruta.',
                          style: TextStyle(color: AppColors.ink4),
                        ),
                      )
                    else
                      ...data.prestamos.map((prestamo) {
                        final cliente = data.clientes.firstWhere(
                          (c) => c.id.toString() == prestamo.clienteId.toString(), 
                          orElse: () => ClienteModel(id: 0, nombre: 'Desconocido', telefono: '')
                        );
                        
                        // Determinar si ya se cobró hoy
                        final yaCobrado = data.cobrosHoy.any((c) => c.prestamoId == prestamo.id);

                        return InkWell(
                          onTap: yaCobrado ? null : () => _showCobroModal(prestamo, cliente, data.tiposPago),
                          child: ListCard(
                            role: Role.cobrador,
                            title: cliente.nombre,
                            subtitle: 'Cr. ${prestamo.codigo ?? '#${prestamo.id}'} · ${yaCobrado ? 'Cobrado' : 'Pendiente'}',
                            amount: '\$${prestamo.cuotaSemanal.toStringAsFixed(0)}',
                            badge: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: yaCobrado ? AppColors.okSurface : AppColors.infoSurface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                yaCobrado ? 'Ok' : 'Pen', 
                                style: TextStyle(
                                  color: yaCobrado ? AppColors.ok : AppColors.info, 
                                  fontSize: 10, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ),
                            icon: Icon(
                              yaCobrado ? Icons.check_circle : Icons.person, 
                              color: yaCobrado ? AppColors.ok : AppColors.cobrador, 
                              size: 22
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
          _buildNavItem(icon: Icons.home, label: 'Inicio', isActive: true),
          _buildNavItem(icon: Icons.map, label: 'Mapa', isActive: false),
          // FAB placeholder
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: AppColors.cobradorGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x660A7C5C),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
          ),
          _buildNavItem(icon: Icons.route, label: 'Ruta', isActive: false),
          _buildNavItem(icon: Icons.person, label: 'Perfil', isActive: false),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required bool isActive}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.cobradorSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.cobrador : AppColors.ink4,
            size: 24,
          ),
        ),
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
    );
  }
}

