import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prestamo_model.dart';
import '../models/cliente_model.dart';
import '../models/cobro_model.dart';
import '../config/supabase_config.dart';
import '../utils/time_util.dart';

class AdminDashboardData {
  final List<PrestamoModel> prestamos;
  final List<ClienteModel> clientes;
  final List<CobroModel> cobros;
  final List<Map<String, dynamic>> cobradores;
  final List<Map<String, dynamic>> asesores;
  final List<Map<String, dynamic>> prestamistas;

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
    required this.asesores,
    required this.prestamistas,
    required this.carteraTotal,
    required this.cobradoHoy,
    required this.enMora,
    required this.montoEnMora,
    required this.porAprobar,
  });
}

final _prestamosStreamProv = StreamProvider((ref) => SupabaseConfig.client.from('prestamos').stream(primaryKey: ['id']).map((list) => list.where((e) => e['activo'] == true).toList()));
final _clientesStreamProv = StreamProvider((ref) => SupabaseConfig.client.from('clientes').stream(primaryKey: ['id']).map((list) => list.where((e) => e['activo'] == true).toList()));
final _cobrosStreamProv = StreamProvider((ref) => SupabaseConfig.client.from('cobros').stream(primaryKey: ['id']));
final _cobradoresStreamProv = StreamProvider((ref) => SupabaseConfig.client.from('usuarios').stream(primaryKey: ['id']).map((l) => l.where((e) => e['rol'] == 'cobrador' && e['activo'] == true).toList()));
final _asesoresStreamProv = StreamProvider((ref) => SupabaseConfig.client.from('usuarios').stream(primaryKey: ['id']).map((l) => l.where((e) => e['rol'] == 'asesor' && e['activo'] == true).toList()));
final _prestamistasStreamProv = StreamProvider((ref) => SupabaseConfig.client.from('usuarios').stream(primaryKey: ['id']).map((l) => l.where((e) => e['rol'] == 'prestamista' && e['activo'] == true).toList()));

class AdminNotifier extends AsyncNotifier<AdminDashboardData> {
  @override
  Future<AdminDashboardData> build() async {
    return _buildFromStreams();
  }

  Future<AdminDashboardData> _buildFromStreams() async {
    try {
      // 1. Fetch Streams
      final prestamosRes = await ref.watch(_prestamosStreamProv.future);
      final clientesRes = await ref.watch(_clientesStreamProv.future);
      final cobrosRes = await ref.watch(_cobrosStreamProv.future);
      final cobradoresRes = await ref.watch(_cobradoresStreamProv.future);
      final asesoresRes = await ref.watch(_asesoresStreamProv.future);
      final prestamistasRes = await ref.watch(_prestamistasStreamProv.future);

      final prestamos = prestamosRes.map((e) => PrestamoModel.fromJson(e)).toList();
      final clientes = clientesRes.map((e) => ClienteModel.fromJson(e)).toList();
      final cobros = cobrosRes.map((e) => CobroModel.fromJson(e)).toList();

      final cobradores = List<Map<String, dynamic>>.from(cobradoresRes);
      final asesores = List<Map<String, dynamic>>.from(asesoresRes);
      final prestamistas = List<Map<String, dynamic>>.from(prestamistasRes);

      // --- CALCULATIONS ---
      
      final carteraTotal = prestamos
          .where((p) => ['activo', 'vencido', 'liquidado'].contains(p.estado))
          .fold(0.0, (sum, p) => sum + (p.cuotaSemanal * p.cuotasTotales));

      final hoy = TimeUtil.todayIsoDate();
      final cobradoHoy = cobros
          .where((c) {
            if (c.fechaCobro == null) return false;
            return c.fechaCobro!.startsWith(hoy);
          })
          .fold(0.0, (sum, c) => sum + c.monto);

      final prestamosMora = prestamos.where((p) => p.estado == 'vencido');
      final enMora = prestamosMora.length;
      final montoEnMora = prestamosMora.fold(0.0, (sum, p) => sum + (p.cuotaSemanal * p.cuotasTotales));

      final porAprobar = prestamos.where((p) => p.estado == 'solicitado').length;

      return AdminDashboardData(
        prestamos: prestamos,
        clientes: clientes,
        cobros: cobros,
        cobradores: cobradores,
        asesores: asesores,
        prestamistas: prestamistas,
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
    // Para forzar recarga (pull-to-refresh) invalidamos los providers base
    ref.invalidate(_prestamosStreamProv);
    ref.invalidate(_clientesStreamProv);
    ref.invalidate(_cobrosStreamProv);
    ref.invalidate(_cobradoresStreamProv);
    ref.invalidate(_asesoresStreamProv);
    ref.invalidate(_prestamistasStreamProv);
  }

  Future<void> registrarUsuario(String nombre, String usuario, String password, String rol) async {
    try {
      await SupabaseConfig.client.from('usuarios').insert({
        'nombre': nombre,
        'usuario': usuario,
        'password': password,
        'rol': rol,
        'activo': true,
      });
      await refresh();
    } catch (e) {
      throw Exception('Este usuario ya existe o hubo un error al registrar: $e');
    }
  }
}

final adminProvider = AsyncNotifierProvider<AdminNotifier, AdminDashboardData>(() {
  return AdminNotifier();
});
