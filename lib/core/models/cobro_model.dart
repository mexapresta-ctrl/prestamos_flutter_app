class CobroModel {
  final int id;
  final int prestamoId;
  final int clienteId;
  final int cobradorId;
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
      id: json['id'] as int,
      prestamoId: json['prestamoId'] as int,
      clienteId: json['clienteId'] as int,
      cobradorId: json['cobradorId'] as int,
      monto: (json['monto'] as num?) ?? 0.0,
      // The original db used 'fecha' but the app normalizes to 'fechaCobro' sometimes
      fechaCobro: json['fechaCobro'] as String? ?? json['fecha'] as String?,
    );
  }
}
