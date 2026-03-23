import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prestamo_model.dart';
import '../models/cobro_model.dart';
import '../models/cliente_model.dart';
import '../models/tipo_pago_model.dart';
import '../providers/auth_provider.dart';
import '../utils/time_util.dart';
import '../config/supabase_config.dart';

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

final _tiposPagoProv = StreamProvider((ref) {
  return SupabaseConfig.client.from('tipos_pago').stream(primaryKey: ['id']).map((l) => l.where((e) => e['activo'] == true).toList());
});

final _cobradorPrestamosProv = StreamProvider((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return const Stream<List<Map<String,dynamic>>>.empty();
  return SupabaseConfig.client.from('prestamos').stream(primaryKey: ['id']).map((l) => l.where((e) => e['cobrador_id'] == user.id && e['estado'] == 'activo' && e['activo'] == true).toList());
});

final _cobradorCobrosProv = StreamProvider((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return const Stream<List<Map<String,dynamic>>>.empty();
  return SupabaseConfig.client.from('cobros').stream(primaryKey: ['id']).map((l) => l.where((e) => e['cobrador_id'] == user.id).toList());
});

final _clientesProv = StreamProvider((ref) {
  return SupabaseConfig.client.from('clientes').stream(primaryKey: ['id']).map((l) => l.where((e) => e['activo'] == true).toList());
});

class CobradorProvider extends AsyncNotifier<CobradorState> {
  final _supabase = SupabaseConfig.client;

  @override
  Future<CobradorState> build() async {
    return _buildFromStreams();
  }

  Future<CobradorState> _buildFromStreams() async {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return CobradorState.initial();
    }

    // 1. Fetch Streams
    final tiposData = await ref.watch(_tiposPagoProv.future);
    final prestamosData = await ref.watch(_cobradorPrestamosProv.future);
    final cobrosData = await ref.watch(_cobradorCobrosProv.future);
    final clientesData = await ref.watch(_clientesProv.future);

    final tiposPago = tiposData.map((e) => TipoPagoModel.fromJson(e)).toList();
    final prestamos = prestamosData.map((e) => PrestamoModel.fromJson(e)).toList();
    // 3. Filtrar clientes relacionados y listos
    List<ClienteModel> clientes = [];
    if (prestamos.isNotEmpty) {
      final clienteIds = prestamos.map((p) => p.clienteId).toSet().toList();
      clientes = clientesData.where((c) => clienteIds.contains(c['id'])).map((e) => ClienteModel.fromJson(e)).toList();
    }

    // 4. Transformar y Filtrar Cobros de Hoy
    final now = TimeUtil.now();
    final hoyStr = TimeUtil.todayIsoDate(); 

    final todosCobros = cobrosData.map((e) => CobroModel.fromJson(e)).toList();
    final cobrosHoy = todosCobros.where((c) {
      if (c.fechaCobro == null) return false;
      try {
        final date = TimeUtil.parse(c.fechaCobro!);
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
    ref.invalidate(_tiposPagoProv);
    ref.invalidate(_cobradorPrestamosProv);
    ref.invalidate(_cobradorCobrosProv);
    ref.invalidate(_clientesProv);
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
        'tipoPagoId': tipoPago.id,
        'monto': monto,
        'nombrePago': tipoPago.nombre,
        'cuotaNum': prestamo.cuotasPagadas + 1,
        'fecha': TimeUtil.toIsoDb(),
        'fecha_cobro': TimeUtil.toIsoDb(),
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
        'fecha': TimeUtil.toIsoDb(),
      });

      // 4. No necesitamos llamar a refresh(), el Realtime stream empujará los cambios y recalculará la UI solo.
    } catch (e) {
      throw Exception('Error al registrar cobro: $e');
    }
  }
}


final cobradorProvider = AsyncNotifierProvider<CobradorProvider, CobradorState>(() {
  return CobradorProvider();
});
