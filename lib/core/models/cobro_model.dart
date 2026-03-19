class CobroModel {
  final String id;
  final String prestamoId;
  final String clienteId;
  final String cobradorId;
  final num monto;
  final String? fechaCobro;

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
      id: (json['id'] ?? '').toString(),
      prestamoId: (json['prestamoId'] ?? json['prestamo_id'] ?? '').toString(),
      clienteId: (json['clienteId'] ?? json['cliente_id'] ?? '').toString(),
      cobradorId: (json['cobradorId'] ?? json['cobrador_id'] ?? '').toString(),
      monto: (json['monto'] is num) ? json['monto'] : num.tryParse(json['monto']?.toString() ?? '0') ?? 0,
      fechaCobro: (json['fecha_cobro'] ?? json['fechaCobro'] ?? json['fecha'])?.toString(),
    );
  }
}
