import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prestamo_model.dart';
import '../models/cliente_model.dart';
import '../models/cobro_model.dart';
import '../config/supabase_config.dart';

class AdminDashboardData {
  final List<PrestamoModel> prestamos;
  final List<ClienteModel> clientes;
  final List<CobroModel> cobros;
  final List<Map<String, dynamic>> cobradores;

  // Calculados
  final double carteraTotal;
  final double cobradoHoy;
  final int enMora;
  final double montoEnMora;
  final int porAprobar;

  AdminDashboardData({
    required this.prestamos,
    required this.clientes,
    required this.cobros,
    required this.cobradores,
    required this.carteraTotal,
    required this.cobradoHoy,
    required this.enMora,
    required this.montoEnMora,
    required this.porAprobar,
  });
}

class AdminNotifier extends AsyncNotifier<AdminDashboardData> {
  @override
  Future<AdminDashboardData> build() async {
    return _fetchData();
  }

  Future<AdminDashboardData> _fetchData() async {
    try {
      // 1. Fetch Prestamos
      final prestamosRes = await SupabaseConfig.client
          .from('prestamos')
          .select('*')
          .eq('activo', true);
      
      final prestamos = (prestamosRes as List)
          .map((e) => PrestamoModel.fromJson(e))
          .toList();

      // 2. Fetch Clientes
      final clientesRes = await SupabaseConfig.client
          .from('clientes')
          .select('*')
          .eq('activo', true);
      
      final clientes = (clientesRes as List)
          .map((e) => ClienteModel.fromJson(e))
          .toList();

      // 3. Fetch Cobros
      final cobrosRes = await SupabaseConfig.client
          .from('cobros')
          .select('*');
      
      final cobros = (cobrosRes as List)
          .map((e) => CobroModel.fromJson(e))
          .toList();

      // 4. Fetch Cobradores (usuarios rol = cobrador)
      final usuariosRes = await SupabaseConfig.client
          .from('usuarios')
          .select('id, nombre, usuario, iniciales')
          .eq('rol', 'cobrador')
          .eq('activo', true);
          
      final cobradores = List<Map<String, dynamic>>.from(usuariosRes);

      // --- CALCULATIONS ---
      
      // Cartera Total (Sum of cuotaSemanal * cuotasTotales for active loans)
      final carteraTotal = prestamos
          .where((p) => ['activo', 'vencido', 'liquidado'].contains(p.estado))
          .fold(0.0, (sum, p) => sum + (p.cuotaSemanal * p.cuotasTotales));

      // Cobrado Hoy
      final hoy = DateTime.now().toIso8601String().substring(0, 10);
      final cobradoHoy = cobros
          .where((c) {
            if (c.fechaCobro == null) return false;
            return c.fechaCobro!.startsWith(hoy);
          })
          .fold(0.0, (sum, c) => sum + c.monto);

      // En mora (vencidos)
      final prestamosMora = prestamos.where((p) => p.estado == 'vencido');
      final enMora = prestamosMora.length;
      final montoEnMora = prestamosMora.fold(0.0, (sum, p) => sum + (p.cuotaSemanal * p.cuotasTotales));

      // Por Aprobar (solicitado)
      final porAprobar = prestamos.where((p) => p.estado == 'solicitado').length;

      return AdminDashboardData(
        prestamos: prestamos,
        clientes: clientes,
        cobros: cobros,
        cobradores: cobradores,
        carteraTotal: carteraTotal,
        cobradoHoy: cobradoHoy,
        enMora: enMora,
        montoEnMora: montoEnMora,
        porAprobar: porAprobar,
      );
    } catch (e) {
      throw Exception('Error loading admin dashboard: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}

final adminProvider = AsyncNotifierProvider<AdminNotifier, AdminDashboardData>(() {
  return AdminNotifier();
});
