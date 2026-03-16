import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prestamo_model.dart';
import '../models/cliente_model.dart';
import '../config/supabase_config.dart';
import 'auth_provider.dart';

class AsesorDashboardData {
  final List<PrestamoModel> misPrestamosTramitados;
  final List<ClienteModel> clientes; 
  
  // Calculados
  final double montoColocado;
  final int clientesActivos;
  final int prestamosAprobados;
  final int prestamosPendientes;

  AsesorDashboardData({
    required this.misPrestamosTramitados,
    required this.clientes,
    required this.montoColocado,
    required this.clientesActivos,
    required this.prestamosAprobados,
    required this.prestamosPendientes,
  });
}

final asesorProvider = AsyncNotifierProvider<AsesorNotifier, AsesorDashboardData>(() {
  return AsesorNotifier();
});

class AsesorNotifier extends AsyncNotifier<AsesorDashboardData> {
  @override
  Future<AsesorDashboardData> build() async {
    return _fetchData();
  }

  Future<AsesorDashboardData> _fetchData() async {
    final userState = ref.watch(authProvider);
    final user = userState.user;

    if (user == null || user.rol != 'asesor') {
      return AsesorDashboardData(
        misPrestamosTramitados: [],
        clientes: [],
        montoColocado: 0,
        clientesActivos: 0,
        prestamosAprobados: 0,
        prestamosPendientes: 0,
      );
    }

    try {
      // 1. Fetch prestamos that belong to this asesor
      final prestamosRes = await SupabaseConfig.client
          .from('prestamos')
          .select('*')
          .eq('activo', true)
          .eq('asesor_id', user.id);
          
      final prestamos = (prestamosRes as List)
          .map((e) => PrestamoModel.fromJson(e))
          .toList();

      // 2. Fetch all active clientes to display their names
      final clientesRes = await SupabaseConfig.client
          .from('clientes')
          .select('*')
          .eq('activo', true);
          
      final clientes = (clientesRes as List)
          .map((e) => ClienteModel.fromJson(e))
          .toList();

      // 3. Calc KPIs
      double montoColocado = 0;
      Set<String> clientesUnicosActivos = {};
      int aprobados = 0;
      int pendientes = 0;

      for (var p in prestamos) {
        if (p.estado == 'activo' || p.estado == 'aprobado') {
          montoColocado += p.monto;
          clientesUnicosActivos.add(p.clienteId);
          aprobados++;
        } else if (p.estado == 'pendiente') {
          pendientes++;
        }
      }

      // Sort recent first
      prestamos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return AsesorDashboardData(
        misPrestamosTramitados: prestamos,
        clientes: clientes,
        montoColocado: montoColocado,
        clientesActivos: clientesUnicosActivos.length,
        prestamosAprobados: aprobados,
        prestamosPendientes: pendientes,
      );
    } catch (e) {
      throw Exception('Error al cargar datos del asesor: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final res = await _fetchData();
      state = AsyncValue.data(res);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
