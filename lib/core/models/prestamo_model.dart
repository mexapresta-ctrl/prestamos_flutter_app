class PrestamoModel {
  final String id;
  final String? codigo;
  final String clienteId;
  final String cobradorId;
  final num monto;
  final num cuotaSemanal;
  final int cuotasTotales;
  final int cuotasPagadas;
  final String estado;
  final bool activo;
  final DateTime createdAt;

  PrestamoModel({
    required this.id,
    this.codigo,
    required this.clienteId,
    required this.cobradorId,
    required this.monto,
    required this.cuotaSemanal,
    required this.cuotasTotales,
    required this.cuotasPagadas,
    required this.estado,
    required this.activo,
    required this.createdAt,
  });

  factory PrestamoModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      return false;
    }

    int safeInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return PrestamoModel(
      id: json['id'] as String,
      codigo: json['codigo'] as String?,
      clienteId: json['clienteId'] as String? ?? json['cliente_id'] as String,
      cobradorId: json['cobradorId'] as String? ?? json['cobrador_id'] as String,
      monto: (json['monto'] as num?) ?? 0.0,
      cuotaSemanal: (json['cuota_semanal'] as num?) ?? (json['cuotaSemanal'] as num?) ?? 0.0,
      cuotasTotales: safeInt(json['cuotas_totales'] ?? json['cuotasTotales']),
      cuotasPagadas: safeInt(json['cuotas_pagadas'] ?? json['cuotasPagadas']),
      estado: (json['estado'] as String?) ?? 'activo',
      activo: parseBool(json['activo']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }
}
