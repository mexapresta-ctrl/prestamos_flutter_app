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

final _asesorPrestamosProv = StreamProvider((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null || user.rol != 'asesor') return const Stream<List<Map<String, dynamic>>>.empty();
  return SupabaseConfig.client.from('prestamos').stream(primaryKey: ['id']).map((l) => l.where((e) => e['asesor_id'] == user.id && e['activo'] == true).toList());
});

final _asesorClientesProv = StreamProvider((ref) {
  return SupabaseConfig.client.from('clientes').stream(primaryKey: ['id']).map((l) => l.where((e) => e['activo'] == true).toList());
});

final asesorProvider = AsyncNotifierProvider<AsesorNotifier, AsesorDashboardData>(() {
  return AsesorNotifier();
});

class AsesorNotifier extends AsyncNotifier<AsesorDashboardData> {
  @override
  Future<AsesorDashboardData> build() async {
    return _buildFromStreams();
  }

  Future<AsesorDashboardData> _buildFromStreams() async {
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
      // 1. Fetch Streams
      final prestamosData = await ref.watch(_asesorPrestamosProv.future);
      final clientesData = await ref.watch(_asesorClientesProv.future);

      final prestamos = prestamosData.map((e) => PrestamoModel.fromJson(e)).toList();
      final clientes = clientesData.map((e) => ClienteModel.fromJson(e)).toList();

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
    ref.invalidate(_asesorPrestamosProv);
    ref.invalidate(_asesorClientesProv);
  }
}
