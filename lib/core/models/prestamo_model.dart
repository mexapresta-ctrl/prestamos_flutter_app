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
    int safeInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    num safeNum(dynamic value) {
      if (value is num) return value;
      if (value is String) return num.tryParse(value) ?? 0;
      return 0;
    }

    bool safeBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    return PrestamoModel(
      id: (json['id'] ?? '').toString(),
      codigo: json['codigo']?.toString(),
      clienteId: (json['clienteId'] ?? json['cliente_id'] ?? '').toString(),
      cobradorId: (json['cobradorId'] ?? json['cobrador_id'] ?? '').toString(),
      monto: safeNum(json['monto']),
      cuotaSemanal: safeNum(json['cuota_semanal'] ?? json['cuotaSemanal']),
      cuotasTotales: safeInt(json['cuotas_totales'] ?? json['cuotasTotales']),
      cuotasPagadas: safeInt(json['cuotas_pagadas'] ?? json['cuotasPagadas']),
      estado: (json['estado'] ?? 'activo').toString(),
      activo: safeBool(json['activo']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
