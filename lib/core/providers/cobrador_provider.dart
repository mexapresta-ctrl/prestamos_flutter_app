import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Removed duplicate
import '../models/prestamo_model.dart';
import '../models/cobro_model.dart';
import '../models/cliente_model.dart';
import '../models/tipo_pago_model.dart';
import '../providers/auth_provider.dart';

class CobradorState {
  final List<PrestamoModel> prestamos;
  final List<CobroModel> cobrosHoy;
  final List<ClienteModel> clientes;
  final List<TipoPagoModel> tiposPago;

  final num metaDiaria;
  final num cobradoHoy;
  final double porcentajeMeta;

  CobradorState({
    required this.prestamos,
    required this.cobrosHoy,
    required this.clientes,
    required this.tiposPago,
    required this.metaDiaria,
    required this.cobradoHoy,
    required this.porcentajeMeta,
  });

  factory CobradorState.initial() => CobradorState(
    prestamos: [],
    cobrosHoy: [],
    clientes: [],
    tiposPago: [],
    metaDiaria: 0,
    cobradoHoy: 0,
    porcentajeMeta: 0,
  );
}

class CobradorProvider extends AsyncNotifier<CobradorState> {
  final _supabase = Supabase.instance.client;

  @override
  Future<CobradorState> build() async {
    return _fetchData();
  }

  Future<CobradorState> _fetchData() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      return CobradorState.initial();
    }

    // 1. Fetch Tipos Pago
    final tiposData = await _supabase.from('tipos_pago').select().eq('activo', true);
    final tiposPago = tiposData.map((e) => TipoPagoModel.fromJson(e)).toList();

    // 2. Fetch Préstamos activos asignados al cobrador
    final prestamosData = await _supabase
        .from('prestamos')
        .select()
        .eq('cobrador_id', user.id)
        .eq('estado', 'activo')
        .eq('activo', true)
        .order('id');
    
    final prestamos = prestamosData.map((e) => PrestamoModel.fromJson(e)).toList();

    // 3. Obtener clientes relacionados a los préstamos
    List<ClienteModel> clientes = [];
    if (prestamos.isNotEmpty) {
      final clienteIds = prestamos.map((p) => p.clienteId).toSet().toList();
      final clientesData = await _supabase.from('clientes').select().inFilter('id', clienteIds);
      clientes = clientesData.map((e) => ClienteModel.fromJson(e)).toList();
    }

    // 4. Fetch Cobros de Hoy
    final now = DateTime.now();
    // Padding with leading zeros for generic matching (e.g. 2024-03-12)
    final hoyStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}'; 

    // We query all cobros by this cobrador and filter in memory by today's date
    // to mimic the web app's `c.fecha.startsWith(hoy)` logic consistently.
    final cobrosData = await _supabase
        .from('cobros')
        .select()
        .eq('cobrador_id', user.id);
        
    final todosCobros = cobrosData.map((e) => CobroModel.fromJson(e)).toList();
    final cobrosHoy = todosCobros.where((c) {
      if (c.fechaCobro == null) return false;
      try {
        final date = DateTime.parse(c.fechaCobro!).toLocal();
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } catch (e) {
        return c.fechaCobro!.startsWith(hoyStr);
      }
    }).toList();

    // 5. Cálculos (KPIs)
    num metaDiaria = prestamos.fold(0, (sum, p) => sum + p.cuotaSemanal);
    num cobradoHoy = cobrosHoy.fold(0, (sum, c) => sum + c.monto);
    double porcentajeMeta = metaDiaria > 0 ? (cobradoHoy / metaDiaria) : 0;
    if (porcentajeMeta > 1) porcentajeMeta = 1;

    return CobradorState(
      prestamos: prestamos,
      cobrosHoy: cobrosHoy,
      clientes: clientes,
      tiposPago: tiposPago,
      metaDiaria: metaDiaria,
      cobradoHoy: cobradoHoy,
      porcentajeMeta: porcentajeMeta,
    );
  }

  // Refrescar manualmente
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }

  // Ejecutar Cobro
  Future<void> ejecutarCobro({
    required PrestamoModel prestamo,
    required ClienteModel cliente,
    required TipoPagoModel tipoPago,
    required num monto,
  }) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    try {
      // 1. Insertar el cobro
      await _supabase.from('cobros').insert({
        'prestamo_id': prestamo.id,
        'cliente_id': cliente.id,
        'cobrador_id': user.id,
        'tipo_pago_id': tipoPago.id,
        'monto': monto,
        'nombre_pago': tipoPago.nombre,
        'cuota_num': prestamo.cuotasPagadas + 1,
        'fecha': DateTime.now().toIso8601String(),
        'fecha_cobro': DateTime.now().toIso8601String(),
      });

      // 2. Opcional: Actualizar el avance del préstamo
      await _supabase.from('prestamos').update({
        'cuotas_pagadas': prestamo.cuotasPagadas + (tipoPago.afectaSaldo ? 1 : 0),
      }).eq('id', prestamo.id);

      // 3. Registrar auditoría (log)
      await _supabase.from('auditoria').insert({
        'tipo': 'COBRO',
        'descripcion': '${user.nombre} registró [${tipoPago.nombre}] por \$${monto.toStringAsFixed(2)} para ${cliente.nombre}',
        'usuario': user.nombre,
        'rol': user.rol,
        'fecha': DateTime.now().toIso8601String(),
      });

      // 4. Recargar el state para reflejar el progreso
      await refresh();
      
    } catch (e) {
      throw Exception('Error al registrar cobro: $e');
    }
  }
}


final cobradorProvider = AsyncNotifierProvider<CobradorProvider, CobradorState>(() {
  return CobradorProvider();
});
