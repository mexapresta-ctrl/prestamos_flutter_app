class CobroModel {
  final String id;
  final String prestamoId;
  final String clienteId;
  final String cobradorId;
  final num monto;
  final String? fechaCobro; // Usually ISO 8601 string

  CobroModel({
    required this.id,
    required this.prestamoId,
    required this.clienteId,
    required this.cobradorId,
    required this.monto,
    this.fechaCobro,
  });

  factory CobroModel.fromJson(Map<String, dynamic> json) {
    return CobroModel(
      id: json['id'] as String,
      prestamoId: json['prestamoId'] as String? ?? json['prestamo_id'] as String,
      clienteId: json['clienteId'] as String? ?? json['cliente_id'] as String,
      cobradorId: json['cobradorId'] as String? ?? json['cobrador_id'] as String,
      monto: (json['monto'] as num?) ?? 0.0,
      // The original db used 'fecha' but the app normalizes to 'fechaCobro' sometimes
      fechaCobro: json['fechaCobro'] as String? ?? json['fecha'] as String?,
    );
  }
}
