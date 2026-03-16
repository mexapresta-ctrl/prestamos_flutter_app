class PrestamoModel {
  final String id;
  final String? codigo;
  final String clienteId;
  final String cobradorId;
  final num cuotaSemanal;
  final int cuotasTotales;
  final int cuotasPagadas;
  final String estado;
  final bool activo;

  PrestamoModel({
    required this.id,
    this.codigo,
    required this.clienteId,
    required this.cobradorId,
    required this.cuotaSemanal,
    required this.cuotasTotales,
    required this.cuotasPagadas,
    required this.estado,
    required this.activo,
  });

  factory PrestamoModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      return false;
    }

    return PrestamoModel(
      id: json['id'] as String,
      codigo: json['codigo'] as String?,
      clienteId: json['clienteId'] as String? ?? json['cliente_id'] as String,
      cobradorId: json['cobradorId'] as String? ?? json['cobrador_id'] as String,
      cuotaSemanal: (json['cuotaSemanal'] as num?) ?? 0.0,
      cuotasTotales: (json['cuotasTotales'] as int?) ?? 0,
      cuotasPagadas: (json['cuotasPagadas'] as int?) ?? 0,
      estado: (json['estado'] as String?) ?? 'activo',
      activo: parseBool(json['activo']),
    );
  }
}
